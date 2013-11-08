# encoding: utf-8

def time_cmd(command,timeout)
  cmd_output = []
  LOGGER.info "Entering #{command} at #{Time.now}"
  begin
    pipe = IO.popen("#{command} 2>&1")
  rescue Exception => e
    LOGGER.error "#{command} failed"
    return {:timeout =>false, :status => 255, :output=> [e.to_s]}
  end

  begin
    status = Timeout.timeout(timeout) do
      #puts "pid: #{$$}"
      pipe.each_line {|g| cmd_output << g.chomp }
      #return [child pid, status]
      Process.waitpid2(pipe.pid)
    end
    return {:timeout =>false, :status =>status[1].exitstatus, :output => cmd_output, :pid => pipe.pid}
  rescue Timeout::Error
    LOGGER.error "#{command} pid #{pipe.pid} timeout at #{Time.now}" rescue nil
    Process.kill 9, pipe.pid if pipe.pid rescue nil
    return {:timeout =>true, :status => 254, :output => cmd_output}
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
    failed = false
    @phrases.each do |p|
      LOGGER.info "Running #{p.name}"
      st = Time.now
      #run it
      res = p.run
      time = Time.now - st
      @result << {:name => p.name, :time => time, :result => res}
      ## IMPORTANT
      if res[:status] != 0
        failed = true
        break
      end
    end
    [failed, @result]
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
