use Mix.Config
#import_config "#{Mix.Project.config[:target]}.exs"
config :nerves, :firmware,
  rootfs_additions: "config/rootfs-additions-#{Mix.Project.config[:target]}",
  hardware: "config/rootfs-additions-#{Mix.Project.config[:target]}"

config :uart,
  tty:  "/dev/ttyACM0",
  baud: 115200

config :fb,
  user: nil,
  pass: nil,
  ro_path: "/root"
