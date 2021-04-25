# dxlAPRS-radiosonde-rx
Wettersonden-Empfänger mit dxlAPRS

Stand 25.04.2021 by DL1NUX (attila@dl1nux.de)

# Inhaltsverzeichnis
* Einleitung
* Hinweise für den Empfang von Wettersonden
* Für wen sind diese Skripte und Dateien geeignet?
* Welche Wettersonden können empfangen werden?
* Benötigte Hardware
* Installationshinweise
* Vor dem ersten Start beachten
* Programmstart
* Autostart
* Ausführliche Erläuterung aller Parameter
* Tipps & Tricks

# Einleitung

Die folgende Anleitung dient dazu in wenigen Schritten einen Wettersonden-
Empfänger aufzubauen, der seine Daten an die Community-Seite radiosondy.info
und auch in das APRS-Netzwerk weiterleitet. Selbstverständlich kann man den
Empfänger auch nur lokal nutzen ohne eine Weiterleitung der Daten.

dxlAPRS ist eine „Toolchain“ bzw. Programmsammlung für Linux Systeme rund um
die Betriebsart APRS und wird von Christian OE5DXL entwickelt. Neben
zahlreichen Funktionen für die Betriebart APRS bietet diese Toolchain auch
einen Dekoder für Wettersonden. Der Begriff „Toolchain“ erklärt bereits, wie
diese Programme funktionieren. Im Gegensatz zu vielen anderen APRS Programmen
wie APRX oder Direwolf sind es viele kleine Programme die miteinander verkettet
werden (chain = Kette). Jeder Programmteil ist für eine bestimmte Funktion
zuständig und die Verkettung findet über UDP Ports statt. Das macht es
einerseits etwas schwierig die Funktionsweise zu verstehen und das Ganze
einzurichten, andererseits ermöglicht es eine sehr flexible und effektive
Nutzung der Programme. Kein anderes APRS Tool hat diese Fülle an Funktionen und
Möglichkeiten wie dxlAPRS. Die dxlAPRS Tools laufen komplett eigenständig und
es sind bis auf eine Ausnahme keine weiteren Libraries notwendig oder
Abhängigkeiten vorhanden. Lediglich für die Nutzung von SDR Sticks ist die
Installation eines weiteren Pakets notwendig. Die dxlTools lassen sich daher
auf quasi jedem beliebigen Linux System ohne Weiteres nutzen. Da die dxlAPRS
Tools Open Source sind, sind auch die Quellcodes verfügbar.

Für den Wettersondenempfang und die Weiterleitung der Daten werden die
folgenden Komponenten aus den dxlAPRS Tools benötigt:

* sdrtst (Empfänger)
* sondeudp (Sondendekodierung)
* sondemod (Erzeugung von APRS Paketen aus den Sondendaten)
* udpgate4 (APRS iGate)
* Optional: udpbox (Verfielfältigung der AXUDP Streams)

rtl_tcp stellt einen SDR Server bereit. sdrtst zapt diesen SDR Server an und
erzeugt Empfänger auf den vorgegebenen Frequenzen (sdrcfg0.txt). sdrtst sendet
die empfangenen Signale in eine Audiopipe, an dessen Ende sondeudp arbeitet.
sondeudp dekodiert empfangene Sondensignale und sendet die Rohdaten an 
sondemod. sondemod wiederrum erzeugt aus den Sondendaten konforme APRS-Pakete
als APRS-Objekt und sendet diese entweder an das iGate udpgate4 zur 
Weiterleitung ins Internet, oder vorher noch an udpbox, wo sie verfielfältigt
werden können um die Pakete zeitgleich noch in einem Kartenprogramm, z.B.
ARPSMAP, darstellen zu können (optional).

# Hinweise für den Empfang von Wettersonden

