use Mix.Config
config :nerves, :firmware,
  rootfs_additions: "config/rootfs-additions-#{Mix.Project.config[:target]}",
  hardware: "config/rootfs-additions-#{Mix.Project.config[:target]}"

config :uart,
  baud: 115200

config :fb,
  ro_path: "/root"

config :json_rpc
    transport: MqttHandler
