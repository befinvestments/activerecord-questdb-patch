require 'rubygems'
require 'rspec'

# Optional simplecov loading
begin
  require 'simplecov'
  SimpleCov.start
rescue LoadError
end

require 'active_record'
require 'active_record/version'
$: << File.join(File.dirname(__FILE__), "..", "lib")


module QuestDbPatch
  # Minimal Fake Connection class
  # Adapted from: https://github.com/rails/rails/blob/main/activerecord/test/cases/adapters/postgresql/postgresql_adapter_test.rb#L29-L54
  class FakeConnection
    def async_exec(*)
      [{}]
    end

    def type_map_for_queries=(_)
    end

    def type_map_for_results=(_)
    end

    def exec_params(*)
      {}
    end

    def escape(query)
      PG::Connection.escape(query)
    end

    def query(sql)
    end

    def server_version
      15_00_00
    end
  end
end

RSpec.configure do |config|
  if config.files_to_run.one?
    config.default_formatter = "doc"
  end
end

RSpec::Matchers.define :ignore_whitespace do |x|
  match do |actual|
    (
      actual.respond_to?(:squish) ? actual.squish : actual
    ) == x.squish
  end
end
