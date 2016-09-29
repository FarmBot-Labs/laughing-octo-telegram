ExUnit.start
defmodule AuthTest do
  require IEx
  Code.require_file "test/test_router.exs"
  @path Application.get_env(:fb, :ro_path)
  use ExUnit.Case, async: true
  setup  do
    HTTPotion.start
    Plug.Adapters.Cowboy.http(TestRouter, [])
    :ok
  end

  test "gets a public key" do
    {rsa_atom, _key, _something_else} = Auth.get_public_key("http://localhost:4000")
    assert( rsa_atom == :RSAPublicKey )
  end

  test "fails to get a public key on a not running server" do
    {error, reason} = Auth.get_public_key("http://localhost:4001")
    assert(error == :error)
    assert(reason == "econnrefused")
  end

  test "encrypts a secret file" do
    server = "http://localhost:4000"
    secret = Auth.encrypt("fred_flinstone@tehflinstones.co.uk", "johnGoodman_is+GR8", server)
    assert(secret != nil)
    assert(is_bitstring(secret))
    contents = File.read!("/tmp/secretes.txt") |> :erlang.binary_to_term
    assert(contents.secret == secret)
  end
end
