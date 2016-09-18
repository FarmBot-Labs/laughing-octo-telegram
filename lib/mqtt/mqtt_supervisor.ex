defmodule MqttSupervisor do
  @moduledoc """
    The main application for handling MQTT messages
  """
  def start_link(_args) do
    import Supervisor.Spec
    children = [
      worker(MqttMessageManager, []),
      worker(MqttMessageHandler, [], id: 1)
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end

  def init(_) do
    {:ok, %{}}
  end
end
