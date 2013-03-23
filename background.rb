#!/usr/bin/env ruby
# encoding: utf-8

require 'yaml'
require 'grit'
require 'pp'
require 'logger'
require 'time'
require 'timeout'

ROOT= File.dirname(File.expand_path __FILE__)
CONFIG_FILE= File.join ROOT, "config.yaml"
puts CONFIG_FILE
LOGGER = Logger.new STDOUT
LOGGER_VERBOSE = Logger.new STDERR
$CONFIG = Hash.new

def md5sum fn
	md5 = `md5sum #{fn}`
	fail if $?.exitstatus != 0
	md5
end

def error info
	LOGGER.error info
end

def time_cmd(command,timeout)
	cmd_output = []
	LOGGER.info "Entering #{command} at #{Time.now}"
	pid = nil
	begin
		status = Timeout.timeout(timeout) do
			p = IO.popen(command, :err=>[:child, :out])
			pid = $?.pid
			#puts "pid: #{$$}"
			p.each_line {|g| cmd_output << g.chomp }
			$?
		end
		return {:timeout =>false, :status =>status.exitstatus, :output => cmd_output}
	rescue Timeout::Error
		LOGGER.error "#{command} pid #{pid} timeout at #{Time.now}"
		Process.kill 9, pid if pid rescue nil
		return {:timeout =>true, :status => 254, :output => cmd_output}
	rescue Errno
		LOGGER.error "#{command} failed"
		return {:timeout =>false, :status => 255, :output=> ["ERRNO"]}
    	end
end

class Grit::Actor
	def simplify
		"#{@name} <#{@email}>"
	end
end

class Grit::Commit
	def simplify
		{:id => id, :author => author.simplify,
		 :committer => committer.simplify, 
		 :authored_date => authored_date.to_s,
		 :committed_date => committed_date.to_s,
		 :message => message.split.first
		}
	end
end

class CommitFilter
	class << self
		def method_missing(name, *args)
			LOGGER.error "filter not found #{name}"
			args.first
		end

		def ext(extlist, commits)
			commits.select do |c|
				# f => ["test.c", 1, 0 ,1]
				(c.parents.count > 1)  \
				  || (c.stats.files.any? { |f| extlist.include? File.extname(f.first) })
			end
		end
	end
end

class TestGroup
	attr_reader :phrases, :result
	def initialize
		@phrases = Array.new
		@result = Array.new
	end

	def push(phrase)
		@phrases << phrase
	end

	def run_all
		@result = Array.new
		@phrases.each do |p|
			LOGGER.info "Running #{p.name}"
			st = Time.now
			#run it
			res = p.run
			time = Time.now - st
			@result << {:name => p.name, :time => time, :result => res}
		end
		@result
	end

	class TestPhrase
		attr_accessor :name, :cmd, :timeout
		attr_reader :result
		def initialize(_name, _cmd, _timeout=10)
			@name = _name
			@cmd = _cmd
			@timeout = _timeout
		end

		def run
			@result = time_cmd @cmd, @timeout
		end
	end

end

