class ResultParser
  class << self
    def parse_blast(result, src_dir)
      begin_pat = /\*\*\*begin\*\*\*/
      end_pat = /\*\*\*end\*\*\*/

      filename_pat =   /ERROR:FILENAME:(.*)/
      rules_pat =      /ERROR:RULES:(.*)/
      rulesname_pat =  /ERROR:RULESNAME:(.*)/
      rulestitle_pat = /ERROR:RULESTITLE:(.*)/
      rulessum_pat =   /ERROR:RULESSUMMARY:(.*)/
      tracefile_pat =  /ERROR:TRACES:(.*)/

      beginning = false
      parsed_result = []
      item = {}
      if(src_dir[-1] != "/")
        src_dir = src_dir + "/"
      end
      
      rulesname = ""
      result.each do |r|
        r = r.sub(src_dir, "")

        endm = end_pat.match(r)
        if(endm)
          item[:title] = item[:file].split("/")[-1] + ":" + rulesname
          parsed_result.push(item)
          beginning = false
        end

        if(beginning)
          m = filename_pat.match(r)
          if(m)
            item[:file] = m[1]
          end
          m = rules_pat.match(r)
          if(m)
            item[:toolDescription] = item[:toolDescription] + "BLAST Rule: "
            item[:toolDescription] = item[:toolDescription] + m[1]
          end
          m = rulesname_pat.match(r)
          if(m)
            item[:toolDescription] = item[:toolDescription] + "Rule Name: "
            item[:toolDescription] = item[:toolDescription] + m[1]
            rulesname = m[1]
          end
          m = rulestitle_pat.match(r)
          if(m)
            item[:toolDescription] = item[:toolDescription] + "Rule Title: "
            item[:toolDescription] = item[:toolDescription] + m[1]
          end
          m = rulessum_pat.match(r)
          if(m)
            item[:toolDescription] = item[:toolDescription] + "Rule Name: "
            item[:toolDescription] = item[:toolDescription] + m[1]
          end
          m = tracefile_pat.match(r)
          if(m)
            item[:toolDescription] = item[:toolDescription] + "Description: \n"
            item[:toolDescription] = item[:toolDescription] + `cat #{m[1]}`
          end
        end
                
        beginm = begin_pat.match(r)
        if(beginm)
          item = {
            :target => "Linux Kernel",
            :opensource => 1,
            :bugType => "",
            :toolDescription => ""
          }
          beginning = true
        end
                
        
      end
      parsed_result
    end
  end
end