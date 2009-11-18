# To change this template, choose Tools | Templates
# and open the template in the editor.
require 'rubygems'
require 'activesupport'
require 'net/http'
require 'uri'

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

    def metadata_url(plugin)
      "#{@url}#{"/" unless @url.ends_with?("/")}repository/#{plugin.repo_type.pluralize}/#{plugin.group_id}/#{plugin.artifact_id}/maven-metadata.xml"
    end

    def download_url(plugin)
      "#{@url}#{"/" unless @url.ends_with?("/")}repository/#{plugin.repo_type.pluralize}/#{plugin.group_id}/#{plugin.artifact_id}/#{plugin.version}/#{plugin.artifact_id}-#{plugin.version}.#{plugin.type}"
    end

    def get_metadata(plugin)
      uri = URI.parse(metadata_url(plugin))

      req = Net::HTTP::Get.new(uri.path)
      req.basic_auth(@username, @password)
      res = Net::HTTP.start(uri.host, uri.port) {|http|
        http.request(req)
      }
      case res
      when Net::HTTPSuccess, Net::HTTPRedirection
        return Hash.from_xml(res.body)
      else
        nil
      end
    end

  end

end