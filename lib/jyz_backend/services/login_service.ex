defmodule JyzBackend.LoginService do
    
  def checkPassword(username, password) do
    user = JyzBackend.UserService.getByName(username)
    cond do
      # 用户存在，且密码正确
      user && Comeonin.Pbkdf2.checkpw(password, user.password_hash) ->
        {:ok, user}
      true ->
        {:error, "invalid username or password"}
    end
  end
end