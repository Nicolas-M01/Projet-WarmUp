
>### **⚙️ Installation Prometheus sur Debian 12 :**  
Créer VM Debian 12, puis télécharger Prometheus :  
`wget https://github.com/prometheus/prometheus/releases/download/v2.51.0/prometheus-2.51.0.linux-amd64.tar.gz`  
`tar xvf prometheus-2.51.0.linux-amd64.tar.gz`
`cd prometheus-2.51.0.linux-amd64`  
`sudo cp prometheus /usr/local/bin/`  
`sudo cp promtool /usr/local/bin/`  

**Copier les fichiers de config :**  
``sudo mkdir /etc/prometheus``  
``sudo mkdir /var/lib/prometheus``  
``sudo cp -r consoles/ console_libraries/ /etc/prometheus/``  
``sudo cp prometheus.yml /etc/prometheus/``  


>### **⚙️ Création du fihier `/etc/systemd/system/prometheus.service` et durcissement des règles :**  
Création utilisateur système sans home, sans login :  
 **`useradd --no-create-home --shell /bin/false prometheus`**  


```ini
[Unit]
# Attend que le réseau soit disponible avant de démarrer
Wants=network-online.target
After=network-online.target

[Service]
# Exécution sous l'utilisateur et groupe dédiés (principe du moindre privilège)
User=prometheus
Group=prometheus
# Type simple : systemd considère le service comme démarré dès le lancement du processus
Type=simple

# Sécurité : bind local si lifecycle activé (pas d'accès externe non authentifié)
ExecStart=/usr/local/bin/prometheus \
  # Fichier de configuration principal
  --config.file=/etc/prometheus/prometheus.yml \
  # Répertoire de stockage des données TSDB (time series)
  --storage.tsdb.path=/var/lib/prometheus \
  # Templates web de la console Prometheus
  --web.console.templates=/etc/prometheus/consoles \
  # Bibliothèques des consoles web
  --web.console.libraries=/etc/prometheus/console_libraries \
  # Écoute sur toutes les interfaces sur le port 9090
  --web.listen-address=0.0.0.0:9090 \
  # Active l'API lifecycle (reload, quit) via HTTP POST
  --web.enable-lifecycle

# Rechargement de la config sans redémarrage (SIGHUP)
ExecReload=/bin/kill -HUP $MAINPID
# Redémarre automatiquement en cas de crash
Restart=always
# Délai de 10s avant redémarrage
RestartSec=10

# Hardening systemd
# Interdit l'élévation de privilèges (setuid, capabilities)
NoNewPrivileges=true
# Répertoire /tmp isolé et privé pour le service
PrivateTmp=true
# Système de fichiers en lecture seule (sauf exceptions)
ProtectSystem=strict
# Interdit l'accès aux répertoires home des utilisateurs
ProtectHome=true
# Seul ce chemin est accessible en lecture/écriture
ReadWritePaths=/var/lib/prometheus

[Install]
# Activé dans la cible multi-utilisateur (démarrage normal du système)
WantedBy=multi-user.target
```
![alt text](<Images/Capture d'écran 2026-03-30 115127.png>)

---

>### **⚙️ Installation Grafana et règles de firewall :**  

`sudo apt install -y apt-transport-https software-properties-common wget gnupg2`  
`wget -q -O - https://apt.grafana.com/gpg.key | sudo gpg --dearmor -o /usr/share/keyrings/grafana.gpg`  
`echo "deb [signed-by=/usr/share/keyrings/grafana.gpg] https://apt.grafana.com stable main" | sudo tee /etc/apt/sources.list.d/grafana.list`  
`sudo apt update && sudo apt install -y grafana`  
**Démarrage service :**  
``sudo systemctl daemon-reload``  
``sudo systemctl enable grafana-server``  
``sudo systemctl status grafana-server``  
**Règle de firewall :**  
`sudo ufw allow from 10.1.10.0/24 to any port 3000 proto tcp`  
`sudo ufw reload`  

---

>### **⚙️ Installation agent sur Windows avec règles de FireWall :**  

Installer agent Windows_exporter après avoir vérifié le hash de l'exécutable et mettre des règles de firewall :  
**`New-NetFirewallRule -DisplayName "Prometheus Windows Exporter" -Direction Inbound -Action Allow -Protocol tcp -LocalPort 9182 -RemoteAddress 10.1.10.11 -Pofile private`**  

**Les métriques ne doivent être visibles que depuis le serveur Prometheus :**  
`curl http://10.1.10.12:9182:metrics`  

---

>### **⚙️ Installation agent sur Linux avec règles de FireWall :**  

Vérifier hash du binaire puis installer node_exporter :  

``sudo useradd --no-create-home --shell /sbin/nologin node_exporter``  
``https://github.com/prometheus/node_exporter/releases/download/v1.10.2/node_exporter-1.10.2.linux-amd64.tar.gz``
Décompression de l'archive :
``tar xvf node_exporter-1.10.2.linux-amd64.tar.gz``

**Copie du binaire dans un repertoire standard du système et modification des droits :**  
``cp node_exporter-1.10.2.linux-amd64/node_exporter /usr/local/bin/``  
``sudo chmod 750 /usr/local/bin/node_exporter``  
``sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter``  


**Règles de firewall (après installation de ufw) :**  
Autoriser uniquement l'IP du serveur Prometheus  
`sudo ufw allow from 10.1.10.11 to any port 9100 proto tcp`  
`sudo ufw enable` : Si UFW n'est pas encore actif  
`sudo ufw reload` : Recharger après modification  
`sudo ufw status verbose`  



**Fichier de configuration du service node_exporter :**  
`sudo nano /etc/systemd/system/node_exporter.service` :  
```yml

[Unit]
# Description du service affichée par systemd
Description=Prometheus Node Exporter

# Indique que le service a besoin du réseau opérationnel
Wants=network-online.target

# Assure que le service démarre après que le réseau soit disponible
After=network-online.target


[Service]
# Utilisateur système sous lequel le service s’exécute
# (bonne pratique de sécurité : ne pas utiliser root)
User=node_exporter

# Groupe associé à l’utilisateur du service
Group=node_exporter

# Type "simple" : le processus lancé est le service principal
Type=simple

# Commande exécutée pour démarrer node_exporter
# Le binaire expose les métriques système sur le port TCP 9100
ExecStart=/usr/local/bin/node_exporter


[Install]
# Définit à quel niveau d’exécution le service est activé
# multi-user.target correspond au mode serveur standard
WantedBy=multi-user.target
```



---

>### **⚙️ Paramétrage minimal de Prometheus :**  
![alt text](<Images/Capture d'écran 2026-03-30 112123.png>)

---

>### **⚙️ Vérification du status des clients depuis port 9090 :**  
![alt text](<Images/Capture d'écran 2026-03-30 112546.png>) 

---

>### **⚙️ Visualisation des dashboards avec Grafana depuis son port 3000 :**  
![alt text](<Images/Capture d'écran 2026-03-30 113042.png>)  


