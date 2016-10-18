local D1 = 1; --pin1
local D2 = 2; --pin2
A0 = 0;  --A0 value 
A1 = 0;  --A1 value
local D8 = 8;  --pin8
gpio.mode(D8,gpio.OUTPUT);--pin8 output mode
pwm.setup(D1,500,A0);--pin1 pwm  mode
pwm.start(D1);--pwm start
pwm.setup(D2,500,A1)--pin2 pwm mode
pwm.start(D2);--pwm start
tmr.alarm(0,1000,1,function ()

	gpio.write(D8,gpio.HIGH); --read A0 mode
	A0 = adc.read(0);
	if A0 < 5 then
		A0 = 0;
	elseif A0 >940 then
		A0 = 1023;
	end
	pwm.setduty(D1,A0);
	
	gpio.write(D8,gpio.LOW);--read A1 mode
	A1 = adc.read(0);
	if A1 < 5 then
		A1 = 0;
	elseif A1 >948 then
		A1 = 1023;
	end
	pwm.setduty(D2,A1);
	test_display(A0,A1)
end)

function test_display(a0,a1)
	disp:firstPage()
	repeat
		disp:drawStr(0,10,"A0:"..a0)
		disp:drawStr(0,20,"A1:"..a1)
	until disp:nextPage() == false
end
