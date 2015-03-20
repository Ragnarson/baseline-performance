require "sequel"
require "slim"
require "dotenv"

Dotenv.load

DB = Sequel.connect("postgres://#{ENV["POSTGRESQL_USER"]}:#{ENV["POSTGRESQL_PASSWORD"]}@#{ENV["POSTGRESQL_HOST"]}:5432/#{ENV["POSTGRESQL_DATABASE"]}")

require './models/post'

Post.all.each(&:delete)
