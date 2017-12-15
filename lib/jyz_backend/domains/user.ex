defmodule JyzBackend.User do
    use Ecto.Schema
    use Arc.Ecto.Schema
    import Ecto.Changeset
    alias JyzBackend.{User}
  
    schema "users" do
      field :username, :string
      field :email, :string
      field :password, :string, virtual: true, default: "p@ssw0rd"
      field :password_hash, :string
      field :fullname, :string, default: ""
      field :position, :string, default: ""
      field :is_admin, :boolean, default: false
      field :active, :boolean, default: false
      field :permissions, :integer, default: 1
      field :avatar, JyzBackend.Avatar.Type
      timestamps()
    end
    
    @doc false
    def changeset(%User{} = user, attrs) do
      user
        |> cast(attrs, [:username, :email, :password, :fullname, :position, :is_admin, :active, :permissions])
        |> cast_attachments(attrs, [:avatar])
        |> validate_required([:username, :email, :is_admin])
        |> validate_format(:email, ~r/@/)
        |> unique_constraint(:username)
        |> unique_constraint(:email)
        |> validate_length(:username, min: 4)
        |> validate_length(:password, min: 6)
        |> put_password_hash()
    end
    
    defp put_password_hash(changeset) do
      case changeset do
        %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
          put_change(changeset, :password_hash, Comeonin.Pbkdf2.hashpwsalt(password))
        _ ->
          changeset
      end
    end
  end