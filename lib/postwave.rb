require_relative "postwave/blog_creator"
require_relative "postwave/blog_builder"
require_relative "postwave/post_creator"
require_relative "postwave/version"

module Postwave
  def self.call(command, options)
    case command
    when "new"
      Postwave::BlogCreator.instance.create
    when "post"
      Postwave::PostCreator.instance.create
    when "build"
      Postwave::BlogBuilder.instance.build
    else
      if options[:version]
        puts "postwave #{VERSION} [ruby]"
      end
    end
  end
end
