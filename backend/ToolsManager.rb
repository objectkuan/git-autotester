# encoding: utf-8

class ToolsManager
  _tools = YAML.load File.read($TOOLS_CONFIG)
  @@tools = {}
  _tools[:tools].map  { |tool| @@tools[tool[:name]] = tool }
  @@tools.select  { |name, tool| 
    parserPath = File.join($ROOT, tool[:result_parser]);
    puts parserPath
    require(parserPath) if FileTest::exist?(parserPath)
  }
    

  def ToolsManager.commandOf(tool)
    return nil unless @@tools.has_key?(tool)
    script = File.join($BASE, @@tools[tool][:path])
  end
  
end

