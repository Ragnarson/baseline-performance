require_relative 'hosting'

class Shelly < Hosting
  def create
    run_in_app_dir("git init")
    run_in_app_dir("git add .")
    run_in_app_dir("git commit -m Init")
    @codename = random_codename
    run_in_app_dir("shelly add --databases none --size #{size} --code-name #{@codename} #{'--organization '+$shelly_organization if $shelly_organization} --region eu")
    sleep 10
    set_pumas(pumas_per_server)
    "http://#{@codename}.shellyapp.com/"
  end

  def deploy
    run_in_app_dir("git push #{@codename} master")
    run_in_app_dir("shelly start --cloud #{@codename}")
  end

  def pre_deploy
    if servers > 1
      add_servers
    end
  end

  def cleanup
    run_in_app_dir("echo 'yes' | shelly stop --cloud #{@codename}")
    run_in_app_dir("rm -rf .git/")
    run_in_app_dir("rm -f Cloudfile")
  end

  def name
    "shelly-#{servers}-servers-#{pumas_per_server*servers}-pumas"
  end

  def description
    "shelly (#{servers} #{size} server#{'s' if servers > 1} with #{pumas_per_server} pumas each)"
  end

  # Small server costs €0.0287/hour which we'll count as $0.0374/hour.
  def monthly_cost
    0.0374 * 24 * 31 * servers
  end

  def size
    'small'
  end

  private

  def add_servers
    (2..servers).each do |server|
      change_cloudfile(/\z/, "    app#{server}:\n      size: #{size}\n      puma: #{pumas_per_server}\n")
    end
    git_commit_file("Cloudfile")
  end

  def random_codename
    'benchmark-' + Array.new(8){('a'..'z').to_a.sample}.join
  end

  def set_pumas(number)
    change_cloudfile(/puma: \d+/, "puma: #{number}")
    git_commit_file("Cloudfile")
  end

  def change_cloudfile(pattern, replacement)
    contents = File.read(cloudfile_path)
    contents.gsub!(pattern, replacement)
    File.write(cloudfile_path, contents)
  end

  def cloudfile_path
    File.join(@app_dir, "Cloudfile")
  end
end

class Shelly1Server2Pumas < Shelly
  def servers
    1
  end

  def pumas_per_server
    2
  end
end

class Shelly2Servers1Pumas < Shelly
  def servers
    2
  end

  def pumas_per_server
    1
  end
end

class Shelly2Servers2Pumas < Shelly
  def servers
    2
  end

  def pumas_per_server
    2
  end
end
