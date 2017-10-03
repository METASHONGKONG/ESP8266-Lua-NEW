PwmSvr={
	id=0,pinSCL=6,pinSDA=7, LED0_ON_L=0X6,			
	_i2caddr=0x41,	PCA9685_MODE1=0x0,addr=nil,	PCA9685_PRESCALE=0xFE}
	
function PwmSvr.read8(addr)
	i2c.start(PwmSvr.id)
	i2c.address(PwmSvr.id, PwmSvr._i2caddr,i2c.TRANSMITTER)
	i2c.write(PwmSvr.id,addr)
	i2c.stop(PwmSvr.id)
	i2c.start(PwmSvr.id)
	i2c.address(PwmSvr.id, PwmSvr._i2caddr,i2c.RECEIVER)
	local c=i2c.read(PwmSvr.id,1)
	i2c.stop(PwmSvr.id)
	return string.byte(c)
end
function PwmSvr.write8(addr,d)
	i2c.start(PwmSvr.id)
	i2c.address(PwmSvr.id, PwmSvr._i2caddr ,i2c.TRANSMITTER)
	i2c.write(PwmSvr.id,addr,d)
	i2c.stop(PwmSvr.id)
end
function PwmSvr.reset()
	PwmSvr.write8(PwmSvr.PCA9685_MODE1,0x0)
end
function PwmSvr.begin()
	i2c.setup(PwmSvr.id, PwmSvr.pinSDA, PwmSvr.pinSCL, i2c.SLOW)
	PwmSvr.reset()
end
function PwmSvr.setPWMFreq(freq)
	local prescale=math.ceil((25000000/4096)/(freq*0.9)+0.5)
	local oldmode = PwmSvr.read8(PwmSvr.PCA9685_MODE1)
	local newmode =bit.bor(bit.band(oldmode,0x7F),0x10)
	PwmSvr.write8(PwmSvr.PCA9685_MODE1,newmode)
	PwmSvr.write8(PwmSvr.PCA9685_PRESCALE,prescale)
	PwmSvr.write8(PwmSvr.PCA9685_MODE1,oldmode)
	for i=0,6000 do tmr.wdclr() end
	PwmSvr.write8(PwmSvr.PCA9685_MODE1, bit.bor(oldmode,0xa1))
end
function PwmSvr.setPWM(num,on,off)
	i2c.start(PwmSvr.id)
	i2c.address(PwmSvr.id, PwmSvr._i2caddr ,i2c.TRANSMITTER)
	i2c.write(PwmSvr.id
		,PwmSvr.LED0_ON_L+4*num
		,bit.band(on,0xff)
		,bit.rshift(on,8)
		,bit.band(off,0xff)
		,bit.rshift(off,8)
	)
	i2c.stop(PwmSvr.id)
end
