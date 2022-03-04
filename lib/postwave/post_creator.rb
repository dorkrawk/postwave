require "fileutils"
require "singleton"
require_relative "blog_utilities"


module Postwave
   class PostCreator
    include Singleton
    include BlogUtilities

    def create
      # if !is_set_up?
      #   puts "you need to set up the blog first!"
      #   return
      # end

      now = Time.now
      post_file_name = "#{now.to_i}.md"

      initial_content = <<~CONTENT
      ---
      title: 
      date: #{now}
      tags:
      ---
      
      Start writing!
      CONTENT


      File.write(File.join(Dir.pwd, POSTS_DIR, post_file_name), initial_content)
    end
  end
end
