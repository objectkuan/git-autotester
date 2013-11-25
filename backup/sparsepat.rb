#!/usr/bin/env ruby
# encoding: utf-8
pat_sparse = /([^:]+):([\d]+):([\d]+):\s(warning|error):\s(.+)/
str = "arch/x86/boot/compressed/../cmdline.c:30:5: warning: symbol '__cmdline_find_option' was not declared. Should it be static?"

match = pat_sparse.match(str)

puts match[0]
puts match[1]
puts match[2]
puts match[3]
puts match[4]
puts match[5]