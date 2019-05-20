# ArtsyAuthEx
[![Build Status](https://travis-ci.org/artsy/artsy_auth_ex.svg?branch=master)](https://travis-ci.org/artsy/artsy_auth_ex)
[![Hex version](https://img.shields.io/hexpm/v/artsy_auth_ex.svg "Hex version")](https://hex.pm/packages/artsy_auth_ex)
[![Hex downloads](https://img.shields.io/hexpm/dt/artsy_auth_ex.svg "Hex downloads")](https://hex.pm/packages/artsy_auth_ex)

Library for adding Artsy's omniauth based authentication to your app.


## Installation

The package can be installed by adding `artsy_auth_ex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:artsy_auth_ex, "~> 0.1"}
  ]
end
```

## Setup

This library provides modules needed to setup OAUTH with Artsy's authentication service. For [Phoenix](https://phoenixframework.org/) based applications you can follow these following steps:

### Create AuthController

You need to create a controller for handling, redirect to Artsy's auth, handling callback when coming back from login and signout. An example of a controller can look like this:
```elixir
#lib/test_app_web/auth_controller.ex
defmodule TestApp.AuthController do
  use TestAppWeb, :controller

  @doc """
  This action is reached via `/auth` and redirects to the OAuth2 provider
  based on the chosen strategy.
  """
  def index(conn, _params) do
    redirect(conn, external: Artsy.Auth.OauthStrategy.authorize_url!())
  end

  def signout(conn, _params) do
    conn
    |> put_flash(:info, "You have been logged out!")
    |> configure_session(drop: true)
    |> redirect(external: Artsy.Auth.OauthStrategy.signout_url())
  end

  @doc """
  This action is reached via `/auth/callback` is the the callback URL that
  the OAuth2 provider will redirect the user back to with a `code` that will
  be used to request an access token. The access token will then be used to
  access protected resources on behalf of the user.
  """
  def callback(conn, %{"code" => code}) do
    # Exchange an auth code for an access token
    client = Artsy.Auth.OauthStrategy.get_token!(code: code)
    conn
    |> put_session(:access_token, client.token.access_token)
    |> redirect(to: "/")
  end
end
```

### Add AuthController to our routes
Now we need to add the controller we just created to our route. Update `router.ex` and add following section.

```elixir
# lib/test_web_app/router.ex
scope "/auth", AprWeb do
  pipe_through :browser

  get "/", AuthController, :index
  get "/callback", AuthController, :callback
  get "/signout", AuthController, :delete
end
```

### Force authentication for other routes
For the routes that need to be behind Artsy's authentication we need to create a new pipeline and put them behind this new pipeline. For that we can use `Artsy.Auth.Plug` provided by this library. In your `router.ex` add this:
```elixir
pipeline :authenticated do
  plug Artsy.Auth.Plug
end
```
For routes you want to put behind Artsy authentication you can add this newly added pipeline to their `pipe_through`:
```elixir
pipe_through [:browser, :authenticated]
```

### Configure Authentication
We now need to setup this module to be able to properly authenticate with Artsy. In your `config.ex` add following configuration:

```elixir
# config/config.ex
config :artsy_auth_ex,
  token_aud: System.get_env("ARTSY_TOKEN_AUD"), # aud of your JWT token, Gravity's ClientApplication.id
  client_id: System.get_env("ARTSY_CLIENT_ID"), # Gravity's ClientApplication.app_id
  client_secret: System.get_env("ARTSY_CLIENT_SECRET"), # Gravity's ClientApplication.app_secret
  redirect_uri: Map.get(System.get_env(), "HOST_URL", "http://localhost:4000") <> "/auth/callback",
  site: System.get_env("ARTSY_URL"), # Gravity's api url ex. https://stagingapi.artsy.net
  authorize_url: "/oauth2/authorize",
  token_url: "/oauth2/access_token",
  allowed_roles: ["admin"] # list of roles allowed to access your app
```

Docs can be found at [https://hexdocs.pm/artsy_auth_ex](https://hexdocs.pm/artsy_auth_ex).

