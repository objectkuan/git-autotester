#!/usr/bin/env ruby
# encoding: utf-8
require 'rubygems'    
require 'active_record'    
require 'yaml' 

dbconfig = YAML::load(File.open('database.yaml'))
puts dbconfig[:database]
ActiveRecord::Base.establish_connection(dbconfig[:database])

puts ActiveRecord::Base.connection.tables

class Bug < ActiveRecord::Base
  self.table_name = "buglist"
end


puts Bug.count

Bug.create(:title => 'Luc Juggery', :commitId => "Nashville, Tenessee", :submitter => '')  
Bug.create(:title => 'Sunil Kelkar', :commitId => "Pune, India", :submitter => '')  
Bug.create(:title => 'Adam Smith', :commitId => "San Fransisco, USA", :submitter => '')  

puts Bug.count
Bug.first.destroy
puts Bug.count
Bug.first.destroy
puts Bug.count
Bug.first.destroy
puts Bug.count