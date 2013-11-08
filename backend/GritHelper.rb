# encoding: utf-8

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
     :message => message.split("\n").first
    }
  end
end
