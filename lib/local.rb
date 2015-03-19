require_relative 'hosting'

class Local < Hosting
  def create
    run_in_app_dir("puma --port 3000 --preload --daemon --quiet --pidfile /tmp/puma.pid")
    sleep(1)
    'http://localhost:3000/'
  end

  def cleanup
    run_in_app_dir("pumactl --pidfile /tmp/puma.pid stop")
  end

  def name
    'local'
  end

  def description
    'local (1 puma)'
  end

  def monthly_cost
    0
  end
end
