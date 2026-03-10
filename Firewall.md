# Paramétrage des Firewalls
---

## Configuration des VLANs sur le firewall.  
Il existe 2 méthodes pour simuler les VLAN sous Proxmox :  
* Méthode 1 : Un bridge (vmbr) par VLAN  
* Méthode 2 : Un seul bridge avec VLAN Aware  


### Méthode 1 : Un bridge (vmbr) par VLAN


>:bulb: **Ici les cartes réseaux créées :**  
>* vmbr10 : WAN  
>* vmbr11 : Réseau d'administration du Firewall.  
>* vmbr100 à vmbr105 : VLAN10 à VLAN60.  

![alt text](<Images/Capture d'écran 2026-02-09 164441.png>)  

**Une fois créés, les VLANS sont liés aux FireWalls de chaque site :**  
![alt text](<Images/Capture d'écran 2026-02-09 165207.png>)  

**Puis sur chaque machine cliente, on lie la carte réseau représentant le VLAN, ici VLAN10 (vmbr100) et Lan d'admin de PfSense (vmbr11) :**  
![alt text](<Images/Capture d'écran 2026-02-09 165322.png>)  

**Puis, on renomme et active les cartes réseaux (OPT1 en VLAN10 SRV...) et on attribue les adresses logiques qui serviront de passerelle pour les VLAN (VLAN10 => 10.1.10.254/24)**  

Une fois les cartes réseaux assignées, nous avons implémentés des règles de FireWall afin d'autoriser ou de bloquer le traffic.  
Puis une activation du relai DHCP est effectué sur le FIreWall, car les serveurs DHCP seront les serveurs Windows.  

![alt text](<Images/Capture d'écran 2026-02-09 170047.png>)  




## Méthode 2 : Un seul bridge avec VLAN Aware

Principe : Un seul `vmbr` avec l'option "VLAN aware" activée, et chaque VM reçoit un tag VLAN.

Cocher "VLAN aware" sur le bridge (ex: vmbr0)
Côté VM, assigner un VLAN tag (ex: 10, 20) sur l'interface réseau
pfSense reçoit le trunk et gère les sous-interfaces (ex: vtnet0.10, vtnet0.20)  

Visu des cartes réseaux sur le firewall :  
![alt text](<Images/Capture d'écran 2026-03-10 171116.png>)

Il reste à paramétrer les cartes et les vlans sur le firewall.  
Chaque client devra être tagué sur le bon VLAN come ici en vlan 50 :  
![alt text](<Images/Capture d'écran 2026-03-10 172224.png>)

