defmodule JyzBackendWeb.UserController do
    use JyzBackendWeb, :controller
    alias JyzBackend.{User, UserService, Permissions}
  
    def index(conn, params) do
      username = Map.get(params, "username", "")
      sort_field = Map.get(params, "sort_field", "username")
      sort_direction = Map.get(params, "sort_direction", "asc")
      page = Map.get(params, "page", 1)
      page_size = Map.get(params, "page_size", 20)
      result = UserService.page(username,sort_field,sort_direction,page,page_size)
      case  result.entries do 
        [] ->
          json conn, result
        _list -> # => 获取用户头像url
          json conn,
          result |> Map.update!(:entries, fn(list) -> 
            for u <- list do
              case u.avatar do
                nil ->
                  u
                _avatar ->
                  avatar = getAvatarUrl(u)
                  Map.update!(u, :avatar, fn(_v) -> avatar end)
              end      
            end
          end )
      end  
    end
  
    def new(conn, %{"user" => user_params}) do
      # 新创建的用户active设置为false
      user_changeset = User.changeset(%User{}, user_params |> Map.update("active", false, &(&1 and false)))
      case UserService.create(user_changeset) do
        {:ok, user} ->
          json conn, user
        {:error, changeset} ->
          json conn, %{error: JyzBackendWeb.ChangesetError.translate_changeset_errors(changeset.errors)}
      end
    end
  
    def delete(conn, %{"id" => id}) do 
      # 判断是否具备权限
      checkperm = Permissions.hasAllPermissions(conn, [:all_users])
      case { checkperm, UserService.getById(id) } do
        { false, _ } ->
          json conn, %{error: "Unauthorized operation."}
        { true, nil } ->
          json conn , %{error: "can not find user"}
        { true, user } ->
          json conn, UserService.delete(user)
      end
    end
  
    def update(conn, %{"id" => id, "user" => user_params}) do
      # 判断是否具备权限
      checkperm = Permissions.hasAllPermissions(conn, [:all_users])
      case { checkperm, UserService.getById(id) } do
        { false, _ } ->
          json conn, %{error: "Unauthorized operation."}
        { true, nil } ->
          json conn , %{error: "can not find user."}
        { true, user } ->
          user_changeset = User.changeset(user, user_params)
          case UserService.update(user_changeset) do
            {:ok, user} ->
              json conn, user
            {:error, changeset} ->
              json conn, %{error: JyzBackendWeb.ChangesetError.translate_changeset_errors(changeset.errors)}
          end
      end
    end
  
    def show(conn, %{"id" => id}) do
      case UserService.getById(id) do
        nil ->
          json conn, %{error: "can not find user"}
        user ->
          case user.avatar do
            nil ->
              json conn, user |> Map.drop([:password, :password_hash])
            _avatar ->
              avatar = getAvatarUrl(user)
              json conn, user |> Map.drop([:password, :password_hash]) |> Map.update!(:avatar, fn(_v) -> avatar end)
          end
      end
    end
  
    def checkUsername(conn, %{"username" => name}) do
      case UserService.getByName(name) do
        nil ->
          json conn, %{error: "can not find user"}
        user ->
          json conn, user |> Map.drop([:password, :password_hash])
      end
    end
  
    # 上传用户头像图片文件
    def setAvatar(conn,  %{"avatar" => avatar_params}) do
      # 判断是否具备权限
      checkperm = Permissions.hasAllPermissions(conn, [:user_about_me])
      case { checkperm, Guardian.Plug.current_resource(conn) } do
        { false, _} ->
          json conn, %{error: "Unauthorized operation."}
        { true, nil } ->
          json conn, %{error: "can not find user."}
        { true, user } ->
          user_params = %{"avatar" => avatar_params}
          changeset = User.changeset(user, user_params)
          case UserService.update(changeset) do
            {:ok, user} ->
              json conn, user |> Map.drop([:avatar, :password, :password_hash])
            {:error, changeset} ->
              json conn, %{error: JyzBackendWeb.ChangesetError.translate_changeset_errors(changeset.errors)}
          end
      end
    end

    # 激活用户,实现与修改用户相同
    def activateUser(conn, %{"id" => id}) do 
      # 判断是否具备权限
      checkperm = Permissions.hasAllPermissions(conn, [:all_users])
      case { checkperm, UserService.getById(id) } do
        { false, _ } ->
          json conn, %{error: "Unauthorized operation."}
        { true, nil } ->
          json conn , %{error: "can not find user."}
        { true, user } ->
          user_changeset = User.changeset(user, %{"active" => true})
          case UserService.update(user_changeset) do
            {:ok, user} ->
              json conn, user
            {:error, changeset} ->
              json conn, %{error: JyzBackendWeb.ChangesetError.translate_changeset_errors(changeset.errors)}
          end
      end
    end
  
    # 获取用户头像url
    defp getAvatarUrl(user) do
      url = JyzBackendWeb.StringHandler.take_prefix(JyzBackend.Avatar.url({user.avatar, user}, :thumb),"/priv/static")
      base = Application.get_env(:jyz_backend, JyzBackendWeb.Endpoint)[:baseurl]
      base<>url
    end
  
    
  
  end