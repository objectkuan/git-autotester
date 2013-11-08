# encoding: utf-8

require "./backend/TestGroup.rb"
require "./backend/CommitFilter.rb"
require "./backend/GritHelper.rb"

class CompileRepo
  attr_reader :repo, :name, :url, :blacklist
  @@result_abspath
  
  def CompileRepo.result_abspath=(x)  
    @@result_abspath=x  
  end  
  
  def initialize config

    @name = config[:name]
    fail "REPO name is null" if @name.nil?
    @url = config[:url]
    @nomail = config[:nomail]
    @mode = config[:mode] || :normal

    @blacklist = config[:blacklist] || []
    #@blacklist.map! {|e| "origin/" + e}
    @blacklist.map! {|e| /#{e}/}
    @whitelist = config[:whitelist] || []
    @whitelist.map! {|e| /#{e}/}

    @build_timeout_s = (config[:build_timeout_min] || 1) * 60
    @run_timeout_s = (config[:run_timeout_min] || 1) * 60
    @filters = config[:filters] || []
    @result_dir = File.join @@result_abspath, @name

    @runner = TestGroup.new
    @runner.push(TestGroup::TestPhrase.new "AutoBuild", './build_sparse.sh', @build_timeout_s)
    # @runner.push(TestGroup::TestPhrase.new "AutoTest", './autotest.sh ' + @result_dir, @run_timeout_s)

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

    LOGGER.info "Repo #{@name}: OK, let's test branch #{ref.name}:#{ref.commit.id}"

    #now begin test
    failed, result = @runner.run_all
    ok = failed ? "FAIL" : "OK"
    ## we can use c.to_hash
    commits_info = new_commits.map {|c| c.simplify }

    report_name = File.join @result_dir, "#{ref.commit.id}-#{Time.now.to_i}-#{ok}-#{$$}.yaml"
    # replace all the invalid UTF-8 bytes
    result.each { |r|
      newresult = []
      r[:result][:output].map { |line| newresult << line.encode("UTF-8", 'binary', :invalid => :replace, :undef => :replace, :replace => '') }
      r[:result][:output] = newresult
    }
    # remove the color descriptors in the output 
    result.each { |r|
      r[:result][:output].map { |line| line.gsub(/(\[\d+(;\d+)*m)/, '') }
    }
    report = {:ref => [ref.name, ref.commit.id], :filter_commits => commits_info, :ok => ok, :result => result, :timestamp => Time.now.to_i }

      
    begin
      File.open(report_name, "w") do |io|
        YAML.dump report, io
      end
    rescue
      puts report
    end

    LOGGER.info "Repo #{@name}: Test done"

  end

  def white_black_list(refname)
    return @whitelist.any? {|r| refname =~ r} unless @whitelist.empty?
    !(@blacklist.any?{|r| refname =~ r})
  end

  def start_test
    #we are in repo dir
    origin = @repo.remote_list.first
    return unless origin
    #LOGGER_VERBOSE.info "fetching #{@name}"

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
      #next if @blacklist.include? ref.name
      next unless white_black_list ref.name

      next if compiled_list.include? ref.commit.id

      commitid = ref.commit.id

      begin
        #force checkout here
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

      puts "#{@name} before filters:"
      new_commits.each {|c| puts "  #{c.id}" }

      #apply filters
      @filters.each {
        |f| new_commits = CommitFilter.__send__(*f, new_commits)
      }

      puts "#{@name} after filters:"
      new_commits.each {|c| puts " #{c.id}" }

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