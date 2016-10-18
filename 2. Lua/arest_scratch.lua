local aREST = {}

-- Handler
function aREST.handle(conn, request)
    
    -- Variables
    local mode;
    local pin;
    local command;
    local password;
    local answer = {};
    
    local R_CW = 5 --右脚正转
    local R_ACW = 4 --右脚反转
    local L_CW = 2 --左脚正转
    local L_ACW = 3 --左脚反转

    -- HTTP Request Parser
    local httprequest = string.sub(request, 1, string.find(request, "\r\n") + 1);
    local temparray = string.gmatch(httprequest, "([^ ]*) ");
    temparray(0);
    local url = temparray(1);
    temparray = nil;
    
    local path = {};
    for i in string.gmatch(url, "/([^/]*)") do
        path[#path + 1] = i;
    end
    
    print('httprequest: ', httprequest)
    
    mode=path[1];
    pin=path[2];
    command=path[3];
    --check password
	-- password=path[4];
	-- if tonumber(password) ~= connectionpw then
        -- conn:send("HTTP/1.1 403 Forbidden\r\nConnection: close\r\n\r\n");
        -- conn:close();
        -- return;
    -- end
    
    -- Process Request
    if mode == "reset" then
        pwm.stop(1);
        pwm.stop(2);
		pwm.stop(3);
        pwm.stop(4);

        pwm.setup(R_CW,100,200)
        pwm.setup(R_ACW,100,200)
        pwm.setup(L_CW,100,200) 
        pwm.setup(L_ACW,100,200) 

        pwm.start(R_CW)
        pwm.start(R_ACW)
        pwm.start(L_CW)
        pwm.start(L_ACW)
        
        gpio.mode(1,gpio.OUTPUT);
        gpio.write(1,gpio.LOW);
        gpio.mode(8,gpio.OUTPUT);
        gpio.write(8,gpio.LOW);

        answer["message"] = "Pin Reset";
        
    elseif mode == "mode" then
      if command == "o" then
        gpio.mode(pin, gpio.OUTPUT);
        answer["message"] = "Pin D" .. pin .. " set to output";
      elseif command == "i" then
        gpio.mode(pin, gpio.INPUT);
        answer["message"] = "Pin D" .. pin .. " set to input";
      elseif command == "p" then
        pwm.setup(pin, 100, 0);
        pwm.start(pin);
        answer["message"] = "Pin D" .. pin .. " set to PWM";
      end

    elseif mode == "digital" then
		if command == "0" then
			gpio.write(pin, gpio.LOW);
			answer["message"] = "Pin D" .. pin .. " set to 0";
		elseif command == "1" then
			gpio.write(pin, gpio.HIGH);
			answer["message"] = "Pin D" .. pin .. " set to 1";
		elseif command == "r" then
			answer["return_value"] = gpio.read(pin);
		elseif command == nil then
			answer["return_value"] = gpio.read(pin);
		end
	  
	elseif mode == "analog" then
		gpio.mode(0,gpio.OUTPUT);
		if pin == "0" then
			gpio.write(0, gpio.HIGH);
		else
			gpio.write(0, gpio.LOW);
		end
        answer["return_value"] = tonumber(adc.read(0));
    
    elseif mode == "pwm" then
        local num = tonumber(command);
        if num == 0 then
            pwm.stop(pin);
        else
            pwm.setup(pin,100,num);
            pwm.start(pin);
        end
        answer["message"] = "pin"..pin.."num:"..num;

    elseif mode == "i2cwrite" then
        local datastr = "";
        for i in string.gmatch(command, "_?([^_]*)") do
            if tonumber(i) == nil then break end
            datastr = datastr..string.char(tonumber(i));
        end
        local addrtemp = string.gmatch(pin, "_?([^_]*)");
        i2c_write_reg(tonumber(addrtemp(0)), tonumber(addrtemp(1)), datastr);
        
    elseif mode == "i2cread" then
        local addrtemp = string.gmatch(pin, "_?([^_]*)");
        local datastr = i2c_read_reg(tonumber(addrtemp(0)), tonumber(addrtemp(1)), tonumber(command));
        answer["return_value"] = "";
        for i = 1, #datastr do
            answer["return_value"] = answer["return_value"]..tonumber(string.byte(datastr:sub(i, i))).."_";
        end
        answer["return_value"] = string.sub(answer["return_value"], 1, -2);
    
    elseif mode == "servo" then
        local num = math.floor(tonumber(command) * 5683 / 10000) + 25;
        pwm.setup(pin,50,num);
        pwm.start(pin);
        answer["message"] = "pin"..pin.."servo:"..num;
    
    elseif mode == "car" then
        if command=="backward" or  command=="backwards" then
            pwm.setduty(R_CW,1000) 
            pwm.setduty(R_ACW,0)
            pwm.setduty(L_ACW,0)
            pwm.setduty(L_CW,1000) 
        elseif command=="forward" or command=="forwards"then
            pwm.setduty(R_CW,1000) 
            pwm.setduty(R_ACW,0)
            pwm.setduty(L_ACW,0)
            pwm.setduty(L_CW,1000) 
        elseif command=="left" then
            pwm.setduty(R_CW,0) 
            pwm.setduty(R_ACW,1000)
            pwm.setduty(L_ACW,0)
            pwm.setduty(L_CW,1000)
        elseif command=="right" then
            pwm.setduty(R_CW,1000) 
            pwm.setduty(R_ACW,0)
            pwm.setduty(L_ACW,1000)
            pwm.setduty(L_CW,0)
        else
            pwm.setduty(R_CW,200) 
            pwm.setduty(R_ACW,200)
            pwm.setduty(L_ACW,200)
            pwm.setduty(L_CW,200) 
        end
		
    end

    jsonreply(conn, answer);

    mode = nil;
    pin = nil;
    command = nil;
    password = nil;
    answer = nil;
end

function jsonreply(conn, answer)
    answer["id"] = "1";
    answer["name"] = "esp8266";
    conn:send("HTTP/1.1 200 OK\r\nContent-type: text/html\r\nAccess-Control-Allow-Origin:* \r\n\r\n" .. table_to_json(answer) .. "\r\n")
	conn:close();
end

function table_to_json(json_table)
    local json = "{";
    for key, value in pairs(json_table) do
      json = json .. "\"" .. key .. "\": \"" .. value .. "\", ";
    end
    json = string.sub(json, 1, -3);
    json = json .. "}";
    return json;
end
return aREST