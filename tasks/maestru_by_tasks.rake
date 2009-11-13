$:.unshift File.join(File.dirname(__FILE__),"../lib/")

require 'maestru_by'

namespace :maestro do

  desc "Setup Maestro Ruby environment"
  task :setup do

  end

  namespace :plugin do
    desc "install plugins"
    task :install do
      t = Maestro::Tasks.new
    end
  end
end