defmodule MyRouter do
  use Plug.Router
  plug Plug.Parsers, parsers: [:urlencoded, :json],
                     pass:  ["text/*"],
                     json_decoder: Poison
  plug :match
  plug :dispatch

  post "/login" do
    IO.inspect(conn.params)
    email = conn.params["email"]
    password = conn.params["password"]
    server = conn.params["server"]
    Auth.login(email,password,server)
    send_resp(conn, 200, "world")
  end

  match _ do
    send_resp(conn, 404, "oops")
  end
end
