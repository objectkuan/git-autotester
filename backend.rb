#!/usr/bin/env ruby
# encoding: utf-8

require 'yaml'
require 'grit'
require 'pp'
require 'logger'
require 'time'
require 'timeout'
require 'socket'
require 'mail'

require "./backend/PingLogger.rb"
require "./backend/CompileRepo.rb"


ROOT= File.dirname(File.expand_path __FILE__)
CONFIG_FILE= File.join ROOT, "config.yaml"
puts CONFIG_FILE

# quick fix to get correct string encoding
YAML::ENGINE.yamler='syck'

$CONFIG = Hash.new

LOGGER_VERBOSE = Logger.new STDERR
LOGGER = PingLogger.new STDOUT

def error info
  LOGGER.error info
end

def md5sum fn
	md5 = `md5sum #{fn}`
	fail if $?.exitstatus != 0
	md5
end

def create_all_repo
	LOGGER.info "Create or checkout all repos"
	repos = Hash.new
	$CONFIG[:repos].each do |r|
		begin
			repos[ r[:name] ] = CompileRepo.new r
		rescue StandardError => e
			error "#{r[:name]} #{e} not available, skip"
			puts e.backtrace
			next
		end
		unless File.directory? $CONFIG[:result_abspath]
		  `mkdir -p #{$CONFIG[:result_abspath]}`
		end
		report_dir = File.join $CONFIG[:result_abspath], r[:name]
		unless File.directory? report_dir
			`mkdir -p #{report_dir}`
			#`mkdir #{File.join report_dir, 'compile'}`
			#`mkdir #{File.join report_dir, 'running'}`
		end
	end
	repos
end

def start_logger_server
	Thread.start do
		LOGGER.server_loop $CONFIG[:ping][:backend_addr], $CONFIG[:ping][:port]
	end
end

def startme
	old_config_md5 = nil
	repos = Hash.new
	loop do
		config_md5 = md5sum CONFIG_FILE
		if config_md5 != old_config_md5
			puts "============================"
			puts "Loading config..."
			puts "============================"
			$CONFIG = YAML.load File.read(CONFIG_FILE)
			old_config_md5 = config_md5
			unless File.directory? $CONFIG[:repo_abspath]
			  `mkdir -p #{$CONFIG[:repo_abspath]}`
			end
			CompileRepo.result_abspath = $CONFIG[:result_abspath]
			Dir.chdir $CONFIG[:repo_abspath]
			repos = create_all_repo
			Grit::Git.git_timeout = $CONFIG[:git_timeout] || 10
      Grit::Git.git_max_size = $CONFIG[:git_max_size] || 100000000
			start_logger_server
		end
		repos.each do |k,v|
			#chdir first
			Dir.chdir File.join($CONFIG[:repo_abspath], k)
			v.start_test
			Dir.chdir $CONFIG[:repo_abspath]
		end
		sleep ($CONFIG[:sleep] || 30)
		LOGGER.ping
	end
end

if __FILE__ == $0
	startme
end

