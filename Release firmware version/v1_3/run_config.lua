	wifi.setmode(wifi.SOFTAP)

	cfg = {}
	cfg.ssid = "Metas"..node.chipid()
	l = string.len(cfg.ssid)
	cfg.ssid = string.sub(cfg.ssid,1,l-1)
	cfg.pwd = "12345678"
	--wifi.setmode(wifi.SOFTAP)  
    wifi.ap.config(cfg)  
	srv = nil
    srv=net.createServer(net.TCP)  
    srv:listen(80,function(conn)  
        conn:on("receive", function(client,request)  
			
            local buf = "";  
            local _, _, method, path, vars = string.find(request, "([A-Z]+) (.+)?(.+) HTTP");  
         
			if(method == nil)then  
                _, _, method, path = string.find(request, "([A-Z]+) (.+) HTTP");  
            end  
			local _GET={}
			if (vars ~= nil)then
				for k, v in string.gmatch(vars, "(%w+)=([^%&]+)&*") do
					_GET[k] = v
				end
				_GET.sta = string.gsub(_GET.sta, "%%(%x%x)", function (h)
					return string.char(tonumber(h, 16))
				end)
				_GET.sta = string.gsub(_GET.sta,"+"," ")
			end
				
			if _GET.sta~=nil and  string.len(_GET.psd)>=8  then
				--print(_GET.sta)
				file.open("config_wifi.lua","w+")
				file.writeline('ssid="'.._GET.sta..'"')
				file.writeline('pwd="'.._GET.psd..'"')
				file.close()
				node.restart()
			end
            buf = buf.."HTTP/1.1 200 OK\r\nContent-type: text/html\r\nAccess-Control-Allow-Origin:* \r\n\r\n <!DOCTYPE html><html><head><meta http-equiv=Content-Type content=\"text/html;charset=utf-8\"></head>"
			buf = buf.."<body><h1>Wifi Configuration</h1>" 
			buf = buf.."Please input the required WIFI and password，then click 'save' button.</br></br>"
            buf = buf.."(Note 1： The wifi information will be memorized in NodeOne after this configuration.)</br>"
            buf = buf.."(Note 2： If you want to reset it, place the pressed button in A0, then re-open NodeOne again. Afterwards, remove button in 5 seconds.)</br></br>"
			buf = buf.."<form method = 'get' action='http://"..wifi.ap.getip().."'>"
			buf = buf.."Wifi ID:<input name='sta'></input></br>"
			buf = buf.."Wifi Password:<input type='password' name='psd'></input><br><br>"
			buf = buf.."<button type='submit'>save</button></form></body><html>"
            client:send(buf); 
			tmr.delay(50000)			
            client:close();  
            collectgarbage();  
        end)  
    end)  

