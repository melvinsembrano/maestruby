# To change this template, choose Tools | Templates
# and open the template in the editor.

module Maestro
  class Artifact
    attr_accessor :group_id, :artifact_id, :version, :type, :repo_type
    MHOME = File.expand_path("~/.maestruby/")

    def initialize(data = nil)
      if data
        @group_id = data["group_id"]
        @artifact_id = data["artifact_id"]
        @version = data["version"]
        @type = data["type"]
        @repo_type = data["repo_type"]
      end
    end

    def filename
      "#{@group_id}_#{@artifact_id}-#{@version}.#{@type}"
    end

    def fullname
      "#{@group_id}_#{@artifact_id}-#{@version}"
    end

    def extract_folder
      File.join(local_folder,fullname)
    end

    def local_folder
      File.join(MHOME,"artifacts", @group_id, @artifact_id)
    end

    def local_path
      File.join(local_folder, filename)
    end

    def app_plugin_folder
      File.join(RAILS_ROOT, "vendor", "plugins", "#{@group_id}_#{@artifact_id}")
    end
    
  end
end
