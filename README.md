# dxlAPRS-radiosonde-rx
Wettersonden-Empfänger mit dxlAPRS

Stand 25.01.2026

# Inhaltsverzeichnis
* Einleitung
* Hinweise für den Empfang von Wettersonden
* Für wen sind diese Skripte und Dateien geeignet?
* Welche Wettersonden können empfangen werden?
* Benötigte Hardware
* Funktionsweise der vorliegenden Skripte
* Installationshinweise
* Daten zusätzlich an sondehub.org senden
* Vor dem ersten Start beachten
* Programmstart
* Autostart
* Ausführliche Erläuterung aller Parameter
* Tipps & Tricks

# Einleitung

Die folgende Anleitung dient dazu in wenigen Schritten einen Wettersonden-
Empfänger aufzubauen, der seine Daten an die Community-Seite radiosondy.info,
zu wettersonde.net und auch in das APRS-Netzwerk weiterleitet. 
Selbstverständlich kann man den Empfänger auch nur lokal nutzen ohne eine 
Weiterleitung der Daten.

Optional ist eine Weiterleitung der Daten auch an sondehub.org möglich. Hierzu
sind aber weitere manuelle Angaben und Codeinstallationen notwendig. Bitte 
hierzu den Abschnitt "Daten zusätzlich an sondehub.org senden" lesen. Eine
Installation von weiterem Code ist nicht notwendig, wenn die fertigen Images
von Attila DL1NUX verwendet werden.

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
* udpbox (Verfielfältigung der AXUDP Streams)
* udpgate4 (APRS iGate)

rtl_tcp stellt einen SDR Server bereit. sdrtst zapft diesen SDR Server an und
erzeugt Empfänger auf den vorgegebenen Frequenzen (sdrcfg0.txt). sdrtst sendet
die empfangenen Signale in eine Audiopipe, an dessen Ende sondeudp arbeitet.
sondeudp dekodiert empfangene Sondensignale und sendet die Rohdaten an 
sondemod. sondemod wiederrum erzeugt aus den Sondendaten konforme APRS-Pakete
als APRS-Objekte und sendet diese an udpbox. Dort werden sie verfielfältigt 
um die erzeugten Pakete zeitgleich an zwei Server und ggf. noch an das 
Kartenprogramm APRSMAP schicken zu können.

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

Von Wolfgang Hallmann DF7PN gibt es eine Anwendung, mit der man an einem extra
Stick die Frequenzen regelmäßig abscannen kann um damit Sonden auf unbekannten
Frequenzen zu finden. Mit etwas Geschick und viel Wissen kann man den 
die vorliegenden Scripte auch mit dem Sondenscanner ergänzen.
Weitere Infos: https://github.com/whallmann/SondenUtils

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

# Funktionsweise der vorliegenden Skripte

Die Skripte empfangen und dekodieren die Daten der Wettersonden. Daraus werden
APRS-Pakete (APRS-Objekte) erzeugt. Diese APRS Pakete werden dann an den APRS- 
Server von radiosondy.info gesendet. Zusätzlich können die Daten noch mit 
APRSMAP auf einer Karte dargestellt werden.

Die meisten Parameter müssen in der Datei sondeconfig.txt eingetragen werden.
Diese Datei wird von jedem Skript zu Beginn eingelesen und die enthaltenen
Variablen an den richtigen Stellen eingefügt. Dadurch ist es möglich mit nur
einer Konfigurationsdatei alle Skripte zu verwenden. Die verschiedenen Skripte
müssen nicht mehr alle einzeln angepasst werden.

Darüberhinaus sind natürlich noch manuelle Anpassungen an den Skripten erlaubt.

Es sind insgesamt Sieben Skripte enthalten. Drei Startskripte für den 
Konsolenbetrieb ohne grafische Oberfläche, und drei für die Nutzung in der
grafischen Oberfläche (*-gui.sh). Diese sind jeweils für die Nutzung von ein,
zwei oder drei Sticks parallel gedacht. Ein weiteres Skript ist zum stoppen
aller Prozesse gedacht (sondestop.sh).

Wenn der Empfänger läuft, kann man das Webinterface des iGates einfach
im Browser über den Port 14501 aufrufen, z.B.:

    http://<IP-Adresse-des-RaspberryPis>:14501/mh

