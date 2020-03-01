class PushNotification::NewEpisodeNotifier
  NOTIFICATION_CUTOFF_DATE = Time.parse("2020-03-08 00:00:00 +0000")
  LESSON_MESSAGE = "New lesson out now."
  FUN_FRIDAY_MESSAGE = "New fun friday out now."
  NOTIFICATION_MESSAGES = {
    lesson: LESSON_MESSAGE,
    fun_friday: FUN_FRIDAY_MESSAGE,
  }

  attr_reader :rss_feed, :update_tracker, :push_notification_sender

  def initialize(rss_feed: RssFeed.new, 
                 update_tracker: RssFeed::UpdateTracker, 
                 push_notification_sender: PushNotification::Sender.new)
    @rss_feed = rss_feed
    @update_tracker = update_tracker.find_by!(feed_name: "learn_japanese_pod_2020")
    @push_notification_sender = push_notification_sender
  end

  def notify!
    return if push_tokens.empty?
    return if latest_feed_item.date < NOTIFICATION_CUTOFF_DATE
    return if !last_episode_at.nil? && latest_feed_item.date <= last_episode_at

    notification_batch = build_notification_batch(push_tokens)

    push_notification_sender.send_batch(batch: notification_batch)

    update_tracker.update!(last_episode_at: latest_feed_item.date)
  end

  private

  def push_tokens
    @push_tokens ||= User.all.pluck(:push_token)
  end

  def last_episode_at
    @last_episode_at ||= update_tracker.last_episode_at
  end

  def latest_feed_item
    @latest_feed_item ||= rss_feed.items.last
  end

  def build_notification_batch(push_tokens)
    message = NOTIFICATION_MESSAGES[latest_feed_item.category]

    push_tokens.map do |token| 
      { to: token, body: message}
    end
  end
end