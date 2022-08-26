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
      count = posts.count
      puts "Processed #{count} #{simple_pluralizer("post", count)}."
    end

    def output_drafts_skipped(drafts)
      if drafts.any?
        count = drafts.count
        puts "Skipped #{count} #{simple_pluralizer("draft", count)}."
      end
    end

    def output_tags_created(tags)
      count = tags.count
      puts "Built tag files for #{count} #{simple_pluralizer("tag", count)}."
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

    private
    def simple_pluralizer(word, count)
      if count == 1
        word
      else
        word + "s"
      end
    end
  end
end

# 🐒 patch String to add terminal colors
class String
  def red;            "\e[31m#{self}\e[0m" end
  def green;          "\e[32m#{self}\e[0m" end
end
