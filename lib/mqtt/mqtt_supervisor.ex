defmodule MqttSupervisor do
  require Logger
  use Supervisor
  def start_link(_) do
    Logger.debug("MQTT INIT")
    spawn_link fn -> log_in end
    children = [worker(Blah, [[]], restart: :permanent)]
    Supervisor.start_link(children, strategy: :one_for_one)
  end

  def log_in do
    Blah.log_in
  end
end

defmodule Blah do
  require Logger
  use GenServer
  def init(args) do
    {:ok, args}
  end

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def log_in(:pause) do
    Logger.debug("Something turrible happened. Trying to reconnect in 5 seconds")
    Process.sleep(5000)
    log_in
  end

  def log_in do
    # WHAT IS OTP???????
    Logger.debug("Waiting for Token")
    Process.flag(:trap_exit, true)
    spawn_link fn ->
        Process.flag(:trap_exit, true)
        {:ok, client_pid} = Mqtt.Client.start_link(%{parent: self()})
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
        spawn_link fn ->  MqttHandler.start_link(client_pid) end
        make_sure_not_dead
    end # spawn_link
    make_sure_not_dead
  end # log_in
  def make_sure_not_dead do
    receive do
      {:EXIT, pid, :normal} ->  Logger.debug("https://www.youtube.com/watch?v=dQw4w9WgXcQ")
                                Process.exit(self(), :normal)
      {:EXIT, pid, reason} -> log_in(:pause)
      other -> Logger.debug("#{inspect other}")
                make_sure_not_dead
    end
  end




end
