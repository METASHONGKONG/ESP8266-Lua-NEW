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

	pwm.setup(5,50,70) --右脚正转
	pwm.setup(4,50,70) --右脚反转
	pwm.setup(2,50,70) --左脚正转
	pwm.setup(3,50,70) --左脚反转

	pwm.start(5)
	pwm.start(4)
	pwm.start(2)
	pwm.start(3)
end

--AP SSID/PW config--                
apcfg = {}
apcfg.ssid = "Metas"..node.chipid()                    
apcfg.ssid = string.sub(apcfg.ssid,1,string.len(apcfg.ssid)-1)
apcfg.pwd = "12345678"

--Reset network wifi--
pwm.setup(2,50,1023) -- Because pin 3 is initially 1023 value, stop pin 2 first
pwm.start(2)
gpio.mode(3,gpio.INPUT)

local timeout = 0        
tmr.alarm(1,500,1,function()                 
	timeout = timeout+0.5
	flash_value = gpio.read(3)
	print("Reset checking..  "..flash_value)
	
	if timeout == 4 then
		tmr.stop(1)
	else
		if flash_value == 0 then
			tmr.stop(0)
			tmr.stop(4)
			tmr.stop(5)
			timeout = 3.5
			file.remove("config_wifi.lua")
			display_word(" Reset OK")
			print("Reset OK")                
			tmr.alarm(2,4000,0,function() display_word("Restart...")    end)
			tmr.alarm(3,5000,0,function() node.restart()    end)                
		end
	end
end)  

print("ADC Checking: "..adc.read(0))

--Show welcome page 5s--
display_word("  Welcome")

--Input wifi/connect wifi--
tmr.alarm(4,5000,0,function()
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
                tmr.alarm(0,5000,0,function() display_three_row(apcfg.ssid,apcfg.pwd,"192.168.4.1")	end) 
            end
        end)
		
		rest = require "arest"
        srv=net.createServer(net.TCP) 
        srv:listen(80,function(conn)
            conn:on("receive",function(conn,request) rest.handle(conn, request) end)
            conn:on("sent",function(conn) conn:close() end)
        end)
        
    else
        print("run_config: input wifi")
        --require "run_config"
        display_two_row("NodeOne"," OS Ver1.4")
        tmr.alarm(5,5000,0,function()  display_word("Input Wifi") Initialization() end)
        tmr.alarm(0,10000,0,function()
            wifi.ap.config(apcfg)  
            wifi.setmode(wifi.SOFTAP)
            display_three_row(apcfg.ssid,apcfg.pwd,"192.168.4.1")
            
			rest = require "arest"
            srv=net.createServer(net.TCP) 
            srv:listen(80,function(conn)
                conn:on("receive",function(conn,request) rest.handle(conn, request) end)
                conn:on("sent",function(conn) conn:close() end)
            end)
        end)  
    end
end)
