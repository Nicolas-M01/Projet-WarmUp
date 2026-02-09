# Paramétrage des Firewalls
---

## Configuration des VLANs sur le firewall.

Nous avons choisi de créer une carte réseau par VLAN sur Proxmox, que nous avons ensuite attribué aux FireWalls de chaque site.  

Ici les cartes réseau créées :  
vmbr10 : WAN  
vmbr11 : Réseau d'administration du Firewall.  
vmbr100 à vmbr105 : VLAN10 à VLAN60.  
![alt text](<Images/Capture d'écran 2026-02-09 164441.png>)  

Une fois créés, les VLANS sont liés aux FireWalls de chaque site :  
![alt text](<Images/Capture d'écran 2026-02-09 165207.png>)  

Puis sur chaque machine cliente, on lie la carte réseau représentant le VLAN, ici VLAN10 (vmbr100) et Lan d'admin de PfSense (vmbr11) :  
![alt text](<Images/Capture d'écran 2026-02-09 165322.png>)  


