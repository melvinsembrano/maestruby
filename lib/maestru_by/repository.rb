# To change this template, choose Tools | Templates
# and open the template in the editor.

module Maestro
  class Repository
    attr_accessor :name, :url, :username, :password
    def initialize(data = nil)
      if data
        @name = data["name"]
        @url = data["url"]
        @username = data["username"]
        @password = data["password"]
      end
    end

    def download_url(plugin)
      "#{@url}#{"/" unless @url.ends_with?("/")}repositories/#{plugin.group_id}/#{plugin.artifact_id}/#{plugin.filename}"
    end
  end

end