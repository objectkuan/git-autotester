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


$ROOT= File.dirname(File.expand_path(__FILE__))
$CONFIG_FILE= File.join $ROOT, "config.yaml"
$TOOLS_CONFIG= File.join $ROOT, "tools.yaml"

$LOAD_PATH.unshift(File.dirname(__FILE__))
require "backend/PingLogger"
require "backend/CompileRepo"


# quick fix to get correct string encoding
YAML::ENGINE.yamler='syck'

$CONFIG = Hash.new
$BASE = File.dirname(__FILE__)

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

###
# Create all the repositories 
###
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
		
		# Find the result dir
		`mkdir -p #{CompileRepo.result_abspath}` unless File.directory? CompileRepo.result_abspath
		`mkdir -p #{repos[ r[:name] ].result_dir}` unless File.directory? repos[ r[:name] ].result_dir
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
		config_md5 = md5sum $CONFIG_FILE
		if config_md5 != old_config_md5
		  # Load Config
			puts "============================"
			puts "Loading config..."
			puts "============================"
			$CONFIG = YAML.load File.read($CONFIG_FILE)
			old_config_md5 = config_md5
			
			# Connect to database
      BugHelper::connectToDB
			
			# Create the Repo Absolute Path and Result Path
      CompileRepo.source_abspath = $CONFIG[:source_abspath]
      CompileRepo.result_abspath = $CONFIG[:result_abspath]
			`mkdir -p #{CompileRepo.source_abspath}` unless File.directory? CompileRepo.source_abspath
      `mkdir -p #{CompileRepo.result_abspath}` unless File.directory? CompileRepo.result_abspath
			
      # Create Repos
			Dir.chdir CompileRepo.source_abspath
			repos = create_all_repo
			
			# Set Grit limit
			Grit::Git.git_timeout = $CONFIG[:git_timeout] || 10
      Grit::Git.git_max_size = $CONFIG[:git_max_size] || 100000000
        
      # Start server
			start_logger_server
		end
		
		repos.each do |k,v|
			#chdir first
			Dir.chdir File.join(CompileRepo.source_abspath, k)
			v.start_test
			Dir.chdir CompileRepo.source_abspath
		end
		
		sleep ($CONFIG[:sleep] || 30)
		LOGGER.ping
	end
end

if __FILE__ == $0
	startme
end

