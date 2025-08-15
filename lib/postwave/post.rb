require_relative "blog_utilities"
require "redcarpet"
require "cgi"

module Postwave
  class Post
    include BlogUtilities

    KNOWN_FIELDS = %w(title date tags title_slug body draft)
    REQUIRED_FIELDS = %w(title date)
    METADATA_DELIMITER = "---"
    FILE_NAME_DATE_LEN = 11 # YYYY-MM-DD-

    attr_accessor :file_name

    @@markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, fenced_code_blocks: true)

    def self.new_from_file_path(path)
      metadata_delimter_count = 0
      body_buffer_count = 0
      field_content = { "body" => "" }

      File.readlines(path).each do |line|
        clean_line = line.strip
        if clean_line == METADATA_DELIMITER
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

          field_content["body"] += "#{line}"
        end
      end

      # turn "date" into a Time object
      field_content["date"] = Time.parse(field_content["date"])

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
        instance_variable_set("@#{field}", value) unless self.instance_variables.include?("@#{field}".to_sym)
        self.class.send(:attr_reader, field) unless self.public_methods.include?(field.to_sym)
      end

      @slug = file_name_slug&.empty? ? title_slug : file_name_slug
    end

    def title_slug
      @title_slug ||= @title.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')
    end

    def file_name_slug
      # YYYY-MM-DD-slug.md
      File.basename(@file_name, ".md")[FILE_NAME_DATE_LEN..]
    end
    
    def slug
      @slug ||= @title_slug
    end

    def slug=(new_slug)
      @slug = new_slug
    end

    def body_html
      @body_html ||= @@markdown.render(@body)
    end

    def body_preview(limit = 100, ellipsis = "...")
      text = body_html.to_s

      # Turn common block boundaries into newlines first
      text = text.gsub(/<(br|\/p|\/div|\/h\d|\/li)[^>]*>/i, "\n")
      # Strip remaining tags
      text = text.gsub(/<[^>]*>/, "")
      # Decode entities
      text = CGI.unescapeHTML(text)
      # Collapse spaces but keep single newlines
      text = text.gsub(/[ \t]+/, " ").gsub(/\n+/, "\n").strip

      # Unicode-safe character counting (grapheme clusters)
      graphemes = text.scan(/\X/)
      return text if graphemes.length <= limit

      candidate = graphemes.first(limit).join

      # If we cut mid-word, trim back to the previous word boundary.
      # Word characters = letters, numbers, marks, connector punctuation (e.g., underscore)
      # This removes a trailing partial word if present.
      cut = candidate.sub(/[\p{L}\p{N}\p{M}\p{Pc}]+\z/u, "").rstrip

      # If the very first "word" exceeds the limit, we err under limit and just show an ellipsis.
      cut.empty? ? ellipsis : "#{cut}#{ellipsis}"
    end

    def generated_file_name
      # YYYY-MM-DD-slug-from-title.md
      "#{@date.to_s[..9]}-#{slug}.md"
    end

    def update_file_name!
      desired_file_name = generated_file_name
      return false if @file_name == desired_file_name

      File.rename(@file_name, File.join(Dir.pwd, POSTS_DIR, desired_file_name))
      @file_name = desired_file_name
    end
  end
end
