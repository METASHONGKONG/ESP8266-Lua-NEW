require "oled"

init_set()
gpio.mode(3,gpio.OUTPUT)
gpio.write(3,gpio.LOW)
gpio.mode(5,gpio.OUTPUT)
gpio.write(5,gpio.LOW) 
gpio.mode(8,gpio.OUTPUT)
gpio.write(8,gpio.HIGH)
analog_value = adc.read(0)
if analog_value >= 800 then
	file.remove("config.lua")
	file.remove("config_wifi.lua")
end
print(analog_value)
if pcall(function ()require "config" end) then
	
	if value ~= "test" then
				if pcall(function ()require "config_wifi" end) then
					
					--file.remove("config.lua")
					srv = nil
					wifi.setmode(wifi.STATIONAP)
					wifi.sta.config(ssid,pwd)
					wifi.sta.connect()
					local timeout = 0
					local ip = wifi.sta.getip()
					tmr.alarm(0,1000,1,function ()
					timeout = timeout+1
				if ip == nil then
				
					 print("please wait")
					
					if timeout >= 40 then
						--file.remove("config_wifi.lua")
						cfg = {}
						cfg.ssid = "Metas"..node.chipid()
						l = string.len(cfg.ssid)
						cfg.ssid = string.sub(cfg.ssid,1,l-2)
						cfg.pwd = "12345678"
						wifi.ap.config(cfg)  
						ip = wifi.ap.getip()
						init_display(cfg.ssid,cfg.pwd,ip)
					else	
						display_runconfig(ssid,pwd)
						ip = wifi.sta.getip()
						
					end
				else
					tmr.stop(0)
					if value == "scratch" then
						math.randomseed(tmr.now());
					    connectionpw = math.random(0,255);
						local deviceid = "";
						for i in string.gmatch(ip..".", "([^\.]*)\.") do
						deviceid = deviceid..string.format("%02X", tonumber(bit.bxor(i, connectionpw)));
						end
						deviceid = deviceid..string.format("%02X", connectionpw);
						deviceid = string.sub(deviceid, 5);
						deviceid = string.sub(deviceid, 1, 3).." "..string.sub(deviceid, 4);
						if timeout>=40 then
							display_deviceid(cfg.ssid,cfg.pwd,deviceid)
						else
						
							--display_deviceid(ssid,pwd,deviceid)
					
							ip_len = string.len(ip)
							display_deviceid(string.sub(ip,1,11),string.sub(ip,12,ip_len),deviceid)
						end
						require "wire"
						rest = require "arest_scratch"
					else
						if value == "snap" then
							print("snap working")
							work_display(value)	
							rest = require "arest_snap"		
						elseif value == "car" then
							print("car working")
							work_display(value)
							rest = require "arest_car"
						end
						if timeout>=40 then
							display_deviceid(cfg.ssid,cfg.pwd,ip)
						else
							len_num = string.len(ip)
							display_deviceid(ssid,string.sub(ip,1,7),string.sub(ip,8,len_num))
					end
				end
					ip = nil
					cfg = nil
					ssid = nil 
					pwd = nil
					l = nil
					len_num  = nil
					deviceid = nil
				
					srv=net.createServer(net.TCP) 
					srv:listen(80,function(conn)
					conn:on("receive",function(conn,request)
						rest.handle(conn, request)
					  end)
					  conn:on("sent",function(conn) conn:close() end)
					end)
				end
																						end)
				else
					print("run_config")
					require "run_config"
					init_display(cfg.ssid,cfg.pwd,wifi.ap.getip())

				end
				
	else
		print("test working")
		work_display(value)
		require "test"
		file.remove("config.lua")
	end
	
	
else
	print("choose project")
	require "list_config"
	init_display(cfg.ssid,cfg.pwd,wifi.ap.getip())
end