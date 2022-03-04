require "fileutils"
require "yaml"
require "singleton"
require_relative "blog_utilities"

module Postwave
  class BlogBuilder
    include Singleton
    include BlogUtilities

    def build

    end
  end
end
