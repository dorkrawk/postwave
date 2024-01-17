class Postwave::Post
  KNOWN_FIELDS = %w(title date tags title_slug body draft)
  REQUIRED_FIELDS = %w(title date)
  MEATADATA_DELIMTER = "---"

  def self.new_from_file_path(path : String)
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

        field_content["body"] += "#{line}"
      end      
    end

    # turn "date" into a Time object
    field_content["date"] = Time.parse(field_content["date"])

    # turn "tags" into an array
    if field_content["tags"]
      field_content["tags"] = field_content["tags"].split(",").map do |tag|
        tag.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, "")
      end
    end

    # turn "draft" into boolean
    if field_content["draft"]
      field_content["draft"] = field_content["draft"].downcase == "true"
    end

    self.new(path, field_content)
  end

  def initialize(@file_name : String, field_content : Hash)

    field_content.each do |field, value|
      # instance_variable_set("@#{field}", value)
      self.send("@#{field}".to_sym, value)
      self.class.send(:attr_accessor, field)
    end
  end

  def title_slug : String
    @title_slug ||= @title.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, "")
  end

  def slug : String
    @slug ||= @title_slug
  end

  def slug=(new_slug)
    @slug = new_slug
  end

  def generated_file_name
    # YYYY-MM-DD-slug-from-title.md
    "#{@date.to_s[..9]}-#{slug}.md"
  end
end
