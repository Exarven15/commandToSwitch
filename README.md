# Script PowerShell de gestion de switches via SSH
## Description

Ce script PowerShell permet de se connecter à des switches via SSH, d'interagir avec eux, et d'exécuter des commandes pour récupérer des informations diverses. Il offre une interface interactive pour sélectionner un switch à partir d'un fichier CSV, se connecter au switch via SSH, et exécuter des commandes comme display interface brief, display vlan, display device, etc. Le script permet également une gestion sécurisée des mots de passe avec la fonctionnalité super pour passer en mode super administrateur sur le switch.
Prérequis

PowerShell 7.0 ou version supérieure.
Le module SSH pour PowerShell doit être installé. Il peut être installé via 
    
    Install-Module -Name Posh-SSH.
    
Un fichier CSV contenant les informations des switches, avec un séparateur ;. Ce fichier doit avoir au moins deux colonnes : Name (Nom du switch) et Hostname (Adresse IP du switch).

## Fonctionnalités

    Chargement de la liste des switches depuis un fichier CSV.
    Sélection d'un switch : l'utilisateur peut choisir un switch dans une liste interactive générée par le script.
    Connexion SSH : l'utilisateur peut se connecter à un switch en utilisant un nom d'utilisateur et un mot de passe pour SSH.
    Exécution de commandes : après s'être connecté, l'utilisateur peut choisir parmi plusieurs commandes pour interagir avec le switch.

# Utilisation
## 1. Prérequis : Préparer le fichier CSV

Assurez-vous que votre fichier CSV (liste_addr.csv) contient les informations suivantes :
Name	Hostname
Switch1	192.168.1.1
Switch2	192.168.1.2
...	...

Le fichier doit être séparé par un point-virgule ;.

## 2. Lancer le script

Pour exécuter le script, suivez ces étapes :

    Ouvrir PowerShell et naviguer vers le répertoire contenant le script.

    Exécuter le script avec la commande suivante :

    .\nom_du_script.ps1

    Le script va vérifier l'existence du fichier CSV et afficher un tableau interactif des switches disponibles, 
    avec un numéro associé à chaque switch.

## 3. Sélectionner un switch

Le script vous demandera d'entrer le numéro du switch que vous souhaitez administrer. Si vous entrez "0", le script se termine.

## 4. Connexion SSH

Après avoir sélectionné un switch, le script vous demandera :

    Le nom d'utilisateur pour la connexion SSH.
    Le mot de passe SSH (saisissez-le de manière sécurisée).
    Le mot de passe super pour passer en mode super administrateur sur le switch.

Le script tentera de se connecter au switch en SSH, puis de passer en mode super pour exécuter des commandes.
## 5. Exécution des commandes

Une fois connecté, vous aurez la possibilité de choisir parmi une liste de commandes préconfigurées à exécuter sur le switch. Parmi les commandes disponibles :

    display interface brief
    display vlan
    display device
    display current-configuration
    display logbuffer reverse

Vous pouvez entrer le numéro correspondant à la commande souhaitée, et le script l'exécutera. Si la sortie d'une commande est paginée, le script gère cette pagination pour afficher les résultats dans son intégralité.
## 6. Quitter le script

Pour quitter à tout moment, entrez "0" lorsque le script vous demande de sélectionner un switch ou une commande.
# Explication du Code
## 1. Chargement du fichier CSV

Le script commence par vérifier l'existence du fichier CSV (liste_addr.csv). Il charge les données dans une variable $switches en utilisant le séparateur ;.
## 2. Interaction avec l'utilisateur

Le script génère une liste interactive des switches disponibles et permet à l'utilisateur de sélectionner un switch en entrant son numéro.
## 3. Connexion SSH

Après la sélection du switch, le script établit une connexion SSH en utilisant les informations d'identification fournies par l'utilisateur. Le mot de passe super est utilisé pour passer en mode administrateur sur le switch.
## 4. Commandes disponibles

Une fois connecté, le script permet à l'utilisateur d'exécuter des commandes spécifiques sur le switch. Il gère aussi la pagination pour les sorties longues (affichage de --More--).
## 5. Gestion des erreurs

Le script contient des blocs try-catch-finally pour gérer les erreurs pendant la connexion SSH et la gestion des commandes. Il assure également une fermeture propre de la session SSH à la fin de l'exécution.
# Exemple d'exécution

### Exemple de sélection du switch
Entrez le numero du switch (0 pour quitter) : 1

### Exemple de connexion SSH et exécution de commande
Entrez le nom d'utilisateur pour la connexion SSH : admin
Entrez le mot de passe pour la connexion SSH : ********
Entrez le mot de passe super : ********
Connexion SSH reussie au switch 192.168.1.1.
Commande a executer :
1. display interface brief
2. display vlan
3. display device
4. display current-configuration
0. Quitter
Entrez le numero de la commande a executer (0 pour quitter) : 1
Execution de la commande : display interface brief...
--------------------

Dépannage

    Erreur de connexion SSH : Assurez-vous que le nom d'utilisateur, le mot de passe SSH et le mot de passe super sont corrects.
    Commande non reconnue : Vérifiez que le switch prend bien en charge les commandes spécifiées dans le tableau des commandes.

Licence

Ce script est mis à disposition sous la licence MIT.
