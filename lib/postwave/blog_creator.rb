require "fileutils"
require "yaml"
require "singleton"
require_relative "blog_utilities"
require_relative "display_helper"

module Postwave
  class BlogCreator
    include Singleton
    include BlogUtilities
    include DisplayHelper

    def create
      output_creating_blog

      if is_set_up?
        output_exising_setup
        return
      end

      build_directories
      build_files
      write_initial_summary_contents

      configure_blog

      output_blog_created 
    end

    def build_directories
      directory_paths.each do |path|
        FileUtils.mkdir_p(path)
      end
    end

    def build_files
      file_paths.each do |path|
        FileUtils.touch(path)
      end
    end

    def write_initial_summary_contents
      summary = {
        post_count: 0,
        tags: []
      }

      File.write(File.join(Dir.pwd, POSTS_DIR, META_DIR, SUMMARY_FILE_NAME), summary.transform_keys(&:to_s).to_yaml)
    end

    def configure_blog
      config = {}

      output_blog_name_prompt
      config[:name] = gets.chomp
      output_blog_url_prompt
      config[:url] = gets.chomp
      output_blog_description_prompt
      config[:description] = gets.chomp

      File.write(File.join(Dir.pwd, CONFIG_FILE_NAME), config.transform_keys(&:to_s).to_yaml)      
    end
  end
end
