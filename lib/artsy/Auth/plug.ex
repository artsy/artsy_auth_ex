defmodule Artsy.Auth.Plug do
  @moduledoc """
  Plug for enforcing authentication using Artsy's oauth.

  You can configure this plug by defining what roles are allowed to pass this plug:
  config :artsy_auth_ex,
    allowed_roles: [<list of your allowed roles>]

  This plug checks if current session has access token in the session,
  verifies if user has proper role based on allowed roles.
  If user is not allowed, it will return 403 and halt the connection.
  If user is not logged in, it redirects to "/auth" to get redirected to proper login page.
  """
  import Plug.Conn

  def init(default), do: default

  def call(conn, _params) do
    with access_token when not is_nil(access_token) <- Plug.Conn.get_session(conn, :access_token),
         {:ok, %{"roles" => roles}} <- Artsy.Auth.Token.verify_and_validate(access_token),
         {:ok, _roles} <- validate_role(roles) do
      conn
    else
      {:invalid_roles} ->
        # cannot access
        conn
        |> send_resp(403, "Access Denied")
        |> halt()

      _ ->
        # not logged in, redirect to login
        conn
        |> put_resp_header("location", "/auth")
        |> send_resp(301, "You are being redirected.")
        |> halt()
    end
  end

  defp validate_role(roles) do
    if valid_role?(roles), do: {:ok, roles}, else: {:invalid_roles}
  end

  defp valid_role?(roles) do
    roles
    |> String.split(",")
    |> Enum.any?(fn role ->
      Enum.member?(Application.get_env(:artsy_auth_ex, :allowed_roles), role)
    end)
  end
end
