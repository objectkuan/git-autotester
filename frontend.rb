#!/usr/bin/env ruby
# encoding: utf-8

require 'sinatra'
require 'grit'
require 'yaml'
require 'pp'
require 'socket'
require 'timeout'

YAML::ENGINE.yamler='syck'
ROOT= File.dirname(File.expand_path __FILE__)
CONFIG_FILE= File.join ROOT, "config.yaml"
$CONFIG=YAML.load File.read(CONFIG_FILE)
pp $CONFIG

set :public_folder, File.dirname(__FILE__) + '/views'
set :bind, $CONFIG[:bind] || '0.0.0.0'
set :port, $CONFIG[:port] || 4567

$formats = {
  /(\[ *PASS *\])/ => '<span class="line-ok">\1</span>',
  /(\[ *! *PASS *! *\])/ => '<span class="line-warning">\1</span>',
  /(\[ *FAIL *\])/ => '<span class="line-warning">\1</span>',
  /(\[ *! *FAIL *! *\])/ => '<span class="line-error">\1</span>',
  /(\[ *!? *BROKEN *!? *\])/ => '<span class="line-error">\1</span>',
}

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
		t = h line.chomp
		$formats.each do |p, s|
			return t.gsub(p, s) if t =~ p
		end
		t
	end
	def format(section, repo, tid, result)
		text = ""
		formatter_output = ""

		cwd = Dir.getwd
		# FIXME: Hardcoded repo abspath
		repo_abspath = cwd + "/../../linux-xyj/linux-test"
		result_abspath = repo_abspath + "/result"
		Dir.chdir File.join(repo_abspath, repo)

		if File.executable_real? "formatter.py"
			command = "./formatter.py " + section + " " + result_abspath + " " + repo + " " + tid
			result.each do |line|
				text << line + "\n"
			end
			begin
				pipe = IO.popen("#{command}", mode="r+")
			rescue Exception => e
				return text
			end
			pipe.write text
			pipe.close_write
			formatter_output = pipe.read
			Process.waitpid2(pipe.pid)
		else
			result.each do |line|
				formatter_output << ol(line) + "<br>"
			end
		end
		Dir.chdir cwd
		return formatter_output
	end
end

class ReportCache
	@@cache = Hash.new

	class << self

		def check_repo(repo)
			return false unless repo =~ /[a-zA-A_]+/
			$CONFIG[:repos].any? {|e| e[:name] == repo }
		end

		def [](repo)
			@@cache[repo]
		end

		def check_and_update(repo)
			return nil unless check_repo repo
			unless File.directory? File.join($CONFIG[:result_abspath], repo)
				@@cache.delete repo
				return nil
			end

			@@cache[repo] = Hash.new
			fs = Hash.new

			dir = File.join($CONFIG[:result_abspath], repo)
			Dir.foreach dir do |f|
				fs[f[0..-6]] = :f if f =~ /^[a-z0-9]{40}-\d+-[A-Z]+-\d+\.yaml$/
			end
			@@cache[repo].delete_if { |k,v| fs[k].nil? }
			fs.each do |k,v|
				next if @@cache[repo][k]
				file = File.join($CONFIG[:result_abspath], repo, k+".yaml")
				report = YAML.load File.read(file) rescue nil
				next unless report
				report[:ok] ||= k.include?("OK") ? "OK" : "FAIL"
				report[:timestamp] ||= k.split('-')[1].to_i
				report[:ref] ||= ["UNKNOWN", ""]
				report[:result] ||= []
				report[:filter_commits] ||= []
				report[:tid] = k
				report[:head] ||= k.split('-')[0]

				@@cache[repo][k] = report
			end
			@@cache[repo]
		end
	end

	private
	def initialize
	end
end

get '/repo/:repo/' do
	repo = params[:repo]
	halt 404 unless ReportCache.check_and_update repo
	cache = ReportCache[repo]
	halt 404 if cache.nil?
	@list = cache.sort_by {|k,v| v[:timestamp]}.reverse.map{|e| e[1]}
	@repo = repo
	erb :testlist
end

get '/repo/:repo/:tid' do
	repo = params[:repo]
	tid = params[:tid]
	halt 404 unless ReportCache.check_repo repo
	cache = ReportCache[repo]
	halt 404 if cache.nil?
	@report = cache[tid]
	halt 404 if @report.nil?
	@repo = repo
	@tid = tid
	erb :result
end

get '/repo/:repo/:commit/:arch/:testcase' do
	repo = params[:repo]
	commit = params[:commit]
	arch = params[:arch]
	testcase = params[:testcase]
	filepath = File.join(Dir.getwd, "..", "result", repo, commit, arch, testcase + ".error")
	@error = File.read(filepath).gsub(/\n/, '<br>') rescue "Error logs not found!"
	erb :error
end

get '/about' do
	erb :about
end

get '/' do
	@status_line = []
	begin
		Timeout.timeout(2) do
			s = TCPSocket.open($CONFIG[:ping][:frontend_addr], $CONFIG[:ping][:port]) 
			while l = s.gets 
				@status_line << l.chomp
			end
			s.close
		end
	rescue Timeout::Error
		@status_line << "ERROR: Timeout to connect to backend!"
	rescue StandardError => e
		@status_line << "ERROR: Failed to connect to backend!"
	end
	@env = File.read(File.join(ROOT, "env.txt")) rescue "Unknown"

	@repos = $CONFIG[:repos]
	erb :index, :locals => {}
end

