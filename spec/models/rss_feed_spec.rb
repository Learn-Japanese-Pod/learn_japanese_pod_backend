require 'rails_helper'

describe RssFeed do
  subject(:rss_feed) { described_class.new } 
  describe '#items' do
    it "returns 5 episodes" do
      VCR.use_cassette("rss_feed_items") do
        expected_items = [
          RssFeed::Item.new(date: Time.parse("2015-11-24 00:10:22 +0000"), title: "Podcast 04: How to talk about your home town in Japanese", category: "Lesson"),
          RssFeed::Item.new(date: Time.parse("2016-03-01 00:10:22 +0000"), title: "Podcast 05: Top 10 tips for studying Japanese", category: "Lesson"),
          RssFeed::Item.new(date: Time.parse("2016-09-01 00:10:02 +0000"), title: "Podcast 06: Useful Classroom Japanese Phrases", category: "Lesson"),
          RssFeed::Item.new(date: Time.parse("2016-11-05 00:10:48 +0000"), title: "Podcast 07: How to ask for help in Japanese", category: "Lesson"),
          RssFeed::Item.new(date: Time.parse("2016-12-09 00:00:18 +0000"), title: "Fun Friday 01: Sayonara 2016", category: "Fun Friday"),
        ]
        items = subject.items
        
        expect(items).to match(expected_items)
      end
    end
  end
end