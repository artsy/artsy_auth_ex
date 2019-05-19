defmodule Artsy.Auth.OauthStrategy do
  @moduledoc """
  An OAuth2 strategy for Artsy.
  """
  use OAuth2.Strategy

  alias OAuth2.Strategy.AuthCode

  def client do
    OAuth2.Client.new(
      client_id: Application.get_env(:artsy_auth_ex, :client_id),
      client_secret: Application.get_env(:artsy_auth_ex, :client_secret),
      redirect_uri: Application.get_env(:artsy_auth_ex, :redirect_uri),
      site: Application.get_env(:artsy_auth_ex, :site),
      authorize_url: Application.get_env(:artsy_auth_ex, :authorize_url),
      token_url: Application.get_env(:artsy_auth_ex, :token_url)
    )
    |> OAuth2.Client.put_serializer("application/json", Jason)
  end

  @doc """
  Returns authorization url.
  """
  def authorize_url! do
    OAuth2.Client.authorize_url!(client(), scope: "offline_access")
  end

  @doc """
  Returns signout url
  """
  def signout_url do
    Application.get_env(:artsy_auth_ex, :site) <> "/users/sign_out"
  end

  @doc """
  Given authorization code, asks for access token.
  """
  def get_token!(params \\ [], _headers \\ []) do
    OAuth2.Client.get_token!(
      client(),
      Keyword.merge(params,
        client_secret: client().client_secret,
        scope: "offline_access",
        grant_type: "authorization_code"
      )
    )
  end

  # Strategy Callbacks

  def authorize_url(client, params) do
    AuthCode.authorize_url(client, params)
  end

  def get_token(client, params, headers) do
    client
    |> put_param(:client_secret, client.client_secret)
    |> put_header("accept", "application/json")
    |> OAuth2.Strategy.AuthCode.get_token(params, headers)
  end
end
