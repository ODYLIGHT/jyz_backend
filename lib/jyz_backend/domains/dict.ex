defmodule JyzBackend.Dict do
  use Ecto.Schema
  import Ecto.Changeset
  alias JyzBackend.{Dict}
  
  schema "dict" do
    field :code, :string    #编码
    field :name, :string    #名称
    field :key, :string     #键
    field :parm, :string    #值
    timestamps()
  end
    
  @doc false
  def changeset(%Dict{} = dict, attrs) do
    dict
      |> cast(attrs, [:code, :name, :key, :parm])
      |> validate_required([:code, :name, :key])
      |> unique_constraint(:code)
      |> validate_length(:code, min: 4)
  end

  # 自定义验证器
  defp validate_positive_number(changeset, field, options \\ []) do
    validate_change(changeset, field, fn _, n ->
      case n > 0 do
        true -> []
        false -> [{field, options[:message] || "invalid number"}]
      end
    end)
  end

end