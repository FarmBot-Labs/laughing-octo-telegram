use Mix.Config
#import_config "#{Mix.Project.config[:target]}.exs"
config :nerves, :firmware,
  rootfs_additions: "config/rootfs-additions-#{Mix.Project.config[:target]}",
  hardware: "rpi3",
  ro_pat: "/root"

config :bus,
  port: 1883,
  client_id: "FB", #needs to be string.
  keep_alive: 0, #this is in seconds.
  auto_reconnect: true, #if client get disconnected, it will auto reconnect.
  auto_connect: true, #this will make sure when you start :bus process, it gets connected autometically
  callback: Mqtt.Callback #callback module, you need to implement callback inside.

config :uart,
  tty:  "/dev/ttyACM0",
  baud: 115200

config :fb,
  user: nil,
  pass: nil
