defmodule Fw.Mixfile do
  use Mix.Project

  @target System.get_env("NERVES_TARGET") || "rpi3"

  def project do
    [app: :fw,
     version: "0.0.1",
     target: @target,
     archives: [nerves_bootstrap: "~> 0.1.4"],
     deps_path: "deps/#{@target}",
     build_path: "_build/#{@target}",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     config_path: "config/config.exs",
     aliases: aliases,
     deps: deps ++ system(@target) ++ platform_deps(@target)]
  end

  def application do
    [mod: {Fw, []},
     applications: [:logger,
                    :nerves,
                    :nerves_firmware_http,
                    :nerves_uart,
                    :httpotion,
                    :poison,
                    :gen_stage,
                    :nerves_lib,
                    :rsa,
                    :cowboy,
                    :plug,
                    :cors_plug,
                    :hulaaki
                    ] ++ platform_apps(@target) ]
  end

  def deps do
    [
     {:nerves, "~> 0.3.0"},
     {:nerves_firmware_http, github: "nerves-project/nerves_firmware_http"},
     {:nerves_uart, "~> 0.1.0"},
     {:httpotion, "~> 3.0.0"},
     {:poison, "~> 2.0"},
     {:gen_stage, "~> 0.4"},
     {:nerves_lib, github: "nerves-project/nerves_lib"},
     {:rsa, "~> 0.0.1"},
     {:cowboy, "~> 1.0.0"},
     {:plug, "~> 1.0"},
     {:cors_plug, "~> 1.1"},
     {:hulaaki, "~> 0.0.4"}
   ]
  end

  def system(target) do
    [{:"nerves_system_#{target}", ">= 0.0.0"}]
  end

  def platform_deps("rpi") do
    [
      {:nerves_networking, github: "nerves-project/nerves_networking"}
    ]
  end

  def platform_deps("rpi2") do
    [
      {:nerves_networking, github: "nerves-project/nerves_networking"}
    ]
  end

  def platform_deps("rpi3") do
    [
      {:nerves_networking, github: "nerves-project/nerves_networking"},
      {:nerves_interim_wifi, github: "nerves-project/nerves_interim_wifi" }
    ]
  end

  def platform_apps("rpi") do
    [ :nerves_networking ]
  end

  def platform_apps("rpi2") do
    [ :nerves_networking ]
  end

  def platform_apps("rpi3") do
    [ :nerves_networking,
      :nerves_interim_wifi]
  end

  def aliases do
    ["deps.precompile": ["nerves.precompile", "deps.precompile"],
     "deps.loadpaths":  ["deps.loadpaths", "nerves.loadpaths"]]
  end
end
