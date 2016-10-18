
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
local R_CW = 5 --右脚正转
local R_ACW = 4 --右脚反转
local L_CW = 2 --左脚正转
local L_ACW = 3 --左脚反转

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
    pwm.setup(R_CW,100,200)
    pwm.setup(R_ACW,100,200)
    pwm.setup(L_CW,100,200) 
    pwm.setup(L_ACW,100,200) 

    pwm.start(R_CW)
    pwm.start(R_ACW)
    pwm.start(L_CW)
    pwm.start(L_ACW)
	
end


car_init()

  
  if mode == "forward" or mode=="forwards"then 
	
    pwm.setduty(R_CW,1000) 
    pwm.setduty(R_ACW,0)
    pwm.setduty(L_ACW,0)
    pwm.setduty(L_CW,1000) 
    answer['message'] = "car forwards now... "   
	
	
  elseif mode == "backward" or mode=="backwards" then
	
	
    pwm.setduty(R_CW,0) 
    pwm.setduty(R_ACW,1000)
    pwm.setduty(L_ACW,1000)
    pwm.setduty(L_CW,0) 
    answer['message'] = "car backwards now... " 
	
	
  elseif  mode == "left" then

    pwm.setduty(R_CW,0) 
    pwm.setduty(R_ACW,1000)
    pwm.setduty(L_ACW,0)
    pwm.setduty(L_CW,1000)
	answer['message'] = "car left now... " 
  elseif mode == "right" then

    pwm.setduty(R_CW,1000) 
    pwm.setduty(R_ACW,0)
    pwm.setduty(L_ACW,1000)
    pwm.setduty(L_CW,0) 
	
	
	answer['message'] = "car right now... " 

  elseif mode == "stop" then
    pwm.setduty(R_CW,200) 
    pwm.setduty(R_ACW,200)
    pwm.setduty(L_ACW,200)
    pwm.setduty(L_CW,200) 
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