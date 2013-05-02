require 'terminal-table'

def print_summary(hostings, concurrency)
  rows = []
  rows << ['Hosting', 'rps', 'min', 'mean', 'median', '90%', '95%', 'max', 'cost']
  rows << :separator
  hostings.each do |hosting|
    result = hosting.get_result(concurrency)
    if result.failed_requests > 0
      puts "!!! #{hosting.name} has #{result.failed_requests} failed requests"
    end
    rows << [hosting.description,
      result.rps,
      *result.processing_times,
      "$#{hosting.monthly_cost.round}"]
  end
  puts
  puts "Concurrency: #{concurrency}"
  puts Terminal::Table.new(:rows => rows)
end
