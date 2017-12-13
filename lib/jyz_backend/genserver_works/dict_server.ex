defmodule JyzBackend.DictServer do
  use GenServer
  alias JyzBackend.DictService

  def start_link do
    # 数据字典表中应该包含下面的键值对
    # app_dictionary = %{
    #   stockchange_type_godownentry: "油品入库校验",
    #   stockchange_type_metering_for_return: "油品计量回灌",
    #   fuel_type_95: "95#汽油",
    #   fuel_type_97: "97#汽油"
    # }
    GenServer.start_link(__MODULE__, DictService.getDictMap(), name: AppDict)
  end
  
  def handle_call(:get_dict, _from, state) do
    {:reply, state , state}
  end

  def handle_cast({:set_dict, map}, state) do
    {:noreply, map}
  end

end 