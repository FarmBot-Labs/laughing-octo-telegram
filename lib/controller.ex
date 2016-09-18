defmodule Controller do
  # use Application
  require Logger
  require IEx

  @mqttport  Application.get_env(:bus, :port )
  @mqttid    Application.get_env(:bus, :client_id )
  @mqttka    Application.get_env(:bus, :keep_alive )
  @mqttar    Application.get_env(:bus, :auto_reconnect )
  @mqttac    Application.get_env(:bus, :auto_connect )
  @mqttcb    Application.get_env(:bus, :callback )

  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    Logger.debug("Starting Controller")

    # DEBUG FOR RUNNIN LOCAL NOT ON HARDWARE
    # spawn fn -> Process.sleep(15000)
    #             Auth.login "admin@admin.com", "password123", "localhost:3000"
    # end

    children = [
      worker(BotStatus, [[]]),
      worker(Auth, [[]]),
      supervisor(MqttSupervisor, [[]]),
      supervisor(SerialSupervisor, [[]]),
      supervisor(CommandSupervisor, [[]]),
      supervisor(SequenceSupervisor, [[]])
    ]
    opts = [strategy: :one_for_one, name: Controller.Supervisor]
    {:ok, sup} = Supervisor.start_link(children, opts)

    Logger.debug("Getting Token")
    token = fetch_token
    mqtt_host = String.to_charlist(Map.get(token, "unencoded") |> Map.get("mqtt") )
    mqtt_user = Map.get(token, "unencoded") |> Map.get("bot")
    mqtt_pass = Map.get(token, "encoded")

    # I DON'T KNOW WHO YOU ARE OR WHY YOU MADE YOUR APP LIKE THIS BUT STOP
    Logger.debug("Got Token. Starting Farmbot")
    Application.put_env(:bus, :host,           mqtt_host )
    Application.put_env(:bus, :port,           @mqttport )
    Application.put_env(:bus, :client_id,      @mqttid   )
    Application.put_env(:bus, :keep_alive,     @mqttka   )
    Application.put_env(:bus, :username,       mqtt_user )
    Application.put_env(:bus, :password,       mqtt_pass )
    Application.put_env(:bus, :auto_reconnect, @mqttar   )
    Application.put_env(:bus, :auto_connect,   @mqttac   )
    Application.put_env(:bus, :callback,       @mqttcb   )
    Bus.start(:normal, [])
    {:ok, sup}
  end

  # Infinite recursion until we have a token.
  def fetch_token do
    case Auth.get_token do
      nil -> fetch_token
      token -> token
    end
  end
end
