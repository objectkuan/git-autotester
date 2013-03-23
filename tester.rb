#!/usr/bin/env ruby
# encoding: utf-8

require 'sinatra'
require 'grit'
require 'yaml'
require 'pp'

CONFIG=YAML.load File.read("config.yaml")
pp CONFIG

set :public_folder, File.dirname(__FILE__) + '/views'
set :bind, CONFIG[:bind] || '0.0.0.0'
set :port, CONFIG[:port] || 4567

get '/' do
	erb :index, :locals => {}
end
