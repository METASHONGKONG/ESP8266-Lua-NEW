##Step (How to use):
1.	Firstly, use your computer or smart phone to connect the wifi emitted from NodeOne.
In this example, 
Wifi: Metas138927, password: 12345678
2.	Secondly, Type 192.168.4.1 in your browser. Afterwards, input the required wifi and password.
3.	Finally, the NodeOne will connect the WIFI and the IP address will appear.

####Note: 

1.	If the WIFI cannot be connected successfully after 30s, it will be changed to “Direct control” mode.

2.	If you want to reset the WIFI, snap the press switch (pressed) into input port A0 and turn on NodeOne.

Direct control mode: The NodeOne act as an router, use your mobile phone to connect the NodeOne and control it directly.

###1. General API
These APIs are general API that can control all function of the NodeOne. However, these APIs are for more advanced user.
For details, please refer to http://www.funmetas.com.hk/nodeone/

Link | Description 
----|------
http://IP/mode/pin/o | Set pin as output (pin: 0~8)  
http://IP/mode/pin/i | Set pin as input (pin: 0~8)
http://IP/mode/pin/p | Set pin as PWM (pin: 0~8)
http://IP/digital/pin/0 | Set the output of the pin as 0 (pin: 0~8)
http://IP/digital/pin/1 | Set the output of the pin as 1 (pin: 0~8)
http://IP/digital/pin/r | Read the value of the digital port (pin: 0~8)
http://IP/pwm/pin/num | Set pwm value of the pin (pin: 0~8, num: 0~1023)
http://IP/analog/pin | Read the analog value (pin: 0/1)



###2. Function pin API
Actually, there are 5 main functions for our NodeOne. Thus, the below APIs are for your EASY control.

1.	Input X2
2.	Output X2
3.	Servo X4
4.	Motor X2
5.	I2C X1 (temperature/humidity/RGB)


Link | Description 
----|------
http://IP/input/pin | Read input pin (pin: 0/1) 
http://IP/output/pin/num | Set output pin (pin: 0~8, num: 0~1023)
http://IP/servo/pin/num | Set servo pin (pin: 1~4, num: 0~180)
http://IP/motor/No/dir/num | Set motor (No: 1/2, dir: cw/acw, num: 0~1023)
http://IP/PM | Return PM value
http://IP/temperature | Return temperature 
http://IP/humidity | Return humidity
http://IP/rgb/address/off | Turn off rgb (address: 0x40)
http://IP/rgb/address/r/g/b/w | Control rgb (address: 0x40, rgbw: 0~100)




###3. METAS Car API
The below API is only for METAS car. You can refer to https://www.youtube.com/watch?v=zPAyf31GXbs

Link | Description 
----|------
http://IP/forward | Move forward
http://IP/backward | Move backward
http://IP/left | Turn left
http://IP/right | Turn right
http://IP/stop | Stop
