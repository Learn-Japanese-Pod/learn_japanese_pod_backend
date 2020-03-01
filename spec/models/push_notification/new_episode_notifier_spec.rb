require 'rails_helper'

describe PushNotification::NewEpisodeNotifier do
  let(:last_episode_category) { "Lesson" }
  let(:items) do 
    [
      RssFeed::Item.new(date: Time.parse("2015-11-24 00:10:22 +0000"), title: "Podcast 04: How to talk about your home town in Japanese", category: "Lesson"),
      RssFeed::Item.new(date: Time.parse("2016-03-01 00:10:22 +0000"), title: "Podcast 05: Top 10 tips for studying Japanese", category: "Lesson"),
      RssFeed::Item.new(date: Time.parse("2016-09-01 00:10:02 +0000"), title: "Podcast 06: Useful Classroom Japanese Phrases", category: "Lesson"),
      RssFeed::Item.new(date: Time.parse("2016-11-05 00:10:48 +0000"), title: "Podcast 07: How to ask for help in Japanese", category: "Lesson"),
      RssFeed::Item.new(date: Time.parse("2016-12-09 00:00:18 +0000"), title: "Fun Friday 01: Sayonara 2016", category: "Fun Friday"),
      RssFeed::Item.new(date: Time.parse("2020-03-09 00:00:18 +0000"), title: "Podcast 08: How to math in Japanese", category: "Lesson"),
      RssFeed::Item.new(date: Time.parse("2020-04-09 00:00:18 +0000"), title: "Podcast 09: How to grammar in Japanese", category: last_episode_category),
    ]
  end
  let(:rss_feed) { instance_double(RssFeed, items: items) }
  let(:push_notification_sender) { instance_double(PushNotification::Sender, send_batch: []) }
  let(:tokens) do 
    [
      "ExponentPushToken[asdf123123]",
      "ExponentPushToken[110022993388]",
    ]
  end

  subject(:notifier) do
    described_class.new(rss_feed: rss_feed, push_notification_sender: push_notification_sender)
  end

  before do
    tokens.each { |token| User.create(push_token: token) }
    RssFeed::UpdateTracker.create!(feed_name: "learn_japanese_pod_2020")
  end

  describe "#notify!" do
    context "when there are no users registered" do
      before do
        User.destroy_all
      end

      it "does not try to send any notifications" do
        expect(push_notification_sender).to_not receive(:send_batch)

        subject.notify!
      end
    end

    context "when latest episode in the feed is earlier than cutoff date" do
      let(:items) do 
        [
          RssFeed::Item.new(date: Time.parse("2015-11-24 00:10:22 +0000"), title: "Podcast 04: How to talk about your home town in Japanese", category: "Lesson"),
          RssFeed::Item.new(date: Time.parse("2016-03-01 00:10:22 +0000"), title: "Podcast 05: Top 10 tips for studying Japanese", category: "Lesson"),
        ]
      end

      it "does not try to send any notifications" do
        expect(push_notification_sender).to_not receive(:send_batch)

        subject.notify!
      end
    end

    context "when no new episode is found in the feed" do
      let(:items) do 
        [
          RssFeed::Item.new(date: Time.parse("2015-11-24 00:10:22 +0000"), title: "Podcast 04: How to talk about your home town in Japanese", category: "Lesson"),
          RssFeed::Item.new(date: Time.parse("2016-03-01 00:10:22 +0000"), title: "Podcast 05: Top 10 tips for studying Japanese", category: "Lesson"),
          RssFeed::Item.new(date: Time.parse("2020-04-09 00:00:18 +0000"), title: "Podcast 08: How to math in Japanese", category: "Lesson"),
        ]
      end

      before do
        RssFeed::UpdateTracker
          .find_by!(feed_name: "learn_japanese_pod_2020")
          .update!(last_episode_at: Time.parse("2020-04-09 00:00:18 +0000"))
      end
      
      it "does not try to send any notifications" do
        expect(push_notification_sender).to_not receive(:send_batch)

        subject.notify!
      end
    end

    context "when the notifier runs for the first time" do
      it "does not try to send any notifications" do
        batch = tokens.map do |token| 
          { to: token, body: "New podcast out now." }
        end

        expect(push_notification_sender)
          .to receive(:send_batch)
          .with(batch: batch)

        subject.notify!
      end
    end

    context "when new episode is found in the feed" do
      before do
        RssFeed::UpdateTracker
          .find_by!(feed_name: "learn_japanese_pod_2020")
          .update!(last_episode_at: Time.parse("2020-03-09 00:00:18 +0000"))
      end

      context "and new episode has a fun_friday category" do
        let(:last_episode_category) { "Fun Friday" }

        it "sends a fun friday notification out" do
          batch = tokens.map do |token| 
            { to: token, body: "New fun friday out now." }
          end

          expect(push_notification_sender)
            .to receive(:send_batch)
            .with(batch: batch)

          subject.notify!
        end
      end

      context "and new episode has a lesson category" do
        it "sends a lesson notification out" do
          batch = tokens.map do |token| 
            { to: token, body: "New podcast out now." }
          end

          expect(push_notification_sender)
            .to receive(:send_batch)
            .with(batch: batch)

          subject.notify!
        end
      end
    end
  end
end