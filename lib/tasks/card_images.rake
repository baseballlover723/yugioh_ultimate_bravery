namespace :cards do
  namespace :images do
    desc "Downloads card images"
    task download: [:environment] do
      ActiveRecord::Base.logger = Logger.new STDOUT
      DownloadCardImagesJob.perform_now
    end
  end

  desc "Download new card data and then invokes cards:images:download to get the images"
  task download: [:environment] do
    ActiveRecord::Base.logger = Logger.new STDOUT
    DownloadCardsJob.perform_now
  end

  Rake::Task[:download].enhance do
    Rake::Task["cards:images:download"].invoke
  end
end