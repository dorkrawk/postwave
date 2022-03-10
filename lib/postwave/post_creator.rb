require "fileutils"
require "singleton"
require_relative "blog_utilities"
require_relative "display_helper"


module Postwave
   class PostCreator
    include Singleton
    include BlogUtilities
    include DisplayHelper

    def create
      output_creating_post

      if !is_set_up?
        output_missing_setup
        return
      end

      now = Time.now
      post_file_name = "#{now.to_i}.md"

      initial_content = <<~CONTENT
      ---
      title: #{(0...8).map { (65 + rand(26)).chr }.join}
      date: #{now.strftime("%F %R")}
      tags:
      ---
      
      Start writing!
      CONTENT


      File.write(File.join(Dir.pwd, POSTS_DIR, post_file_name), initial_content)

      output_post_created(File.join(POSTS_DIR, post_file_name))
    end
  end
end
