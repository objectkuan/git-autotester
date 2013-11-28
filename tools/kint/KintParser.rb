class ResultParser
  class << self
    def parse_kint(result, src_dir)
      spl_pat = /---/
      bug_pat = /bug: (.+)/
      file_pat = / - ([^:]+):([\d]+):([\d]+)/
      parsed_result = []
      index = {}
      item = {}
      if(src_dir[-1] != "/")
        src_dir = src_dir + "/"
      end
      
      result.each do |r|
        r = r.sub(src_dir, "")
        splm = spl_pat.match(r)
        if(splm)
          item = {
            :target => "Linux Kernel",
            :opensource => 1,
            :toolDescription => ""
          }
        end

        bugm = bug_pat.match(r)
        if(bugm)
          item[:bugType] = bugm[1]
        end
                
        filem = file_pat.match(r)
        if(filem)
          item[:file] = filem[1]
          item[:line] = filem[2]
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