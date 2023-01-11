module Postwave
  module BlogUtilities
    CONFIG_FILE_NAME = "postwave.yaml"
    INDEX_FILE_NAME = "index.csv"
    SUMMARY_FILE_NAME = "summary.yaml"
    RSS_FILE_NAME = "rss"
    POSTS_DIR = "_posts"
    META_DIR = "meta"
    TAGS_DIR = "tags"

    def is_set_up?
      missing_paths = find_missing_paths
      missing_paths.empty?
    end

    def file_paths
      [
        File.join(Dir.pwd, CONFIG_FILE_NAME),
        File.join(Dir.pwd, POSTS_DIR, META_DIR, INDEX_FILE_NAME),
        File.join(Dir.pwd, POSTS_DIR, META_DIR, SUMMARY_FILE_NAME),
      ]
    end

    def directory_paths
      [
        File.join(Dir.pwd, POSTS_DIR),
        File.join(Dir.pwd, POSTS_DIR, META_DIR),
        File.join(Dir.pwd, POSTS_DIR, META_DIR, TAGS_DIR),
      ]
    end

    def find_missing_paths
      paths_to_check = directory_paths + file_paths
      missing_paths = []
      paths_to_check.each do |path|
        missing_paths << path if !FileTest.exists?(path)
      end
      missing_paths
    end

    def config_values
      @config_values ||= if yaml_load = YAML.load_file(File.join(Dir.pwd, CONFIG_FILE_NAME))
          yaml_load.transform_keys(&:to_sym)
        else
          {}
      end
    end
  end
end
