defmodule Mqtt.Callback do
  require Logger
  @moduledoc """
    This is just a redefine of the callback module (Thanks Bus for being a normal
    Elixir application..)
    The functions are pretty self explanatory. they just forward the message
    into the genserver for Async action yo.
  """
    def on_publish(data) do
      MqttMessageManager.sync_notify {:on_publish, data}
    end

    def on_connect(data) do
      MqttMessageManager.sync_notify {:on_connect, data}
    end

    def on_disconnect(data) do
      MqttMessageManager.sync_notify {:on_disconnect, data}
    end

    def on_error(data) do
      Logger.debug("error: #{inspect data}")
      MqttMessageManager.sync_notify {:on_error, data}
    end

    def on_subscribe(data) do
      MqttMessageManager.sync_notify {:on_subscribe, data}
    end

    def on_unsubscribe(data) do
      MqttMessageManager.sync_notify {:on_unsubscribe, data}
    end

    def on_message_received(topic,message) do
      MqttMessageManager.sync_notify {:on_message_received, topic, message}
    end
end
