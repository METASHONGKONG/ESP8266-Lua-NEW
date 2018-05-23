
function read_data(id,si7021,commands)
	i2c.start(id)
	i2c.address(id,si7021, i2c.TRANSMITTER)
	i2c.write(id, commands)
	i2c.stop(id)
	i2c.start(id)
	i2c.address(id,si7021,i2c.RECEIVER)
	tmr.delay(20000)
	c = i2c.read(id,2)
	i2c.stop(id)	
	return c

end

-- read humidity from si7021
function read_humi()
	
	humi = read_data(0,0x40,0xE5)
	humi = string.byte(humi, 1) * 256 + string.byte(humi, 2)
	humi = 12500*humi/65536-600
	return humi/100
	
end

-- read temperature from si7021
function read_temp()
	
	temp = read_data(0,0x40,0xE3)
	temp = string.byte(temp, 1) * 256 + string.byte(temp, 2)
	temp = 17572*temp/65536-4685
	return temp/100
end

