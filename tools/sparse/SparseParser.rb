class ResultParser
  class << self
    def parse_sparse(result, src_dir)
      pat_sparse = /([^:]+):([\d]+):([\d]+):\s(warning|error):\s(.+)/
      parsed_result = []
      index = {}
      result.each do |r|
        if(src_dir[-1] != "/")
          src_dir = src_dir + "/"
        end
        r = r.sub(src_dir, "")
        match = pat_sparse.match(r)
        if(match)
          item = {
            :file => match[1],
            :line => match[2],
            :toolDescription => match[4] + ": " + match[5],
            :target => "Linux Kernel",
            :opensource => 1,
            :bugType => ""
          }
          item[:title] = item[:file].split("/")[-1] + ":" + item[:line]
            
          # Remove duplicated
          if(index[item[:file]] == nil)
            index[item[:file]] = {}
          end
          if(index[item[:file]][item[:line]] == nil)
            index[item[:file]][item[:line]] = {}
          end
          if(index[item[:file]][item[:line]][item[:toolDescription]] == nil)
            index[item[:file]][item[:line]][item[:toolDescription]] = 1
            parsed_result.push(item)
          end

        end
      end
      parsed_result
    end
  end
end