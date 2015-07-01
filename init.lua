timeout = 5
gpio.mode(3,gpio.INPUT,gpio.PULLUP)
              
statuses = {[0]="Idle",
            [1]="Connecting",
            [2]="Wrong password",
            [3]="No AP found",
            [4]="Connect fail",
            [5]="Got IP",
            [255]="Not in STATION mode"}

checkCount = 0
function checkStatus()
  checkCount = checkCount + 1
  local s=wifi.sta.status()
  print("Status = " .. s .. " (" .. statuses[s] .. ")")  
  if(gpio.read(3) == 0)then
  tmr.stop(0)
    print("Entering Web Setup")
    dofile("setup.lc")
  elseif(s==5) then -- successful connect
    launchApp()
    return
  elseif(s==0 or s==2 or s==3 or s==4 or s==255) then -- failed
    tmr.stop(0)
    dofile("setup.lc")
  end
  if(checkCount >= timeout) then
    node.restart()
    return
  end
end

function launchApp()
tmr.stop(0)
dofile('switch.lc')
print("switched, going to sleep")
--tmr.alarm(1, 1000, 0, function() 
       node.dsleep(0) 
    end )

end

-- every second, check our status
tmr.alarm(0,500, 1, checkStatus)
--tmr.alarm(2, 240000, 0, node.dsleep(0))
