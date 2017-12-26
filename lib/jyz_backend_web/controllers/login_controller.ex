defmodule JyzBackendWeb.LoginController do
    
  use JyzBackendWeb, :controller   
  alias JyzBackend.{LoginService, Guardian, Permissions}
  use Ecto.Schema
    
  def login(conn, %{"login" => login_params}) do
    %{"password" => pw, "username" => un} = login_params
    case LoginService.checkPassword(un, pw) do
      {:ok, user} ->
        new_conn = Guardian.Plug.sign_in(conn, user)
        jwt = Guardian.Plug.current_token(new_conn)
        claims = Guardian.Plug.current_claims(new_conn) 
        exp = Map.get(claims, "exp") 
        user = user |> Map.drop([:chat_with_somebodies, :password, :password_hash])
                    |> Map.update!(:avatar, fn(_v) -> JyzBackendWeb.UserController.getAvatarUrl(user) end)
        perms = Permissions.getPermissions(new_conn)[:default]
        json new_conn, %{user: user, jwt: jwt, perms: perms, exp: exp}
      {:error, _} ->
        conn
          |> put_status(401)
          json conn, %{error: "Invalid username or password"}
    end
  end

end