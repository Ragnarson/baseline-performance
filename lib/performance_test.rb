require_relative 'performance_test_result'
require_relative 'util'

class PerformanceTest
  attr_reader :name, :address, :concurrency

  def initialize(name, address, concurrency)
    @name = name
    @address = address
    @concurrency = concurrency
  end

  def run!
    warm_up
    run_ab
  end

  def warm_up
    run("ab -c 16 -n 200 #{address}")
  end

  def run_ab
    base = data_base_name(concurrency)
    requests = 500 * concurrency
    run("mkdir -p data")
    run("ab -c #{concurrency}" \
      " -n #{requests}" \
      " -g #{base}.plot" \
      " -e #{base}.csv" \
      " #{address} > #{base}.output")
  end

  def result
    PerformanceTestResult.new("#{data_base_name(concurrency)}.output")
  end

  def data_base_name(concurrency)
    "data/c-#{concurrency}-#{name}"
  end
end
