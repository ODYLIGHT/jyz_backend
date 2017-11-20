defmodule JyzBackendWeb.ChangesetError do
    
  def translate_changeset_errors(errors) do
    Enum.map(errors, fn {k, v} ->
      "#{k} -> #{get_error(v)}" end) |> Enum.join(" && ")
  end

  defp get_error({error, _}) do
    error
  end
  
end