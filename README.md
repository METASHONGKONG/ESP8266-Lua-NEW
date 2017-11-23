# NodeOne OS Version 1.4

http://www.funmetas.com.hk/nodeone/

## Overview
This is the source code of operation System for NodeOne (1st generation). The main programming language is written in Lua. In the future, NodeOne OS Version 2 would be used in python!

##How to import program to the ESP8266?

1. Using ESP8266Flasher64.exe to import "1.firmware" into ESP8266
2. Using Lualoader or ESPlorer to load all "2. Lua" into ESP8266

Lualoader: http://benlo.com/esp8266/

ESPlorer: http://esp8266.ru/esplorer/

## History

Version 1.4 [11/Oct/2017]
* Flash button to reset wifi, remove the A0 pin to reset wifi function
* Initially, Direct control for 8266 is work now.
* Deleted the 192.168.4.1 page to config wifi. Instead, use need to use Set Wifi and Re-set Wifi API. (2 wifi API are added.)
* Added the servo2 api for external servo controller
* Allow speed parameter for forward/backward/left/right API
* Deleted the PM2.5,RGB API
* Add error handling to prevent reboot issue(Wrong API or exceed the range 0-1023)
* Code consolidation and Bug fixed

Version 1.3 [10/Nov/2016]
* Bug fix: PWM value must be in the range 0-1023
* Bug fix: PWM interahcnge with digital, digital can be used
* Showed the NodeOne OS version page in "input wifi" mode only
* Showed one more digit of chipID
* Code consolidation

Version 1.2 [10/Nov/2016]
* Bug fix: Motor and servo control will be reseted after api called
* Bug fix: return value of input must be in the range 0-1023
* Improvement: servo API (0-180 degree) can be used instead of pwm API
* Changed more stable pulse value of the servo
* Added welcome page and NodeOne OS version page

Version 1.1 [4/Nov/2016]
* Bug fix: header of the web browser(IOS)
* Decrease the time to 25s (direct mode)
* Changed the way to reset NodeOne
* Changed the note in config wifi page


Version 1.0 [22/Oct/2016]
* The initial source code from NodeOne (Beta generation)
* Designed API that are compatible with ALL application
* Deleted mode selection
* Made it more user-friendly
* Removed the AP mode when NodeOne is connected to WIFI network
