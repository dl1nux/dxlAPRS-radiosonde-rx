#!/bin/bash
#
# sonde.sh: Starten des Sondenempfängers in der grafischen Oberfläche eines Linux-Systems mit seperaten Fenstern
#
# Wichtiger Hinweis: Dieses Skript kann bis zu drei SDR-Sticks gleichzeitig ansteuern (z.B. 400-402, 402-404 und 404-406 MHz)
# Bei Nutzung von 2 oder 3 Sticks bitte die Auskommentierungen "#" der entsprechenden Zeilen entfernen bei Audiopipe, RTL_TCP, SDRTST und SONDEMOD
#------------------------------------------------------------------------------------------------------------------------------------------------------
# Bitte unbedingt die folgenden Daten ändern:
#------------------------------------------------------------------------------------------------------------------------------------------------------
# - Bitte alle Programm- und Dateipfade anpassen, wenn sich der Programmordner nicht unter /home/pi/dxlAPRS/aprs/ befindet
# - SONDEUDP: Rufzeichen der Empfänger
# - SONDEMOD: Rufzeichen (-I), Eigener Locator (10stellig) oder GPS Position im Format 70.0506 10.0092 (-P), Höhe über NN (-N)
# - UDPGATE4: Rufzeichen des lokalen APRS Gateways (-s)
# - UDPGATE4: Gateway Zieladresse zum einspeisen der Daten ins Internet/Hamnet (-g)
# - UDPGATE4: APRS-Passcode für das eigene Gateway-Rufzeichen (-p).
# Bitte auch netbeacon.txt (Koordinaten und Bakentext) sowie sdrcfg0.txt (Sondenfrequenzen) bearbeiten
#------------------------------------------------------------------------------------------------------------------------------------------------------

#------------------------------------------------------------------------------------------------------------------------------------------------------
# Wir beenden sicherheitshalber alle Tools die bereits laufen könnten
#------------------------------------------------------------------------------------------------------------------------------------------------------
#sleep 10
killall -9 getalmd rtl_tcp sdrtst sondeudp sondemod udpbox udpgate4 
sleep 1

#------------------------------------------------------------------------------------------------------------------------------------------------------
# Hier befindet sich das Programmverzeichnis. Bitte ggf. anpassen
#------------------------------------------------------------------------------------------------------------------------------------------------------
PATH=/home/pi/dxlAPRS/aprs:$PATH

#------------------------------------------------------------------------------------------------------------------------------------------------------
# getalmd lädt den stets aktuellen GPS Almanach (wird für RS92 Sonden benötigt)
#------------------------------------------------------------------------------------------------------------------------------------------------------
xfce4-terminal --title GETALMD -e getalmd &
sleep 1

#------------------------------------------------------------------------------------------------------------------------------------------------------
# Starten der SDR Server (RTL_TCP)
#------------------------------------------------------------------------------------------------------------------------------------------------------
# Die einzelnen Sticks sind durchnummeriert mit -d0 / -d1 / -d2 usw.
#------------------------------------------------------------------------------------------------------------------------------------------------------
# Stick 0
xfce4-terminal --minimize --title RTL_TCP0 -e 'bash -c "rtl_tcp -a 127.0.0.1 -d0 -p 18100 -n 1"' &
sleep 1
# Stick 1
#xfce4-terminal --minimize --title RTL_TCP1 -e 'bash -c "rtl_tcp -a 127.0.0.1 -d1 -p 18101 -n 1"' &
#sleep 1
# Stick 2
#xfce4-terminal --minimize --title RTL_TCP2 -e 'bash -c "rtl_tcp -a 127.0.0.1 -d2 -p 18102 -n 1"' &
#sleep 1

#------------------------------------------------------------------------------------------------------------------------------------------------------
# Audiopipe erstellen (falls nicht vorhanden)
#------------------------------------------------------------------------------------------------------------------------------------------------------
# Stick 0
mknod /home/pi/dxlAPRS/aprs/sondepipe0 p 2> /dev/null
# Stick 1
#mknod /home/pi/dxlAPRS/aprs/sondepipe1 p 2> /dev/null
# Stick 2
#mknod /home/pi/dxlAPRS/aprs/sondepipe2 p 2> /dev/null

#------------------------------------------------------------------------------------------------------------------------------------------------------
# Sondendekodierung starten (SONDEUDP)
#------------------------------------------------------------------------------------------------------------------------------------------------------
# Stick 0
xfce4-terminal --title SONDEUDP0 -e 'bash -c "sondeudp -f 16000 -o /home/pi/dxlAPRS/aprs/sondepipe0 -I MYCALL-11 -L SDR0 -u 127.0.0.1:18000 -c 0 -v -n 0 -W 5"' & 
sleep 1
# Stick 1
#xfce4-terminal --title SONDEUDP1 -e 'bash -c "sondeudp -f 16000 -o /home/pi/dxlAPRS/aprs/sondepipe1 -I MYCALL-11 -L SDR1 -u 127.0.0.1:18000 -c 0 -v -n 0 -W 5"' &
#sleep 1
# Stick 2
#xfce4-terminal --title SONDEUDP2 -e 'bash -c "sondeudp -f 16000 -o /home/pi/dxlAPRS/aprs/sondepipe2 -I MYCALL-11 -L SDR2 -u 127.0.0.1:18000 -c 0 -v -n 0 -W 5"' &
#sleep 1

