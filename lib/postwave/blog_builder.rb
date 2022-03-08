require "fileutils"
require "yaml"
require "singleton"
require 'csv'
require_relative "blog_utilities"
require_relative "post"

module Postwave
  class BlogBuilder
    include Singleton
    include BlogUtilities

    INDEX_HEADERS = ["file_name", "date", "title"]

    def build
      # if !is_set_up?
      #   puts "you need to set up the blog first!"
      #   return
      # end

      # load and rename post file names
      posts = load_posts
      tags = {}

      CSV.open(File.join(Dir.pwd, POSTS_DIR, META_DIR, INDEX_FILE_NAME), "w") do |csv|
        csv << INDEX_HEADERS
        posts.each do |post|
          post.update_file_name!

          csv << [post.file_name, post.date, post.title]

          post.tags.each do |tag|
            if tags.has_key? tag
              tags[tag] << post.file_name
            else
              tags[tag] = [post.file_name]
            end
          end
        end
      end

      build_tags_files(tags)

      summary = {
        post_count: posts.count,
        tags: tags.keys
      }
      build_summary(summary)
    end

    def load_posts
      posts = []
      Dir.glob(File.join(Dir.pwd, POSTS_DIR, "*.md")) do |post_file_path|
        posts << Postwave::Post.new_from_file_path(post_file_path)
      end
      posts
    end

    def build_tags_files(tags)
      tags.each do |tag, post_files|
        File.open(File.join(Dir.pwd, POSTS_DIR, META_DIR, TAGS_DIR, "#{tag}.md"), "w") do |tag_file|
          post_files.each do |post_file|
            tag_file.puts post_file
          end
        end
      end
    end

    def build_summary(summary)
      File.write(File.join(Dir.pwd, POSTS_DIR, META_DIR, SUMMARY_FILE_NAME), summary.to_yaml)
    end
  end
end
