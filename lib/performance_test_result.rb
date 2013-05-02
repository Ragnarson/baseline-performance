class PerformanceTestResult
  def initialize(filename)
    @filename = filename
  end

  def present?
    File.exists?(@filename)
  end

  def failed_requests
    first_match(ab_output, /Failed requests:\s+(\d+)/).to_i
  end

  def rps
    first_match(ab_output, /Requests per second:\s+([0-9.]+)/)
  end

  # Returns min, mean, median, 90%, 95% and max processing times.
  def processing_times
    total = ab_output.match(/Total:\s+([0-9.]+)\s+([0-9.]+)\s+([0-9.]+)\s+([0-9.]+)\s+([0-9.]+)/)
    ninety = ab_output.match(/  90%\s+([0-9.]+)/)
    ninetyfive = ab_output.match(/  95%\s+([0-9.]+)/)
    [total[1], total[2], total[4], ninety[1], ninetyfive[1], total[5]]
  end

  private

  def ab_output
    File.read(@filename)
  end
end
