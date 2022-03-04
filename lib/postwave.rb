require_relative "postwave/blog_creator"
require_relative "postwave/blog_builder"
require_relative "postwave/post_creator"
require_relative "postwave/version"

module Postwave
  def self.call(options)
    # handle command line options here

    # new
    #Postwave::BlogCreator.instance.create
    
    # post
    Postwave::PostCreator.instance.create
    
    # build
    # Postwave::BlogBuilder.instance.build
  end
end

Postwave.call({})
