# Importation du CSV contenant les informations des utilisateurs
$CSVFile = "C:\Users\Administrateur\utilisateurs_AD.csv"
$CSVData = Import-CSV -Path $CSVFile -Delimiter "," -Encoding UTF8

# Domaine racine
$Domain = "DC=nab,DC=local"

# Boucle sur tous les départements uniques
$Departements = $CSVData | Select-Object -ExpandProperty Departement -Unique

foreach ($Departement in $Departements) {
    $OUPath = "OU=$Departement,$Domain"

    # Vérifier si l'OU existe et la créer si nécessaire
    $OUExist = Get-ADOrganizationalUnit -Filter "Name -eq '$Departement'"
    if (-not $OUExist) {
        New-ADOrganizationalUnit -Name $Departement -ProtectedFromAccidentalDeletion $false
        Write-Host "OU créée : $OUPath" -ForegroundColor Green
    }
    else {
        Write-Host "L'OU $OUPath existe déjà." -ForegroundColor Yellow
    }

    # Vérifier si le groupe de sécurité existe et le créer si nécessaire
    $GroupName = $Departement
    $GroupExist = Get-ADGroup -Filter "Name -eq '$GroupName'"
    if (-not $GroupExist) {
        New-ADGroup -Name $GroupName -GroupScope Global -Path $OUPath -GroupCategory Security
        Write-Host "Groupe de sécurité créé : $GroupName dans $OUPath" -ForegroundColor Green
    }
    else {
        Write-Host "Le groupe $GroupName existe déjà." -ForegroundColor Yellow
    }
}

# Déplacer les utilisateurs et les ajouter aux groupes
foreach ($Utilisateur in $CSVData) {
    $SamAccountName = ($Utilisateur.Prenom).Substring(0, 1) + "." + $Utilisateur.Nom
    $Departement = $Utilisateur.Departement
    $OUPath = "OU=$Departement,$Domain"
    $GroupName = $Departement

    # Récupérer l'utilisateur existant dans l'OU par défaut
    $ADUser = Get-ADUser -Filter "samaccountname -eq '$SamAccountName'" -SearchBase "CN=Users,$Domain"
    
    if ($ADUser) {
        Move-ADObject -Identity $ADUser.DistinguishedName -TargetPath $OUPath
        Write-Host "Utilisateur $SamAccountName déplacé vers $OUPath" -ForegroundColor Cyan

        Add-ADGroupMember -Identity $GroupName -Members $SamAccountName
        Write-Host "Utilisateur $SamAccountName ajouté au groupe $GroupName" -ForegroundColor Green
    }
    else {
        Write-Host "Utilisateur $SamAccountName non trouvé dans l'OU 'Users'" -ForegroundColor Red
    }
}
