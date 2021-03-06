module JIRAMigrator
  class Config

    require 'json'

    CONFIG_PATH = "./config/"

    def initialize
      @env = ENV['MIGRATE_ENV'].downcase || "development"
      load_config
    end

    def [](key)
      @config_data[key]
    end

    private

    def load_config
      file_data = File.read(config_path)
      @config_data = ::JSON.parse(file_data)

    rescue JSON::ParserError => e
      raise JIRA::ConfigLoadError.new
    end

    def config_path
      if ENV['CONFIG_PATH'] != nil
        ENV['CONFIG_PATH']
      else
        "#{CONFIG_PATH}/#{@env}.json"
      end
    end

  end
end
