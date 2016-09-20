defmodule MqttHandler do
  require GenServer
  require Logger
  def init(client) do
    {:ok, client}
  end

  def start_link(client) do
    GenServer.start_link(__MODULE__, client, name: __MODULE__)
  end

  def handle_cast({:connect_ack, _message}, client) do
    options = [id: 24_756, topics: ["bot/#{bot}/request"], qoses: [1]]
    Mqtt.Client.subscribe(client, options)
    keep_connection_alive(client)
    {:noreply,client }
  end

  def handle_cast({:publish, _message}, client) do
    {:noreply,client }
  end

  def handle_cast({:subscribed_publish, message}, client) do
    Map.get(message, :message) |> Poison.decode! |>
    CommandMessageManager.sync_notify
    {:noreply,client }
  end

  def handle_cast({:subscribed_publish_ack, _message}, client) do
    {:noreply,client }
  end


  def handle_cast({:publish_receive, _message}, client) do
    {:noreply,client }
  end

  def handle_cast({:publish_release, _message}, client) do
    {:noreply,client }
  end

  def handle_cast({:publish_complete, _message}, client) do
    {:noreply,client }
  end

  def handle_cast({:publish_ack, _message}, client) do
    {:noreply,client }
  end

  def handle_cast({:subscribe, _message}, client) do
    {:noreply,client }
  end

  def handle_cast({:subscribe_ack, _message}, client) do
    {:noreply,client }
  end

  def handle_cast({:unsubscribe, _message}, client) do
    {:noreply,client }
  end

  def handle_cast({:unsubscribe_ack, _message}, client) do
    {:noreply,client }
  end

  def handle_cast({:ping, _message}, client) do
    {:noreply,client }
  end

  def handle_cast({:disconnect, _message}, client) do
    Logger.debug("Disconnected. Trying to reconnect.")
    {:noreply,client }
  end

  def handle_cast({:pong, _message}, client) do
    {:noreply, client}
  end

  def handle_cast({:emit, message}, client) do
    options = [ id: 1234,
                topic: "bot/#{bot}/response",
                message: message,
                dup: 0, qos: 1, retain: 1]
    Mqtt.Client.publish(client, options)
    {:noreply,client }
  end

  def handle_cast(event, client) do
    Logger.debug("unhandled event: #{inspect event}")
    {:noreply, client}
  end

  def handle_call(:client, _from, client) do
    {:reply, client, client}
  end

  def handle_info({:keep_alive, _pid}, client) do
    Mqtt.Client.ping(client)
    keep_connection_alive(client)
    {:noreply, client}
  end

  def client do
    GenServer.call(__MODULE__, :client)
  end

  def bot do
    Map.get(token, "unencoded") |>  Map.get("bot")
  end

  def token do
    Auth.fetch_token
  end

  # I don't feel like i should have to do this.
  def keep_connection_alive(pid) do
    # Logger.debug("I suck")
    Process.send_after(__MODULE__, {:keep_alive, pid}, 15000)
  end
end
