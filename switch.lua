dofile('lifxids.lua')
dofile('state.lua')
toggle = state
flipped = toggle * -1

file.open("state.lua", "w+")    
      file.seek(set)
      file.write("state = " .. flipped .. "")
      file.flush()
      file.close()

on        = "2A00001400000000" .. lifxid .. "00004C494658563200000000000000000000750000000100F4010000"
off       = "2A00001400000000" .. lifxid .. "00004C494658563200000000000000000000750000000000D0070000"
 

function UDPpayload(s)
     print ("Payload = " .. s)
     local i = 1
     local h = (string.char(tonumber(s:sub(i , i + 1), 16)))
     local nh = (nil)
          while (i + 2) < s:len()
               do 
               i = i + 2
               local cp = s:sub(i , i + 1)
               nh = h .. (string.char(tonumber(cp, 16)))
               h = nh
          end
     print ("Payload length:" .. nh:len())
     cu=net.createConnection(net.UDP) 
     cu:on("receive",function(cu,c) print(c) end)
     cu:connect(56700, wifi.sta.getbroadcast()) 
     cu:send(nh)
     --cu:close()
end

print("lifx id: " .. lifxid)
     
if toggle == 1 then
    UDPpayload(on)
    UDPpayload(on) 
else 
    UDPpayload(off)
    UDPpayload(off)
end


-- Drop through here to let NodeMcu run
