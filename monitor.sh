# Dieses Skript zeigt alle APRS-Pakete in der Konsole an, welche an Port 9999 geschickt werden.
# 
# Programmpfad bestimmen und in den Systempfad einfügen
export DXLPATH=$(dirname `realpath $0`)
export PATH=$DXLPATH:$PATH

# Monitor starten
echo "Listening on Port 9999 UDP. Press CTRL+C to exit."
udpflex -U :0:9999 -V