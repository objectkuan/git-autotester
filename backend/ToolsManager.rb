# encoding: utf-8

class ToolsManager
  @@tools = ["sparse", "trinity"]
  @@toolPaths = {
    'sparse' => 'tools/sparse/sparse.sh', 
    'trinity' => 'tools/trinity/trinity.sh'
  }
    
  def ToolsManager.commandOf(tool)
    return nil unless @@toolPaths.has_key?(tool)
    script = File.join($BASE, @@toolPaths[tool])
  end
end

