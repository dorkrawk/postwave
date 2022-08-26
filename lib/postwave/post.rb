require_relative "blog_utilities"

module Postwave
   class Post
    include BlogUtilities

    KNOWN_FIELDS = %w(title date tags title_slug body draft)
    REQUIRED_FIELDS = %w(title date)
    MEATADATA_DELIMTER = "---"

    attr_accessor :file_name

    def self.new_from_file_path(path)
      metadata_delimter_count = 0
      body_buffer_count = 0
      field_content = { "body" => "" }

      File.readlines(path).each do |line|
        clean_line = line.strip
        if clean_line == MEATADATA_DELIMTER
          metadata_delimter_count += 1
          next
        end

        if metadata_delimter_count == 0
          next
        elsif metadata_delimter_count == 1
          field, value = clean_line.split(":", 2).map(&:strip)
          field_content[field] = value
        else
          if body_buffer_count == 0
            body_buffer_count += 1
            next if clean_line.empty?
          end

          field_content["body"] += "#{line}\n"
        end
      end

      # turn "tags" into an array
      if field_content["tags"]
        field_content["tags"] = field_content["tags"].split(",").map do |tag|
          tag.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')
        end
      end

      # turn "draft" into boolean
      if field_content["draft"]
        field_content["draft"] = field_content["draft"].downcase == "true"
      end

      self.new(path, field_content)
    end
    
    def initialize(file_name, field_content = {})
      @file_name = file_name

      field_content.each do |field, value|
        instance_variable_set("@#{field}", value)
        self.class.send(:attr_accessor, field)
      end
    end

    def slug
      @file_name[...-3] # get rid of ".md"
    end

    def generated_file_name
      title_slug = @title_slug || @title.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')

      # YYYY-MM-DD-slug-from-title.md
      "#{@date[..9]}-#{title_slug}.md"
    end

    def update_file_name!
      desired_file_name = generated_file_name
      return false if @file_name == desired_file_name

      File.rename(@file_name, File.join(Dir.pwd, POSTS_DIR, desired_file_name))
      @file_name = desired_file_name
    end
  end
end
