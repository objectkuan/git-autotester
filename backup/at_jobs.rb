#!/usr/bin/env ruby
# encoding: utf-8

require 'mail'
require 'logger'
require 'time'
require 'yaml'
require 'grit'
require 'clockwork'
require 'pp'

ROOT= File.dirname(File.expand_path __FILE__)
CONFIG_FILE= File.join ROOT, "config.yaml"
puts CONFIG_FILE

# quick fix to get correct string encoding
YAML::ENGINE.yamler='syck'
LOGGER = Logger.new STDERR

$CONFIG_FILE = YAML.load File.read(CONFIG_FILE)
pp $CONFIG_FILE

fail "No jobs" unless $CONFIG_FILE[:jobs]

class Jobs
	class << self
		def daily_report
			return unless $CONFIG_FILE[:mail]
			_to = $CONFIG_FILE[:mail][:daily_to]
			return unless _to
			$CONFIG_FILE[:repos].each do |r|
				next if r[:nomail]
				dir = File.join $CONFIG_FILE[:result_abspath], r[:name] 
				next unless File.directory? dir
				today_list = Array.new
				Dir.foreach dir do |f|
					if f =~ /^([a-z0-9]{40}-\d+-[A-Z]+-\d+)\.yaml$/
						fn = $1
						today_list << fn if Time.now.to_i - fn.split('-')[1].to_i < 1.day
					end
				end
				#pp today_list
				b = Array.new
				dm = $CONFIG_FILE[:domain_name] || "localhost"
				b << "Hi! Daily report for repo #{r[:name]}"
				b << "Here is a report from autotest system, please visit: http://#{dm}"
				b << "#{Time.now}"
				b << "====================="
				b << ">>> git clone #{r[:url]}\n"
				today_list.map {|e| e.split('-')}.sort_by{|e| e[1].to_i}.each do |e|
					b << "#{e[0]}\t#{e[2]}\t#{Time.at(e[1].to_i)}"
				end
				b << "====================="
				b << "Git autobuild system"
				mail = Mail.new do
					from $CONFIG_FILE[:mail][:from]
					to   _to
					subject "[autotest][daily] #{r[:name]}"
					body b.join("\n")
				end
				puts mail.to_s
				LOGGER.info "Send daily report to #{_to}"
				mail.deliver!	
			end
		end

		def method_missing(m, *args, &block)
			LOGGER.error "undefined job: #{m}"
		end
	end
end

class AutoMerger
	def self.merge(params)
		Grit::Git.git_timeout = $CONFIG_FILE[:git_timeout] || 10
		fail "url empty" if params[:url].nil?
		repo = Grit::Repo.new params[:url]
		url = params[:url]
		upstream = params[:upstream] || "origin/master"
		repo.git.checkout({:f=>true, :chdir=>url}, upstream)
		repo.git.reset({:hard=>true, :chdir=>url}, "HEAD")
		repo.remote_list.each do |r|
			5.times do
				begin
					LOGGER.info "fetching #{r}"
					repo.remote_fetch r
					break
				rescue Grit::Git::GitTimeout => e
					LOGGER.error "timeout #{params[:url]}"
					sleep 30
				end
			end
		end
		branchname = "automerge-#{DateTime.now}".tr ":+", "-"
		ret = repo.git.checkout({:b=>branchname, :chdir=>url}, upstream)
		fail "create branch #{branchname}" if repo.head.name != branchname
		merged_branches = []
		merged_branches << upstream
		params[:branches].each do |b|
			puts "merging #{b}"
			exitstatus, out, err = repo.git.merge({:process_info=>true, :chdir=>url, :no_ff=>true, :m=>"#{merged_branches.join(' ')} #{b}"}, b)
			puts out, err
			if exitstatus == 0
				merged_branches << b
			else
				repo.git.merge({:abort => true, :chdir=>url})
			end
		end
		LOGGER.info "Merge #{params[:url]} #{merged_branches.join(' ')} to #{branchname}"
	end
end

module Clockwork
	handler do |job|
		puts "Running #{job}"
		begin
			Jobs.__send__ job.to_sym
		rescue StandardError => e
			LOGGER.error e
		end
	end

	if $CONFIG_FILE[:jobs][:daily_report]
		$CONFIG_FILE[:jobs][:daily_report].each do |t|
			every(1.day, 'daily_report', :at => t)
		end
	end
	if $CONFIG_FILE[:jobs][:automerge]
		$CONFIG_FILE[:jobs][:automerge].each do |t|
			every(t[:hours].hour, 'automerge.do') do
				begin
					AutoMerger.merge t 
				rescue StandardError => e
					LOGGER.error "Fail to merge #{t[:url]}: #{e}"
				end
			end
		end
	end
end

#Jobs.daily_report
