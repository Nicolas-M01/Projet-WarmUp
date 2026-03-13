# Windows Server 2025 GUI
---


## Script PowerShell de création des dossiers partagés pour chaque Service (des OU dans notre cas).  

![alt text](<Images/Capture d'écran 2026-03-11 163933.png>)


✅ **Après exécution du script, les lecteurs sont bien mappés**  

![alt text](<Images/Capture d'écran 2026-03-11 122531.png>)

### Vérification dans l'explorateur de fichier du serveur  
✅ **Sur le serveur de partages SMB (SRV-AD-FR01), j'exécute `Get-SmbShare` me permet de voir que les partages sont bien présents**   
![alt text](<Images/Capture d'écran 2026-03-11 174548.png>)


### Création des GPO de mappage  
>⚙️ 1 GPO est créée et contient tous les mappages et sera liée à chaque OU de chaque service. Les mappages de lecteurs sont ciblés au niveau du groupe de sécurité  
![alt text](<Images/Capture d'écran 2026-03-11 175006.png>)

>⚙️ Pour le SMB "Commun_Informatique", l'utilisateur doit être membre du groupe Informatique pour obtenir un mappage.  
![alt text](<Images/Capture d'écran 2026-03-11 175254.png>)  

> :bulb: Groupe de sécurité et ses membres.  
![alt text](<Images/Capture d'écran 2026-03-11 175554.png>)

Après lisaison de la GPO dans les bonnes OU, `gpupdate /force` et `gpresult /R` sur les machines clientes permettent d'appliquer la GPO.  
✅ **Au démarrage de session, on peut voir la bonne application du lecteur du service.**  
![alt text](<Images/Capture d'écran 2026-03-11 181107.png>)



## Script de création des dossiers partagés personnels et mappage par GPO.

[Script de création des dossier personnels partagés](Scripts/PartagePersoCachéUser.ps1)
Le script est exécuté depuis le Windows serveur.  
![alt text](<Images/Capture d'écran 2026-03-13 154756.png>)  

Mappage par GPO :  
![alt text](<Images/Capture d'écran 2026-03-13 160449.png>)  

Vérification sur 2 clients :  
![alt text](<Images/Capture d'écran 2026-03-13 160120.png>)  
![alt text](<Images/Capture d'écran 2026-03-13 160621.png>)  


