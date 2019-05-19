defmodule Artsy.Auth.Token do
  @moduledoc """
  Joken based module for encode/decoding Artsy's JWT token.
  """
  use Joken.Config

  def token_config do
    aud = Application.get_env(:artsy_auth_ex, :token_aud)

    %{}
    |> Joken.Config.add_claim("aud", fn -> aud end, &(&1 == aud))
  end
end
