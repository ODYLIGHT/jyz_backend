defmodule JyzBackend.Permissions do
  use Guardian, otp_app: :jyz_backend,
    permissions: %{
                      # 每组最大31个权限
                      default: [
                        # 公有权限 
                        :public_profile, 
                        :user_about_me,
                        # 普通用户权限
                        :list_something,
                        :add_something,
                        # 修改与审核权限
                        :modify_something,
                        :audit_something,
                        # 管理员权限
                        :all_users,
                        :all_something,
                      ]  # 9个权限位，转换为十进制为255
  
                  }
  use Guardian.Permissions.Bitwise
  
  # 获取用户权限
  def getPermissions(conn) do
    resource = Guardian.Plug.current_resource(conn)
    claims = Guardian.Plug.current_claims(conn) |> Map.put("pem", %{"default" => resource.permissions}) 
    JyzBackend.Permissions.decode_permissions_from_claims(claims)
  end
  
  # 判断是否具备权限
  def hasAllPermissions(conn, list) do
    getPermissions(conn) |> JyzBackend.Permissions.all_permissions?(%{default: list})
  end

end