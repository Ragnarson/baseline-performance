require_relative 'performance_test'
require_relative 'util'

class Hosting
  def initialize(app_dir, concurrencies)
    @app_dir = app_dir
    @concurrencies = concurrencies
  end

  def test!
    if pending_tests.empty?
      puts ">>> Skipping #{name}, all tests already run. Remove results from data/ to rerun."
      return
    end
    puts ">>> Creating..."
    @address = create
    pre_deploy if respond_to?(:pre_deploy)
    puts ">>> Deploying to #{@address}..."
    deploy if respond_to?(:deploy)
    puts ">>> Benchmarking..."
    benchmark
    puts ">>> Cleaning up..."
    cleanup if respond_to?(:cleanup)
  end

  def get_result(concurrency)
    test(concurrency).result
  end

  def self.name
    new(nil, nil).name
  end

  private

  def benchmark
    pending_tests.each(&:run!)
  end

  def pending_tests
    tests.reject {|t| t.result.present?}
  end

  def tests
    @concurrencies.map { |c| test(c) }
  end

  def test(concurrency)
    PerformanceTest.new(name, @address, concurrency)
  end

  def run_in_app_dir(command)
    run(command, @app_dir)
  end

  def git_commit_file(filename)
    run_in_app_dir("git add #{filename}")
    run_in_app_dir("git commit -m #{filename}")
  end
end
