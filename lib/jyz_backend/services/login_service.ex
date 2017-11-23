defmodule JyzBackend.LoginService do
    
  def checkPassword(username, password) do
    user = JyzBackend.UserService.getByName(username)
    cond do
      user && user.active && Comeonin.Pbkdf2.checkpw(password, user.password_hash) ->
        {:ok, user}
      user && not user.active && Comeonin.Pbkdf2.checkpw(password, user.password_hash) ->
        {:error, "User is not actived."}
      true ->
        {:error, "Invalid username or password."}
    end
  end
end