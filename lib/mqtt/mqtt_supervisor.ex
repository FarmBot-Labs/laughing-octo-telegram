defmodule MqttSupervisor do
  require Logger
  use Supervisor

  def init(_) do
    {:ok, client_pid} = Mqtt.Client.start_link(%{parent: self()})
    children = [worker(MqttHandler, [client_pid], restart: :permanent)]
    opts = [strategy: :one_for_all]
    supervise(children, opts)
  end

  def start_link(_) do
    Supervisor.start_link(__MODULE__, [])
  end
end
