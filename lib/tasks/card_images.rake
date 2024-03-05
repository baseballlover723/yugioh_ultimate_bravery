namespace :cards do
  namespace :images do
    desc "Downloads card images"
    task download: [:environment] do
      puts "TODO download card images"
    end
  end

  desc "Download new card data and then invokes cards:images:download to get the images"
  task download: [:environment] do
    DownloadCardsJob.perform_now
  end

  Rake::Task[:download].enhance do
    Rake::Task["cards:images:download"].invoke
  end
end