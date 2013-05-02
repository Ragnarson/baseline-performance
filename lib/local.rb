require_relative 'hosting'

class Local < Hosting
  def create
    run_in_app_dir("thin start -p 3000 -d -l /dev/null -P /tmp/thin.pid")
    sleep(1)
    'http://localhost:3000/'
  end

  def cleanup
    run_in_app_dir("thin stop -P /tmp/thin.pid")
  end

  def name
    'local'
  end

  def description
    'local (1 thin)'
  end

  def monthly_cost
    0
  end
end
