require 'optparse'
require_relative 'local'
require_relative 'heroku'
require_relative 'shelly'

def options
  @options ||= default_options.tap do |options|
    parser = OptionParser.new do |parser|
      parser.banner = "Usage: measure-performance.rb [options]"

      parser.separator ""
      parser.separator "Tests the sample application in app/ on all known hostings by default."
      parser.separator ""
      parser.separator "You can experiment with different concurrency values, modify the sample app, or"
      parser.separator "subclass a hosting to test a different configuration."
      parser.separator ""
      parser.separator "Specific options:"

      parser.on("-a", "--app DIRECTORY",
        "Test given application instead of the default in app/") do |app|
        options[:app] = app
      end

      parser.on("-c", "--concurrencies x,y,z", Array,
        "Comma-separated list of concurrency values to use") do |concurrencies|
        options[:concurrencies] = concurrencies.map(&:to_i)
      end

      parser.on("--hostings x,y,z", Array,
        "Comma-separated list of hostings to test") do |names|
        begin
          options[:hostings] = names.map {|name| hostingbyname(name)}
        rescue KeyError => e
          puts e.message
          puts
          print_known_hostings
          exit(1)
        end
      end

      parser.on("--shelly-organization NAME",
        "When creating the application on Shelly create it under this organization") do |organization|
        # An obvious hack, but will do for now.
        $shelly_organization = organization
      end

      parser.on_tail("-h", "--help", "This help") do
        puts parser
        puts
        print_known_hostings
        exit
      end
    end
    parser.parse!(ARGV)
  end
end

KNOWN_HOSTINGS = [Local, Heroku1Puma, Heroku2Pumas, Shelly1Server2Pumas,
  Shelly2Servers1Pumas, Shelly2Servers2Pumas]

def print_known_hostings
  puts "Known hostings (use with --hostings option):"
  KNOWN_HOSTINGS.each do |hosting|
    puts "  - #{hosting.name}"
  end
end

def hostingbyname(name)
  KNOWN_HOSTINGS.find {|hosting| hosting.name == name} ||
    (raise KeyError.new("Unknown hosting: #{name}"))
end

def default_options
  {app: "app", hostings: KNOWN_HOSTINGS, concurrencies: [10, 30]}
end
