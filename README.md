# ESP8266-Lifx-switch-for-nodemcu
Here are the lua scripts for a lifx light physical switch. 
To use it, you *need* the latest dev version of nodemcu firmware on an ESP8266 as it provides enough RAM heap for the webserver to work (although it is a bit unstable and my code doesnt work with Safari, ony Chrome, anyone can help me fix it and look pretty please?). 

GPIO16 needs to be connected to RST so deep sleep works. 

The ESP8266 will boot up, wait to connect to the designated access point and then send a pair of UDP broadcast packets to the specified Lifx light and tells it to switch on/off. It then writes that state to a lua script so that it can survive reboot and then the ESP8255 goes to deep sleep. Pulling GPIO16 low (pressing the 'user' button on the v.09 nodemcu devboard) reboots the ESP8266 which starts the cycle over but sends 'on' if it was previously off or vice versa. If the light was switched in the meantime by the life app on a phone then two presses/boot cycles will be needed to 'resync' the switch with the light state (i.e. if first press sends 'off' to an already off light).

To configure the light, pull GPIO16 low and then almost immediately after press GPIO0 ('flash' button on the v.09 nodemcu devboard). This is problematic as if you press it too soon it will boot into the bootloader for flashing firmware, and too late and the ESP8266 will have already got its IP address from the access point and sent its packets/gone to sleep. However if there is no wifi access point configured yet then you have a few seconds before the board reboots to try again. 

Once the GPIO0 press is detected then the ESP looks again for a recognised access point. 

If it finds it then it assigns itself the IP ***.***.***.250 on the local network and starts a webserver at this address which can configure the network and also allows you to input the MAC address of th lifx globe (printed on the light itself or accessible from api.lifx.com) as a 12 digit string to identify the bulb to switch. currently POST from safari appears as 'nil' regardless of input on page, clearly my poor coding but it works with chrome browser.. rebooting the light after submitting details should return it to normal switching/sleeping mode. 

If it does not find a recognised access point then it will create its own access point with the name ‘ConfigureMe’ and with the IP address 192.168.4.1 where the webpage will be accessible for configuration.

I managed to get around a week of use as a wall switch with allot of use running from a tiny 260mah Lipo battery.
 
The code switches the bulb immediately and you can modify it to use another GPIO as the trigger for switching and tell it not to sleep so it behaves just like a 'real' switch but then it will need allot more power than my little battery as it will stay awake on the network.

The fact that the ESP8266 goes from cold boot effectively on every switch saves power but as a consequence there is a 1-3 second delay while it connects to the access point  - for me totally tolerable and made more so by telling the globe to 'fade' on/off which softens the sensation of delay. Still, it is VERY fast considering it is reconnecting to the access point each time!
I hope you have fun with this, please share any cleanup and improvement to this code with me and let me know if I have trodden on any toes with my code. 
