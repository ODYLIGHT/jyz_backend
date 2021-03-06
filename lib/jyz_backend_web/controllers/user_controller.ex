defmodule JyzBackendWeb.UserController do
    use JyzBackendWeb, :controller
    alias JyzBackend.{User, UserService, LoginService, Permissions, Guardian}
  
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
  
    # 创建用户激活状态一律为false
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
  
    # 用户自己修改自己，无法修改激活状态，无法修改用户名;另外如果是连接用户与传入用户不相等，则代表是管理员正在修改用户
    def update(conn, %{"user" => user_params, "id" => id}) do
      conn_user = Guardian.resource_from_conn(conn)
      modify_user = UserService.getById(id)
      user = nil
      checkperm = false
      case conn_user == modify_user do
        true -> 
          user = conn_user
          checkperm =  Permissions.hasAnyPermissions(conn, [:user_about_me, :all_users])
        false ->
          user = modify_user
          checkperm =  Permissions.hasAllPermissions(conn, [:all_users])
      end

      case { checkperm, user } do
        { false, _ } ->
          json conn, %{error: "Unauthorized operation."}
        { true, nil } ->
          json conn , %{error: "can not find user."}
        { true, user } ->
          user_changeset = User.changeset(user, user_params 
                                                  |> Map.update("active", user.active, fn(c) -> user.active end)
                                                  |> Map.update("username", user.username, fn(c) -> user.username end)
                                                  |> Map.update("permissions", user.permissions, fn(c) -> user.permissions end))
          case UserService.update(user_changeset) do
            {:ok, user} ->
              json conn, user
            {:error, changeset} ->
              json conn, %{error: JyzBackendWeb.ChangesetError.translate_changeset_errors(changeset.errors)}
          end
      end
    end

    # 用户修改密码,需要验证旧密码
    def changePassword(conn, %{"pwd" => pwd}) do
      user = Guardian.resource_from_conn(conn)
      checkperm = Permissions.hasAllPermissions(conn, [:user_about_me])


          case { checkperm, user } do
            { false, _ } ->
              json conn, %{error: "Unauthorized operation."}
            { true, nil } ->
              json conn , %{error: "can not find user."}
            { true, user } ->
              user_changeset = User.changeset(user, %{"password" => pwd})
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
              json conn, user |> Map.drop([:password, :password_hash]) 
                              |> Map.update!(:avatar, fn(_v) -> avatar end)
          end
      end
    end
  
    # 验证用户注册时的用户名重复
    def checkUsername(conn, %{"username" => name}) do
      case UserService.getByName(name) do
        nil ->
          json conn, %{error: "can not find user"}
        user ->
          json conn, user |> Map.drop([:password, :password_hash])
      end
    end

    # 验证用户修改时的邮箱重复
    def checkEmail(conn, %{"email" => email}) do
      IO.puts("###### before get email######")
      case { Guardian.resource_from_conn(conn).email == email, UserService.getByEmail(email) } do
        { _, nil } ->
          json conn, %{success: "can not find user"}
        { true, _ } ->
          json conn, %{success: "use the old email"}
        _ ->
          json conn, %{error: "email has been taken"}
      end
    end

    # 验证用户修改密码时的旧密码
    def checkPassword(conn, %{"pwd" => pwd}) do
      case LoginService.checkPassword(Guardian.resource_name_from_conn(conn), pwd) do
        {:ok, user} -> json conn, %{success: "Valid username or password"}
        {:error, _} -> json conn, %{error: "Invalid username or password"}
      end
    end
  
    # 上传用户头像图片文件
    def setAvatar(conn,  %{"avatar" => avatar_params, "token" => token}) do
      # 判断是否具备权限
      # checkperm = Permissions.hasAllPermissions(conn, [:user_about_me])
      { :ok, user } = Guardian.get_user_from_token(token)
      # user = UserService.getById(1)
      case { true, user} do
        { false, _} ->
          json conn, %{error: "Unauthorized operation."}
        { true, nil } ->
          json conn, %{error: "can not find user."}
        { true, user } ->
          user_params = %{"avatar" => avatar_params}
          changeset = User.changeset(user, user_params)
          case UserService.update(changeset) do
            {:ok, user} ->
              # IO.puts("### before store manually ###")
              # JyzBackend.Avatar.store(%{filename: "file.png", binary: Base.decode64!(avatar_params)})
              # IO.puts("### after store manually ###")
              json conn, user |> Map.drop([:avatar, :password, :password_hash])
            {:error, changeset} ->
              json conn, %{error: JyzBackendWeb.ChangesetError.translate_changeset_errors(changeset.errors)}
          end
      end
    end

    # 激活用户,实现与修改用户相同
    def activateUser(conn, %{"id" => id}) do
      IO.puts("激活用户#####")
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
    def getAvatarUrl(user) do
      case user.avatar do
        nil -> ""
        avatar -> 
          url = JyzBackendWeb.StringHandler.take_prefix(JyzBackend.Avatar.url({avatar, user}, :thumb),"/priv/static")
          base = Application.get_env(:jyz_backend, JyzBackendWeb.Endpoint)[:baseurl]
          base<>url
      end
    end
  
    
  
  end