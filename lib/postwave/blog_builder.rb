require "fileutils"
require "yaml"
require "singleton"
require 'csv'
require 'time'
require_relative "blog_utilities"
require_relative "display_helper"
require_relative "rss_helper"
require_relative "post"
require_relative "errors"

module Postwave
  class BlogBuilder
    include Singleton
    include BlogUtilities
    include DisplayHelper
    include RssHelper

    INDEX_HEADERS = ["slug", "date", "title"]

    def build
      start = Time.now
      
      output_building

      if !is_set_up?
        output_missing_setup
        return
      end

      # load, rename, and sort post file names
      posts = load_posts
      posts = ensure_unique_slugs(posts).sort_by { |p| p.date }.reverse
      draft_posts, published_posts = posts.partition { |p| p.draft? }
      tags = {}

      CSV.open(File.join(Dir.pwd, POSTS_DIR, META_DIR, INDEX_FILE_NAME), "w") do |csv|
        csv << INDEX_HEADERS
        published_posts.each do |post|
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
      output_post_processed(published_posts)
      output_drafts_skipped(draft_posts)

      build_tags_files(tags)
      build_summary(published_posts, tags)

      build_rss(published_posts)

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

    def ensure_unique_slugs(posts)
      slug_count = {}

      posts.sort_by { |p| p.date }.each do |post|
        post_slug = post.frozen_slug? ? post.frozen_slug : post.title_slug
        if slug_count.key?(post_slug)
          raise BlogBuilderError, "Duplicate frozen slug: #{post_slug}" if post.frozen_slug?
          slug_count[post_slug] += 1
          post.slug = "#{post_slug}-#{slug_count[post_slug]}"
        else
          slug_count[post_slug] = 0
        end
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
        most_recent_file_name: posts.first&.file_name,
        most_recent_date: posts.first&.date,
        tags: tags.keys
      }
      File.write(File.join(Dir.pwd, POSTS_DIR, META_DIR, SUMMARY_FILE_NAME), summary.to_yaml)
    end
  end
end