Der Empfang von Wettersonden ist in manchen Ländern ein Verstoß gegen nationale
Telekommunikationsgesetze. Bitte beachten sie ihre nationalen Gesetzgebungen!
Ich übernehme keine Haftung für Verstöße jeglicher Art. Jeder ist für sein
eigenes Tun und Handeln verantwortlich. Sagt hinterher nicht, ihr habt es nicht
gewusst 🙂 Die Anleitung dient ausschließlich technisch wissenschaftlichen
Experimenten für den privatgebrauch. Kommerzielle Nutzung ist nicht erlaubt. Die
dxlAPRS Tools sind eine Entwicklung von Christian Rabler OE5DXL und seinen
Freunden. Sie unterstehen der GPL Lizenz.

# Für wen sind diese Skripte und Dateien geeignet?

Zielgruppe sind interessierte Wettersondenbeobachter, welche sich mit der
Technik der dxlAPRS Tools auseinandersetzen möchten und auch entsprechende
Linux-Vorkenntnisse besitzen. Anhand des Aufbaus des Skripts kann man die
Funktionsweise der dxlAPRS Tools kennenlernen. Dies versetzt einem beim
aufmerksamen studieren der Programme und Parameter in die Lage Optimierungen
durchzuführen sowie Probleme zu erkennen und zu beseitigen. Mit diesen Dateien
kann man auch den Wettersondenempfang in ein bereits bestehendes Linux-System
integrieren, z.B. auf einem bereits laufenden Linux-Server oder RaspberryPi.
Außerdem kann kann man damit auch ein mobiles Sondenempfangssystem auf Laptop
oder RaspberryPi zu bauen, welches man auf der Suche dabei hat.

Wenn ihr keine Ahnung von Linux habt oder lieber ein fertiges System nutzen
wollt, greift lieber zum Image von Michal SQ6KXY von radiosondy.info. Das könnt
ihr euch nach einer Registrierung auf seiner Seite einfach selbst
zusammenklicken und herunterladen. Man lernt zwar nichts dabei, aber in der
Regel funktioniert es auf Anhieb.

# Welche Wettersonden können empfangen werden?

Die dxlAPRS Tools können alle gängigen Wettersonden dekodieren, egal ob es
Vaisala RS41 oder RS92 sind, DFM Sonden von Graw oder sonstige Sonden wie M10,
C50, IMET etc. Voraussetzung ist jeweils, dass deren genaue Sendefrequenzen
bekannt sind und diese in der Frequenzdatei (sdrcfgX.txt) eingetragen sind. Die
dxlAPRS Tools können selbst nicht automatisch das Frequenzspektrum abscannen um
neue Frequenzen zu finden. Insbesondere ist dies bei DFM Sonden ein Problem, da
deren Frequenzen immer anders sind und auch nicht vorhergesagt werden können.
Die dxlAPRS Tools sind in der Lage die Signale dieser Sonden zu dekodieren,
jedoch nur wenn man die Frequenzen händisch einpflegt.

Für den Empfang von Sonden des Typs M10 sind Änderungen an der Konfiguration
notwendig. Die Samplerate bei sdrtst und sondeudp muss dann mindestens 20000 Hz
auf dem Stick betragen, wo M10 Sonden gehört werden. Dies erhöht allerdings
proportional die CPU Last. Deswegen sollte es auch wirklich nur dann geändert
werden, wenn wirklich M10 Sonden in Reichweite sind.

# Benötigte Hardware

Für den Sondenempfang ist ein gewöhnlicher RTL SDR USB-Stick zu empfehlen.
Idealerweise benutzt man einen RTL SDR mit TCXO. Diese sind von der ersten
Sekunde an frequenzstabil und benötigen auch keine Frequenzkorrektur. Als ideal
hat sich der „nesdr Smart“ von NooElec erwiesen. Dieser hat einen TCXO, ein
Metallgehäuse (gut für die Wärmeabfuhr!) und ein kompaktes Gehäuse. Die
Gehäuseform ermöglicht es z.B. am RaspberryPi auch zwei Sticks nebeneinander zu
betreiben ohne Verlängerungskabel. Zu beziehen sind die Sticks unter anderem bei
Amazon. Es gibt eine Version ohne Bias-T und eine mit Bias-T. Je nachdem ob ihr
noch einen Vorverstärker mit einer Versorgungsspannung versorgen wollt, nehmt
ihr den richtigen. Man kann auch zwei oder mehr Sticks parallel an einem Rechner
benutzen. Beschränkungen gibt es nur bei der CPU-Leistung und der
Stromversorgung der Sticks über USB. Letzteres muss bei der Nutzung eines
RaspberryPi berücksichtigt werden. Als Rechner kann jeder 32bit oder 64 bit PC
oder auch so ziemlich jeder Einplatinenrechner (RaspberryPi, BananPi, OrangePi
etc.) mit Linux Betriebssystem verwendet werden. Die dxlAPRS Tools stehen für
folgende PC Architekturen zu Verfügung:

