# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'questdb_patch/version'

Gem::Specification.new do |s|
  s.name = "activerecord-questdb-patch"
  s.version = QuestDbPatch::VERSION

  s.require_paths = ["lib"]
  s.authors = ["Eirik Dentz Sinclair"]
  s.summary = "Provides read-only access to QuestDB backed ActiveRecord models"
  s.description = "Monkey patches ActiveRecord Postgresql Connection adapters to enable Read only access to QuestDB instances."
  s.email = "edsinclair@users.noreply.github.com"
  s.extra_rdoc_files = [
    "LICENSE",
    "README.md"
  ]
  s.files    = `git ls-files`.split($/)
  s.homepage = "https://github.com/befinvestments/activerecord-questdb-patch"
  s.licenses = ["MIT"]

  s.add_runtime_dependency 'activerecord', '>= 7', '< 9'
  s.add_runtime_dependency 'pg'
  s.add_development_dependency 'rdoc'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'simplecov'
end
