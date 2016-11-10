--加载文件 temperature, PM2.5, RGB--
require "si7021"
require "PM"
local M = require "pca8695"

local aREST = {}

function aREST.handle(conn, request)

    -- Variables
    local pin 
    local command
    local value
    local answer = {}
    local mode
    local variables = {}
    local g
    local b
    local w

    --usb下载口朝向车头--
    local M2_CW = 5 --右脚正转
    local M2_ACW = 4 --右脚反转
    local M1_CW = 2 --左脚正转
    local M1_ACW = 3 --左脚反转

    -- Find start
    local e = string.find(request, "/")
    local request_handle = string.sub(request, e + 1)

    -- Cut end
    e = string.find(request_handle, "HTTP")
    request_handle = string.sub(request_handle, 0, (e-2))

    -- Find mode
    e = string.find(request_handle, "/")

    if e == nil then
      mode = request_handle
    else
      mode = string.sub(request_handle, 0, (e-1))
      
      -- Find pin & command
      request_handle = string.sub(request_handle, (e+1))
      e = string.find(request_handle, "/")

      if e == nil then
        pin = request_handle
        pin = tonumber(pin)
      else
        pin = string.sub(request_handle, 0, (e-1))
        pin = tonumber(pin)
        request_handle = string.sub(request_handle, (e+1))
        e = string.find(request_handle, "/")
        if e == nil then
            command  = request_handle
        else
            command = string.sub(request_handle, 0, (e-1))
            --Find RGB--
            request_handle = string.sub(request_handle, (e+1))
            
            e = string.find(request_handle, "/")
            if e == nil then
                g = request_handle
            else
                g=string.sub(request_handle, 0, (e-1))
                request_handle = string.sub(request_handle, (e+1))
                e = string.find(request_handle,"/")
                if e == nil then
                    b = request_handle
                else
                    b=string.sub(request_handle,0,(e-1))
                    request_handle = string.sub(request_handle,(e+1))
                    w = request_handle
                end
            end
        end        
      end
    end

    -- Debug output, pattern: http://IP/mode/pin/command/g/b/w
    print('-----------------------')
    print('Mode: ', mode)
    print('Pin: ', pin)
    print('Command: ', command)
    print('g: ', g)
    print('b: ', b)
    print('w: ', w)

    -- Apply command
    if pin == nil then
        for key,value in pairs(variables) do
            if key == mode then answer[key] = value end
        end
    end

    --------------General---------------------
    if mode == "mode" then
        if command == "o" then
            gpio.mode(pin, gpio.OUTPUT)
            answer['message'] = "" .. pin .. " set to output" 
        elseif command == "i" then
            gpio.mode(pin, gpio.INPUT)
            answer['message'] = "" .. pin .. " set to input"
        elseif command == "p" then
            pwm.setup(pin, 50, 0);
            pwm.start(pin);
            answer["message"] = "Pin D" .. pin .. " set to PWM";
        end 
    end

    if mode == "digital" then
        if command == "0" then 
            gpio.mode(pin, gpio.OUTPUT)
            gpio.write(pin, gpio.LOW)
            answer['message'] = "" .. pin .. " set to 0"   
        elseif command == "1" then
            gpio.mode(pin, gpio.OUTPUT)
            gpio.write(pin, gpio.HIGH)
            answer['message'] = "" .. pin .. " set to 1" 
        elseif command == "r" then
            value = gpio.read(pin)
            answer['return_value'] = value
        end
    end

    if mode == "pwm" or mode == "output" then
		num	= tonumber(command)
        if num <= 0 then
            num = 0
        elseif  num >= 1023 then
            num=1023
        end
		pwm.setup(pin,50,num)	
		pwm.start(pin)
		answer['message'] = ""..pin..":"..num	
	end
    
    if mode == "analog" or mode == "input" then
        gpio.mode(0,gpio.OUTPUT)
        if pin == 0 then
            gpio.write(0,gpio.HIGH)
        else
            gpio.write(0,gpio.LOW)
        end
        value = adc.read(0)
        if value == 1024 then
            value = 1023
        end
        answer['return_value'] = value
    end
      
    --------------Function port---------------------
    if mode == "servo" then
        num = tonumber(command)
        if num <= 0 then
            num = 0
        elseif  num >= 180 then
            num=180
        end
        pwm.setup(pin,50,math.floor(33+((128-33)*num/180)))
        pwm.start(pin)
        answer['message'] = ""..pin..":"..num
    end
    
    if mode == "motor" then
        if pin == 1 then 
            if command == "cw" then 
                pwm.setduty(M1_CW,g) 
                pwm.setduty(M1_ACW,0)
                answer['message'] = "Motor " .. pin .. " set to " .. g .. " in " .. command   
            elseif command == "acw" then
                pwm.setduty(M1_CW,0) 
                pwm.setduty(M1_ACW,g)
                answer['message'] = "Motor " .. pin .. " set to " .. g .. " in " .. command  
            end 
        elseif pin == 2 then
            if command == "cw" then 
                pwm.setduty(M2_ACW,0) 
                pwm.setduty(M2_CW,g)
                answer['message'] = "Motor " .. pin .. " set to " .. g .. " in " .. command   
            elseif command == "acw" then
                pwm.setduty(M2_ACW,g) 
                pwm.setduty(M2_CW,0)
                answer['message'] = "Motor " .. pin .. " set to " .. g .. " in " .. command  
            end 
        end
    end
    
  if mode == "forward" then 
        pwm.setduty(M2_CW,1000) 
        pwm.setduty(M2_ACW,0)
        pwm.setduty(M1_CW,0)
        pwm.setduty(M1_ACW,1000) 
        answer['message'] = "car forward now... "   
      elseif mode == "backward" then
        pwm.setduty(M2_CW,0) 
        pwm.setduty(M2_ACW,1000)
        pwm.setduty(M1_CW,1000)
        pwm.setduty(M1_ACW,0) 
        answer['message'] = "car backward now... " 
      elseif  mode == "left" then
        pwm.setduty(M2_CW,1000) 
        pwm.setduty(M2_ACW,0)
        pwm.setduty(M1_CW,1000)
        pwm.setduty(M1_ACW,0) 
        answer['message'] = "car left now... " 
      elseif mode == "right" then
        pwm.setduty(M2_CW,0) 
        pwm.setduty(M2_ACW,1000)
        pwm.setduty(M1_CW,0)
        pwm.setduty(M1_ACW,1000) 
        answer['message'] = "car right now... " 
      elseif mode == "stop" then
        pwm.setduty(M2_CW,200) 
        pwm.setduty(M2_ACW,200)
        pwm.setduty(M1_CW,200)
        pwm.setduty(M1_ACW,200) 
        answer['message'] = "car stop now... " 
    end	

    if mode == "PM" then 
        local pm_value = read_PM()
        answer['message'] = ""..pm_value	
    end
                   
    if mode == "temperature" then
        local temp = read_temp()
        answer['message'] = ""..temp	
    end
    
    if mode == "humidity" then
        local humi = read_humi()
        answer['message'] = ""..humi	
    end
    
    if mode == "rgb" then
        M.init(0,pin,1)
        if command == "off" then
            M.set_chan_off(0, 1)
            M.set_chan_off(1, 1)
            M.set_chan_off(2, 1)
            M.set_chan_off(3, 1)
            answer['message'] = "RGB_OFF"
        else
            M.set_chan_percent(0, tonumber(command))
            M.set_chan_percent(1, tonumber(g))
            M.set_chan_percent(2,  tonumber(b))
            M.set_chan_percent(3, tonumber(w))
            answer['message'] = "OK"
        end
            
    end               
        
    conn:send("HTTP/1.1 200 OK\r\nContent-type: text/html\r\nAccess-Control-Allow-Origin:* \r\n\r\n" .. table_to_json(answer) .. "\r\n")
    --conn:send("HTTP/1.1 200 OK\r\nContent-Type: application/json\r\nConnection: close\r\n\r\n" .. table_to_json(answer) .. "\r\n")
end

function table_to_json(json_table)

local json = ""
--json = json .. "{"

for key,value in pairs(json_table) do
  json = json .. value  --json = json .. "\"" .. key .. "\": \"" .. value .. "\", "
end

--json = string.sub(json, 0, -3)
--json = json .. "}"

return json

end

return aREST