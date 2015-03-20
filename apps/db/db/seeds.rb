require "sequel"
require "slim"
require "dotenv"

Dotenv.load

DB = Sequel.connect("postgres://#{ENV["POSTGRESQL_USER"]}:#{ENV["POSTGRESQL_PASSWORD"]}@#{ENV["POSTGRESQL_HOST"]}:5432/#{ENV["POSTGRESQL_DATABASE"]}")

require './models/post'

def random_char
  (('a'..'z').to_a + [' ']).sample
end

def random_string(n)
  Array.new(n) { random_char }.join
end

Post.all.each(&:delete)

1000.times do
  title = random_string(30)
  body = random_string(2048)
  created_at = DateTime.now

  Post.create(title: title, body: body, created_at: created_at)
end
