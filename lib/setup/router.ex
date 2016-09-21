defmodule MyRouter do
  use Plug.Router
  plug Plug.Parsers, parsers: [:urlencoded, :json],
                     pass:  ["text/*"],
                     json_decoder: Poison
  plug :match
  plug :dispatch

  post "/login" do
    case Map.has_key?(conn.params, "email")
     and Map.has_key?(conn.params, "password")
     and Map.has_key?(conn.params, "server")
     and Map.has_key?(conn.params, "wifi") do
       true -> email = conn.params["email"]
               ssid = conn.params["wifi"]["ssid"]
               psk = conn.params["wifi"]["psk"]
               Wifi.connect(ssid, psk)
               password = conn.params["password"]
               server = conn.params["server"]
               case Auth.login(email,password,server) do
                 nil -> send_resp(conn, 401, "LOGIN FAIL")
                 token -> send_resp(conn, 200, "LOGIN OK")
               end
       _ -> send_resp(conn, 401, "BAD PARAMS")

     end
  end

  get "/scan" do
    dur = Wifi.scan
    send_resp(conn, 200, Poison.encode!(dur) )
  end

  get "/tea" do
    send_resp(conn, 418, "IM A TEAPOT")
  end

  match _ do
    send_resp(conn, 404, "Whatever you did could not be found.")
  end
end
