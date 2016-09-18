defmodule Auth do
  require GenServer
  require Logger

  @hardware Application.get_env(:nerves, :hardware)
  @path Application.get_env(:nerves, :ro_path)

  def get_public_key(server) do
    resp = HTTPotion.get("#{server}/api/public_key")
    RSA.decode_key(resp.body)
  end

  def encrypt(email, pass, server) do
    # Json to encrypt.
    json = Poison.encode!(%{"email": email,"password": pass,
        "id": Nerves.Lib.UUID.generate,"version": 1})

    # RSA that sumbitch
    secret = String.Chars.to_string(RSA.encrypt(json, {:public, get_public_key(server)}))
    save_encrypted(secret, server)
    secret
  end

  def save_encrypted(secret, server) do
    File.write("#{@path}/secretes.txt", :erlang.term_to_binary(%{secret: secret, server: server}))
  end

  def load_encrypted do
    file = File.read("#{@path}/secretes.txt")
    case file do
      {:ok, contents} -> t = :erlang.binary_to_term(contents)
                         get_token(Map.get(t, :secret), Map.get(t, :server))
      _ -> nil
    end
  end

  def get_token(secret, server) do
    payload = Poison.encode!(%{user: %{credentials: :base64.encode_to_string(secret) |> String.Chars.to_string }} )
    resp = HTTPotion.post "#{server}/api/tokens", [body: payload, headers: ["Content-Type": "application/json"]]
    Map.get(Poison.decode!(resp.body), "token")
  end

  def get_token do
    token = GenServer.call(__MODULE__, {:get_token})
    token
  end

  def init(_args) do
    {:ok, load_encrypted}
  end

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__ )
  end

  def login(email,pass,server) when is_bitstring(email)
        and is_bitstring(pass)
        and is_bitstring(server) do
    GenServer.call(__MODULE__, {:login, email,pass,server})
  end

  def handle_call({:login, email,pass,server}, _from, old_token) do
    secret = encrypt(email,pass,server)
    token = get_token(secret, server)
    {:reply,token,token}
  end

  def handle_call({:get_token}, _from, token) do
    {:reply, token, token}
  end
end
