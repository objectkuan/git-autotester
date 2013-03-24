#!/usr/bin/env ruby
# encoding: utf-8

require 'sinatra'
require 'grit'
require 'yaml'
require 'pp'

YAML::ENGINE.yamler='syck'
ROOT= File.dirname(File.expand_path __FILE__)
CONFIG_FILE= File.join ROOT, "config.yaml"
$CONFIG=YAML.load File.read(CONFIG_FILE)
pp $CONFIG

set :public_folder, File.dirname(__FILE__) + '/views'
set :bind, $CONFIG[:bind] || '0.0.0.0'
set :port, $CONFIG[:port] || 4567

helpers do
	def h(text)
		Rack::Utils.escape_html(text)
	end
	def tr(text, len)
		len = 3 if len<3
		return "nil" unless text
		return text if text.length < len
		text[0..len-3]+"..."
	end
	def ol(line)
		t = line.chomp
		return "<span class=\"line-warning\">#{h t}</span>" if t =~ /\bwarning\b/i
		return "<span class=\"line-error\">#{h t}</span>" if t =~ /\b(error|fail|failed)\b/i
		return "<span class=\"line-ok\">#{h t}</span>" if t =~ /\bok\b/i
		h t
	end
end

def check_repo repo
	return false unless repo =~ /[a-zA-A_]+/
	return false unless File.directory? File.join($CONFIG[:repo_abspath], repo)
	$CONFIG[:repos].any? {|e| e[:name] == repo }
end

get '/repo/:repo/' do
	repo = params[:repo]
	halt 404 unless check_repo repo
	dir = File.join($CONFIG[:result_abspath], repo)
	@list = []
	Dir.foreach dir do |f|
		@list << f[0..-6] if f =~ /^[a-z0-9]{40}-\d+-[A-Z]+-\d+\.yaml$/
	end
	@list.map! {|e| r = e.split '-'; r[1] = r[1].to_i; r << e}.sort_by!{|e| e[1]}.reverse!
	@repo = repo
	erb :testlist
end

get '/repo/:repo/:tid' do
	repo = params[:repo]
	tid = params[:tid]
	halt 404 unless check_repo repo
	halt 404 unless tid =~ /^[a-z0-9]{40}-\d+-[A-Z]+-\d+$/
	file = File.join($CONFIG[:result_abspath], repo, tid+".yaml")
	halt 404 unless File.file? file
	@report = YAML.load File.read(file) rescue halt 404, 'fail to read file'
	@report[:ref] ||= ["UNKNOWN", ""]
	@report[:result] ||= []
	@report[:filter_commits] ||= []
	@ok = tid.include? "OK"
	@repo = repo
	erb :result
end

get '/about' do
	erb :about
end

get '/' do
	@repos = $CONFIG[:repos]
	erb :index, :locals => {}
end