Natürlich müsst ihr die passende IP-Adresse einsetzen, die euer RaspberryPi
bzw. Rechner im Netzwerk hat. Erscheint nur eine Leere Seite beim Aufruf?
Dann habt ihr vielleicht im Ordner /dxlAPRS/aprs/www/ die Datei index.html.
Diese müsst ihr dann löschen.

Im Webinterface sieht man dann nach einiger Zeit die Empfangenen Sonden mit all
ihren Daten aus den letzten 48 Stunden. Die Zeitspanne der Anzeige lässt sich 
auch bei Bedarf in den Startskripten händisch anpassen (-B beim udpgate4).

# Installationshinweise  (Nicht notwendig für Nutzer des fertigen Images!)

1. dxlAPRS installieren

Installiert die dxlAPRS Tools gemäß folgender Anleitung:
http://dxlwiki.dl1nux.de/index.php?title=Installationsanleitung

Führt anschließend noch ein Update mit dem Updateskript dxl-update.sh durch.
Siehe auch: https://github.com/dl1nux/dxlAPRS-update

2. Zusätzliche Pakete installieren

SDR-Softwarepaket:

    sudo apt install rtl-sdr

Wenn man die Tools in einer grafischen Oberfläche laufen lassen will, empfiehlt
sich die Nutzung des xfce4-terminal. Es ermöglicht die getrennte Betrachtung der
Ausgaben der einzelnen Tools und hilft auch oft bei der Fehlersuche ;-)

    sudo apt install xfce4-terminal

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

4.1. Download der Dateien von github in den Ordner ~/dxlAPRS/aprs:

	  cd ~/dxlAPRS/aprs/
      git clone https://github.com/dl1nux/dxlAPRS-radiosonde-rx.git
	
Die Dateien landen nun im Unterordner /dxlAPRS-radiosonde-rx des APRS Ordners.

Das Archiv enthält folgende Dateien:
* getalmd - Bash Skript von OE5DXL zum Laden des GPS Almanach für RS92 Sonden
* netbeacon_sonde.txt - Defniert die APRS-Bake für den Empfänger ins APRS-IS Netzwerk
* objectlink.txt - externer Link zu radiosondy.info für die Sondeneinträge im Webinterface
* README.md - Diese Infodatei
* sdrcfg0.txt - Musterdatei für die Sonden-Empfangsfrequenzen für den 1. Stick
* sdrcfg1.txt - Musterdatei für die Sonden-Empfangsfrequenzen für den 2. Stick
* sdrcfg2.txt - Musterdatei für die Sonden-Empfangsfrequenzen für den 3. Stick
* sonde1.sh - Startskript für ein System ohne grafischer Oberfläche und EINEM Stick
* sonde2.sh - Startskript für ein System ohne grafischer Oberfläche und ZWEI Sticks
* sonde3.sh - Startskript für ein System ohne grafischer Oberfläche und DREI Sticks
* sonde1-gui.sh - Startskript für ein System mit grafischer Oberfläche und EINEM Stick
* sonde2-gui.sh - Startskript für ein System mit grafischer Oberfläche und ZWEI Sticks
* sonde3-gui.sh - Startskript für ein System mit grafischer Oberfläche und DREI Sticks
* sondecom.txt - Enthält Parameter für den APRS-Kommentartext
* sondeconfig.txt - Enthält die wichigen Variablen für die Konfiguration
* sondestop.sh - Beendet sofort alle dxlAPRS Prozesse
* WW15MGH.DAC - Geoid Höhen Datenfile

4.2. Dateien verschieben oder kopieren

Im Unterordner "Desktop" befinden sich Desktopverknüpfungen für die grafische Oberfläche
* desktop-sonde1.desktop - Verknüpfung zum Startskript für EINEN Stick
* desktop-sonde2.desktop - Verknüpfung zum Startskript für ZWEI Sticks
* desktop-sonde3.desktop - Verknüpfung zum Startskript für DREI Sticks
* desktop-sondenstop.desktop - Verknüpfung zum Sondenstop-Skript
* aprsmap.desktop - Verknüpfung zu APRSMAP

