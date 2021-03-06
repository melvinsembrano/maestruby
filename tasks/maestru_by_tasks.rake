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
    FileUtils.cp(File.join(File.dirname(__FILE__),"../lib/templates/maestru_by.yml"), File.join(RAILS_ROOT,"config/maestru_by.yml")) unless File.exist?(File.join(RAILS_ROOT,"config/maestru_by.yml"))
    puts "DONE.."
  end

  namespace :plugin do
    group_id = ENV["group_id"] || ENV["g"]
    artifact_id = ENV["artifact_id"] || ENV["a"]
    version = ENV["version"] || ENV["v"]
    repo_type = ENV["repo_type"] || ENV["r"]
    desc "install plugin"
    task :install do
      if group_id and artifact_id
        task = Maestro::Tasks.new
        artifact = Maestro::Artifact.new({:group_id => group_id, :artifact_id => artifact_id, :version => version, :repo_type => repo_type})
        plugin_offline_task(task, artifact)
        plugin_install_task(artifact)
        puts "DONE"
      else
        puts "rake syntax: den:plugin:install group_id=maestro artifact_id=sample_plugin"
      end
    end
  end

  namespace :plugins do
    config_file = ENV['config']

    desc "install plugins"
    task :install do
      t = Maestro::Tasks.new(config_file)
      plugins_offline_task(t)
      plugins_install_task(t, force)
    end
  
    desc "download plugins to the local repository"
    task :offline do
      t = Maestro::Tasks.new(config_file)
      plugins_offline_task(t)
      puts "DONE..."
    end
  end

end

def plugins_install_task(t, force = false)
  t.plugins.each do |p|
    plugin_install_task(p, force)
  end
end

def plugin_install_task(p, force = false)
    puts "installing #{p.artifact_id} plugin to application..."
    if force || !File.directory?(p.app_plugin_folder)
      FileUtils.rm_rf(p.app_plugin_folder) if File.exist?(p.app_plugin_folder)
      unless File.directory?(p.extract_folder)
        Dir.chdir(p.local_folder)
        res = `gem unpack #{p.filename}`
        abort_if_system_error(res)
        Dir.chdir(RAILS_ROOT)
      end
      FileUtils.cp_r(p.extract_folder, p.app_plugin_folder)
    end
end

def plugins_offline_task(t)
  t.plugins.each do |p|
    plugin_offline_task(t,p)
  end
  Dir.chdir(RAILS_ROOT)
end


def plugin_offline_task(t, p)
  puts "bringing #{p.artifact_id} to offline.."
  unless File.exist?(p.local_path)
    FileUtils.mkdir_p(p.local_folder) unless File.exist?(p.local_folder)
    puts "downloading #{p.artifact_id}..."
    Dir.chdir(p.local_folder)
    cmd = t.download_command(p)
    unless cmd
      puts "ERROR: cannot download #{p.artifact_id} from any of the repositories."
      abort
    end
    unless File.exist?(p.local_path)
      res = `#{cmd}`
      abort_if_system_error(res)
    end
  end
  Dir.chdir(RAILS_ROOT)
  return p
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
