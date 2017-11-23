defmodule JyzBackend.DateTimeHandler do
    
  # 删除前缀，示例 输入 ("helloworld", "hello") 输出 ("world")
  def getDateTime() do 
    {{year, month, day}, {hour, minute, second}} = :calendar.local_time()
    "#{year}-#{month}-#{day} #{getHms(hour)}:#{getHms(minute)}:#{getHms(second)}"

  end  

  defp getHms(hms) do
    hms = Integer.to_string(hms)
    cond  do
      String.length(hms) == 1 -> "0" <> hms
      String.length(hms) == 2 -> hms
      true -> "00"
    end
  end


  
end