# Script de création des dossiers en partage SMB pour chaque OU

# Récupération des OUs, on affiche le DN et on exclue les DC, on ajoute dans une variable
$OUs = Get-ADOrganizationalUnit -Filter * | Where-Object { $_.distinguishedname -notlike "*Domain Controllers" }

# Boucle qui parcourt chaque OU
foreach ($ou in $OUs) {

    # Le dossier sera nommé "Commun" suivi du nom de l'OU
    $nomDossier = "Commun_$($ou.Name)"

    # Chemin du dossier partagé
    $cheminLocal = "C:\$nomDossier"

    # Création du dossier pour chaque OU
    New-Item -ItemType Directory -Force -Path $cheminLocal | Out-Null

    # Création du partage SMB de chaque dossier
    New-SmbShare -Name $nomDossier -Path $cheminLocal

    # Information dans le terminal pour chaque dossier créé
    Write-Host "Création de \\$env:COMPUTERNAME\$nomDossier"

}