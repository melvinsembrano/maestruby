$:.unshift File.join(File.dirname(__FILE__),"../lib/")

require 'maestru_by'

namespace :maestro do
  MHOME = File.expand_path("~/.maestruby/")
  force = ENV['force'] || ENV['f'] || false
  desc "Setup Maestro Ruby environment"
  task :setup do
    repo_path = File.join(MHOME, "repositories")

    puts "Initializing Maestro Ruby environment..."
    FileUtils.mkdir_p(MHOME) unless File.exist?(MHOME)    
    FileUtils.mkdir_p(repo_path) unless File.exist?(repo_path)
    puts "DONE.."
  end

  namespace :plugins do
    config_file = ENV['config-file']

    desc "install plugins"
    task :install do
      t = Maestro::Tasks.new
      plugins_offline_task(t)
      plugins_install_task(t, force)
    end
  
    desc "download plugins to the local repository"
    task :offline do
      t = Maestro::Tasks.new(config_file)
      plugins_offline_task(t)
    end
  end

end

def plugins_install_task(t, force = false)
  t.plugins.each do |p|
    puts "installing #{p.artifact_id} plugin to application..."
    if force || !File.Directory?(p.app_plugin_folder)
      FileUtils.rm_rf(p.app_plugin_folder) if File.exist?(p.app_plugin_folder)
      unless File.Directory?(p.extract_folder)
        Dir.chdir(local_folder)
        res = `gem unpack #{p.filename}`
        abort_if_system_error(res)
        Dir.chdir(RAILS_ROOT)
      end
      FileUtils.cp_r(p.extract_folder, p.app_plugin_folder)
    end
    
  end
end

def plugins_offline_task(t)
  t.plugins.each do |p|
    puts "bringing #{p.artifact_id} to offline.."
    unless File.exist?(p.local_path)
      FileUtils.mkdir_p(p.local_folder) unless File.exist?(p.local_folder)
      puts "downloading #{p.artifact_id}..."
      Dir.chdir(p.local_folder)
      res = `#{t.download_command(p)}`
      abort_if_system_error(res)
    end
  end
  Dir.chdir(RAILS_ROOT)
end


def abort_if_system_error(message)
  if system_error?
    puts "ERROR: #{message}"
    abort
  end
end

def system_error?
  $?.to_i != 0
end
