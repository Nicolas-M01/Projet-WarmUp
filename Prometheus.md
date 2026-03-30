
>**⚙️ Création du fihier prometheus.yml et durcissement des règles :**  
Création utilisateur système sans home, sans login :  
 **`useradd --no-create-home --shell /bin/false prometheus`**  
![alt text](<Images/Capture d'écran 2026-03-30 115422.png>)
![alt text](<Images/Capture d'écran 2026-03-30 115127.png>)


---

>**⚙️ Installation agent sur Windows avec règles de FireWall :**  

Installer agent Windows_exporter après avoir vérifié le hash de l'exécutable et mettre des règles de firewall :  
**`New-NetFirewallRule -DisplayName "Prometheus Windows Exporter" -Direction Inbound -Action Allow -Protocol tcp -LocalPort 9182 -RemoteAddress 10.1.10.11 -Pofile private`**  

**Les métriques ne doivent être visibles que depuis le serveur Prometheus :**  
`curl http://10.1.10.12:9182:metrics`  

---

>**⚙️ Installation agent sur Linux avec règles de FireWall :**  

Vérifier hash du binaire puis installer node_exporter :  

``sudo useradd --no-create-home --shell /sbin/nologin node_exporter``  
``https://github.com/prometheus/node_exporter/releases/download/v1.10.2/node_exporter-1.10.2.linux-amd64.tar.gz``
Décompression de l'archive :
``tar xvf node_exporter-1.10.2.linux-amd64.tar.gz``

**Copie du binaire dans un repertoire standard du système et modification des droits :**  
``cp node_exporter-1.10.2.linux-amd64/node_exporter /usr/local/bin/``  
``sudo chmod 755 /usr/local/bin/node_exporter``  
``sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter``  


**Règles de firewall (après installation de ufw) :**  
Autoriser uniquement l'IP du serveur Prometheus  
`sudo ufw allow from 10.1.10.11 to any port 9100 proto tcp`  
`sudo ufw enable` : Si UFW n'est pas encore actif  
`sudo ufw reload` : Recharger après modification  
`sudo ufw status verbose`  



Fichier de configuration du service node_exporter :  
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

>**⚙️ Paramétrage minimal de Prometheus :**  
![alt text](<Images/Capture d'écran 2026-03-30 112123.png>)

---

>**⚙️ Vérification du status des clients depuis port 9090 :**  
![alt text](<Images/Capture d'écran 2026-03-30 112546.png>) 

---

>**⚙️ Visualisation des dashboards avec Grafana depuis son port 3000 :**  
![alt text](<Images/Capture d'écran 2026-03-30 113042.png>)  


