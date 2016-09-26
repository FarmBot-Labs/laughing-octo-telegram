defmodule MqttHandler do
  require GenServer
  require Logger

  def log_in(err_wait_time\\ 10000) do
    mqtt_host = Map.get(token, "unencoded") |> Map.get("mqtt")
    mqtt_user = Map.get(token, "unencoded") |> Map.get("bot")
    mqtt_pass = Map.get(token, "encoded")

    options = [client_id: mqtt_user,
               username: mqtt_user,
               password: mqtt_pass,
               host: mqtt_host,
               port: 1883,
               timeout: 5000,
               keep_alive: 500]
    case GenServer.call(MqttHandler, {:log_in, options}) do
      {:error, reason} -> Logger.debug("Error connecting. #{inspect reason}")
                          Process.sleep(err_wait_time)
                          log_in(err_wait_time + 10000) # increment the sleep time for teh lawls
      _ -> :ok
    end
  end

  def init(_args) do
    Mqtt.Client.start_link(%{parent: MqttHandler})
  end

  def start_link(args) do
    blah = GenServer.start_link(__MODULE__, args, name: __MODULE__)
    log_in
    blah
  end

  def handle_call({:connect, _message}, _from, client) do
    {:reply, :ok, client}
  end

  def handle_call({:connect_ack, _message}, _from, client) do
    options = [id: 24_756, topics: ["bot/#{bot}/request"], qoses: [1]]
    spawn fn ->
      Mqtt.Client.subscribe(client, options)
      Command.write_pin(13, 1, 1)
      Command.write_pin(13, 0, 1)
      Command.read_all_pins # I'm truly sorry these are here
      Command.read_all_params
    end
    keep_connection_alive
    {:reply, :ok, client}
  end

  def handle_call({:publish, _message}, _from, client) do
    {:reply, :ok, client}
  end

  def handle_call({:subscribed_publish, message}, _from, client) do
    Map.get(message, :message) |> Poison.decode! |>
    CommandMessageManager.sync_notify
    {:reply, :ok, client}
  end

  def handle_call({:subscribed_publish_ack, _message}, _from, client) do
    {:reply, :ok, client}
  end

  def handle_call({:publish_receive, _message}, _from, client) do
    {:reply, :ok, client}
  end

  def handle_call({:publish_release, _message}, _from, client) do
    {:reply, :ok, client}
  end

  def handle_call({:publish_complete, _message}, _from, client) do
    {:reply, :ok, client}
  end

  def handle_call({:publish_ack, _message}, _from, client) do
    {:reply, :ok, client}
  end

  def handle_call({:subscribe, _message}, _from, client) do
    {:reply, :ok, client}
  end

  def handle_call({:subscribe_ack, _message}, _from, client) do
    Logger.debug("Subscribed.")
    {:reply, :ok, client}
  end

  def handle_call({:unsubscribe, _message}, _from, client) do
    {:reply, :ok, client}
  end

  def handle_call({:unsubscribe_ack, _message}, _from, client) do
    {:reply, :ok, client}
  end

  def handle_call({:ping, _message}, _from, client) do
    {:reply, :ok, client}
  end

  def handle_call({:disconnect, _message}, _from, client) do
    {:reply, :ok, client}
  end

  def handle_call({:pong, _message}, _from, client) do
    {:reply, :ok, client}
  end

  def handle_call({:log_in, options}, _from, client) do
    case Mqtt.Client.connect(client, options) do
      {:error, reason} -> {:reply, {:error, reason}, client}
      _ -> {:reply, :ok, client}
    end
  end

  def handle_call({:emit, message}, _from, client) do
    options = [ id: 1234,
            topic: "bot/#{bot}/response",
            message: message,
            dup: 0, qos: 1, retain: 1]
    spawn fn -> Mqtt.Client.publish(client, options) end
    {:reply, :ok, client}
  end

  def handle_call(thing, _from, client) do
    Logger.debug("FIND ME #{inspect thing}")
    {:reply, :ok, client}
  end

  def handle_cast(event, state) do
    Logger.debug("#{inspect event}")
    {:noreply, state}
  end

  def handle_info({:keep_alive}, client) do
    Mqtt.Client.ping(client)
    keep_connection_alive
    {:noreply, client}
  end

  def emit(message) do
    GenServer.call(__MODULE__, {:emit, message})
  end

  defp bot do
    Map.get(token, "unencoded") |>  Map.get("bot")
  end

  defp token do
    Auth.fetch_token
  end

  defp keep_connection_alive do
    Process.send_after(__MODULE__, {:keep_alive}, 15000)
  end

  def terminate(reason, _state) do
    Logger.debug("MqttHandler died. #{inspect reason}")
  end
end