* armv6 (z.B. RaspberryPi 1. Generation und Zero)
* armv7hf (ab RaspberryPi 2 aufwärts)
* x86_32 (z.B. Intel/AMD PC 32 bit)
* x86_64 (z.B. Intel/AMD PC 64 bit)

Für nur einen SDR Stick würde ein RaspberryPi 2B reichen. An der CPU-Leistung
sollte man jedoch nicht sparen. Empfehlenswert ist daher immer mindestens ein
RaspberryPi 3B+ oder neuer. Diese haben dann auch genug Reserven. Bei normalen
PCs spielt das keine Rolle mehr, die haben natürlich alle ausreichen CPU Power.

Um die Empfangsleistung zu verbessern kann man noch einen passenden
Vorverstärker vor die Antenne schalten. Auch ein SAW Filter für 403 MHz ist
empfehlenswert. Wenn ein Tetra BOS Sender in der Nähe ist, ist dies oft sogar
notwendig, da deren Signale bei knapp unter 400 MHz gleich „um die Ecke“ lauern
und dadurch den Wettersondenempfang stören können. Tipp: Bei Uputronics in
Großbritannien bekommt man ein solches Fertiggerät mit Filter und Vorverstärker
in einem schönen Alu-Gehäuse. Es kursieren aber auch Bauanleitungen für solche
Filter und Vorverstärker im internet.

# Installationshinweise  (Nicht notwendig für Nutzer des fertigen Images!)

1. dxlAPRS installieren

Installieren Sie die dxlAPRS Tools gemäß folgender Anleitung:
http://www.dl1nux.de/dxlaprs-tools-grundinstallation/

2. Zusätzliche Pakete installieren

SDR-Softwarepaket:

    sudo apt-get install rtl-sdr

Wenn man die Tools in einer grafischen Oberfläche laufen lassen will, empfiehlt
sich die Nutzung des xfce4-terminal. Es ermöglicht die getrennte Betrachtung der
Ausgaben der einzelnen Tools und hilft auch oft bei der Fehlersuche ;-)

    sudo apt-get install xfce4-terminal

3. Bei Bedarf: Zugriffsberechtigungen anpassen

In den meisten Linux-Distributionen können Standard-User nicht ohne Weiteres 
den USB SDR-Stick ansprechen, sondern benötigen Root-Rechte. Weil dies zu 
vielfältigen Problemen führen kann, geben wir den normalen Benutzern mit 
folgenden Schritten die benötigten Rechte, um auf den USB SDR-Stick zugreifen 
zu können:

    sudo nano /etc/udev/rules.d/20.rtlsdr.rules

Dort fügen wir folgende Zeile ein und speichern diese mit STRG+O:

    SUBSYSTEM=="usb", ATTRS{idVendor}=="0bda", ATTRS{idProduct}=="2838",GROUP="adm", MODE="0666", SYMLINK+="rtl_sdr"

4. Beispielskript und -dateien herunterladen und ggf. in den APRS Ordner kopieren

Download der Dateien von github in den Ordner ~/dxlAPRS/aprs:

	  git clone https://github.com/dl1nux/dxlAPRS-radiosonde-rx.git ~/dxlAPRS/aprs
	
Sollten die Dateien im falschen Ordner landen, einfach alles in den aprs
Programmordner kopieren oder verschieben.

