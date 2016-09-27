defmodule BotCommandManager do
  use GenEvent
  def start_link() do
    GenEvent.start_link([])
  end

  # add event to the log
  def handle_event({event, params}, events) do
    {:ok, [{event, params} | events]}
  end

  # dump teh current events to be handled
  def handle_call(:events, events) do
    {:ok, Enum.reverse(events), []}
  end

  def handle_call(:latest_event, events) do
    event = Enum.reverse(events) |> List.first
    {:ok, event, events -- [event]}
  end
end
