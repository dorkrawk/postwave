$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require "minitest/autorun"
require "minitest/spec"
require "minitest/pride"
require "postwave/client"
require "rss"

def valid_rss?(rss_string)
  RSS::Parser.parse(rss_string, false)
  true
rescue RSS::NotWellFormedError, RSS::Error
  false
end
