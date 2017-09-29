require "oled"
init_set()

--Initialize all pins--
function Initialization()
	gpio.mode(1,gpio.OUTPUT);
	gpio.write(1,gpio.LOW);
	gpio.mode(8,gpio.OUTPUT);
	gpio.write(8,gpio.LOW);
	gpio.mode(0,gpio.OUTPUT);
	gpio.write(0,gpio.HIGH);
	
	local M2_CW = 5 --右脚正转
	local M2_ACW = 4 --右脚反转
	local M1_CW = 2 --左脚正转
	local M1_ACW = 3 --左脚反转

	pwm.setup(M2_CW,50,70)
	pwm.setup(M2_ACW,50,70)
	pwm.setup(M1_CW,50,70) 
	pwm.setup(M1_ACW,50,70) 

	pwm.start(M2_CW)
	pwm.start(M2_ACW)
	pwm.start(M1_CW)
	pwm.start(M1_ACW)
end

--AP SSID/PW config--                
apcfg = {}
apcfg.ssid = "Metas"..node.chipid()                    
apcfg.ssid = string.sub(apcfg.ssid,1,string.len(apcfg.ssid)-1)
apcfg.pwd = "12345678"

--Reset network wifi--
gpio.mode(3,gpio.INPUT)

local timeout = 0        
tmr.alarm(1,500,1,function()                 
	timeout = timeout+0.5
	flash_value = gpio.read(3)
	print("Reset checking..  "..flash_value)
	
	if timeout == 5 then
		tmr.stop(1)
	else
		if flash_value == 0 then
			tmr.stop(0)
			tmr.stop(4)
			tmr.stop(5)
			timeout = 4.5
			file.remove("config_wifi.lua")
			display_word(" Reset OK")
			print("Reset OK")                
			tmr.alarm(2,4000,0,function() display_word("Restart...")    end)
			tmr.alarm(3,5000,0,function() node.restart()    end)                
		end
	end
end)  

print("ADC Checking: "..adc.read(0))

--Show welcome page 2s--
display_word("  Welcome")

rest = require "arest"



--Input wifi/connect wifi--
tmr.alarm(4,2000,0,function()
    if pcall(function ()require "config_wifi" end) then
        
		Initialization()        
        display_three_row("WIFI",ssid,pwd)
        
        srv = nil
        wifi.setmode(wifi.STATION)
        wifi.sta.config(ssid,pwd)
        wifi.sta.connect()
        local timeout = 0
        local ip = wifi.sta.getip()        
        
        tmr.alarm(0,1000,1,function ()
            timeout = timeout+1
            
            if timeout <= 25 then
            
                if ip == nil then
                    print("Connecting...")
                    ip=wifi.sta.getip()
                    if timeout >=4 then
                        display_word("Connecting..") 
                    end
                else
                    tmr.stop(0)
                    print('IP: ', ip) 
                    len_num = string.len(ip)
                    display_word("  Ready")
                    tmr.alarm(0,5000,0,function() display_three_row(string.sub(ip,1,10),string.sub(ip,11,len_num),"Connected")	end) 
                end
                
            else
                tmr.stop(0)

                wifi.ap.config(apcfg)  
                wifi.setmode(wifi.SOFTAP)   
                
                display_word(" Time Out")  
                --display_word("Direct Mode") 
                tmr.alarm(0,5000,0,function() display_three_row(apcfg.ssid,apcfg.pwd,wifi.ap.getip())	end) 
            end
        end)

        srv=net.createServer(net.TCP) 
        srv:listen(80,function(conn)
            conn:on("receive",function(conn,request) rest.handle(conn, request) end)
            conn:on("sent",function(conn) conn:close() end)
        end)
        
    else
        print("run_config: input wifi")
        --require "run_config"
        display_two_row("NodeOne"," OS Ver1.3")
        tmr.alarm(5,5000,0,function()  display_word("Input Wifi") end)
        tmr.alarm(0,10000,0,function()
            
            wifi.ap.config(apcfg)  
            wifi.setmode(wifi.SOFTAP)
            display_three_row(apcfg.ssid,apcfg.pwd,wifi.ap.getip())
            
            srv=net.createServer(net.TCP) 
            srv:listen(80,function(conn)
                conn:on("receive",function(conn,request) rest.handle(conn, request) end)
                conn:on("sent",function(conn) conn:close() end)
            end)
        end)  
    end
end)
