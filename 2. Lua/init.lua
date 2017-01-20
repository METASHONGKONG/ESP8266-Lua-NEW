require "oled"
init_set()

--Initialize all pins--

gpio.mode(1,gpio.OUTPUT);
gpio.write(1,gpio.LOW);
gpio.mode(8,gpio.OUTPUT);
gpio.write(8,gpio.LOW);
gpio.mode(0,gpio.OUTPUT)
gpio.write(0,gpio.HIGH)

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
    
--Reset network wifi--

analog_value = adc.read(0) 
if analog_value >= 800 then
    local timeout = 0    
    print("Reset mode")
    tmr.alarm(1,500,1,function()                 
        timeout = timeout+1
        analog_value = adc.read(0)
        print("Checking..  "..analog_value)
        
        if timeout == 5 then
            tmr.stop(1)
        else
            if analog_value < 100 then
                tmr.stop(0)
                tmr.stop(4)
                tmr.stop(5)
                timeout = 4
                file.remove("config_wifi.lua")
                display_word(" Reset OK")
                print("Reset OK")                
                tmr.alarm(2,4000,0,function() display_word("Restart...")	end)
                tmr.alarm(3,5000,0,function() node.restart()	end)                
            end
        end
    end)  
end
print(analog_value)

--Welcome page with OS version--
display_word("  Welcome")


--Input wifi/connect wifi--
tmr.alarm(4,5000,0,function()
    if pcall(function ()require "config_wifi" end) then
            
        srv = nil
        wifi.setmode(wifi.STATION)
        wifi.sta.config(ssid,pwd)
        wifi.sta.connect()
        local timeout = 0
        local ip = wifi.sta.getip()
        
        tmr.alarm(0,1000,1,function ()
            timeout = timeout+1
            
            if ip == nil then

                print("please wait")
                
                if timeout >= 25 then
                    --file.remove("config_wifi.lua")
                    cfg = {}
                    cfg.ssid = "Metas"..node.chipid()
                    l = string.len(cfg.ssid)
                    cfg.ssid = string.sub(cfg.ssid,1,l-1)
                    cfg.pwd = "12345678"
                    wifi.ap.config(cfg)  
                    wifi.setmode(wifi.SOFTAP)
                    ip = wifi.ap.getip()                        
                    display_word(" Time Out")                                              
                    
                else	               
                    ip = wifi.sta.getip()
                    if timeout < 4 then                   
                        display_wifi(ssid,pwd)
                    else
                        display_word("Connecting..") 
                    end
                end
            else
                tmr.stop(0)
                            
                print('IP: ', ip)        
                rest = require "arest"
                    
                if timeout>=25 then
                    display_word("Direct Mode") 
                    tmr.alarm(0,5000,0,function() init_display(cfg.ssid,cfg.pwd,ip)	end) 
                else
                    len_num = string.len(ip)
                    display_word("  Ready")
                    tmr.alarm(0,5000,0,function() display_ip(ssid,string.sub(ip,1,10),string.sub(ip,11,len_num))	end)  
                    
                    --mqtt
                    m = mqtt.Client(wifi.sta.getmac(), 10, "user", "password")
                    m:lwt("/lwt", wifi.sta.getmac(), 0, 0)

                    print ("Attemp to connect") 
                    -- for TLS: m:connect("192.168.11.118", secure-port, 1)
                    
                    m:connect("192.168.1.22", 1883, 0, function(conn) print("connected") end, 
                                                         function(client, reason) print("failed reason: "..reason) end)
                                                        
                    m:on("connect", function(client) print ("connected") end)
                    
                    print ("offline")
                    m:on("offline", function(con) 
                         print ("reconnecting...") 
                         print(node.heap())
                         tmr.alarm(0, 1000, 1, function()
                              m:connect("192.168.1.22", 1883, 0)
                         end)
                    end)

                    print ("message")
                    -- on publish message receive event
                    m:on("message", function(client, topic, data) 
                      print(topic .. ":" ) 
                      if data ~= nil then
                        print(data)
                      end
                    end)

                    

                    -- Calling subscribe/publish only makes sense once the connection
                    -- was successfully established. In a real-world application you want
                    -- move those into the 'connect' callback or make otherwise sure the 
                    -- connection was established.

                    -- subscribe topic with qos = 0
                    --m:subscribe("/topic",0, function(client) print("subscribe success") end)
                    -- publish a message with data = hello, QoS = 0, retain = 0
                    --m:publish("/topic","hello",0,0, function(client) print("sent") end)

                    --m:close();

                    --ws:connect('ws://115.160.160.214/websocket/actions')
                                
                end

                
            
            end
        end)
        
    else
        print("run_config: input wifi")
        require "run_config"
        display_two_row("NodeOne"," OS Ver1.3")
        tmr.alarm(5,5000,0,function()  display_word("Input Wifi") end)
        tmr.alarm(0,10000,0,function()
            init_display(cfg.ssid,cfg.pwd,wifi.ap.getip())
        end)  

    end
end)  