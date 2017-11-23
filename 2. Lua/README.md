## **GET STARTED: Connect your NodeOne to the router
1. Firstly, use your computer or smart phone to connect the wifi emitted from NodeOne. In this example, Wifi: Metas138927, password: 12345678
2. In your browser, type "http://192.168.4.1/wifi/METASHONGKONG/12345678" where METASHONGKONG is your router ssid and 12345678 is the password.

#### Note: 
If the WIFI cannot be connected successfully after 25s, it will be changed to “Direct control” mode.
Direct control mode: The NodeOne act as an router, use your mobile phone to connect the NodeOne and control it directly.

## **RESET wifi
After open the NodeOne in the first 5 second, press the flash button on 8266.

## **PLAY with NodeOne

### 1. How to play with NodeOne (Direct control - PC connect the wifi from NodeOne):
1. Go to the SNAP "http://snap.metas-services.com/snap/snap.html"
2. Connect your pc/smartphone to your NodeOne. (E.g. Wifi: Metas138927, password: 12345678)
3. Go to Robotic tab, find the one block you want to use(IP is 192.168.4.1).

### 2. How to play with NodeOne (Both PC and NodeOne connect to the same router):
1. Go to the SNAP "http://snap.metas-services.com/snap/snap.html"
2. Go to Robotic tab, find the one block you want to use (IP is on your NodeOne screen).

## **ALL API
There are 4 types of API categories - (WIFI, General, Function pin and METAS Car)

### 1. WIFI API

Link | Description 
----|------
http://IP/wifi/ssid/pwd | Set the NodeOne to connect router (ssid: Router ssid, pwd: Router pwd)

### 2. General API
These APIs are general API that can control all function of the NodeOne. However, these APIs are for more advanced user.
For details, please refer to http://www.funmetas.com.hk/nodeone/

Link | Description 
----|------
http://IP/mode/pin/o | Set pin as output (pin: 0-8)  
http://IP/mode/pin/i | Set pin as input (pin: 0-8)
http://IP/mode/pin/p | Set pin as PWM (pin: 0-8)
http://IP/digital/pin/0 | Set the output of the pin as 0 (pin: 0-8)
http://IP/digital/pin/1 | Set the output of the pin as 1 (pin: 0-8)
http://IP/digital/pin/r | Read the value of the digital port (pin: 0-8)
http://IP/pwm/pin/num | Set pwm value of the pin (pin: 0-8, num: 0-1023)
http://IP/analog/pin | Read the analog value (pin: 0/1)

#### Note: Servo2 API is used for External servo controller.

### 3. Function pin API
Actually, there are 5 main functions for our NodeOne. Thus, the below APIs are for your EASY control.

1.	Input X2
2.	Output X2
3.	Servo X4
4.	Motor X2
5.	I2C X1 (temperature/humidity)

Link | Description 
----|------
http://IP/input/pin | Read input pin (pin: 0/1) 
http://IP/output/pin/num | Set output pin (pin: 0-8, num: 0-1023)
http://IP/servo/pin/num | Set servo pin (pin: 1-4, num: 0-180)
http://IP/servo2/pin/num | Set External servo pin (pin: 0-15, num: 0-180)
http://IP/motor/No/dir/num | Set motor (No: 1/2, dir: cw/acw, num: 0-1023)
http://IP/temperature | Return temperature 
http://IP/humidity | Return humidity

### 4. METAS Car API
The below API is only for METAS car. You can refer to https://www.youtube.com/watch?v=zPAyf31GXbs

Link | Description 
----|------
http://IP/forward/speed | Move forward (speed: 0-1023)
http://IP/backward/speed | Move backward (speed: 0-1023)
http://IP/left/speed | Turn left (speed: 0-1023)
http://IP/right/speed | Turn right (speed: 0-1023)
http://IP/stop | Stop
