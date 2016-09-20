defmodule MqttSupervisor do
  require Logger
  use Supervisor
  def start_link(_) do
    Logger.debug("MQTT INIT")
    spawn_link fn -> log_in end
    children = []
    Supervisor.start_link(children, strategy: :one_for_one)
  end

  def log_in do
    Logger.debug("Waiting for Token")
    {:ok, client_pid}  = Mqtt.Client.start_link(%{parent: self()})

    token = Auth.fetch_token
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
    Mqtt.Client.connect(client_pid, options)
    Logger.debug("Logged in.")
    {:ok, _handler} = MqttHandler.start_link(client_pid)
  end
end
