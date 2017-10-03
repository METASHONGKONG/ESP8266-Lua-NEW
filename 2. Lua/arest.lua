--加载文件 temperature, PM2.5, RGB--
require "si7021"
--local M = require "pca8695"

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
        if mode ~= "wifi" then
            pin = tonumber(pin)
        end
      else
        pin = string.sub(request_handle, 0, (e-1))
        if mode ~= "wifi" then
            pin = tonumber(pin)
        end
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

    if mode == "wifi" then
        if pin~=nil and string.len(command)>=8 then
            file.open("config_wifi.lua","w+")
            --pin = string.gsub(pin,"%20"," ")
            pin = string.gsub(pin,"+"," ")
            file.writeline('ssid="'..pin..'"')
            file.writeline('pwd="'..command..'"')
            file.close()
            node.restart()
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
		answer['message'] = motor_control(pin,0,0,pin,"forward",pin)
	elseif mode == "backward" then
		answer['message'] = motor_control(0,pin,pin,0,"backward",pin)
	elseif  mode == "left" then
		answer['message'] = motor_control(pin,0,pin,0,"left",pin)
	elseif mode == "right" then
		answer['message'] = motor_control(pin,0,0,pin,"right",pin)
	elseif mode == "stop" then
		answer['message'] = motor_control(200,200,200,200,"stop",pin)
    end	
                   
    if mode == "temperature" then
        local temp = read_temp()
        answer['message'] = ""..temp	
    end
    
    if mode == "humidity" then
        local humi = read_humi()
        answer['message'] = ""..humi	
    end
        
    conn:send("HTTP/1.1 200 OK\r\nContent-type: text/html\r\nAccess-Control-Allow-Origin:* \r\n\r\n" .. answer .. "\r\n")
end

function motor_control(M2_CW_speed,M2_ACW_speed,M1_CW_speed,M1_ACW_speed,direction,speed)

	pwm.setduty(5,M2_CW_speed) 
	pwm.setduty(4,M2_ACW_speed)
	pwm.setduty(2,M1_CW_speed)
	pwm.setduty(3,M1_ACW_speed) 
	return "car "..direction.." "..speed.." now... "
	
end

return aREST