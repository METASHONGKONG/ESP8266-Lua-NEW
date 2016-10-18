
local d1 = 1
local d8 = 8
gpio.mode(d1,gpio.OUTPUT)
gpio.mode(d8,gpio.OUTPUT)
gpio.write(d8,gpio.HIGH)

function read_PM()
	gpio.write(d1,gpio.LOW)
	tmr.delay(280)
	a0 = adc.read(0)
	tmr.delay(40)
	gpio.write(d1,gpio.HIGH)
	tmr.delay(9680)
	return a0+270
end
