--lastStatus = statuses[wifi.sta.status()]
lastStatus = "test"
dofile("configServerInit.lc")
dofile('lifxids.lua')
apRefresh = 15
currentAPs = {}
newssid = ""

function listAPs_callback(t)
  if(t==nil) then
    return
  end
  currentAPs = t
end

function listAPs()
  wifi.sta.getap(listAPs_callback)
end

collectgarbage()
print(node.heap())
newlifxid = ""
local falsesize = 0