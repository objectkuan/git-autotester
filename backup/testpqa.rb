#!/usr/bin/env ruby
# encoding: utf-8
result = [
"[child0:3280] [177] inotify_init\255[0m(\255[0m) \255[1;32m= 90\255[0m",
"[child0:3280] [178] ioperm\255[0m(from=\255[1;36m0x80000\255[0m\255[0m, num=\255[1;36m0x586e8863\255[0m\255[0m, turn_on=\255[1;36m0x8d000051\255[0m\255[0m) \255[1;31m= -1 (Invalid argument)\255[0m",
"[child0:3280] [179] getuid16\255[0m(\255[0m) \255[1;32m= 1000\255[0m",
"[child0:3280] [180] perf_event_open\255[0m(attr_uptr=\255[1;36m0x88bb000\255[0m[page_rand]\255[0m, pid=\255[1;36m\255[0m0\255[0m, cpu=\255[1;36m0\255[0m\255[0m, group_fd=\255[1;36m\255[0m435\255[0m, flags=\255[1;36m0x80ff6868\255[0m\255[0m) \255[1;31m= -1 (Invalid argument)\255[0m",
"[child0:3280] [181] finit_module\255[0m(fd=\255[1;36m\255[0m80\255[0m, uargs=\255[0m0\255[0m\255[0m, flags=\255[1;36m2\255[0m\255[0m) \255[1;31m= -1 (Operation not permitted)\255[0m"
]

puts result 
newresult = []
result.collect { |line|
  newresult << line.encode("UTF-8", 'binary', :invalid => :replace, :undef => :replace, :replace => '')
}

newresult.map { 
  |line| line.gsub(/(\[\d+(;\d+)*m)/, '')
}
# '=========================='
  
puts newresult