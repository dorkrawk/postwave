require "fileutils"
require "yaml"
require "singleton"
require 'csv'
require 'time'
require_relative "blog_utilities"
require_relative "display_helper"
require_relative "post"

module Postwave
  class BlogBuilder
    include Singleton
    include BlogUtilities
    include DisplayHelper

    INDEX_HEADERS = ["slug", "date", "title"]

    def build
      start = Time.now
      
      output_building

      if !is_set_up?
        output_missing_setup
        return
      end

      # load, rename, and sort post file names
      posts = load_posts.sort_by { |p| p.date }.reverse
      tags = {}

      CSV.open(File.join(Dir.pwd, POSTS_DIR, META_DIR, INDEX_FILE_NAME), "w") do |csv|
        csv << INDEX_HEADERS
        posts.each do |post|
          post.update_file_name!

          csv << [post.slug, post.date, post.title]

          post.tags.each do |tag|
            if tags.has_key? tag
              tags[tag] << post.slug
            else
              tags[tag] = [post.slug]
            end
          end
        end
      end
      output_post_processed(posts)

      build_tags_files(tags)
      build_summary(posts, tags)

      build_time = Time.now - start
      output_build_completed(build_time)
    end

    def load_posts
      posts = []
      Dir.glob(File.join(Dir.pwd, POSTS_DIR, "*.md")) do |post_file_path|
        posts << Postwave::Post.new_from_file_path(post_file_path)
      end
      posts
    end

    def build_tags_files(tags)
      tags.each do |tag, post_slugs|
        tag_info = {
          count: post_slugs.count,
          post_slugs: post_slugs
        }
        File.write(File.join(Dir.pwd, POSTS_DIR, META_DIR, TAGS_DIR, "#{tag}.yaml"), tag_info.to_yaml)
      end
      output_tags_created(tags)
    end

    def build_summary(posts, tags)
      summary = {
        post_count: posts.count,
        most_recent_file_name: posts.first.file_name,
        most_recent_date: posts.first.date,
        tags: tags.keys
      }
      File.write(File.join(Dir.pwd, POSTS_DIR, META_DIR, SUMMARY_FILE_NAME), summary.to_yaml)
    end
  end
end
