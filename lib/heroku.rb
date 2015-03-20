require 'fileutils'
require_relative 'hosting'

class Heroku < Hosting
  def create
    run_in_app_dir("git init")
    run_in_app_dir("git add .")
    run_in_app_dir("git commit -m Init")
    output = run_in_app_dir("heroku apps:create --region eu")
    first_match(output, %r{(https://[^/]+/)})
  end

  def deploy
    run_in_app_dir("git push heroku master")
    run_in_app_dir("heroku ps:scale web=#{dynos}")
    sleep 60
  end

  def prepare_database
    run_in_app_dir("heroku pg:wait")

    run_in_app_dir("heroku run rake db:migrate")
    run_in_app_dir("heroku run rake db:seed")
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

class HerokuPumas < Heroku
  def pre_deploy
    create_puma_config
    create_procfile
  end

  def after_cleanup
    File.unlink(puma_config_dst, procfile_dst)
  end

  def description
    "heroku (#{dynos} puma dyno#{'s' if dynos > 1} with 1 worker each)"
  end

  private

  def create_puma_config
    FileUtils.cp(puma_config_src, puma_config_dst)
    git_commit_file("puma.rb")
  end

  def create_procfile
    File.write(procfile_dst, "web: bundle exec puma -C puma.rb\n")
    git_commit_file("Procfile")
  end

  def puma_config_src
    File.join(File.dirname(__FILE__), 'puma.rb')
  end

  def puma_config_dst
    File.join(@app_dir, 'puma.rb')
  end

  def procfile_dst
    File.join(@app_dir, "Procfile")
  end
end

class Heroku1Puma < HerokuPumas
  def dynos
    1
  end

  def name
    'heroku-pumas-1-dynos'
  end
end

class Heroku2Pumas < HerokuPumas
  def dynos
    2
  end

  def name
    'heroku-pumas-2-dynos'
  end
end
