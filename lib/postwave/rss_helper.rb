require_relative "blog_utilities"
require "rss"

module Postwave
  module RssHelper
    include BlogUtilities

    def build_rss(posts)
      File.open(File.join(Dir.pwd, POSTS_DIR, META_DIR, RSS_FILE_NAME), "w") do |rss|
        rss << rss_content(posts)
      end
    end
    
    def rss_content(posts)
      RSS::Maker.make("2.0") do |maker|
        maker.channel.title = config_values[:name]
        maker.channel.description = config_values[:description]
        maker.channel.link = config_values[:url]
        maker.channel.generator = "Postwave"
        maker.channel.updated = Time.now.to_s

        posts.each do |post|
          link = "#{config_values[:url]}/#{config_values[:posts_path]}/#{post.slug}"

          maker.items.new_item do |item|
            item.title = post.title
            item.link = link
            item.description = post.body
            item.pubDate = post.date
          end
        end
      end
    end
  end
end
