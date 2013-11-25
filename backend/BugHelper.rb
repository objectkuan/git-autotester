# encoding: utf-8

require 'rubygems'    
require 'active_record'   

class BugHelper
  def BugHelper.connectToDB
    ActiveRecord::Base.establish_connection($CONFIG[:database])
  end
  class Bug < ActiveRecord::Base
    self.table_name = "buglist"
  end
end