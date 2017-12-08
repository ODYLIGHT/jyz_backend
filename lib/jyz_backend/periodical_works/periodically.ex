defmodule JyzBackend.Periodically do
  use GenServer
  
  def start_link do
    GenServer.start_link(__MODULE__, %{})
  end
  
  def init(state) do
    schedule_work() # Schedule work to be performed at some point
    {:ok, state}
  end
  
  def handle_info(:work, state) do
    # Do the work you desire here
    IO.puts("####call me at startup####")
    # 周期性任务可以通过Reschedule实现
    # schedule_work() # Reschedule once more
    {:noreply, state}
  end
  
  defp schedule_work() do
    Process.send_after(self(), :work, 1000) # In 1 second
  end
end