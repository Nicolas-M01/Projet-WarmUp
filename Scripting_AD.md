

## Création des utilisateurs, groupes de sécurité, OU et attributions respectives selon consignes, ont été établi par scripts PowerShell.  

### Création des utilisateurs [Create_Users](Scripts/NAB_Create_Users.ps1).  
>:bulb: Les utilisateurs ont été créés dans l'OU d'origine **Users**  
![alt text](<Images/Capture d'écran 2026-02-11 120855.png>)  

### Création des OU, des groupes, puis intégrations des users dans leurs groupes, puis déplacement des groupes dans les OU [Create_OU_Groups](Scripts/NAB_Create_OU_GRP.ps1)  

>:bulb: Création des OU, des groupes, puis déplacement des groupes dans les bonnes OU.  
![alt text](<Images/Capture d'écran 2026-02-11 134112.png>)  

>:bulb: Déplacement des utilisateurs dans les bons groupes et les bonnes OU  
![alt text](<Images/Capture d'écran 2026-02-11 141808.png>)  

>✅ **Vérification**  
![alt text](<Images/Capture d'écran 2026-02-11 120911.png>)  

>✅ **Nombre d'utilisateurs : 36 + 3 (Administrateur/Invité/krbtgt)**  
![alt text](<Images/Capture d'écran 2026-02-11 141626.png>)  
![alt text](<Images/Capture d'écran 2026-02-11 141652.png>)  


### 🟢 L'automatisation permet une gestion à grande échelle, rapide et efficace des comptes AD.  
