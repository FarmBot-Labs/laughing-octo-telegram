# Elixir && Nerves Proof of Concept
I lost my old `Readme.md`. This is nothing more than Connor having
a little fun at the moment. It is actually mostly functional (also in the sense that its written in Elixir?? EH? EH?? ITS A PUN! ). This is code that lives on the Raspberry Pi. It currently compiles for Pi 2 and Pi3. Adding support for other systems is pretty  trivial also. See the `mix.exs` file to see how it is done.

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

 ## Initial Configuration Brain Dump
 I was working through the initial [Out of box experience]("https://en.wikipedia.org/wiki/Out-of-box_failure") and decided I'd write it down.

 I think the steps will go as such (from a fully assembled farmbot)
 0. Power Rpi3
 * Rpi3 creates hostap access point (with captive portal)
 * User connects web browser enabled device to said access point
 * User is prompted with a list of access points
 * User selects AP, enters creds for it.
 * User is promped for Farmbot.io username and password
 * `secrets.txt` file is saved.
 * `setup` attempts to connect to it.
 * if fail, `GOTO 2`
 * if success, Farmbot Tries to auth with saved `secrets.txt` file.
 * if fail, delete `secrets.txt` file, `GOTO 2`
 * if success, profit??

This is a little bit messy, but it stops us from having to do any [weird UPnP stuff]("http://www.computerworld.com/article/2474305/malware-vulnerabilities/check-your-router-now--before-lex-luthor-does.html").

The other option is something along the lines of (our current beta model)
  0. plug pi into hdmi enabled device, with keyboard and mouse
  * run `ruby seup.rb`
  * unplug farmbot
  * plug it back into you real hardware.


# HOW DO I BUILD THIS MONSTROSITY?
Ok its actually really easy once your environment is set up. Let me prefix this with this simple phrase. ["YOU NEED LINUX"]("http://www.whylinuxisbetter.net/") I am sorry. It is just the bottom line. A VM works fine, a dual boot environment works. even OpenSuse works. But `bash for windows` does not work. `Cygwin` does not work. and for the love of all things development ready, `osx` does not work. You need Linux to build Linux. So with that rant out of the way, and ready for revision here are the steps to build:
* Install Elixir and Erlang. ([HEY TRY ME?]("https://gist.github.com/ConnorRigby/8a8bffff935d1a43cd74c4b8cf28a845"))
* install [`Nerves`]("https://hexdocs.pm/nerves/installation.html") (and all the things it tells you to install there)
* CopyPasta this?

# READ THIS
 this is a little out of date. There is a pretty big step not documented here. If you personally would like to build this,
  go ahead and talk to me directly. I don't have time to update the readme this very second. 
``` bash
git clone https://github.com/FarmBot-Labs/laughing-octo-telegram
cd laughing-octo-telegram #TODO: change this stupid name.
mix deps.get # Fetch dependencies. Should only need this once.
mix firmware # Compile application. Must do this every time code changes.
```
* this will build an image for the Raspberry Pi 3.
  * If you want to build for other (hopefully supported) devices do: `export NERVES_TARGET=$(MY_HARDWARE_PLATFORM)`
* now plug your sdcard in, and run `mix firmware.burn; sudo sync`
* You should now have a bootable elixir Farmbot.
  * There will be a console on the hardware/ftdi pins. If you want to change this look in `rootfs_additions` or just ask me. I don't know anyone who would want this yet.
* Profit? Help? Break it? I don't know.
