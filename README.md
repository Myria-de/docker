# Docker unter Ubuntu/Linux Mint installieren

```
sudo apt-get update
sudo apt-get install curl dbus-user-session uidmap
curl -fsSL https://get.docker.com/rootless | sh
sudo loginctl enable-linger $(whoami)
```
Öffnen Sie über den Dateimanager die versteckte Datei „.bashrc“ (einblenden mit Strg-H) in einem Editor. Fügen Sie am Ende die Zeile
```
export DOCKER_HOST=unix:///run/user/1000/docker.sock
```
an. Diese Angabe wird von einigen Anwendungen benötigt. Speichern und schließen Sie die Datei.

Die ausführbaren Dateien werden im Home-Verzeichnis im Ordner „bin“ installiert. Damit dieser sich im Suchpfad befindet, muss die Profilkonfiguration neu eingelesen werden:
```
source ~/.profile
```
Die Datei „.bashrc“ wird damit ebenfalls neu eingelesen.

Damit Docker ohne root-Privilegien Netzwerkports unterhalb von 1024 verwenden kann, muss die Konfiguration mit diesen zwei Zeilen angepasst werden:
```
sudo setcap cap_net_bind_service=ep $(which rootlesskit)
systemctl --user restart docker
```
**Hinweis:** Wer Docker traditionell mit root-Rechten verwenden will, entfernt bei der Installation in der curl-Zeile „rootless“.

# Erste Versuche mit Docker
```
docker run -t -i --rm ubuntu bash
```
Wieder verlassen:
```
exit
```
Eine durchsuchbare Datenbank mit allen verfügbaren Systemen und Anwendungen gibt es unter https://hub.docker.com.

# Container anpassen und Image erstellen
```
docker run -t -i ubuntu bash
```
Im Container:
```
apt update && apt install -y mc
```
Verlassen Sie die Shell mit **exit**. Diesen Container können Sie jetzt mit dem Image verschmelzen. Geben Sie zuerst den Befehl
```
docker ps -l
```
ein, der den gerade neu angelegten Container mit dem Midnight Commander auflistet. In der Liste finden Sie die Container-ID auf der linken Seite. Lautet diese ID beispielsweise „17145a42596e“, dann sichern Sie mit dem Kommando
```
docker commit 17145a42596e ubuntu-mit-mc
```
den Container-Zustand dauerhaft in einem Image mit dem Namen „ubuntu-mit-mc“. Wenn Sie daraus mit
```
docker run -i -t ubuntu-mit-mc bash
```
einen neuen Container erstellen, dann können Sie mit dem Befehl mc den dort installierten Midnight Commander im virtuellen Ubuntu starten. Mit exit verlassen Sie den Container. Der Befehl
```
docker images
```
zeigt jetzt neben dem zuerst erstellen Image „ubuntu“ auch „ubuntu-mit-mc“ an. Um einen Container auf der Basis des neuen Images zu erstellen, starten Sie 
```
docker run -t -i ubuntu-mit-mc bash
```
# Docker-Container verwalten
Welche Container aktuell laufen, erfahren Sie über den Befehl
```
docker ps
```
Wenn Sie einen interaktiven Container („run -i“) mit exit verlassen, wird er gestoppt. Mit
```
docker ps -a
```
erhalten Sie eine Übersicht mit allen vorhandenen Containern. In der Ausgabe sehen Sie auch die inaktiven Container und deren IDs. Mit 
```
docker start [Container-ID]
```
starten Sie einen Container wieder und mit
```
docker attach [Container-ID]
```
reaktivieren Sie – wenn vorhanden – die interaktive Verbindung zur Shell.

Docker kennt noch viele weitere Befehle. Eine Übersicht erhalten Sie, indem Sie das Tool ohne Parameter aufrufen. Eine Hilfe zu den Optionen für beispielsweise den Befehl „run“ liefert
```
docker run --help
```
Wichtig ist noch der Befehl „rm“, mit dem Sie Container löschen, oder „rmi“ zum Löschen von Images – jeweils gefolgt von der gewünschten Container-ID beziehungsweise Image-ID.

# Docker über den Webbrowser verwalten
Für einfache Aufgaben reichen die Docker-Befehle im Terminal meist aus. Sobald man jedoch mehrere Images und Container für Webanwendungen einrichten möchte, verwendet man besser eine grafische Oberfläche. Dafür empfiehlt sich die Docker-Verwaltung Portainer (www.portainer.io), die selbst über Docker installiert wird. Dafür verwenden Sie im Terminal diese Befehlszeile:
```
docker run -d -p 8000:8000 -p 9443:9443 --name=portainer --restart=always -v /$XDG_RUNTIME_DIR/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce
```
Anschließend rufen Sie die URL https://localhost:9443 im Webbrowser auf. Da Portainer ein selbst signiertes Zertifikat verwendet erhalten Sie eine Warnung. In Firefox klicken Sie auf „Erweitert“ und dann auf „Risiko akzeptieren und fortfahren“.

Geben Sie Benutzername und Passwort für den administrativen Benutzer ein, klicken Sie auf „Create user“, dann auf „Get started“ und anschließend auf „Live connect“.
Im Menü auf der linken Seite des Fensters sehen Sie nach einem Klick auf „Images“ die bisher erstellten Docker-Images. Bei nicht mehr benötigten Images können Sie ein Häkchen setzen und auf „Remove“ klicken.

Gehen Sie auf „Containers“. Hier werden die Container angezeigt, die Spalte „State“ enthält „exited“ bei gestoppten Containern, andernfalls „running“. Sie können Container markieren und starten. In der Spalte „Quick Actions“ lässt sich über das Icon „Exec Console“ (zweites von rechts) nach einem Klick auf „Connect“ ein Terminal im Browser aufrufen.
Um die Konfiguration eines Containers zu ändern, klicken Sie ihn in der Spalte „Name“ an. Sie können beispielsweise hinter „Restart policies“ den Wert „Allways“ wählen und auf „Update“ klicken. Der Container wird dann nach einem Linux-Neustart automatisch aktiviert.
# Firefox in Docker starten
Klicken Sie auf „Firefox-Docker.tar.gz“ und dann auf „Raw“. Entpacken Sie das Archiv im Dowload-Verzeichnis und öffnen Sie den Ordner im Terminal. Starten Sie 
```
./1_Build_Docker_Firefox.sh
```
und danach
```
./2_Run_Docker_Firefox.sh
```
Das erste Script erstellt das Image „firefox“, installiert darin die nötigen Pakete, stellt die deutsche Sprachunterstützung ein und erstellt das Benutzerkonto „docker_user“. Außerdem wird das Passwort für den VNC-Server auf „1234“ festgelegt. Das zweite Script erstellt und aktiviert den Container.
