require 'fileutils'
require_relative 'hosting'

class Heroku < Hosting
  def create
    run_in_app_dir("git init")
    run_in_app_dir("git add .")
    run_in_app_dir("git commit -m Init")
    output = run_in_app_dir("heroku apps:create --region eu")
    first_match(output, %r{(http://[^/]+/)})
  end

  def deploy
    run_in_app_dir("git push heroku master")
    run_in_app_dir("heroku ps:scale web=#{dynos}")
    sleep 60
  end

  def cleanup
    run_in_app_dir("heroku ps:scale web=0")
    run_in_app_dir("rm -rf .git/")
    after_cleanup if respond_to?(:after_cleanup)
  end

  # Dynos cost $0.05/hour.
  def monthly_cost
    0.05 * 24 * 31 * (dynos-1)
  end
end

class HerokuThins < Heroku
  def description
    "heroku (#{dynos} thin dyno#{'s' if dynos > 1})"
  end
end

class Heroku1Thin < HerokuThins
  def dynos
    1
  end

  def name
    'heroku-thins-1-dyno'
  end
end

class Heroku10Thins < HerokuThins
  def dynos
    10
  end

  def name
    'heroku-thins-10-dynos'
  end
end

class HerokuUnicorns < Heroku
  def pre_deploy
    create_unicorn_config
    create_procfile
  end

  def after_cleanup
    File.unlink(unicorn_config_dst, procfile_dst)
  end

  def description
    "heroku (#{dynos} unicorn dyno#{'s' if dynos > 1} with 5 workers each)"
  end

  private

  def create_unicorn_config
    FileUtils.cp(unicorn_config_src, unicorn_config_dst)
    git_commit_file("unicorn.conf")
  end

  def create_procfile
    File.write(procfile_dst,
      "web: bundle exec unicorn -p $PORT -c ./unicorn.conf\n")
    git_commit_file("Procfile")
  end

  def unicorn_config_src
    File.join(File.dirname(__FILE__), 'unicorn.conf')
  end

  def unicorn_config_dst
    File.join(@app_dir, 'unicorn.conf')
  end

  def procfile_dst
    File.join(@app_dir, "Procfile")
  end
end

class Heroku2Unicorns < HerokuUnicorns
  def dynos
    2
  end

  def name
    'heroku-unicorns-2-dynos'
  end
end
