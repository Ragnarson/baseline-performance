require 'rake'
require_relative 'db/migrator'

namespace :db do
  task :create do
    system("psql -U #{ENV['POSTGRESQL_USER']} -d template1 -c 'CREATE DATABASE \"#{ENV['POSTGRESQL_DATABASE']}\";'")
  end

  task :drop do
    system("psql -U #{ENV['POSTGRESQL_USER']} -d template1 -c 'DROP DATABASE \"#{ENV['POSTGRESQL_DATABASE']}\";'")
  end

  task :migrate do
    Migrator.migrate!
  end

  task seed: :migrate do
    load 'db/seeds.rb'
  end

  task :clean do
    load 'db/clean.rb'
  end

  task :setup do
  end
end
