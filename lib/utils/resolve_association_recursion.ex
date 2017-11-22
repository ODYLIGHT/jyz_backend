defmodule JyzBackend.ResolveAssociationRecursion do
    
      # list中每一个map的out_key字段中每一项的del_key字段将被过滤
      def resolve_recursion_in_map_list(list,out_key,del_key) do
        Enum.map(list, fn(l) -> Map.update!(l, out_key, &Enum.map(&1, fn(v) -> Map.drop(v, [del_key]) end)) end)
      end
    
      # 删除一个map中out_key字段中每一项的del_key字段
      def resolve_recursion_in_map(map, out_key, del_key) do
        Map.update!(map, out_key, &Enum.map(&1, fn(v) -> Map.drop(v, [del_key]) end))
      end
    
    end