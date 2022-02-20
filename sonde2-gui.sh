#!/usr/bin/bash
#sleep 10
# Wettersonden-Empfänger mit Weiterleitung zu radiosondy.info und wettersonde.net
#----------------------------------------------------------------------------------------------------
# Ausführliche Informationen unter: https://www.dl1nux.de/wettersonden-rx-mit-dxlaprs/
# und in der Datei README.md
#----------------------------------------------------------------------------------------------------
# Dieses Skript arbeitet mit ZWEI SDR-Sticks gleichzeitig (z.B. 402-404 und 404-406 MHz)
#----------------------------------------------------------------------------------------------------
# Bitte die Datei sondeconfig.txt und netbeacon_sonde.txt anpassen (siehe README.md)
# Die zu überwachenden Sondenfrequenzen müssen noch in den sdrcfg*.txt Dateien einkommentiert werden.
#----------------------------------------------------------------------------------------------------

# Programmpfad bestimmen und in den Systempfad einfügen
export DXLPATH=$(dirname `realpath $0`)
export PATH=$DXLPATH:$PATH

# Variablen aus Datei sondeconfig.txt einlesen
while read line; do    
    export $line    
done < $DXLPATH/sondeconfig.txt

# Wir beenden sicherheitshalber alle Prozesse die bereits laufen könnten
killall -9 getalmd rtl_tcp sdrtst sondeudp sondemod udpbox udpgate4 
sleep 1

# getalmd lädt den aktuellen GPS Almanach (wird für RS92 Sonden benötigt).
xfce4-terminal --title GETALMD -e getalmd &
sleep 1

# Audiopipes erstellen (falls nicht vorhanden)
# Stick 0
mknod $DXLPATH/sondepipe0 p 2> /dev/null
# Stick 1
mknod $DXLPATH/sondepipe1 p 2> /dev/null

# SRTM1 Ordner erstellen, falls nicht vorhanden
mkdir $DXLPATH/srtm1 2> /dev/null
sleep 1

# Starten der SDR Server (RTL_TCP)
# Die einzelnen Sticks sind durchnummeriert mit -d0 / -d1 / -d2 usw.
# Stick 0
xfce4-terminal --minimize --title RTL_TCP0 -e 'bash -c "rtl_tcp -a 127.0.0.1 -d0 -p 18200 -n 1"' &
sleep 1
# Stick 1
xfce4-terminal --minimize --title RTL_TCP1 -e 'bash -c "rtl_tcp -a 127.0.0.1 -d1 -p 18201 -n 1"' &
sleep 1

# Initialisieren der Empfänger (SDRTST)
# Die Dateien sdrcfgX.txt enthalten die zu empfangenden Sondenfrequenzen (bitte die Datei seperat betrachten und bearbeiten!)
# Stick 0
xfce4-terminal --minimize --title SDRTST0 -e 'bash -c "sdrtst -t 127.0.0.1:18200 -r 16000 -s $DXLPATH/sondepipe0 -Z 100 -c $DXLPATH/sdrcfg0.txt -e -k -v "'&
sleep 1
# Stick 1
xfce4-terminal --minimize --title SDRTST1 -e 'bash -c "sdrtst -t 127.0.0.1:18201 -r 16000 -s $DXLPATH/sondepipe1 -Z 100 -c $DXLPATH/sdrcfg1.txt -e -k -v "'&
sleep 1

# Sondendekodierung starten (SONDEUDP)
# Stick 0
xfce4-terminal --title SONDEUDP0 -e 'bash -c "sondeudp -f 16000 -o $DXLPATH/sondepipe0 -I $SONDECALL -L SDR0 -u 127.0.0.1:18000 -c 0 -v -n 0 -W 5"' & 
sleep 1
# Stick 1
xfce4-terminal --title SONDEUDP1 -e 'bash -c "sondeudp -f 16000 -o $DXLPATH/sondepipe1 -I $SONDECALL -L SDR1 -u 127.0.0.1:18000 -c 0 -v -n 0 -W 5"' &
sleep 1

# Umwandeln der Sondendaten in AXUDP Format (SONDEMOD)
xfce4-terminal --minimize --title SONDEMOD -e 'bash -c "sondemod -o 18000 -I $SONDECALL -r 127.0.0.1:9001 -b $INTERVALLHIGH:$INTERVALL1:$INTERVALL2:$INTERVALL3 -A $ALT1:$ALT2:$ALT3 -x /tmp/e.txt -T 360 -R 240 -d -p 2 -M -L 6=DFM06,7=PS15,A=DFM09,B=DFM17,C=DFM09P,D=DFM17,FF=DFMx -t $DXLPATH/sondecom.txt -v -P $LOCATOR -N $HOEHE -S $DXLPATH/"' &
sleep 1

# Verteilen der AXUDP Daten (UDPBOX)
# 9101 zu radiosondy.info - 9102 zu wettersonde.net - 9999 zu APRSMAP (z.B.)
xfce4-terminal  --minimize --title UDPBOX -e 'bash -c "udpbox -R 127.0.0.1:9001 -l 127.0.0.1:9101 -l 127.0.0.1:9102 -l 127.0.0.1:9999 -v"' &
sleep 1

# APRS iGate (UDPGATE4) - sendet die Daten im APRS Format an einen APRS Server (-g)
#
# radiosondy.info:14580       => Daten zu Radiosondy.info inklusive Weiterleitung an das APRS-IS-Netzwerk (Port 14580)
# radiosondy.info:14590       => Daten zu Radiosondy.info OHNE Weiterleitung an das APRS-IS-Netzwerk (Port 14590)
# wettersonde.net:14580       => Daten zu wettersonde.net
# rotate.aprs2.net:14580      => Daten direkt ins APRS-IS-Netzwerk via INTERNET
# aprs.hc.r1.ampr.org:14580   => Daten direkt ins APRS-IS-Netzwerk via HAMNET

# iGate für radiosondy.info
xfce4-terminal --minimize --title UDPGATE4_Radiosondy -e 'bash -c "udpgate4 -s $IGATECALL -R 127.0.0.1:0:9101 -B 2880 -u 50 -H 0 -I 0 -L 0 -A $DXLPATH/ -n 30:$DXLPATH/netbeacon_sonde.txt -g radiosondy.info:14580#m/1 -p $PASSCODE -w 14501 -v -D $DXLPATH/www/"' &
sleep 1
# iGate für wettersonde.net
xfce4-terminal --minimize --title UDPGATE4-Wettersonde -e 'bash -c "udpgate4 -s $IGATECALL -R 127.0.0.1:0:9102 -B 2880 -u 50 -H 0 -I 0 -L 0 -A $DXLPATH/ -n 30:$DXLPATH/netbeacon_sonde.txt -g wettersonde.net:14580#m/1 -p $PASSCODE -w 14502 -v -D $DXLPATH/www/"' &
