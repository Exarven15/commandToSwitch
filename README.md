# commandToSwitch
Automatisation de certaine commandes afin d'éviter de se connecter au switch systématiquement.

# Requirements pour le script de gestion de switch
## Introduction

Ce document décrit les dépendances et les configurations nécessaires pour exécuter le script de gestion de switch. Dépendances Python

- cryptography : Bibliothèque utilisée pour le chiffrement et le déchiffrement des mots de passe.
- paramiko : Bibliothèque pour établir des connexions SSH avec les switches.

### Versions recommandées

- cryptography : 3.5.1
- paramiko : 3.5.1

### Installation

Pour installer les dépendances, exécutez la commande suivante dans votre terminal :

    pip install cryptography paramiko

### Configuration système

    Python : Version 3.6 ou supérieure.

### Notes supplémentaires

Assurez-vous d'avoir une version récente de pip pour une installation sans problème.
Sur les systèmes Linux, vous pourriez avoir besoin d'un environnement de compilation C et des en-têtes de développement pour Python, OpenSSL et libffi.
Pour une utilisation en production, il est recommandé de créer un environnement virtuel Python dédié pour ce projet.

### Utilisation

Le script utilise une clé Fernet pour déchiffrer le mot de passe. Assurez-vous de générer et de stocker cette clé de manière sécurisée. Le script se connecte ensuite via SSH aux switches pour exécuter des commandes spécifiques.
