$fichier = "liste_addr.csv"

# Vérifier si le fichier existe
if (-Not (Test-Path $fichier)) {
    Write-Error "Le fichier n'a pas ete trouve : $fichier"
    exit
}

# Charger la liste des switches depuis le fichier CSV (en spécifiant le séparateur ";")
$switches = Import-Csv -Path $fichier -Delimiter ';'

# Vérifier si des données ont été chargées
if ($switches.Count -eq 0) {
    Write-Output "Le fichier est vide ou les donnees n'ont pas ete chargees correctement."
    exit
}

# Ajouter l'option 0 pour quitter
$sortie = [PSCustomObject]@{
    'Numero'        = 0
    'Nom du switch' = 'Quitter le programme'
    'Adresse IP'    = '-'
}

# Créer le tableau avec l'option 0 et la liste des switches
$tableauSwitches = $switches | Select-Object @{Name='Numero';Expression={[array]::IndexOf($switches, $_) + 1}}, 
                                                @{Name='Nom du switch';Expression={$_.Name}},  # Le nom du switch
                                                @{Name='Adresse IP';Expression={$_.Hostname}}  # L'adresse IP du switch

# Fusionner l'option 0 avec le tableau
$tableauComplet = @($sortie) + $tableauSwitches

# Afficher le tableau formaté
$tableauComplet | Format-Table -AutoSize

# Demander le choix de l'utilisateur
$choix = Read-Host "Entrez le numero du switch (0 pour quitter)"

# Gérer le choix
if ($choix -eq '0') {
    Write-Output "Fermeture du programme..."
    exit
} else {
    # Convertir le choix en nombre pour comparer correctement
    $choix = [int]$choix

    $switchSelectionne = $tableauComplet | Where-Object { $_.Numero -eq $choix }
    if ($switchSelectionne) {
        Write-Output "Vous avez selectionne : $($switchSelectionne.'Nom du switch') - $($switchSelectionne.'Adresse IP')"
        # Extraire et afficher l'adresse IP du switch sélectionné
        $switchIP = $switchSelectionne.'Adresse IP'
        Write-Output "L'adresse IP du switch selectionne est : $switchIP"
    } else {
        Write-Output "Numero invalide, veuillez reessayer."
    }
}


# Demande des informations pour la connexion SSH
$sshUsername = Read-Host "Entrez le nom d'utilisateur pour la connexion SSH"
$sshPassword = Read-Host "Entrez le mot de passe pour la connexion SSH" -AsSecureString
$superPassword = Read-Host "Entrez le mot de passe super" -AsSecureString

# Conversion du mot de passe super en texte
$superPlainPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($superPassword))

# Création des informations d'identification SSH
$sshCredentials = New-Object System.Management.Automation.PSCredential ($sshUsername, $sshPassword)

try {
    # Connexion SSH au switch
    $session = New-SSHSession -ComputerName $switchIP -Credential $sshCredentials -ErrorAction Stop
    Write-Host "Connexion SSH reussie au switch $switchIP."

    # Utilisation d'un stream interactif pour envoyer les commandes
    $stream = New-SSHShellStream -SessionId $session.SessionId
    Start-Sleep -Seconds 2  # Attendre pour éviter les bugs de buffer

    # Lecture du prompt initial
    $stream.Read()

    # Envoi de la commande 'super'
    $stream.WriteLine("super")
    Start-Sleep -Seconds 1
    $output = $stream.Read()
    Write-Host $output

    # Vérifier si le switch demande un mot de passe
    if ($output -match "Password:") {
        $stream.WriteLine($superPlainPassword)
        Start-Sleep -Seconds 1
        $output = $stream.Read()
        Write-Host "Reponse apres mot de passe:"
        Write-Host $output
    }

    # Vérifier si la connexion au mode super a réussi
    if ($output -match "failure" -or $output -match "incorrect") {
        Write-Host "Echec de l'authentification super."
        throw "Impossible de passer en mode super."
    } else {
        Write-Host "Connexion reussie en mode super."
    }

    # Liste des commandes disponibles
    $availableCommands = @(
        "display interface brief",
        "display vlan",
        "display device",
        "display current-configuration"
        "display logbuffer reverse"
    )

    <# Fonction pour gérer les sorties paginées (--More--)
    function Get-FullCommandOutput {
        param ($stream)
        $fullOutput = ""
        while ($true) {
            $chunk = $stream.Read()
            $fullOutput += $chunk
            Write-Host $chunk

            # Vérifier si la pagination est activée
            if ($chunk -match "----More----") {
                Write-Host "Appui sur Espace pour continuer..."
                $stream.Write(" ")  # Envoi de la touche espace pour continuer l'affichage
                Start-Sleep -Milliseconds 500
            } else {
                break
            }
        }
        return $fullOutput
    }
#>
    # Boucle pour permettre à l'utilisateur d'exécuter des commandes
    while ($true) {
       <# Vérification automatique des messages '--More--' avant d'afficher le menu
        Write-Host "`nVerification des affichages en attente..."
        Get-FullCommandOutput -stream $stream
#>
        # Affichage des commandes disponibles
        Write-Host "`nCommandes disponibles :"
        for ($i = 0; $i -lt $availableCommands.Count; $i++) {
            Write-Host "$($i + 1). $($availableCommands[$i])"
        }
        Write-Host "0. Quitter"

        $commandChoice = Read-Host "Entrez le numero de la commande a executer (0 pour quitter)"
        if ($commandChoice -eq "0") { break }

        $index = [int]$commandChoice - 1
        if ($index -ge 0 -and $index -lt $availableCommands.Count) {
            $cmd = $availableCommands[$index]
            Write-Host "Execution de la commande : $cmd..."
            $stream.WriteLine($cmd)
            Start-Sleep -Seconds 2

            # Récupérer et afficher la sortie complète
            # $result = Get-FullCommandOutput -stream $stream
            Write-Host "--------------------"
        } else {
            Write-Host "Choix invalide. Veuillez reessayer."
        }
    }
} catch {
    Write-Host "Erreur : $_"
} finally {
    if ($session) {
        Remove-SSHSession -SessionId $session.SessionId
        Write-Host "Session SSH fermee."
    }
}
