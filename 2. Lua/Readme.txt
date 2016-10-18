主要项目有：test（左控制右），snap，scratch，car（比赛小车）
1.在AP模式下连接8266，选择要启动的项目，等待8266重启；
2.选择test项目时无需选择网络，等待重启时即可操作；
3.选择其他项目时需重启完成再重新连接8266，选择网络；
4.8266会重启并自动连接选择的网络，如果大于40S时则为AP模式，否则为sta模式;
5.如需选择其他项目时，需重启8266，在连接网络成功的情况下则需重复1,2,4步骤，否则需重复1,2，3,4步骤。



--Snap功能可自己添加减--

http://IP/forward --前进
http://IP/backward --后退
http://IP/left --左转
http://IP/right --右转
http://IP/stop --停止
http://IP/pwm/pin/num --pin取值为1~12，num取值为0~1023
http://IP/servo/pin/num --pin取值为1~12，num取值为0~120
http://IP/mode/pin/o --设置管脚pin为输出,pin取值范围为0~12
http://IP/mode/pin/i --设置管脚pin为输入，pin取值范围为0~12
http://IP/digital/pin/0 --设置管脚pin输出0，pin取值范围为0~12
http://IP/digital/pin/1 --设置管脚pin输出1，pin取值范围为0~12
http://IP/digital/pin/r --设置管脚pin读，pin取值范围为0~12
http://IP/analog/pin 读取模拟量,pin为0或1
http://IP/temperature  返回温度值
http://IP/humidity     返回湿度值
http://IP/rgb/address/off      关掉rgb
http://IP/rgb/address/r/g/b/w     调节rgb