require './app'

class Migrator
  Sequel.extension :migration

  def self.migrate!
    Sequel::Migrator.apply(db, "./db/migrations")
  end

  private

  def self.db
    Sequel.connect(postgresql_connection_string)
  end

  def self.postgresql_connection_string
    ENV["DATABASE_URL"] || "postgres://#{ENV["POSTGRESQL_USER"]}:#{ENV["POSTGRESQL_PASSWORD"]}@#{ENV["POSTGRESQL_HOST"]}:5432/#{ENV["POSTGRESQL_DATABASE"]}"
  end
end
