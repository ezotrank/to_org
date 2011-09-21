#!/usr/bin/ruby

require 'rest_client'
require 'yaml'
require 'find'

CONFIG_FILE = File.open(File.join(ENV['HOME'], '.to_org.yml'))
# Config file should be exist!!!
abort "File #{CONFIG_FILE} not exists" unless File.exists?(CONFIG_FILE)

@config = YAML::load(CONFIG_FILE)
# If we run script wiht DEV=1 ./to_org.rb use test url
@config.merge!({ "url" => "http://localhost:3000/post_by_emacs"}) if ENV["DEV"]

def post_page(url, title, content, private)
  response = RestClient.post @config["url"], :api_key => @config["admin_api_key"],
                                           :blog_page => { :url => url, :title => title, :content => content, :private => private}
  if response.code == 200
    puts "#{url} good"
  else
    puts "#{url} bad"
  end
end

use_direcotry = ARGV[0]

Find.find(use_direcotry) do |f|
  next unless f =~ /\.html$/
  url = f.match(/#{use_direcotry}\/(.+)\.html$/)[1]
  private = url =~ /private\// ? true : false
  content = File.open(f, "r").read
  title = url
  post_page(url, title, content, private)
end
