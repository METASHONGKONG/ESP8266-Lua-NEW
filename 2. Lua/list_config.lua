wifi.setmode(wifi.SOFTAP)
cfg = {}
cfg.ssid = "Metas"..node.chipid()
l = string.len(cfg.ssid)
cfg.ssid = string.sub(cfg.ssid,1,l-2)
cfg.pwd = "12345678"
wifi.ap.config(cfg)
local srv = nil
srv = net.createServer(net.TCP)
srv:listen(80,function(conn)
	conn:on("receive",function(client,request)
		local buf = ""
		local _,_,method,path,vars = string.find(request,"([A-Z]+) (.+)?(.+) HTTP")
		if method == nil then
			_,_,method,path = string.find(request, "([A-Z]+) (.+) HTTP")
		end
		local _GET = {}
		if (vars ~= nil)then
            for k, v in string.gmatch(vars, "(%w+)=([^%&]+)&*") do
                _GET[k] = v
            end
        end
		if _GET.num ~= nil then
			file.open("config.lua","w+")
			file.writeline('value="'.._GET.num..'"')
			file.close()
			node.restart()
		end
		buf = buf.."<!DOCTYPE html><html><head><meta http-equiv=Content-Type content=\"text/html;charset=utf-8\"></head>"
		buf = buf.."<body><h1>Metas choose project</h1>"
		buf = buf.."1.請選擇項目,點擊保存,等待重啟完成,重啟後請再次連接192.168.4.1進行下壹步操作。</br></br>"
		buf = buf.."<form method = 'get' action='http://"..wifi.ap.getip().."'>"
		buf = buf.."Project:<select name = 'num'>"
		buf = buf.."<option value = snap>snap</option>"
		buf = buf.."<option value = scratch>scratch</option>"
		buf = buf.."<option value = car>car</option>"
		buf = buf.."<option value = test>test</option></select></br>"
		buf = buf.."<button type='submit'>save</button></form></body><html>"
		client:send(buf)
		client:close()
		collectgarbage()
	end)

end)