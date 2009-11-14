require 'rubygems'
require 'yaml'
require 'erb'

module Maestro
  class Tasks
    attr_accessor :repositories, :plugins, :downloader

    DEFAULT_COMMANDS = {
      :wget => "wget --http-user=<%= param[:user] %> --http-password=<%= param[:pwd] %> -O <%= param[:filename] %> <%= param[:url] %>",
      :curl => "curl -u <%= param[:user] %>:<%= param[:pwd] %> -o <%= param[:filename] %> <%= param[:url] %>"
    }
      
    def initialize(config_file = nil)
      config_file ||= File.join(RAILS_ROOT, "config/maestru_by.yml")
      setup_data(config_file)
    end

    def download_command(plugin, repo = @repositories.first)
      param = {
        :user => repo.username,
        :pwd => repo.password,
        :url => repo.download_url(plugin),
        :filename => plugin.filename,
      }
      t = ERB.new(@downloader[:command])
      t.result(param.send(:binding))
    end
    

    private

    def setup_data(config_file)
      if config_file && File.exist?(config_file)
        data = YAML.load_file(config_file)
        if data
          setup_settings(data["settings"])
          setup_plugins(data["plugins"])
        end
      end
    end

    def setup_settings(data)
      if data
        setup_repositories(data["repositories"])
        setup_downloader(data["downloader"])
      end
    end
    
    def setup_downloader(data)
      if data
        @downloader = {:name => data["name"], :command => data["command"]}
      else
        @downloader = {:name => "wget"}
      end
      @downloader[:command] = DEFAULT_COMMANDS[@downloader[:name].to_sym] if @downloader[:command].nil? || @downloader[:command].eql?("default") || @downloader[:command].eql?("")
    end

    def setup_repositories(data)
      @repositories = []
      data.each {|d| @repositories << Repository.new(d)} if data
    end

    def setup_plugins(data)
      @plugins = []
      data.each {|d| @plugins << Artifact.new(d)} if data
    end
  end

end
