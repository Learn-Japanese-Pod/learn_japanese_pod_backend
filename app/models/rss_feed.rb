require 'open-uri'
require 'rss'

class RssFeed
  class Item
    include ActiveModel::Model

    attr_accessor :date, :title, :category

    def category=(value)
      @category = value.parameterize.underscore.to_sym
    end

    def ==(other)
      return false unless self.class == other.class

      self.date == other.date && 
        self.title == other.title && 
        self.category == other.category
    end
  end
   
  RSS_URL="http://feeds.feedburner.com/learnjapanesepod"

  def items
    @items ||= build_items
  end

  private

  def feed
    @feed ||= begin
      conn = URI.open(RSS_URL)

      RSS::Parser.parse(conn)
    end
  end

  def build_items
    feed
      .items
      .map { |item| Item.new(date: item.date, title: item.title, category: item.category.content) }
      .select { |item| item.category == :lesson || item.category == :fun_friday }
      .sort_by(&:date)
  end
end