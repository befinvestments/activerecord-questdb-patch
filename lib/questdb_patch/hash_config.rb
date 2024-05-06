module QuestDbPatch
  class HashConfig < ActiveRecord::DatabaseConfigurations::HashConfig
    def questdb?
      configuration_hash.fetch(:questdb, false)
    end
  end
end
