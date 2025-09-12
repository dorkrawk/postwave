require_relative "blog_utilities"
require "erb"
require 'redcarpet'

module Postwave
  module RssHelper
    include BlogUtilities

    FeedPost = Struct.new(:title, :link, :body, :date, :tags)

    def build_rss(posts)
      File.open(File.join(Dir.pwd, POSTS_DIR, META_DIR, RSS_FILE_NAME), "w") do |rss|
        rss << feed_content(posts)
      end
    end
    
    def feed_content(posts)
      link = config_values[:url].chomp("/")
      updated = Time.now.iso8601.to_s
      title = config_values[:name]
      description = config_values[:description]

      markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, fenced_code_blocks: true)
      feed_posts = posts.map do |post|
        post_link = "#{link}/#{config_values[:posts_path]}/#{post.slug}"
        html_body = CGI.unescapeHTML(markdown.render(post.body))
        post_title = CGI.escapeHTML(post.title)
        FeedPost.new(post_title, post_link, html_body, post.date.iso8601, post.tags)
      end

      path = File.join(__dir__, "templates/feed.erb")
      template = File.read(path)
      renderer = ERB.new(template)
      renderer.result(binding)
    end
  end
end
