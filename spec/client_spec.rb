require "spec_helper"

describe Postwave::Client do

  before do
    @good_blog_path = "./spec/mock_blogs/all_good/postwave.yaml"
    @incomplete_blog_path = "./spec/mock_blogs/incomplete/postwave.yaml"

    @good_client = Postwave::Client.new(@good_blog_path)
  end

  describe "#new" do
    it "initialized a valid blog" do
      # not using @good_client to insure no loaded posts
      postwave_client = Postwave::Client.new(@good_blog_path)

      _(postwave_client).must_be_instance_of Postwave::Client
      _(postwave_client.instance_variables).wont_include :@all_posts # make sure we're not preloading
    end

    it "preloads all posts if preload is set to true" do
      postwave_client = Postwave::Client.new(@good_blog_path, preload: true)

      _(postwave_client.instance_variables).must_include :@all_posts
    end

    it "raises a MissingConfigError if a bad config path is passed" do
      assert_raises(Postwave::MissingConfigError) do
        Postwave::Client.new("./bad/config/path")
      end
    end

    it "raises an InvalidBlogError if the indicated blog is not set up properly" do
      assert_raises(Postwave::InvalidBlogError) do
        Postwave::Client.new(@incomplete_blog_path)
      end
    end
  end

  describe "#index" do
    it "returns an array of PostStubs" do
      index = @good_client.index
      first_post = index.first

      _(index).must_be_instance_of Array
      _(first_post).must_be_instance_of Postwave::PostStub
      _(index.count).must_equal 3
      _(index).must_equal index.sort_by { |p| p.date }.reverse # index should be reverse chronological

      _(first_post.title).must_equal "Most Recent Post"
      _(first_post.date).must_equal Time.parse("2022-06-06 22:53")
      _(first_post.slug).must_equal "most-recent-post"
    end

    it "limits the index items based on limit" do
      index = @good_client.index(limit: 2)

      _(index.count).must_equal 2
    end

    it "offsets the index items based on offset" do
      index = @good_client.index(offset: 2)

      _(index.count).must_equal 1
      _(index.first.title).must_equal "First Test Post" # index should be reverse chronological      
    end

    it "offsets and limits" do
      index = @good_client.index(offset: 1, limit: 1)

      _(index.count).must_equal 1
      _(index.first.title).must_equal "Yet Another Post"
    end
  end

  describe "#posts" do
    it "returns an array of all non-draft Posts" do
      posts = @good_client.posts

      _(posts).must_be_instance_of Array
      _(posts.first).must_be_instance_of Postwave::Post
      _(posts.count).must_equal 3
      _(posts).must_equal posts.sort_by { |p| p.date }.reverse # index should be reverse chronological
    end

    it "limits the posts returned based on limit" do
      posts = @good_client.posts(limit: 2)

      _(posts.count).must_equal 2
    end

    it "offsets the posts returned based on offset" do
      posts = @good_client.posts(offset: 2)

      _(posts.count).must_equal 1
      _(posts.first.title).must_equal "First Test Post" # index should be reverse chronological      
    end

    it "limits the posts returned based on tag" do
      posts = @good_client.posts(tag: "test")

      _(posts.count).must_equal 2
      _(posts.map { |p| p.title }).wont_include "Most Recent Post"
    end
  end

  describe "#post" do
    it "returns a post given a stub" do
      post = @good_client.post("2022-06-06-most-recent-post")

      _(post).must_be_instance_of Postwave::Post
      _(post.title).must_equal "Most Recent Post"
      _(post.date).must_equal Time.parse("2022-06-06 22:53")
      _(post.tags).must_equal ["hi"]
      _(post.body).must_equal "Hi testing!\n"
    end

    it "raises a PostNotFoundError if a bad stub is passed" do
      assert_raises(Postwave::PostNotFoundError) do
        @good_client.post("2022-06-06-bad-stub")
      end
    end
  end 

  describe "#tags" do
    it "returns a list of tags" do
      tags = @good_client.tags

      _(tags.sort).must_equal ["first-post", "hi", "test"]
    end
  end

  describe "#tag" do
    it "returns a Tag struct" do
      tag_name = "test"
      tag = @good_client.tag(tag_name)

      _(tag).must_be_instance_of Postwave::Tag
      _(tag.name).must_equal tag_name
      _(tag.count).must_equal 2
      _(tag.post_slugs).must_equal ["yet-another-post", "first-test-post"]
    end

    it "raises a TagNotFounde if a bad tag path is passed" do
      assert_raises(Postwave::TagNotFoundError) do
        @good_client.tag("bad-tag")
      end
    end
  end
end