class CompileRepo
	attr_reader :repo, :name, :url, :blacklist

	def initialize config

		@name = config[:name]
		fail "REPO name is null" if @name.nil?
		@url = config[:url]
		@blacklist = config[:blacklist] || []
		@build_timeout_s = config[:build_timeout_min] * 60 || 60
		@run_timeout_s = config[:run_timeout_min] * 60 || 60
		@filters = config[:filters] || []
		@result_dir = File.join $CONFIG[:result_abspath], @name
		
		@runner = TestGroup.new
		@runner.push(TestGroup::TestPhrase.new "AutoBuild", './autobuild.sh', @build_timeout_s)
		@runner.push(TestGroup::TestPhrase.new "AutoTest", './autotest.sh', @run_timeout_s)

		begin
			@repo = Grit::Repo.new config[:name]
		rescue Grit::NoSuchPathError
			LOGGER.info  "Cloning #{@name}"
			`git clone "#{@url}" "#{@name}"`
			fail "Fail to clone #{@url}" if $?.exitstatus != 0
			@repo = Grit::Repo.new config[:name]
		end
		LOGGER.info "Repo #{@name} ready!"
		@repo.remotes.each { |r| puts "  #{r.name} #{r.commit.id}" }
	end

	def run_test_for_commits(ref, new_commits)

		LOGGER.info "Repo #{@name} :OK, let's test branch #{ref.name}:#{ref.commit.id}"

		#now begin test
		result = @runner.run_all
		pp result
		commits_info = new_commits.map {|c| c.to_hash }

	end

	def start_test
		#we are in repo dir
		origin = @repo.remote_list.first
		return unless origin
		LOGGER_VERBOSE.info "fetching #{@name}"

		begin
			@repo.remote_fetch origin
		rescue Grit::Git::GitTimeout
			LOGGER.error "fetch #{@name} timeout"
			return
		end

		last_test_file = File.join @result_dir, ".list"
		compiled_file = File.join @result_dir, ".compiled"

		last_test_list = Hash[File.readlines(last_test_file).map {|line| line.chomp.split(/\s/,2)}] rescue Hash.new
		compiled_list = File.readlines(compiled_file).map{|line| line.chomp} rescue []

		new_compiled_list = []
		@repo.remotes.each do |ref|
			next if ref.name =~ /.+\/HEAD/
			next if @blacklist.include? ref.name

			next if compiled_list.include? ref.commit.id

			commitid = ref.commit.id

			begin
				#force checkout here
				@repo.git.checkout( {:f=>true}, commitid)
			rescue Grit::Git::CommandFailed
				error "Fail to checkout #{commitid}"
				next
			end

			## extract commit info, max item 10
			last_test_commit = last_test_list[ref.name]

			if last_test_commit
				# old..new
				new_commits = @repo.commits_between last_test_commit, commitid
			else
				LOGGER.info "#{ref.name} new branch?"
				new_commits = @repo.commits commitid, 30
			end
			# if the branch has been reset after last test,
			# new_commits will be empty
			new_commits = [ref.commit] if new_commits.empty?

			puts "#{@name} before filters:"
			new_commits.each {|c| puts "  #{c.id}" }

			#apply filters
			@filters.each { |f| new_commits = CommitFilter.__send__(*f, new_commits) }

			puts "#{@name} after filters:"
			new_commits.each {|c| puts "  #{c.id}" }

			LOGGER.info "too many commits, maybe new branch or rebased" if new_commits.length > 10

			if new_commits.empty?
				LOGGER.info "#{@name}:#{ref.name}:#{commitid} introduced no new commits after fiters, skip build"
			else
				run_test_for_commits ref, new_commits
			end

			# mark it
			new_compiled_list |= [commitid]
			compiled_list << commitid
			last_test_list[ref.name] = commitid
		end

		File.open(last_test_file, "w") do |f|
			last_test_list.each {|k,v| f.puts "#{k} #{v}"}
		end
		File.open(compiled_file, "a") do |f|
			new_compiled_list.each {|e| f.puts e}
		end
	end

end

def create_all_repo
	LOGGER.info "Create or checkout all repos"
	repos = Hash.new
	$CONFIG[:repos].each do |r|
		begin
			repos[ r[:name] ] = CompileRepo.new r
		rescue
			error "#{r[:name]} not available, skip"
			next
		end
		report_dir = File.join $CONFIG[:result_abspath], r[:name]
		unless File.directory? report_dir
			`mkdir #{report_dir}`
			`mkdir #{File.join report_dir, 'compile'}`
			`mkdir #{File.join report_dir, 'running'}`
		end
	end
	repos
end

def startme
	old_config_md5 = nil
	repos = Hash.new
	loop do
		config_md5 = md5sum CONFIG_FILE
		if config_md5 != old_config_md5
			puts "Refresh config..."
			$CONFIG = YAML.load File.read(CONFIG_FILE)
			old_config_md5 = config_md5
			Dir.chdir $CONFIG[:repo_abspath]
			repos = create_all_repo
		end
		repos.each do |k,v|
			#chdir first
			Dir.chdir File.join($CONFIG[:repo_abspath], k)
			v.start_test
			Dir.chdir $CONFIG[:repo_abspath]
		end
		sleep 5
	end
end

if __FILE__ == $0
	startme
end

