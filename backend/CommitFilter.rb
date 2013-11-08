# encoding: utf-8

class CommitFilter
  class << self
    def method_missing(name, *args)
      LOGGER.error "filter not found #{name}"
      args.first
    end

    def ext(extlist, commits)
      commits.select do |c|
        # f => ["test.c", 1, 0 ,1]
        (c.parents.count > 1)  \
          || 
        (
          stats = c.stats
          files = stats.files
          files.any? { 
            |f| extlist.include? File.extname(f.first) 
          }
        )
      end
    end
  end
end
