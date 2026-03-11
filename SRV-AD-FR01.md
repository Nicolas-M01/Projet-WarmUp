# Windows Server 2025 GUI
---


## Script PowerShell de Création des dossiers partagés en fonction des Services (des OU dans notre cas).  

Il récupère les OU existantes en excluant les controleurs de domaine, puis il crée pour chaque OU, un dossier nommé "Commun_NomDeOU" dans le lecteur C.  
Il crée ensuite un partage SMB pour chaque et nous avertit de la création.  
![alt text](<Images/Capture d'écran 2026-03-11 122837.png>)