Man kopiert diese entweder über den Dateimanager in den Ordner ~/Desktop oder
oder kopiert sie an der Konsole wie folgt:

    cp *.desktop ~/Desktop

Die Datei **objectlink.txt** muss in den Ordner *~/dxlAPRS/aprs/www/* kopiert werden.
Sie enthält den externen Link zu radiosondy.info der aufgerufen wird, sobald man im 
Webinterface die Seriennummer einer empfangenen Sonde anklickt.

5. Geoid Datendatei herunterladen

Zuletzt sollte noch die Datendatei für die Geoid-Berechnung in den aprs Ordner 
geladen werden (dafür den Befehl idealerweise direkt aus dem Ordner
~/dxlAPRS/aprs/ heraus aufrufen)

    wget http://download.osgeo.org/proj/vdatum/egm96_15/outdated/WW15MGH.DAC

6. Optional: SRTM Höhendaten im System hinterlegen

Wenn man SRTM Datenfiles hat, kann das iGate udpgate4 diese nutzen um die Höhen
der Sonden über Grund im Webinterface anzuzeigen. Dazu muss im Ordner 
~/dxlAPRS/aprs/ der Ordner /srtm1 angelegt und die SRTM Datenfiles darin 
abgelegt werden. Bei udpdate4 muss im Aufruf der Parameter -A <Pfad zu /srtm1>
hinzugefügt werden. In den fertigen Startskripten ist dies bereits 
berücksichtigt.

Alle Programmdateien, Skripte und Textdateien sollten sich der Einfachheit
halber im selben Verzeichnis befinden. Auf dem RaspberryPi wäre das 
idealerweise das Verzeichnis  /home/pi/dxlAPRS/aprs . Alle weiteren Anweisungen
setzen voraus dass man sich in diesem Programmordner befindet. Bei Abweichungen
bitte entsprechend anpassen.

# Daten zusätzlich an sondehub.org senden

Falls nur die Skripte und nicht das fertige Image verwendet werden, sind weitere
Installationen notwendig. Zur Weiterleitung der Daten wird das Tool dxlAPRS-SHUE
von Simon Schäfer verwendet: https://github.com/Eshco93/dxlAPRS-SHUE

Kurzanleitung:

1. Zunächst alle Systemupdates laden und einspielen
* sudo apt update
* sudo apt upgrade

2. Python3 und benötigte Python Module installieren
* sudo apt install python3   (ist in Raspberry Pi OS bereits vorinstalliert)
* sudo apt install pip
* python -m pip install crc
* python -m pip install requests

Falls die Installationen mit pip auf ein anzugebendes Python-Environment verweisen,
können die zwei Module auch alternativ wie folgt installiert werden:

* python -m pip install crc --break-system-packages
* python -m pip install requests --break-system-packages

3. dxlAPRS-SHUE installieren

Ins dxlAPRS Programmverzeichnis wechseln - bzw. dorthin, wo die Startskripte liegen.
* cd ~/dxlAPRS/aprs/  (hier ggf. eigenen PFad angeben)
* git clone https://github.com/Eshco93/dxlAPRS-SHUE.git

4. Startskripte und Konfiguration anpassen

In den Startskripten ist der Start von dxlAPRS-SHUE bereits integriert, jedoch 
standardmäßig auskommentiert, da ich nicht davon ausgehen kann, dass jeder die 
Installationen des zuzsätzlichen Codes durchgeführt hat.

In den Startskripten sonde?.sh ist daher vor folgender Zeile das "#" zu entfernen:
    # python dxlAPRS-SHUE/dxlAPRS-SHUE.py -a 127.0.0.1 -p 18001 -k 0 -c $SONDECALL ...

In der sondeconfig.txt sind zwingend folgende Parameter für Sondehub sinnvoll zu 
belegen, da sonst keine Verbindung zu sondehub.org hergestellt werden kann:

LAN=50.23333
LON=11.00000
HOEHE=0
EMAIL=Mailaddresse-nur-für-Sondehub-eintragen

Die Koordinaten sind im Format WGS84 und Dezimalgrad (DD.DDDDD), also NICHT im
APRS Format (DD MM.MM).

Sondehub benötigt eine seperate Angabe der Position und der Höhe des Empfängers
zur Darstellung auf der Karte. Außerdem ist zwingend die Angabe einer validen
E-Mail Adresse erforderlich, mit der der Betreiber des Empfängers bei Problemen
kontaktiert werden kann. Die E-Mail Adresse sehen nur die Admins und wird nicht
veröffentlicht.


# Vor dem ersten Start beachten

Wenn alle Pakete und Programmdateien installiert sind und sich die Skript- 
sowie Textdateien im Programmverzeichnis befinden, müssen noch mindestens die
folgenden Schritte bzw. Anpassungen vorgenommen werden:

1. Parameter in der sondeconfig.txt eintragen:

* IGATECALL = Rufzeichen des iGates inkl. SSID, z.B. NOCALL-10
* SONDECALL = Rufzeichen des Absenders der Sondenobjekte inkl. SSID, z.B. NOCALL-11
* PASSCODE = APRS Passcode für das iGate-Rufzeichen, z.B. 12345
* LOCATOR = Eigener QTH-Locator (10 stellig!), z.B. JO01AA23BB (nur für Entfernungsberechnung relevant)
* LAT=50.23333  (Optional: wird nur für sondehub.org benötigt)
* LON=11.00000 (Optional: wird nur für sondehub.org benötigt)
* HOEHE = Höhe des Empfängers in Meter über NN (für Elevationsberechnung und Sondehub relevant)
* ALT1 = Höhenschwelle in Meter für kleinstes Sendeintervall, z.B. 3000
* ALT2 = Höhenschwelle in Meter für zweites Sendeintervall, z.B. 2000
* ALT3 = Höhenschwelle in Meter für drittes Sendeintervall, z.B. 1000
* INTERVALLHIGH = Sendeintervall in Sekunden für Sonden oberhalb von HEIGHT1, z.B. 30
* INTERVALL1 = Sendeintervall in Sekunden für Sonden in der Höhe zwischen HEIGHT1 und HEIGHT2, z.B. 20
* INTERVALL2 = Sendeintervall in Sekunden für Sonden in der Höhe zwischen HEIGHT2 und HEIGHT3, z.B. 10
* INTERVALL3 = Häufiges Sendeintervall in Sekunden für Sonden unterhalb der Höhe von HEIGHT3, z.B. 5
* EMAIL=Mailaddresse-nur-für-Sondehub-eintragen

Beim Vorhandensein von SRTM Daten in ~/dxlAPRS/aprs/srtm1/ werden bei den 
Parametern ALT* jeweils die Höhen über Grund zugrundegelegt.

**Hinweis:** iGate Rufzeichen und Absenderrufzeichen müssen identisch sein, jedoch
muss sich die SSID der beiden Calls unterscheiden. Also z.B. NOCALL-10 und
NOCALL-11. Dies ist Voraussetzung für die Einspeisung bei wettersonde.net

2. netbeacon_sonde.txt

Die netbeacon_sonde.txt enthält die Koordinaten und den Kommentartext für die APRS-
Netzbake des eigenen iGates. Diese müssen zwingend händisch eingetragen werden.
Bitte die Informationen in der netbeacon_sonde.txt lesen und beachten.
Die Aussendung einer Netz-Bake ist Voraussetzung für die Datenannahme bei 
wettersonde.net

3. sdrcfg0.txt / sdrcfg1.txt / sdrcfg2.txt

Diese Dateien enthalten SDR Parameter und die Sondenfrequenzen, die überwacht
werden sollen. Für jeden SDR-Stick muss eine eigene sdrcfg Datei verwendet 
werden, weshalb diese durchnummeriert sind. Wird nur ein Stick verwendet, muss
die Datei sdrcfg0.txt bearbeitet werden. Bei zwei Sticks die 0 und die 1 und 
bei drei Sticks alle drei. Möchte man hier manuell eingreifen, sind Änderungen
im Startskript beim Punkt **sdrtst** durchzuführen.

4. Optional: sondecom.txt

Optional deswegen, da die Vorgabe in der Regel reichen sollte. Anpassungen sind
jedoch auf Wunsch und nach persönlichem Bedarf möglich. Diese Datei enthält die
Variablen für die Informationen, die den APRS-Paketen als Kommentartext
angehängt werden. Man kann mehrere Zeilen definieren, dann werden die Kommentare
abwechselnd variiert. Zeilen beginnend mit # werden ignoriert. Der mitgelieferte
Inhalt ist ein Vorschlag der nützliche Informationen mit anzeigt und sendet.
Beim Einspeisen zu wettersonde.net werden manche Kommentare nicht akzeptiert.
Die hier gegebene Vorgabe wird aber anerkannt.

# Programmstart

Das Programm kann an der Konsole mit z.B. ./sonde2.sh gestartet werden. Wenn
man sich sich nicht im Programmverzeichnis befinden, kann man auch den 
kompletten Pfad angeben: /home/pi/dxlAPRS/aprs/sonde2.sh

Wenn man eine grafische Oberfläche hat, kann man die Skriptdateien auch direkt
aus einem Dateimanager heraus mit Doppelklick starten.

# Autostart

Möchte man den Sondenempfänger automatisch direkt nach dem Hochfahren des 
Rechners starten, gibt es folgende Möglichkeiten.

1. Automatisches Starten auf einem Standalone-PC ohne grafische Oberfläche

Es hat sich bewährt das Skript direkt nach dem Hochfahren mit der crontab zu
starten. Dazu muss die Datei /etc/crontab als root (sudo) editiert werden:

    sudo nano /etc/crontab

Nun fügt man beispielsweise folgenden Eintrag der Tabelle hinzu:

    @reboot pi /home/pi/dxlAPRS/aprs/sonde2.sh

"pi" nach dem "@reboot" ist der Benutzer, unter dem das Skript ausgeführt werden
soll. Es sollte NICHT! als root laufen. Wenn der Dateiname des Skripts 
abweicht, bitte entsprechend eintragen.

Es gibt darüberhinaus auch andere Möglichkeiten das Skript automatisch starten
zu lassen. Das ist euch dann selbst überlassen. Falls euer Rechner zu lange
zum booten braucht und das Skript zu schnell startet, verpasst ihm einfach
eine Wartezeit am Anfang der Datei. In den Skripten ist dies am Anfrag der 
Datei bereits vorgesehen, jedoch standardmäßig auskommentiert. Zum 
aktivieren entfernt man einfach die # vor der Zeile "sleep 10".

2. Automatisches Starten auf einem RaspberryPi mit PIXEL GUI

Wenn man das Skript in einer grafischen Oberfläche startet, ist man in der Lage
die Ausgabe der einzelnen Tools zu verfolgen. Auch kann man das Programm 
APRSMAP zur grafischen Darstellung der Sonden auf einer Karte nutzen.

Dazu erstellt man erst den autostart Ordner (sofern er noch nicht existiert)
und kopiert anschließend die sondenstart.desktop Datei hinein.

    mkdir ~/.config/autostart
    cp desktop-sonde2.desktop /home/pi/.config/autostart

Im grafischen Dateimanager muss ggf. erst die Option "Versteckte anzeigen"
im Menü "Ansicht" aktiviert werden, damit man den Ordner ~/.config sieht.

===========================================================================

Update 25.01.2026:
* Optionale Nutzung von sondehub.org mit dxlAPRS-SHUE eingebaut
* Muss in den Startskripten durch Einkommentieren aktiviert werden
* Zusätzliche Angaben in der sondeconfig.txt notwendig

Update 06.01.2026:
* Geringfügige Text Anpassungen in den Skripten, README ergänzt.
* Geoid Höhendatei WW15MGH.DAC hinzugefügt

Update 20.02.2022
* wettersonde.net wieder eingebaut da wieder online.
* Programmpfad wird nun automatisch ermittelt und in den Systempfad eingetragen
* DXLPATH aus sondeconfig.txt entfernt, wird nun automatisch ermittelt

Update 05.12.2021: 
* Dateiname geändert netbeacon.txt > netbeacon_sonde.txt
Damit kann man APRS- und Sondenskripte unabhängig voneinander in einem Ordner
ablegen und nutzen (Keine Namensgleichheit mehr).
* objectlink.txt eingefügt (externer Link zu radiosondy.info)
* Downloadpfad zur WW15MGH.DAC aktualisiert.

Update 29.01.2022:
* wettersonde.net ist QRT. Alle Einträge dorthin entfernt bzw. auskommentiert.
* Zeilen können bei Bedarf für einen weiteren APRS-Server genutzt werden.
* Einkommentieren und Serveradresse bei udpgate4 -g eintragen.
  
===========================================================================
FAQ

F: 
Wie geht ich vor wenn ich den verdacht habe dass ich nichts mehr empfange?
Was könnten die Ursachen sein?
A: 
* Webinterface checken - sind länger keine Einträge mehr vorhanden?
* Mit lsusb nachsehen ob noch alle SDR-Sticks im System eingebunden sind.
* Wenn ja, Prozesse checken mit z.B. htop. Jeder SDRTST Prozess muss eine
  nennenswerte CPU-Auslastung vorweisen. Wenn nicht, ist vermutlich der rtl_tcp
  Prozess abgebrochen.
* Ursache könnte eine schlechte USB-Verbindung sein (versehentlich angestoßen).
  Auch Stromversorgungsprobleme gibt es oft, bei mehr als zwei angeschlossenen
  SDR-Sticks. Abhilfe: Externen USB Hub mit eigener Stromversorgung nutzen).
* Ansonsten das Skript einfach neu starten, damit werden alle Prozesse beendet
  und neu gestartet. Man kann auch manuell einfach nur die rtl_tcp und sdrtst 
  Prozesse neu starten, der Rest kann eigentlich weiterlaufen.

F:
Wenn ich das Webinterface aufrufe, sehe ich nur eine leere Seite
A:
Befindet sich im Ordner /dxlAPRS/aprs/www eine Datei namens "index.html"?
Dann muss diese gelöscht werden. Die behindert den Aufruf des Webinterfaces.

F:
Das Webinterface lässt sich gar nicht aufrufen, es erscheint eine Fehlermeldung
im Browser.
A:
Vermutlich läuft das iGate "udpgate4" nicht. Dies kann man mit "top" oder "htop"
kontrollieren. Hier muss es einen Prozess "udpgate4" geben. Läuft er nicht, dann
ist dies die Erklärung, warum das Webinterface nicht erreichbar ist.
Zu Lösung des Problems bitte einmal das Skript manuell in der Konsole (z.B. per
SSH) starten. udpgate4 bringt mit Sicherheit beim Start eine Fehlermeldung.
Dieser muss man nachgehen.

===========================================================================

Diese Anleitung wurde mit bestem Wissen und Gewissen und mit Hilfe des
Entwicklers Christian OE5DXL erstellt. Aber auch hier kann sich natürlich der
Fehlerteufel verstecken. Deshalb sind alle Angaben ohne Gewähr! Auch geht die
Entwicklung der dxlAPRS Tools immer weiter, was auch Veränderungen mit sich
bringen kann. Wenn ihr einen Fehler findet oder Fragen habt, zögert nicht mich
zu kontaktieren. Gerne auch als Kommentar auf der Webseite.

Danksagungen:

* Chris OE5DXL für seine unersatzbare Arbeit an den dxlAPRS Tools
* Michael DL5OCD für die geniale Idee mit der config.txt
* Peter DK4KP für die Perfektonierung der Programmpfadbestimmung
* Al Maecht G0D für viele Inspirationen

Kontaktmöglichkeiten:

* per E-Mail attila@dl1nux.de
* per IRC Chat im Hamnet (HamIRCNet) im Kanal #hamnet-oberfranken 
* per Packet-Radio im DL/EU Converse Kanal 501

Die ausführliche Anleitung mit einer Erklärung aller Parameter befindet sich im
Internet auf meiner Webseite:
http://www.dl1nux.de/wettersonden-rx-mit-dxlaprs/

Support und Infos: 
* dxl-Wiki: http://dxlwiki.dl1nux.de
* Telegramm Community: https://t.me/joinchat/CRNMIBpKRcfQEBTPKLS0zg
* YouTube Video-Tutorials von DL1NUX: https://www.youtube.com/channel/UCRm7ulWMMXAK0PpviOO0xOg