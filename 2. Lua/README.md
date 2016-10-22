##Step (How to use):
1.	Firstly, use your computer or smart phone to connect the wifi emitted from NodeOne.
In this example, 
Wifi: Metas138927, password: 12345678
2.	Secondly, Type 192.168.4.1 in your browser. Afterwards, input the required wifi and password.
3.	Finally, the NodeOne will connect the WIFI and the IP address will appear.

Note: 

1.	If the WIFI cannot be connected successfully after 30s, it will be changed to “Direct control” mode.

2.	If you want to reset the WIFI, snap the press switch (pressed) into input port A0 and turn on NodeOne.

Direct control mode: The NodeOne act as an router, use your mobile phone to connect the NodeOne and control it directly.

###General API

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

###Function pin API

Link | Description 
----|------
http://IP/input/pin | Read input pin (pin: 0/1) 
http://IP/output/pin/num | Set output pin (pin: 0~8, num: 0~1023)
http://IP/servo/pin/num | Set servo pin (pin: 0~8, num: 0~120)
http://IP/motor/No/dir/num | Set motor (No: 1/2, dir: cw/acw, num: 0~1023)
http://IP/PM | return PM value
http://IP/temperature | return temperature 
http://IP/humidity | return humidity
http://IP/rgb/address/off | turn off rgb (address: 0x40)
http://IP/rgb/address/r/g/b/w | Control rgb (address: 0x40, rgbw: 0~100)
