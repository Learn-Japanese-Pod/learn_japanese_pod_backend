desc "Broadcasts a notification to mobile users if a new episode is found on the RSS feed"
task notify_of_new_episode: :environment do
  PushNotification::NewEpisodeNotifier.new.notify!
end 