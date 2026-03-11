

# Créer le dossier racine
New-Item -Path "C:\Personnels" -ItemType Directory

# Créer le partage caché
New-SmbShare -Name "personnels$" -Path "C:\Personnels" `
    -FullAccess "Administrateurs" `
    -ChangeAccess "Utilisateurs du domaine"

Import-Module ActiveDirectory

$racine = "C:\Personnels"
$users = Get-ADUser -Filter { Enabled -eq $true } -SearchBase "DC=nab,DC=local" -SearchScope Subtree

foreach ($user in $users) {
    $chemin = "$racine\$($user.SamAccountName)"
    
    # Créer le dossier s'il n'existe pas
    if (-not (Test-Path $chemin)) {
        New-Item -Path $chemin -ItemType Directory
    }

    # Désactiver l'héritage et vider les ACL existantes
    $acl = Get-Acl $chemin
    $acl.SetAccessRuleProtection($true, $false)

    # Donner contrôle total à l'utilisateur uniquement
    $rule = New-Object System.Security.AccessControl.FileSystemAccessRule(
        "NAB\$($user.SamAccountName)",
        "FullControl",
        "ContainerInherit,ObjectInherit",
        "None",
        "Allow"
    )
    $acl.AddAccessRule($rule)

    # Donner contrôle total aux admins
    $ruleAdmin = New-Object System.Security.AccessControl.FileSystemAccessRule(
        "Administrateurs",
        "FullControl",
        "ContainerInherit,ObjectInherit",
        "None",
        "Allow"
    )
    $acl.AddAccessRule($ruleAdmin)

    Set-Acl -Path $chemin -AclObject $acl
    Write-Host "✅ $($user.SamAccountName) — dossier créé et sécurisé"
}




## Étape 3 — GPO : mapper le lecteur personnel automatiquement

#Dans la GPO (Configuration utilisateur > Préférences > Mappages de lecteurs) :

#Action      : Remplacer
#Lettre      : H: (par exemple)
#Chemin      : \\serveur\personnels$\%USERNAME%