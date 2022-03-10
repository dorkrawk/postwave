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

      File.write(File.join(Dir.pwd, POSTS_DIR, META_DIR, SUMMARY_FILE_NAME), summary.to_yaml)
    end
  end
end
