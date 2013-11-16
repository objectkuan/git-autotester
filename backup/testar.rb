#!/usr/bin/env ruby
# encoding: utf-8
require 'rubygems'    
require 'active_record'    
require 'yaml' 

dbconfig = YAML::load(File.open('database.yaml'))
ActiveRecord::Base.establish_connection(dbconfig)

puts ActiveRecord::Base.connection.tables

class Bug < ActiveRecord::Base
  self.table_name = "bug"
end


puts Bug.count

Bug.create(:title => 'Luc Juggery', :commitId => "Nashville, Tenessee")  
Bug.create(:title => 'Sunil Kelkar', :commitId => "Pune, India")  
Bug.create(:title => 'Adam Smith', :commitId => "San Fransisco, USA")  

puts Bug.count
Bug.first.destroy
puts Bug.count
Bug.first.destroy
puts Bug.count
Bug.first.destroy
puts Bug.count