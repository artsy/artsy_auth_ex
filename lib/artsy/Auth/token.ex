defmodule Artsy.Auth.Token do
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
  use Joken.Config

  def token_config do
    aud = Application.get_env(:artsy_auth_ex, :token_aud)

    %{}
    |> Joken.Config.add_claim("aud", fn -> aud end, &(&1 == aud))
  end
end
