# encoding: utf-8

require "./backend/TestGroup.rb"
require "./backend/CommitFilter.rb"
require "./backend/GritHelper.rb"
require "./backend/ToolsManager.rb"

class CompileRepo
  attr_reader :repo, :name, :remote_url, :timeouts
  attr_reader :source_dir, :result_dir
  attr_reader :tool, :timeout
  @@result_abspath
  @@source_abspath

  def CompileRepo.result_abspath=(dir)
    @@result_abspath = dir
  end
  def CompileRepo.source_abspath=(dir)
    @@source_abspath = dir
  end
  def CompileRepo.result_abspath
    @@result_abspath
  end
  def CompileRepo.source_abspath
    @@source_abspath
  end
  
  def initialize config
    @name = config[:name]
    fail "REPO name is null" if @name.nil?
    
    @remote_url = config[:remote_url]
    @filters = config[:filters] || []
    @result_dir = File.join @@result_abspath, @name
    @tool = config[:tool]
    @timeout = config[:timeout_min]

    @runner = TestGroup.new
    @runner.push(TestGroup::TestPhrase.new @tool, ToolsManager.commandOf(@tool), @timeout)

    begin
      @repo = Grit::Repo.new config[:name]
    rescue Grit::NoSuchPathError
      LOGGER.info  "Cloning #{@name}"
      `git clone "#{@remote_url}" "#{@name}"`
      fail "Fail to clone #{@remote_url}" if $?.exitstatus != 0
      @repo = Grit::Repo.new config[:name]
    end
    LOGGER.info "Repo #{@name} ready!"
    @repo.remotes.each { |r| puts " #{r.name} #{r.commit.id}" }
  end

  def run_test_for_commits(ref, new_commits)

    LOGGER.info "Repo #{@name}: OK, let's test branch #{ref.name}:#{ref.commit.id}"

    # Now begin testing
    failed, result = @runner.run_all
    ok = failed ? "FAIL" : "OK"

    # Replace all the invalid UTF-8 bytes
    result.each { |r|
      newresult = []
      r[:result][:output].map { |line| newresult << line.encode("UTF-8", 'binary', :invalid => :replace, :undef => :replace, :replace => '') }
      r[:result][:output] = newresult
    }
    # Remove the color descriptors in the output 
    result.each { |r|
      r[:result][:output].map { |line| line.gsub(/(\[\d+(;\d+)*m)/, '') }
    }
    
    # Writes out the report
    commits_info = new_commits.map {|c| c.simplify } # We can use c.to_hash
    report = {:ref => [ref.name, ref.commit.id], :filter_commits => commits_info, :ok => ok, :result => result, :timestamp => Time.now.to_i }
    report_name = File.join @result_dir, "#{ref.commit.id}-#{Time.now.to_i}-#{ok}-#{$$}.yaml"
    File.open(report_name, "w") do |io|
      YAML.dump report, io
    end

    LOGGER.info "Repo #{@name}: Test done"

  end

  
  def start_test
    # We are in repo dir
    origin = @repo.remote_list.first
    return unless origin
    # LOGGER_VERBOSE.info "fetching #{@name}"

    begin
      @repo.remote_fetch origin
    rescue Grit::Git::GitTimeout => e
      LOGGER.error "fetch #{@name} timeout: #{e}"
      return
    end

    last_test_file = File.join @result_dir, ".list"
    compiled_file = File.join @result_dir, ".compiled"

    last_test_list = Hash[File.readlines(last_test_file).map {|line| line.chomp.split(/\s/,2)}] rescue Hash.new
    compiled_list = File.readlines(compiled_file).map{|line| line.chomp} rescue []

    new_compiled_list = []
    test_refs = @repo.remotes
    test_refs.each do |ref|
      next if ref.name =~ /.+\/HEAD/
      next if compiled_list.include? ref.commit.id

      commitid = ref.commit.id

      begin
        #  Force checkout here
        LOGGER.info "Checkout #{@name} #{ref.name}:#{commitid}"
        @repo.git.checkout( {:f=>true}, commitid)
      rescue Grit::Git::CommandFailed
        error "Fail to checkout #{commitid}"
        next
      end

      ## extract commit info, max item 10
      last_test_commit = last_test_list[ref.name]

      if last_test_commit
        # old..new
        new_commits = @repo.commits_between(last_test_commit, commitid).reverse
      else
        LOGGER.info "#{ref.name} new branch?"
        new_commits = @repo.commits commitid, 30
      end
      # if the branch has been reset after last test,
      # new_commits will be empty
      new_commits = [ref.commit] if new_commits.empty?

      #puts "#{@name} before filters:"
      #new_commits.each {|c| puts "  #{c.id}" }

      #apply filters
      @filters.each {
        |f| new_commits = CommitFilter.__send__(*f, new_commits)
      }

      #puts "#{@name} after filters:"
      #new_commits.each {|c| puts " #{c.id}" }

      # LOGGER.info "too many commits, maybe new branch or rebased" if new_commits.length > 10

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