Das Archiv enthält folgende Dateien:
* sonde.sh - Startskript für ein System MIT grafischer Oberfläche
* sondestandalone.sh - Startskript für ein Standalone-System OHNE grafischer Oberfläche
* sondenstop.sh - Beendet sofort alle dxlAPRS Prozesse
* sdrcfg0.txt - Musterdatei für die Sonden-Empfangsfrequenzen
* sdrcfg1.txt - Musterdatei für die Sonden-Empfangsfrequenzen
* sdrcfg2.txt - Musterdatei für die Sonden-Empfangsfrequenzen
* sondecom.txt - Enthält die Variablen für den APRS-Kommentartext
* netbeacon.txt - Defniert die APRS-Bake für den Empfänger ins APRS-IS Netzwerk
* README.md - Diese Infodatei
* sondenstart.desktop - Verknüpfung zu Sondenstart-Skript (für Desktop und Autostart)
* sondenstop.desktop - Verknüpfung zu Sondenstop-Skript (für Desktop)
* aprsmap.desktop - Verknüpfung zu APRSMAP (für Desktop)
* getalmd - Bash Skript von OE5DXL zum Laden des GPS Almanach für RS92 Sonden

Für den Standalonebetrieb ohne grafische Oberfläche werden lediglich folgende 
Dateien benötigt: 
* sondestandalone.sh
* sondenstop.sh
* sdrcfg0.txt
* sondecom.txt
* netbeacon.txt
* getalmd (nur für RS92 Sonden notwendig)

Alle weiteren Dateien werden nur benötigt, wenn man die Tools in der grafischen
Oberfläche betreiben will. Die *.desktop Dateien sind für die PIXEL Oberfläche
von Raspbian gedacht. Wenn man diese in den Desktop-Ordner kopiert, sieht man
die entsprechenden Symbole auf dem Desktop und kann diese direkt anklicken:

    cp *.desktop /home/pi/Desktop

5. Geoid Datendatei herunterladen

Zuletzt sollte noch die Datendatei für die Geoid-Berechnung geladen werden und 
im APRS Ordner abgelegt werden (dafür den Befehl idealerweise direkt aus 
~/dxlAPRS/aprs/ heraus aufrufen)

    wget https://earth-info.nga.mil/GandG/wgs84/gravitymod/egm96/binary/WW15MGH.DAC

Alle Programmdateien, Skripte und Textdateien sollten sich der Einfachheit
halber im selben Verzeichnis befinden. Auf dem RaspberryPi wäre das 
idealerweise das Verzeichnis  /home/pi/dxlAPRS/aprs . Alle weiteren Anweisungen
setzen voraus dass man sich in diesem Programmordner befindet. Bei Abweichungen
bitte entsprechend anpassen.

6. Optional: SRTM Höhendaten im System hinterlegen

Wenn man SRTM Datenfiles hat, kann das iGate udpgate4 diese nutzen um die Höhen
der Sonden über Grund im Webinterface anzuzeigen. Dazu muss im Ordner 
~/dxlAPRS/aprs/ der Ordner /srtm1 angelegt und die SRTM Datenfiles darin 
abgelegt werden. Bei udpdate4 muss im Aufruf der Parameter -A <Pfad zu /srtm1>
hinzugefügt werden. Die Startskripte enthalten am Ende eine Extrazeile
in der dieser Parameter bereits integriert ist. Dafür muss dann die "normale"
udpgate4 zeile auskommentiert und die andere einkommentiert werden.
Der /srtm1 Ordner sollte sich idealerweise im ~/dxlAPRS/aprs/ Ordner befinden.

# Vor dem ersten Start beachten

Wenn alle Pakete und Programmdateien installiert sind und sich die Skript- 
sowie Textdateien im Programmverzeichnis befinden, müssen noch mindestens die
folgenden Schritte bzw. Anpassungen vorgenommen werden:

1. Rufzeichen im Skript eintragen

Bei SONDEUDP, SONDEMOD und UDPGATE4 muss MYCALL durch euer Rufzeichen ersetzt
werden.

