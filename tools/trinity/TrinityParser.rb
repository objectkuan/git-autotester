class ResultParser
  class << self
    def parse_trinity(result, src_dir)
      begin_b_pat = /\[[^\]]*\]\sBUG:\s.*/
      begin_w_pat = /\[[^\]]*\]\sWARNING:\s.*/
      end_pat = /\[\send\strace\s.*\s\]/
      
      beginning = false
      title = ""
    
      parsed_result = []
      index = {}
      item = {}
      
      result.each do |r|
        endm = end_pat.match(r)
        if(endm)
          parsed_result.push(item)
          beginning = false
        end
        
        if(beginning)
          item[:toolDescription] = item[:toolDescription] + r
          item[:toolDescription] = item[:toolDescription] + "\n"
        end
    
        beginm = begin_b_pat.match(r)
        if(beginm)
          beginning = true
          item = {
            :file => "",
            :line => "",
            :target => "Linux Kernel",
            :opensource => 1,
            :toolDescription => r,
            :title => "Bug from Trinity",
            :bugType => ""
          }
        end
        beginm = begin_w_pat.match(r)
        if(beginm)
          beginning = true
          item = {
            :file => "",
            :line => "",
            :target => "Linux Kernel",
            :opensource => 1,
            :toolDescription => r,
            :title => "Warning from Trinity",
            :bugType => ""
          }
        end
        
      end
      parsed_result
    end
  end
end