defmodule TestRouter do
  use Plug.Router
  plug CORSPlug
  plug Plug.Parsers, parsers: [:urlencoded, :json],
                     pass:  ["text/*"],
                     json_decoder: Poison
  plug :match
  plug :dispatch
  def test_key do
    "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAzXxHfRyMjsl6s4RMn/T3\nRaKWax8wRhKfVkkrbE7uAtRMlRmvLMlOPGQTD6E+CrhqknGwFiXBy9hfhs9aPBPX\nhhZfI/2QZok4lxvIK7gQzYfF9E5VZWRbv7MjvyVWkqOf1Ab9jTOefvyZL39EgIrM\n9d1g5qPc/a4TBJnrJas1/IzfSZhvFCHYQ7SaONo6UqhkqP+JOOFBXfxYiWP02U1p\nQ253g8Vnu5LjQBQJHkIQQ3jZjQw1ArhP7BM09gINVjyU+igSL+64qH3D5/jjMswv\nd0z9hRA7uCoLQIcbVCfQXQRITCjbVmvM/P3NRuxUtARD/9ZHXokOg0DsnWC1ljpx\ncQIDAQAB\n-----END PUBLIC KEY-----\n"
  end
  get "/api/public_key" do
    send_resp(conn, 200, test_key)
  end

  match _ do
    send_resp(conn, 404, "Whatever you did could not be found.")
  end
end
