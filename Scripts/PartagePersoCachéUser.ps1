
$racine = "C:\Personnels"
$domaine = "NAB"

# --- Création du dossier racine si inexistant ---
if (-not (Test-Path $racine)) {
    New-Item -Path $racine -ItemType Directory | Out-Null
    Write-Host "Dossier racine créé : $racine"
}
else {
    Write-Host "Dossier racine déjà existant : $racine"
}

# --- Création du partage SMB caché (personnels$) ---
if (-not (Get-SmbShare -Name "personnels$" -ErrorAction SilentlyContinue)) {
    # Admins = accès total | Utilisateurs du domaine = accès modifié
    New-SmbShare -Name "personnels$" -Path $racine -FullAccess "Administrateurs" -ChangeAccess "Utilisateurs du domaine"
    Write-Host "Partage caché 'personnel$' créé"
}
else {
    Write-Host "Partage 'personnels'$ déjà existant"
}

# --- Activation de l'énumération basée sur l'accès (chaque user voit seulement son dossier) ---
Set-SmbShare -Name "personnels$" -FolderEnumerationMode AccessBased -Force
Write-Host "Access Based Enumeration activé sur le partage 'personnel$'"

# --- Récupération de tous les utilisateurs AD actifs ---
$users = Get-ADUser -Filter { Enabled -eq $true } -SearchBase "DC=nab,DC=local" -SearchScope Subtree
Write-Host "$($users.Count) utilisateurs actifs trouvés"
$compteur = 0

# --- Boucle : création d'un dossier personnel pour chaque utilisateur ---
foreach ($user in $users) {

    # Chemin du dossier : C:\Personnels\<samaccountname>
    $chemin = "$racine\$($user.samaccountname)"

    # Création du dossier s'il n'existe pas
    if (-not (Test-Path $chemin)) {
        New-Item -Path $chemin -ItemType Directory | Out-Null
    }

    # --- Configuration des permissions NTFS ---
    $acl = Get-Acl $chemin

    # Bloquer l'héritage des permissions du dossier parent
    $acl.SetAccessRuleProtection($true, $false)

    # Règle : l'utilisateur a le contrôle total sur son propre dossier
    $regleUtilisateur = New-Object System.Security.AccessControl.FileSystemAccessRule(
        "$domaine\$($user.samaccountname)", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow"
    )

    # Règle : les admins ont aussi le contrôle total
    $regleAdmin = New-Object System.Security.AccessControl.FileSystemAccessRule(
        "Administrateurs", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow"
    )

    # Application des deux règles sur le dossier
    $acl.AddAccessRule($regleUtilisateur)
    $acl.AddAccessRule($regleAdmin)
    Set-Acl -Path $chemin -AclObject $acl

    $compteur++
    Write-Host "$($user.SamAccountname) - dossier créé : $chemin"
}