2. Eigenen Locator oder GPS-Standort sowie Höhe über NN eintragen

SONDEMOD benötigt für die Berechnung von Distanz, Azimuth und Elevation zur
Wettersonde den eigenen Locator bzw. GPS-Position sowie die eigene Höhe über NN.
Die Position gibt man mit dem Parameter -P im 10-stelligen Maidenhead-Locator
Format oder in Dezimalgrad an, z.B. -P JO01AB50CD oder -P 70.0506 10.0092. Den
10-stelligen Locator kann man auch hier bestimmen: http://k7fry.com/grid/. Die
Höhe über NN trägt man im Parameter „-N“ ein, z.B. „-N 250“ bei 250m über NN.

3. Ziel APRS-Gateway eintragen

Es muss ein Ziel-APRS Gateway eingetragen werden, an welches die erzeugten APRS
Pakete gesendet werden sollen. Für Wettersonden eignet sich der Server bei
radiosondy.info von Michal SQ6KXY. Dieser bereitet die Daten zusätzlich auf
einer eigenen Communityseite auf und leitet sie auch auf Wunsch an das APRS-
Netzwerk weiter. Entscheidend ist hier der Port an den gesendet wird. Der
Zielport 14580 liefert die Daten an radiosondy.info und leitet sie auch an das
APRS-Netzwerk weiter. Möchte man die Daten NUR an radisondy.info senden ohne
diese ans APRS-Netzwerk zu senden, sendet man die Daten an Port 14590.
Selbstverständlich kann man diese Daten auch direkt ins APRS-Netzwerk oder jeden
beliebigen APRS-Server senden ohne den Umweg über radiosondy.info.

4. APRS-Passcode

Den APRS-Passcode für das eigene Gateway-Rufzeichen trägt man bei UDPGATE4 im
Parameter -p ein. Dies ist notwendig, da sonst die APRS-Server keine Daten
entgegen nehmen. Generieren kann man diesen z.B. hier:
    https://apps.magicbug.co.uk/passcode/

5. netbeacon.txt

Die netbeacon.txt enthält die Koordinaten und den Kommentartext für die APRS-
Netzbake des eigenen iGates. Bitte die Informationen in der netbeacon.txt lesen
und beachten.

6. sdrcfg0.txt

Diese Datei enthält Parameter und Sondenfrequenzen, die überwacht werden 
sollen. Für jeden SDR-Stick muss eine eigene sdrcfg Datei erzeugt werden. 
Idealerweise werden diese durchnummeriert: sdrcfg0.txt, sdrcfg1.txt, 
sdrcfg2.txt usw.

7. Optional: sondecom.txt

Optional deswegen, da die Vorgabe in der Regel reichen sollte. Anpassungen sind
jedoch auf Wunsch und nach persönlichem Bedarf möglich. Diese Datei enthält die
Variablen für die Informationen, die den APRS-Paketen als Kommentartext
angehängt werden. Man kann mehrere Zeilen definieren, dann werden die Kommentare
abwechselnd variiert. Zeilen beginnend mit # werden ignoriert. Der mitgelieferte
Inhalt ist ein Vorschlag der nützliche Informationen mit anzeigt und sendet.

    %d%D%A%E%f
    %s%u%v%f

Die Beispielvariablen erzeugen zwei sich abwechselnde APRS-Kommentare bestehend
aus:

* RSSI-Wert (Empfangspegel), Entfernung zur Sonde, Azimuth und Elevation zur
  Sonde in Grad, Frequenzabweichung innerhalb der AFC
* Anzahl der empfangenen GPS-Satelliten, bisherige Laufzeit der Sonde, sondemod
  Programmversion, Frequenzabweichung innerhalb der AFC

