module Postwave
  module DisplayHelper

    # new

    def output_creating_blog
      puts "🌊 Creating new blog..."
    end

    def output_blog_created
      puts "New blog set up.".green
    end

    # post

    def output_creating_post
      puts "🌊 Creating new post..."
    end

    def output_post_created(post_path)
      puts "New post created at: #{post_path}".green
    end

    # build

    def output_building
      puts "🌊 Building..."
    end

    def output_post_processed(posts)
      puts "Processed #{posts.count} posts."
    end

    def output_tags_created(tags)
      puts "Create tag files for #{tags.count} tags."
    end

    def output_build_completed(build_time)
      puts "Built succesfully in #{build_time} seconds.".green
    end

    # errors

    def output_exising_setup
      puts "A blog already exists in this location.".red
    end

    def output_missing_setup
      puts "You need to set up a blog first.".red
    end

    def output_general_error
      puts "Something went wrong.".red
    end

  end
end

# 🐒 patch String to add terminal colors
class String
  def red;            "\e[31m#{self}\e[0m" end
  def green;          "\e[32m#{self}\e[0m" end
end
