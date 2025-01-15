require_relative "post"
require_relative "errors"
require_relative "blog_utilities"

require "csv"
require "time"
require "yaml"

Postwave::PostStub = Struct.new(:date, :title, :slug)

module Postwave
  class Client
    include BlogUtilities

    def initialize(config_path, preload: false)
      raise MissingConfigError unless is_valid_config?(config_path)
      
      @blog_root = File.dirname(config_path)
      raise InvalidBlogError unless is_set_up?(@blog_root)

      @all_posts = get_all_posts if preload
    end

    # returns: an array of PostStub Structs - [<struct PostStub date=Time, title="", stub="">]
    def index(offset: 0, limit: nil)
      working_index = @full_index || get_full_index
      count = limit || working_index.size
      working_index[offset, count]
    end

    # returns: a post - Postwave::Post
    def post(slug)
      post_file_path = Dir["#{File.join(@blog_root, POSTS_DIR)}/*#{slug}.md"].first
      
      raise PostNotFoundError unless post_file_path && File.exist?(post_file_path)

      Postwave::Post.new_from_file_path(post_file_path)
    end

    # returns: an array of posts - [Postwave::Post]
    def posts(offset: 0, limit: nil, tag: nil)
      posts = @all_posts || get_all_posts
      posts = posts.select { |post| post.tags.include?(tag) } if tag
      count = limit || posts.size
      posts[offset, count]
    end

    # returns: an array of tags - [String]
    def tags
      summary = @blog_summary || get_summary
      summary[:tags]
    end

    # returns: a Tag Struct - <Tag tag: "", count: Integer, post_slugs: ["post-slug",..]
    def tag(tag)
      tag_file_path = File.join(@blog_root, POSTS_DIR, META_DIR, TAGS_DIR, "#{tag}.yaml")
      raise TagNotFoundError unless File.exist?(tag_file_path)

      tag_info = YAML.load_file(tag_file_path)

      Postwave::Tag.new(tag, tag_info[:count], tag_info[:post_slugs])
    end

    private

    def is_valid_config?(config_path)
      File.exist?(config_path)
    end

    def get_all_posts
      posts = []
      Dir.glob(File.join(@blog_root, POSTS_DIR, "*.md")) do |post_file_path|
        posts << Postwave::Post.new_from_file_path(post_file_path)
      end
      posts.reject! { |p| p.draft if p.respond_to? :draft }
      posts.sort_by { |p| p.date }.reverse
    end

    def get_full_index
      full_index = []
      index_contents = CSV.read(File.join(@blog_root, POSTS_DIR, META_DIR, INDEX_FILE_NAME))
      index_contents.shift # skip header                 
      index_contents.each do |post|
      full_index << Postwave::PostStub.new(Time.parse(post[1]), post[2], post[0])
      end
      full_index
    end

    def get_summary
      summary_file_path = File.join(@blog_root, POSTS_DIR, META_DIR, SUMMARY_FILE_NAME)
      YAML.load_file(summary_file_path)
    end
  end
end
