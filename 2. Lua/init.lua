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
                    
                    --m = mqtt.Client(wifi.sta.getmac(), 10, "user", "password")
                    --m:lwt("/lwt", wifi.sta.getmac(), 0, 0)
                    m = mqtt.Client(node.chipid(), 10, "user", "password")
                    m:lwt("/lwt", node.chipid(), 0, 0)

                    print ("Attemp to connect") 
                    m:connect("115.160.160.214", 1883, 0, function(conn) print("connected..") end, 
                                                        function(client, reason) print("failed reason: "..reason) end)
                    
                    array = {a0 = 0,a1 = 0,temp=0,humi=0}
                    
                    --value = 0
                    newValue = 0
                    print ("on connect")
                    m:on("connect", function(client) 
                        print ("connected...") 
                        m:subscribe("output/"..node.chipid(),0, function(client) print("subscribe success") end)
                        --m:publish("input/"..node.chipid(),value,0,0, function(client) print(value.." sent") end)
                        
                        tmr.alarm(4,1000,1,function ()
                            print ("----Checking----")
                            local trigger = false
                            for k,v in pairs(array)do
                                if k == "a0" then gpio.write(0,gpio.HIGH) newValue = adc.read(0) elseif k == "a1" then gpio.write(0,gpio.LOW) newValue = adc.read(0)
                                elseif k == "temp" then newValue = read_temp() elseif k == "humi" then newValue = read_humi() end
                                
                                --if (v ~= newValue) then
                                if (math.abs(v - newValue) > 5) then
                                    array[k] = newValue
                                    --for k,v in pairs(array) do print(k,v) end
                                    trigger = true                                    
                                end
                            end                                                        
                            if trigger then
                                m:publish("input/"..node.chipid(),table_to_json(array),0,0, function(client) print(table_to_json(array).." sent") end)
                            end
                        end) 
                    end)
                    
                    print ("on offline")
                    m:on("offline", function(con) 
                        print ("reconnecting...") 
                        print(node.heap())
                        tmr.alarm(0, 1000, 1, function()
                            m:connect("115.160.160.214", 1883, 0)
                        end)
                    end)

                    print ("on message")
                    -- on publish message receive event
                    m:on("message", function(client, topic, data) 
                        print("Topic: "..topic ) 
                        if data ~= nil then
                            print("Data received: "..data)
                            
                            t = cjson.decode(data)
                            for k,v in pairs(t) do 
                                    if( k == "mode") then
                                        mode = v
                                    elseif( k == "pin") then
                                        pin = tonumber(v)
                                    elseif ( k == "intensity") then
                                        intensity = tonumber(v)
                                    end
                            end
                            if (mode == "pwm") then
                                if intensity <= 0 then
                                    intensity = 0
                                elseif  intensity >= 1023 then
                                    intensity=1023
                                end
                                pwm.setup(pin,50,intensity)	
                                pwm.start(pin)
                            elseif (mode == "digital") then
                                if (intensity == 0) then
                                    pwm.close(pin)
                                    gpio.mode(pin, gpio.OUTPUT)
                                    gpio.write(pin, gpio.LOW)
                                else
                                    pwm.close(pin)
                                    gpio.mode(pin, gpio.OUTPUT)
                                    gpio.write(pin, gpio.HIGH)
                                end
                            end
                            
                        end

                        
                    end)


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