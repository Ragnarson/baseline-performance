require 'erb'

def generate_graph(hostings, concurrency)
  puts ">>> Generating graph for concurrency=#{concurrency}..."
  File.write("gnuplot.conf", gnuplot_config(hostings, concurrency))
  run("gnuplot gnuplot.conf")
  File.delete("gnuplot.conf")
end

def plot_list(hostings, concurrency)
  hostings.map do |hosting|
    %Q{"data/c-#{concurrency}-#{hosting.name}.plot" using 9 smooth sbezier with lines title "#{hosting.description}"}
  end.join(", ")
end

def gnuplot_config(hostings, concurrency)
  ERB.new(File.read(File.join(File.dirname(__FILE__), "gnuplot.erb"))).result(binding)
end
