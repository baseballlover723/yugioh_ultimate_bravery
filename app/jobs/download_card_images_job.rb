class DownloadCardImagesJob < ApplicationJob
  queue_as :default

  IMAGES_DIR = "./public/"
  IMAGES_FULL_PATH = "images/cards/full"
  IMAGES_SMALL_PATH = "images/cards/small"
  IMAGES_FULL_DIR = File.join(IMAGES_DIR, IMAGES_FULL_PATH)
  IMAGES_SMALL_DIR = File.join(IMAGES_DIR, IMAGES_SMALL_PATH)
  MAX_ATTEMPTS = 5

  def perform(fresh: false, threads: 8, rate_limit: 18, save_batch_size: 500, use_local: Rails.configuration.use_local)
    if use_local
      threads = 18
    end
    if fresh
      FileUtils.rm_rf([IMAGES_FULL_DIR, IMAGES_SMALL_DIR])
    end
    FileUtils.mkdir_p([IMAGES_FULL_DIR, IMAGES_SMALL_DIR])
    FileUtils.touch([File.join(IMAGES_FULL_DIR, ".keep"), File.join(IMAGES_SMALL_DIR, ".keep")])

    cards = DownloadCardsJob.fetch_cards_info["data"].reject do |card|
      card["frameType"] == "token"
    end

    existing_card_arts = CardArt.all.index_by(&:id)

    print "creating image download jobs "
    jobs_start = Time.now
    jobs = cards.flat_map do |card|
      name = card["name"]
      name.gsub!("\"", "'")
      name.gsub!("/", "-")
      name.gsub!("?", "？")
      name.gsub!("#", "＃")

      card["card_images"].flat_map.with_index(1) do |hash, i|
        full_path = File.join(IMAGES_FULL_PATH, name, i.to_s) + ".jpg"
        small_path = File.join(IMAGES_SMALL_PATH, name, i.to_s) + ".jpg"
        if use_local
          # get from localhost instead of fetching from the internet
          hash["image_url"] = hash["image_url"].sub("https://images.ygoprodeck.com", "http://localhost:#{Rails.application.credentials.local_image_server.port}")
          hash["image_url_small"] = hash["image_url_small"].sub("https://images.ygoprodeck.com", "http://localhost:#{Rails.application.credentials.local_image_server.port}")
        end

        arr = []
        existing_card_art = existing_card_arts[hash["id"]]
        arr << [card["id"], hash["image_url"], full_path, hash["id"], :full_path] if !existing_card_art || existing_card_art.full_path != full_path
        arr << [card["id"], hash["image_url_small"], small_path, hash["id"], :small_path] if !existing_card_art || existing_card_art.small_path != small_path
        arr
      end
    end
    download_start = Time.now
    puts "Took #{download_start - jobs_start} seconds"
    numb_arts = jobs.size

    puts "Downloading Card arts (#{jobs.size.to_fs(:delimited)})"
    old_logger_level = ActiveRecord::Base.logger.level
    ActiveRecord::Base.logger.level = 1

    accumulator = Ractor.new(save_batch_size) do |batch_size|
      card_art_params = Hash.new { |hsh, k| hsh[k] = {id: k, card_id: nil, small_path: nil, full_path: nil} }
      ready_to_save = []

      loop do
        opt, card_id, id, key, value = Ractor.receive
        case opt
        when :add
          params = card_art_params[id]
          params[:card_id] = card_id
          params[key] = value
          if params.values.all?
            card_art_params.delete(id)
            ready_to_save << params
            if ready_to_save.size >= batch_size
              temp = ready_to_save
              ready_to_save = []
              Ractor.yield([:save, temp], move: true)
            end
          end
        when :stop
          temp = ready_to_save
          ready_to_save = []
          Ractor.yield([:save, temp], move: true) unless temp.empty?
          break
        end
      end
      [:stop].freeze
    end

    # ActiveRecord doesn't play nice with Ractors
    save_thread = Thread.new(accumulator) do |ractor|
      loop do
        opt, params = ractor.take
        case opt
        when :save
          CardArt.upsert_all(params)
        when :stop
          break
        end
      end
    end

    queue = Limiter::RateQueue.new(rate_limit, interval: 1)
    Parallel.each(jobs, progress: "DL #{jobs.size.to_fs(:delimited)} / #{numb_arts.to_fs(:delimited)} arts", in_threads: threads) do |card_id, url, path, id, type|
      full_path = File.join(IMAGES_DIR, path)
      existing_card_art = existing_card_arts[id]
      FileUtils.rm_rf(File.dirname(File.join(IMAGES_DIR, existing_card_art.send(type)))) if existing_card_art
      FileUtils.mkdir_p(File.dirname(full_path))

      download_image(queue, url, use_local) do |tempfile|
        if use_local
          cache_path = url.sub("http://localhost:#{Rails.application.credentials.local_image_server.port}", "#{Rails.application.credentials.local_image_server.path}")
          FileUtils.copy_file(tempfile.path, cache_path) if !File.exist?(cache_path)
        end
        FileUtils.copy_file(tempfile.path, full_path) if !use_local || !File.exist?(full_path)
        accumulator.send([:add, card_id, id, type, path].freeze)
      end
    end
    accumulator.send([:stop].freeze)
    save_thread.join
    ActiveRecord::Base.logger.level = old_logger_level
  end

  def download_image(queue, url, is_local, attempt = 1, &block)
    queue.shift unless is_local

    success = false
    tempfile = Tempfile.create(["card_art", ".jpg"], binmode: true)
    response = nil
    begin
      response = HTTParty.get(url, stream_body: true) do |fragment|
        tempfile.write(fragment)
      end
      if response.ok?
        tempfile.close
        yield tempfile
        success = true
      end
    rescue OpenSSL::SSL::SSLError => e
      raise e if attempt >= MAX_ATTEMPTS
      sleep 1 * attempt
      return download_image(queue, url, is_local, attempt + 1, &block)
    ensure
      tempfile.close if !tempfile.closed?
      File.unlink(tempfile)
    end
    if !success
      if is_local && response&.code == 404
        url = url.sub("http://localhost:#{Rails.application.credentials.local_image_server.port}", "https://images.ygoprodeck.com")
        return download_image(queue, url, false, 1, &block)
      end
      if attempt >= MAX_ATTEMPTS
        puts response.parsed_response
        raise "Error (#{response.code}) downloading image (#{url}). Attempted #{MAX_ATTEMPTS} times."
      end
      sleep 1 * attempt
      return download_image(queue, url, is_local, attempt + 1, &block)
    end
  end
end
