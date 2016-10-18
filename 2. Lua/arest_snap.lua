--加载文件--
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
local R_D0 = 0 --右脚正反转
local R_D5 = 5 --右脚马达
local L_D4 = 4 --左脚正反转
local L_D3 = 3 --左脚马达





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

-- Debug output
print('Mode: ', mode)
print('Pin: ', pin)
print('Command: ', command)

-- Apply command
if pin == nil then
  for key,value in pairs(variables) do
     if key == mode then answer[key] = value end
  end
end
--
function car_init()
	gpio.mode(R_D0,gpio.OUTPUT)
	gpio.mode(R_D5,gpio.OUTPUT)
	gpio.mode(L_D4,gpio.OUTPUT)
	gpio.mode(L_D3,gpio.OUTPUT)
	
end


car_init()

  
if mode == "mode" then
  if command == "o" then
    gpio.mode(pin, gpio.OUTPUT)
    answer['message'] = "" .. pin .. " set to output" 
  elseif command == "i" then
    gpio.mode(pin, gpio.INPUT)
    answer['message'] = "" .. pin .. " set to input"
  end 
end
 if mode == "digital" then
  
  if command == "0" then 
    gpio.write(pin, gpio.LOW)
    answer['message'] = "" .. pin .. " set to 0"   
  elseif command == "1" then
    gpio.write(pin, gpio.HIGH)
    answer['message'] = "" .. pin .. " set to 1" 
  elseif command == "r" then
    value = gpio.read(pin)
    answer['return_value'] = value
  end
end

	if mode == "analog" then
		gpio.mode(8,gpio.OUTPUT)
		if pin == 0 then
			gpio.write(8,gpio.HIGH)
		else
			gpio.write(8,gpio.LOW)
		end
		value = adc.read(0)
		answer['return_value'] = value
	end
  

  
  
  
  if mode == "forward" then 
	
		gpio.write(R_D5,gpio.HIGH)
		gpio.write(L_D3,gpio.HIGH)
		gpio.write(R_D0,gpio.HIGH)
		gpio.write(L_D4,gpio.LOW)
		answer['message'] = "car forward now... "   
		
		
	  elseif mode == "backward" then
		
		
		gpio.write(R_D5,gpio.HIGH)
		gpio.write(L_D3,gpio.HIGH)
		gpio.write(R_D0,gpio.LOW)
		gpio.write(L_D4,gpio.HIGH)
		answer['message'] = "car backward now... " 
		
		
	  elseif  mode == "left" then

		gpio.write(R_D5,gpio.HIGH)
		gpio.write(L_D3,gpio.HIGH)
		gpio.write(L_D4,gpio.HIGH)
		gpio.write(R_D0,gpio.HIGH)
		answer['message'] = "car left now... " 
	  elseif mode == "right" then

		gpio.write(R_D5,gpio.HIGH)
		gpio.write(L_D3,gpio.HIGH)
		gpio.write(R_D0,gpio.LOW)
		gpio.write(L_D4,gpio.LOW)
		
		
		answer['message'] = "car right now... " 

	  elseif mode == "stop" then
		gpio.write(R_D5,gpio.LOW)
		gpio.write(L_D3,gpio.LOW)
		answer['message'] = "car stop now... " 
	end	


	if mode == "pwm" then
		num	= tonumber(command)
		pwm.setup(pin,100,num)	
		pwm.start(pin)
		answer['message'] = ""..pin..":"..num	
	end
	
	if mode == "servo" then
		num = tonumber(command)
		if num <= 0 then
			num = 0
		elseif  num >= 120 then
			num=120
			
		end
		pwm.setup(pin,100,num*1023/120)
		pwm.start(pin)
		answer['message'] = ""..pin..":"..num
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