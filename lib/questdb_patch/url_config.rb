module QuestDbPatch
  class UrlConfig < ActiveRecord::DatabaseConfigurations::UrlConfig
    def questdb?
      configuration_hash.fetch(:questdb, false)
    end
  end
end