#------------------------------------------------------------------------------------------------------------------------------------------------------
# Initialisieren der Empfänger (SDRTST)
#------------------------------------------------------------------------------------------------------------------------------------------------------
# Die Dateien sdrcfgX.txt enthalten die zu empfangenden Sondenfrequenzen (bitte die Datei seperat betrachten und bearbeiten!)
#------------------------------------------------------------------------------------------------------------------------------------------------------
# Stick 0
xfce4-terminal --minimize --title SDRTST0 -e 'bash -c "sdrtst -t 127.0.0.1:18100 -r 16000 -s /home/pi/dxlAPRS/aprs/sondepipe0 -Z 100 -c /home/pi/dxlAPRS/aprs/sdrcfg0.txt -e -k -v "'&
sleep 1
# Stick 1
#xfce4-terminal --minimize --title SDRTST1 -e 'bash -c "sdrtst -t 127.0.0.1:18101 -r 16000 -s /home/pi/dxlAPRS/aprs/sondepipe1 -Z 100 -c /home/pi/dxlAPRS/aprs/sdrcfg1.txt -e -k -v "'&
#sleep 1
# Stick 2
#xfce4-terminal --minimize --title SDRTST2 -e 'bash -c "sdrtst -t 127.0.0.1:18102 -r 16000 -s /home/pi/dxlAPRS/aprs/sondepipe2 -Z 100 -c /home/pi/dxlAPRS/aprs/sdrcfg2.txt -e -k -v "'&
#sleep 1

#------------------------------------------------------------------------------------------------------------------------------------------------------
# Umwandeln der Sondendaten in AXUDP Format (SONDEMOD)
#------------------------------------------------------------------------------------------------------------------------------------------------------
xfce4-terminal --minimize --title SONDEMOD -e 'bash -c "sondemod -o 18000 -I MYCALL -r 127.0.0.1:9001 -b 20 -B 6 -A 1500 -x /tmp/e.txt -T 360 -R 240 -d -p 2 -M -L 6=DFM06,7=PS15,A=DFM09,B=DFM17,C=DFM09P,D=DFM17,FF=DFMx -t /home/pi/dxlAPRS/aprs/sondecom.txt -v -P JO12AA01BB -N 123 -S /home/pi/dxlAPRS/aprs/"' &
sleep 1

#--------------------------------------------------------------------------------------------------------------------------------------------------
# Verteilen der AXUDP Daten (UDPBOX)
#--------------------------------------------------------------------------------------------------------------------------------------------------
# Zum eigenen APRS Gateway (udpgate4 Port 9101) und APRSMAP (Port 9105)
# -------------------------------------------------------------------------------------------------------------------------------------------------
xfce4-terminal  --minimize --title UDPBOX -e 'bash -c "udpbox -R 127.0.0.1:9001 -l 127.0.0.1:9101 -l 127.0.0.1:9105 -v"' &
sleep 1

#------------------------------------------------------------------------------------------------------------------------------------------------------
# APRS iGate (UDPGATE4) - sendet die Daten im APRS Format an einen APRS Server
#------------------------------------------------------------------------------------------------------------------------------------------------------
# Beispiele für -g
# 
# radiosondy.info:14580       => Daten zu Radiosondy.info inklusive Weiterleitung an das APRS-IS-Netzwerk (Port 14580)
# radiosondy.info:14590       => Daten zu Radiosondy.info OHNE Weiterleitung an das APRS-IS-Netzwerk (Port 14590)
# euro.aprs2.net:14580        => Daten direkt ins APRS-IS-Netzwerk via INTERNET
# aprsc.db0gw.ampr.org:14580  => Daten direkt ins APRS-IS-Netzwerk via HAMNET
#
# Hinweis: Die Seite wetterson.de wird nicht per iGate sondern direkt von sondeudp mit den Sondenrohdaten "beliefert".
#------------------------------------------------------------------------------------------------------------------------------------------------------
xfce4-terminal --minimize --title UDPGATE4 -e 'bash -c "udpgate4 -s MYCALL-10 -R 127.0.0.1:0:9101 -B 1440 -u 50 -n 30:/home/pi/dxlAPRS/aprs/netbeacon.txt -g radiosondy.info:14580#m/1,-t/to -p PASSCODE -t 14580 -w 14501 -v -D /home/pi/dxlAPRS/aprs/www/"' &
#
# Optional (Zeile unten einkommentieren und Gegenstück oben auskommentieren)
# Wenn man STRM Datenfiles hat, kann man diese in udpgate4 einbinden um Höhendaten über Grund anzeigen zu lassen.
# Das iGate sucht nach dem Ordner /strm1 im unter -A angegebenen Pfad. Im Ordner /strm1 müssen sich alle SRTM Datenfiles befinden
#xfce4-terminal --minimize --title UDPGATE4 -e 'bash -c "udpgate4 -s MYCALL-10 -R 127.0.0.1:0:9101 -B 1440 -u 50 -A /home/pi/dxlAPRS/aprs/ -n 30:/home/pi/dxlAPRS/aprs/netbeacon.txt -g radiosondy.info:14580#m/1,-t/to -p PASSCODE -t 14580 -w 14501 -v -D /home/pi/dxlAPRS/aprs/www/"' &
