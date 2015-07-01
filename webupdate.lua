lastStatus = statuses[wifi.sta.status()]
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

function sendPage(conn)
conn:send('HTTP/1.1 200 OK\n\n')
conn:send('<!DOCTYPE HTML>\n<html>\n<head><meta content="text/html; charset=utf-8">\n')
conn:send('<title>Device Configuration</title></head>\n<style>\n')
conn:send('body{text-align: center; margin:0 auto; font-size:1em; font-family: sans-serif; padding:40px}\n')
conn:send('input[type="text"]{padding:0.7em; font-size: 1em;}\ninput[type="button"], \n')
conn:send('input[type="submit"]{border-radius: 10px; border:none;background:blueviolet; padding: 20px 40px; margin: 10px; font-size:1.3em; color:#fff;}\n')
conn:send('ul{list-style-type: none; margin: 0; padding: 20px 0;}\n')
conn:send('li{border-bottom: 1px solid #ccc; padding:10px 10px 20px 10px;}\n')
conn:send('form {border: 1px solid #ccc; max-width: 30em;  margin: 0 auto; padding-bottom:30px; box-shadow: 0px 14px 33px #888888; border-radius: 10px;}\n')
conn:send('</style>\n<body>\n<form action="/" method="POST">\n')
conn:send('<ul>\n<li>Previous Bulb ID: <strong>' .. lifxid .. '</strong></li>\n</ul>\n')
conn:send('<p>Lifx Bulb ID: <input type="text" id="lifxid" name="lifxid" value="" size="12" maxlength="12"></p>\n')
conn:send('<input type="submit" value="Submit"/>\n')
conn:send('<input type="button" onClick="window.location.reload()" value="Refresh"/>\n')
if(newlifxid:len() == 12) and falsesize ~= 1 then
conn:send('<p>New Bulb ID is <strong>' .. newlifxid .. '</strong></p>\n')
else
conn:send('<p> </p>\n')
end
if(lastStatus ~= nil) then
conn:send('<p>Previous connection status: <strong>' .. lastStatus ..'</strong></p>\n')
end
conn:send('<p><table>\n<tr><th>Choose SSID to connect to:</th></tr></p>\n')
if(newssid ~= "") then
conn:send('<p>Upon reboot, unit will attempt to connect to SSID "' .. newssid ..'".</p>\n')
end
for ap,v in pairs(currentAPs) do
conn:send('<tr><td><input type="button" onClick=\'document.getElementById("ssid").value = "' .. ap .. '"\' value="' .. ap .. '"/></td></tr>\n')
end
conn:send('</table>\n\nSSID: <input type="text" id="ssid" name="ssid" value=""><br/>\n<p>Password: <input type="text" name="passwd" value=""></p>\n')
conn:send('<input type="submit" name="reboot" value="Reboot!"/>\n')
conn:send('</form>\n</body></html>\n')
end
function url_decode(str)
local s = string.gsub (str, "+", " ")
s = string.gsub (s, "%%(%x%x)",
function(h) return string.char(tonumber(h,16)) end)
s = string.gsub (s, "\r\n", "\n")
return s
end
function incoming_connection(conn, payload)
if (string.find(payload, "GET /favicon.ico HTTP/1.1") ~= nil) then
print("GET favicon request")
elseif (string.find(payload, "GET / HTTP/1.1") ~= nil) then
print("GET received")
sendPage(conn)
else
print("POST received")
collectgarbage()
tmr.delay(20000)
local blank, plStart = string.find(payload, "\r\n\r\n");
if(plStart == nil) then
return
end
payload = string.sub(payload, plStart+1)
args={}
for k,v in string.gmatch(payload, "([^=&]*)=([^&]*)") do
args[k]=url_decode(v)
end
if(args.lifxid ~= nil and args.lifxid ~= "" and args.lifxid:len() == 12) then
print("New lifX ID: " .. args.lifxid)
newlifxid = args.lifxid
file.open("lifxids.lua", "w+")    
file.seek(set)
file.write("lifxid = \"" .. args.lifxid .. "\"")
file.flush()
file.close()
falsesize = 0
else 
falsesize = 1
collectgarbage()
print(node.heap())
end
if(args.ssid ~= nil and args.ssid ~= "") then
print("New SSID: " .. args.ssid)
print("Password: " .. args.passwd)
newssid = args.ssid
wifi.sta.config(args.ssid, args.passwd)
end
if(args.reboot ~= nil) then
print("Rebooting with " .. args.lifxid .. " : " .. args.passwd"")
conn:close()
node.restart()
end
conn:send('HTTP/1.1 303 See Other\n')
conn:send('Location: /\n')
end
end
tmr.alarm(0, apRefresh*1000, 1, listAPs)
listAPs() 
srv=net.createServer(net.TCP)
srv:listen(80,function(sock)
  sock:on("receive", incoming_connection)
  sock:on("sent", function(sock) 
    sock:close()
    print(node.heap())
    args=(nil)
    payload=(nil)
    collectgarbage() 
    print(node.heap())
    
  end)
end)
