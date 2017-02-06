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