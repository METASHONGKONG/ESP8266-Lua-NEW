
local aREST = {}


function aREST.handle(conn, request)

-- Variables
local pin 
local command
local value
local answer = {}
local mode
local variables = {}


--usb下载口朝向车头--
local R_D0 = 0 --右脚正反转
local R_D5 = 5 --右脚马达
local L_D4 = 4 --左脚正反转
local L_D3 = 3 --左脚马达

-- ID and name
answer['id'] = _id
answer["name"] = _name



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
    command = request_handle
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
function car_init()
	gpio.mode(R_D0,gpio.OUTPUT)
	gpio.mode(R_D5,gpio.OUTPUT)
	gpio.mode(L_D4,gpio.OUTPUT)
	gpio.mode(L_D3,gpio.OUTPUT)
	
end


car_init()

  
  if mode == "forward" or mode=="forwards"then 
	
	gpio.write(R_D5,gpio.HIGH)
	gpio.write(L_D3,gpio.HIGH)
	gpio.write(R_D0,gpio.HIGH)
	gpio.write(L_D4,gpio.LOW)
    answer['message'] = "car forwards now... "   
	
	
  elseif mode == "backward" or mode=="backwards" then
	
	
    gpio.write(R_D5,gpio.HIGH)
	gpio.write(L_D3,gpio.HIGH)
	gpio.write(R_D0,gpio.LOW)
	gpio.write(L_D4,gpio.HIGH)
    answer['message'] = "car backwards now... " 
	
	
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
		--tmr.delay(200000)
		--pwm.stop(pin)
		answer['message'] = "pin"..pin.."num:"..num	
	end

conn:send("HTTP/1.1 200 OK\r\nContent-Type: application/json\r\nConnection: close\r\n\r\n" .. table_to_json(answer) .. "\r\n")

end

function table_to_json(json_table)

local json = ""
json = json .. "{"

for key,value in pairs(json_table) do
  json = json .. "\"" .. key .. "\": \"" .. value .. "\", "
end

json = string.sub(json, 0, -3)
json = json .. "}"

return json

end

return aREST