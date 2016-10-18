function init_set()
	i2c.setup(0,7,6,i2c.SLOW)
	disp = u8g.ssd1306_128x64_i2c(0X3C)
	disp:setFont(u8g.font_6x10)
	disp:setFontRefHeightExtendedText()
    disp:setDefaultForegroundColor()
    disp:setFontPosTop()
	disp:setScale2x2()
end

function init_display(ssid,pwd,ip)
	disp:firstPage()
	repeat
		disp:drawStr(0,0,""..ssid)
		disp:drawStr(0,10,""..pwd)
		disp:drawStr(0,20,""..ip)
	until disp:nextPage() == false
end

function work_display(value)
	disp:firstPage()
	repeat
		disp:drawStr(4,0,"METAS IOT")
		disp:drawStr(10,15,""..value)
	until disp:nextPage() == false
end

function display_runconfig(ssid,pwd)
    disp:firstPage();
    repeat
        disp:drawStr(5,0, "Metas IOT");
        disp:drawStr(0,10, ""..ssid);
		disp:drawStr(0,20, ""..pwd);
    until disp:nextPage() == false
end

function display_deviceid(ssid,pwd,id)
    disp:firstPage();
    repeat
      
        disp:drawStr(0,0, ""..ssid);
		disp:drawStr(0,10, ""..pwd);
		disp:drawStr(0,20, ""..id);
    until disp:nextPage() == false
end






