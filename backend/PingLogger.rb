# encoding: utf-8

class PingLogger < Logger
  attr_reader :lastping
  def initialize(io, len = 20)
    super io
    @buffer = Array.new
    @lastping = Time.new
    @len = len
    @server = nil

    info "Hello from Tester backend!"
    info "Start now..."
  end

  def newline(line)
    @buffer.shift if @buffer.count >= @len
    @buffer << line
    ping
  end

  def ping
    @lastping = Time.now
  end

  def info t
    newline "INFO #{Time.now} #{t}"
    super t
  end

  def error t
    newline "ERROR #{Time.now} #{t}"
    super t
  end

  def fatal t
    newline "FATAL #{Time.now} #{t}"
    super t
  end

  def server_loop addr, port
    return if @server
    puts "Logger server start @ #{port}"
    @server = TCPServer.new(addr, port)
    loop do
      begin
        client = @server.accept
        client.puts "Last ping: #{@lastping} (#{(Time.now-@lastping).datetime_duration} ago)"
        @buffer.each { |l| client.puts l}
        client.close
      rescue StandardError => e
        puts "TCPServer error: #{e.message}"
        next
      end
    end
  end

end
