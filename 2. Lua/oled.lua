function init_set()
	i2c.setup(0,7,6,i2c.SLOW)
	disp = u8g.ssd1306_128x64_i2c(0X3C)
	disp:setFont(u8g.font_6x10)
	disp:setFontRefHeightExtendedText()
    disp:setDefaultForegroundColor()
    disp:setFontPosTop()
	disp:setScale2x2()
end

function display_three_row(first,second,third)
	disp:firstPage()
	repeat
		disp:drawStr(0,0,""..first)
		disp:drawStr(0,10,""..second)
		disp:drawStr(0,20,""..third)
	until disp:nextPage() == false
end

function display_word(word)
	disp:firstPage()
	repeat		
        disp:drawStr(5,0,"METAS IOT")	
		disp:drawStr(0,20,word)		
	until disp:nextPage() == false
end

function display_two_row(first,second)
    disp:firstPage();
    repeat
        disp:drawStr(13,0, ""..first);
		disp:drawStr(0,20, ""..second);
    until disp:nextPage() == false
end






