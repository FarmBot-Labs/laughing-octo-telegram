defmodule CommandSupervisor do
  def start_link(_) do
    import Supervisor.Spec
    children = [
      worker(CommandMessageManager, []),
      worker(CommandMessageHandler, [], id: 1)
    ]
    Supervisor.start_link(children, strategy: :one_for_one)
  end

  def init(_) do
    {:ok, %{}}
  end
end
