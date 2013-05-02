require_relative 'lib/graph'
require_relative 'lib/summary'
require_relative 'lib/options'

def measure_performance(app_dir, hosting_classes, concurrencies)
  hostings = hosting_classes.map{|h| h.new(app_dir, concurrencies)}
  hostings.each(&:test!)
  concurrencies.each do |concurrency|
    generate_graph(hostings, concurrency)
    print_summary(hostings, concurrency)
  end
end

def main
  measure_performance(*options.values_at(:app, :hostings, :concurrencies))
end

main
