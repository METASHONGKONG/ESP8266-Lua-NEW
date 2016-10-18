
-- Function Definition
function i2c_read_reg(i2c_addr, reg_addr, readlen)
    i2c.start(0);
    i2c.address(0, i2c_addr, i2c.TRANSMITTER);
    i2c.write(0, reg_addr);
    i2c.stop(0);
    i2c.start(0);
    i2c.address(0, i2c_addr, i2c.RECEIVER);
    local c = i2c.read(0, readlen);
    i2c.stop(0);
    return c;
end

function i2c_write_reg(i2c_addr, reg_addr, datastr)
    i2c.start(0);
    i2c.address(0, i2c_addr, i2c.TRANSMITTER);
    i2c.write(0, reg_addr);
    for i = 1, #datastr do
        i2c.write(0, datastr:sub(i, i));
    end
    i2c.stop(0);
end