So sehen die erzeugten APRS-Pakete beispielsweise aus:

    DL1NUX-11>APLWS2:;P3340619 *174008h4927.18N/01232.40EO112/027/A=056331!wbA!
    Clb=6.0m/s Type=RS41 rssi=68.5dB dist=270.218 azimuth=107 elevation=2.34 
    rx=402700(+0/5)

    DL1NUX-11>APLWS2:;P3340619 *174028h4927.14N/01232.56EO107/021/A=056650!wbb!
    Clb=4.6m/s Type=RS41-SGP Sats=11 powerup h:m:s 01:08:51 sondemod 1.36 
    rx=402700(+0/5)

8. Programm und Dateipfade anpassen

Falls sich eure Programme und Dateien nicht in /home/pi/dxlAPRS/aprs befinden,
müsst ihr alle genannten Dateipfade im Skript nachträglich anpassen.

# Programmstart

Das Programm kann an der Konsole mit ./sonde.sh bzw. ./sondestandalone.sh
gestartet werden. Wenn man sich sich nicht im Programmverzeichnis befinden,
kann man auch den kompletten Pfad angeben: /home/pi/dxlAPRS/aprs/sonde.sh

Wenn man eine grafische Oberfläche hat, kann man die Skriptdateien auch direkt
aus einem Dateimanager heraus mit Doppelklick starten.

# Autostart

Möchte man den Sondenempfänger automatisch direkt nach dem Hochfahren des 
Rechners starten, gibt es folgende Möglichkeiten.

1. Automatisches Starten auf einem Standalone-PC ohne grafische Oberfläche

Es hat sich bewährt das Skript direkt nach dem Hochfahren mit der crontab zu
starten. Dazu muss die Datei /etc/crontab als root (sudo) editiert werden:

    sudo nano /etc/crontab

Nun fügt man folgenden Eintrag der Tabelle hinzu:

    @reboot pi /home/pi/dxlAPRS/aprs/sondestandalone.sh

"pi" nach dem "@reboot" ist der Benutzer, unter dem das Skript ausgeführt werden
soll. Es sollte NICHT! als root laufen. Wenn der Dateiname des Skripts 
abweicht, bitte entsprechend eintragen.

Es gibt darüberhinaus auch andere Möglichkeiten das Skript automatisch starten
zu lassen. Das ist euch dann selbst überlassen. Falls euer Rechner zu lange
zum booten braucht und das Skript zu schnell startet, verpasst ihm einfach
einen "sleep 20" oder so am Anfang der Datei, dadurch startet es später.

2. Automatisches Starten auf einem RaspberryPi mit PIXEL GUI

Wenn man das Skript in einer grafischen Oberfläche startet, ist man in der Lage
die Ausgabe der einzelnen Tools zu verfolgen. Auch kann man das Programm 
APRSMAP zur grafischen Darstellung der Sonden auf einer Karte nutzen.

Dazu erstellt man erst den autostart Ordner (sofern er noch nicht existiert)
und kopiert anschließend die sondenstart.desktop Datei hinein.

    mkdir ~/.config/autostart
    cp sondenstart.desktop /home/pi/.config/autostart

Im grafischen Dateimanager muss ggf. erst die Option "Versteckte anzeigen"
im Menü "Ansicht" aktiviert werden, damit man den Ordner ~/.config sieht.

===========================================================================

Diese Anleitung wurde mit bestem Wissen und Gewissen und mit Hilfe des
Entwicklers Christian OE5DXL erstellt. Aber auch hier kann sich natürlich der
Fehlerteufel verstecken. Deshalb sind alle Angaben ohne Gewähr! Auch geht die
Entwicklung der dxlAPRS Tools immer weiter, was auch Veränderungen mit sich
bringen kann. Wenn ihr einen Fehler findet oder Fragen habt, zögert nicht mich
zu kontaktieren. Gerne auch als Kommentar auf der Webseite.

Kontaktmöglichkeiten:

* per E-Mail attila@dl1nux.de
* per IRC Chat im Hamnet (HamIRCNet) im Kanal #hamnet-oberfranken 
* per Packet-Radio im DL/EU Converse Kanal 501

Die ausführliche Anleitung mit einer Erklärung aller Parameter befindet sich im
Internet auf meiner Webseite:
http://www.dl1nux.de/wettersonden-rx-mit-dxlaprs/
