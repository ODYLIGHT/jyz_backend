defmodule JyzBackendWeb.StringHandler do
    
  # 删除前缀，示例 输入 ("helloworld", "hello") 输出 ("world")
  def take_prefix(full, prefix) do  
    base = String.length(prefix)
    String.slice(full, base, String.length(full) - base)
  end  
  
end