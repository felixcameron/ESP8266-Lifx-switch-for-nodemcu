idupdateserver = 1 -- run webserver continuously to update LifX device ID
staticIPlast = 250 -- IP address to use on IP range given by DHCP
timeout = 8 -- seconds to wait for connect before going to AP mode

checkCount = 0
function checkStatus()
  checkCount = checkCount + 1
  local s=wifi.sta.status()
  print("Status = " .. s .. " (" .. statuses[s] .. ")")  
  if(s==5) then -- successful connect
    tmr.stop(3)
    launchApp()
    return  
  elseif(s==0 or s==2 or s==3 or s==4) then -- failed
    tmr.stop(3)
    startServer()
    return
  end
  if(checkCount >= timeout) then
    tmr.stop(3)
    startServer()
    return
  end
end

function launchApp()

bc = wifi.sta.getbroadcast()

 staticip = bc:sub(1, (bc:len() - 3)) .. staticIPlast -- set IP address to match broadcast IP address range
 ip, nm = wifi.sta.getip()
 ip, nm, gw = wifi.sta.getip()

cfgip = {ip      = staticip, 
         netmask = "255.255.255.0",
         gateway = "192.168.0.1"}

wifi.sta.setip(cfgip)
print(wifi.sta.getip())

  cleanup()
  print("Im connected to my last network. Launching my real task.")
  dofile('webupdate.lc')
end

function startServer()
  lastStatus = statuses[wifi.sta.status()]
  cleanup()
  print("network not found, switching to AP mode")
  dofile("configServerInit.lc")
  dofile('webupdate.lc')
end

function cleanup()
  -- stop our alarm
  tmr.stop(0)
  tmr.stop(1)
--  tmr.stop(2)
  tmr.stop(3)
  tmr.stop(4)
  tmr.stop(5)
  tmr.stop(6)
  -- nil out all global vars we used
  timeout = nil
  checkCount = nil
  -- nil out any functions we defined
  checkStatus = nil
  launchApp = nil
  startServer = nil
  cleanup = nil
  g1 = nil
  ip = nil
  nm =nil
  gw = nil
  staticip = nil 
  -- take out the trash
  collectgarbage()
  -- pause a few seconds to allow garbage to collect and free up heap
  tmr.delay(10000)
  
end

-- make sure we are trying to connect as clients
wifi.setmode(wifi.STATION)
wifi.sta.autoconnect(1)

-- every second, check our status
tmr.alarm(3, 1000, 1, checkStatus)
