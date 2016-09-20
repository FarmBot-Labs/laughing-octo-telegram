defmodule Controller do
  # use Application
  require Logger
  use Supervisor

  def start_link(_args) do
    import Supervisor.Spec, warn: false
    Logger.debug("Starting Controller")

    children = [
      worker(Auth, [[]]),
      supervisor(CommandSupervisor, [[]]),
      supervisor(SerialSupervisor, [[]]),
      supervisor(MqttSupervisor, [[]]),
      supervisor(SequenceSupervisor, [[]]),
      worker(BotStatus, [[]])
    ]
    opts = [strategy: :one_for_all, name: Controller.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
