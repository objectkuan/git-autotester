class ResultParser
  class << self
    def parse_trinity(result, src_dir)
      begin_pat = /\[trinityTest\]\sResult:/
      end_pat = /qemu\spid\sto\skill/
      beginning = false
      done = false

      parsed_result = []
      index = {}
      item = {
        :file => "",
        :line => "",
        :target => "Linux Kernel",
        :opensource => 1,
        :toolDescription => "",
        :title => "TrinityTest",
        :bugType => ""
      }
      
      result.each do |r|
        endm = end_pat.match(r)
        if(endm)
          parsed_result.push(item)
          break
        end
        
        if(beginning)
          item[:toolDescription] = item[:toolDescription] + r
          item[:toolDescription] = item[:toolDescription] + "\n"
        end
        
        beginm = begin_pat.match(r)
        if(beginm)
          beginning = true
        end
      end
      parsed_result
    end
  end
end