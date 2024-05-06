require 'active_record/database_configurations'
require 'questdb_patch/hash_config'
require 'questdb_patch/url_config'

module QuestDbPatch
  class Railtie < Rails::Railtie
    config.before_configuration do
      ActiveRecord::DatabaseConfigurations.register_db_config_handler do |env_name, name, url, config|
        if url
          QuestDbPatch::UrlConfig.new(env_name, name, url, config)
        else
          QuestDbPatch::HashConfig.new(env_name, name, config)
        end
      end
    end
  end
end
