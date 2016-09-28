# Elixir && Nerves Proof of Concept

# WHY EVEN BUILD THIS?
This is the main reason I started this. Deploying a Ruby application with native extensions onto a cross compiled environment is just gosh darn difficult. Nerves aims to solve the deployment problem and allows you to focus on just the application.  

# SHORT DESCRIPTION
In the lib directory you will find the different modules that make this system go.
## bot_status
GenServer status register for the bot. It holds the state of all the hardware.

## command
The handler for RPC commands. This will almost certainly need refactoring and probably an overhaul. It works as is but is awfully messy and makes calls to other modules breaking the model of [separation of concerns]("https://en.wikipedia.org/wiki/Separation_of_concerns") in many places. I AM SO SORRY FOR ANYONE WHO HAS TO DEAL WITH THAT

## mqtt
Handles mqtt messages when logged in. Persists a small amount of state across reboots by storing a `secrets.txt` file on the readwrite partition of the system. Upon boot it checks if this file, if its not there it is assumed that the device needs a login from [setup](#setup) portion.

## sequence
To be honest I made this module really late in the night a while back. I know some actions work. I don't know why. I don't know if it is correct. I don't know if it will stay here. There has been talk of putting the actions here into some other scripting language like Lua, Mruby, etc. TBD.

## serial
Contains two parts actually. the handler for raw UART messages. and then the handler for GCODE messages. Not sure why I did that. If i thought it needed a week ago, it probably isn't needed now but whatever. :100:
See `gcode.ex` for a laugh.

## auth
Little GenServer that keeps track of tokens and whatnot. Not very exciting. Not very clean.

## controller/fw
These are just OTP Supervisors. They make sure that none of the above modules crash the entire application, and if they do die, restart them and accompanying/dependent modules until system is stable again. [ENTER COOL BUZZWORDS]("http://blog.oozou.com/an-intro-to-otp-in-elixir/")

## setup
Small cowboy webserver that will be used for initial [Farmbot Configuration]("https://github.com/FarmBot/wifi-configurator")
Currently it allows a login to a running farmbot server. This stores the token until it isn't accepted any longer.
TODO: I think I'm supposed to be checking the expiration date in the token?
Work is currently in progress for network (yes WiFi) configuration.

# Building and Running
Ok its actually really easy once your environment is set up. Let me prefix this with this simple phrase. ["YOU NEED LINUX"]("http://www.whylinuxisbetter.net/") I am sorry. It is just the bottom line. A VM works fine, a dual boot environment works. even OpenSuse works. But `bash for windows` does not work. `Cygwin` does not work. and for the love of all things development ready, `osx` does not work. You need Linux to build Linux. So with that rant out of the way, and ready for revision here are the steps to build:
* Install Elixir and Erlang.  (Shameless plug for ASDF) ([HEY TRY ME?]("https://gist.github.com/ConnorRigby/8a8bffff935d1a43cd74c4b8cf28a845"))
* install [`Nerves`]("https://hexdocs.pm/nerves/installation.html") (and all the things it tells you to install there)
* clone and cd into this directory.
* plug an sdcard into your machine.
``` bash
MIX_ENV=prod mix deps.get
echo "0.7.0-farmbot" > deps/rpi3/nerves_system_rpi3/version
MIX_ENV=prod mix firmware
MIX_ENV=prod mix firmware.burn
```
Obviously that second line shouldn't be there. I accidentally messed up the release/tag for the system image.

If you don't want to go thru installing or anything, hopefully by the time this is public there will be an image you can download from the Releases tab on github.
just flash that image to your sdcard.

either way you should be able to pop that sdcard into your pi3 and boot it up.
Now if you scan for wifi on your mobile device or pc you should see a "FarmbotConfigurator" you can connect to it and load up ["http://192.168.24.1"]("http://192.168.24.1") and follow the on screen instructions. If there were no problems you should have a working Farmbot!
