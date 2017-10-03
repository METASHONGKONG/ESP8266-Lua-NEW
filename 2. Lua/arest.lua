--加载文件 temperature, PM2.5, RGB--
require "si7021"
--local M = require "pca8695"

local aREST = {}

function aREST.handle(conn, request)

    --usb下载口朝向车头--
    local M2_CW = 5 --右脚正转
    local M2_ACW = 4 --右脚反转
    local M1_CW = 2 --左脚正转
    local M1_ACW = 3 --左脚反转
	
    -- New request, Find start/end
    local e = string.find(request, "/")
    local request_handle = string.sub(request, e + 1)
    e = string.find(request_handle, "HTTP")
    request_handle = string.sub(request_handle, 0, (e-2))
    print('-----------------------')
    print('Request: ', request_handle)
	
	-- Pattern: http://IP/mode/value[2]/value[3]/value[4]
	local value={} ; i=1
	for str in string.gmatch(request_handle, "([^//]+)") do
			value[i] = str
			i = i + 1
	end
	
	local mode = value[1]
	local message

	--------------Wifi---------------------
    if mode == "wifi" then
        if value[2]~=nil and string.len(value[3])>=8 then
            file.open("config_wifi.lua","w+")
            value[2] = string.gsub(value[2],"+"," ")
            file.writeline('ssid="'..value[2]..'"')
            file.writeline('pwd="'..value[3]..'"')
            file.close()
            node.restart()
        end
	else
		value[2] = tonumber(value[2])
    end
    
    --------------General---------------------
    if mode == "mode" then
        if value[3] == "o" then
            gpio.mode(value[2], gpio.OUTPUT)
            message = "" .. value[2] .. " set to output" 
        elseif value[3] == "i" then
            gpio.mode(value[2], gpio.INPUT)
            message = "" .. value[2] .. " set to input"
        elseif value[3] == "p" then
            pwm.setup(value[2], 50, 0);
            pwm.start(value[2]);
            answer["message"] = "Pin D" .. value[2] .. " set to PWM";
        end 
    end

    if mode == "digital" then
        if value[3] == "0" then 
            gpio.mode(value[2], gpio.OUTPUT)
            gpio.write(value[2], gpio.LOW)
            message = "" .. value[2] .. " set to 0"   
        elseif value[3] == "1" then
            gpio.mode(value[2], gpio.OUTPUT)
            gpio.write(value[2], gpio.HIGH)
            message = "" .. value[2] .. " set to 1" 
        elseif value[3] == "r" then
            value = gpio.read(value[2])
            answer['return_value'] = value
        end
    end

    if mode == "pwm" or mode == "output" then
		num	= tonumber(value[3])
        if num <= 0 then
            num = 0
        elseif  num >= 1023 then
            num=1023
        end
		pwm.setup(value[2],50,num)	
		pwm.start(value[2])
		message = ""..value[2]..":"..num	
	end
    
    if mode == "analog" or mode == "input" then
        gpio.mode(0,gpio.OUTPUT)
        if value[2] == 0 then
            gpio.write(0,gpio.HIGH)
        else
            gpio.write(0,gpio.LOW)
        end
        value = adc.read(0)
        if value == 1024 then
            value = 1023
        end
        message = value
    end
      
    --------------Function port---------------------
    if mode == "servo" then
        num = tonumber(value[3])
        if num <= 0 then
            num = 0
        elseif  num >= 180 then
            num=180
        end
        pwm.setup(value[2],50,math.floor(33+((128-33)*num/180)))
        pwm.start(value[2])
        message = ""..value[2]..":"..num
    end
    
    if mode == "motor" then
        if value[2] == 1 then 
            if value[3] == "cw" then 
                pwm.setduty(M1_CW,g) 
                pwm.setduty(M1_ACW,0)
                message = "Motor " .. value[2] .. " set to " .. g .. " in " .. value[3]   
            elseif value[3] == "acw" then
                pwm.setduty(M1_CW,0) 
                pwm.setduty(M1_ACW,g)
                message = "Motor " .. value[2] .. " set to " .. g .. " in " .. value[3]  
            end 
        elseif value[2] == 2 then
            if value[3] == "cw" then 
                pwm.setduty(M2_ACW,0) 
                pwm.setduty(M2_CW,g)
                message = "Motor " .. value[2] .. " set to " .. g .. " in " .. value[3]   
            elseif value[3] == "acw" then
                pwm.setduty(M2_ACW,g) 
                pwm.setduty(M2_CW,0)
                message = "Motor " .. value[2] .. " set to " .. g .. " in " .. value[3]  
            end 
        end
    end
    
	if mode == "forward" then 
		message = motor_control(value[2],0,0,value[2],"forward",value[2])
	elseif mode == "backward" then
		message = motor_control(0,value[2],value[2],0,"backward",value[2])
	elseif  mode == "left" then
		message = motor_control(value[2],0,value[2],0,"left",value[2])
	elseif mode == "right" then
		message = motor_control(value[2],0,0,value[2],"right",value[2])
	elseif mode == "stop" then
		message = motor_control(200,200,200,200,"stop",value[2])
    end	
                   
    if mode == "temperature" then
        local temp = read_temp()
        message = ""..temp	
    end
    
    if mode == "humidity" then
        local humi = read_humi()
        message = ""..humi	
    end
        
    conn:send("HTTP/1.1 200 OK\r\nContent-type: text/html\r\nAccess-Control-Allow-Origin:* \r\n\r\n" .. message .. "\r\n")
end

function motor_control(M2_CW_speed,M2_ACW_speed,M1_CW_speed,M1_ACW_speed,direction,speed)

	pwm.setduty(5,M2_CW_speed) 
	pwm.setduty(4,M2_ACW_speed)
	pwm.setduty(2,M1_CW_speed)
	pwm.setduty(3,M1_ACW_speed) 
	return "car "..direction.." "..speed.." now... "
	
end

return aREST