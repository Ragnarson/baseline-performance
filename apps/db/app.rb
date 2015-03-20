require "rack"

require "sinatra/base"
require "sinatra/partial"
require "sinatra/sequel"

require "slim"
require "dotenv"

Dotenv.load

class App < Sinatra::Base
  register Sinatra::Partial
  autoload :Post, "./models/post"

  def self.postgresql_connection_string
    ENV["DATABASE_URL"] || "postgres://#{ENV["POSTGRESQL_USER"]}:#{ENV["POSTGRESQL_PASSWORD"]}@#{ENV["POSTGRESQL_HOST"]}:5432/#{ENV["POSTGRESQL_DATABASE"]}"
  end

  configure do
    set :partial_template_engine, :slim
    set :server, :puma
    set :database, postgresql_connection_string
  end

  before do
    Sequel.connect(settings.database, max_connections: 16)
  end

  helpers do
    def date
      DateTime.now.strftime("%d %B %Y")
    end

    def time
      Time.now.strftime("%H:%M")
    end
  end

  get "/" do
    @posts = Post.order(Sequel.lit("RANDOM()")).limit(5)
    slim :index, layout: :application
  end

  post "/create" do
    Post.create(title: params["title"],
      body: params["body"],
      created_at: DateTime.now)

    redirect '/'
  end
end
