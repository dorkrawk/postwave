require "fileutils"
require "yaml"
require "singleton"
require_relative "blog_utilities"

module Postwave
  class BlogCreator  # need to rename this. "Builder" should pertain to the "build" command 
    include Singleton
    include BlogUtilities

    def create
      if is_set_up?
        puts "postwave blog already exisits in this location"
        return
      end

      puts "creating new blog" # replace all puts here with helper module call

      build_directories
      build_files
      write_initial_summary_contents

      puts "new blog created" 
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
