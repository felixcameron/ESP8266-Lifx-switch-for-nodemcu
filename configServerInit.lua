apNamePrefix = "ConfigureMe" -- your AP will be named this plus "-XX-YY", where XX and YY are the last two bytes of this unit's MAC address

apNetConfig = {ip      = "192.168.4.1", -- NodeMCU seems to be hard-coded to hand out IPs in the 192.168.4.x range, so let's make sure we're there, too
               netmask = "255.255.255.0",
               gateway = "192.168.4.1"}

-- Set up our Access Point with the proper name and settings
local apName = apNamePrefix .. "-" .. string.sub(wifi.ap.getmac(),13)
print("Starting up AP with SSID: " .. apName);
wifi.setmode(wifi.STATIONAP)
local apSsidConfig = {}
apSsidConfig.ssid = apName
wifi.ap.config(apSsidConfig)
wifi.ap.setip(apNetConfig)
