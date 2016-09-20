defmodule Mqtt.Client do
  use Hulaaki.Client
  # I SUCK
  def on_connect(message: message, state: _state) do
    GenServer.cast(MqttHandler, {:connect, message})
  end
  def on_connect_ack(message: message, state: _state) do
    GenServer.cast(MqttHandler, {:connect_ack, message})
  end
  def on_publish(message: message, state: _state) do
    GenServer.cast(MqttHandler, {:publish, message})
  end
  def on_subscribed_publish(message: message, state: _state) do
    GenServer.cast(MqttHandler, {:subscribed_publish, message})
  end
  def on_subscribed_publish_ack(message: message, state: _state) do
    GenServer.cast(MqttHandler, {:subscribed_publish_ack, message})
  end
  def on_publish_receive(message: message, state: _state) do
    GenServer.cast(MqttHandler, {:publish_receive, message})
  end
  def on_publish_release(message: message, state: _state) do
    GenServer.cast(MqttHandler, {:publish_release, message})
  end
  def on_publish_complete(message: message, state: _state) do
    GenServer.cast(MqttHandler, {:publish_complete, message})
  end
  def on_publish_ack(message: message, state: _state) do
    GenServer.cast(MqttHandler, {:publish_ack, message})
  end
  def on_subscribe(message: message, state: _state) do
    GenServer.cast(MqttHandler, {:subscribe, message})
  end
  def on_subscribe_ack(message: message, state: _state) do
    GenServer.cast(MqttHandler, {:subscribe_ack, message})
  end
  def on_unsubscribe(message: message, state: _state) do
    GenServer.cast(MqttHandler, {:unsubscribe, message})
  end
  def on_unsubscribe_ack(message: message, state: _state) do
    GenServer.cast(MqttHandler, {:unsubscribe_ack, message})
  end
  def on_ping(message: message, state: _state) do
    GenServer.cast(MqttHandler, {:ping, message})
  end
  def on_pong(message: message, state: _state) do
    GenServer.cast(MqttHandler, {:pong, message})
  end
  def on_disconnect(message: message, state: _state) do
    GenServer.cast(MqttHandler, {:disconnect, message})
  end
end
