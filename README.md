<#
.SYNOPSIS
Démarrer plusieurs programmes Spring Boot du même type.

.DESCRIPTION
La cmdlet Start-SpringBootPrograms permet de démarrer plusieurs programmes Spring Boot basés sur leur type commun.
Elle prend en charge la spécification du JDK/JRE, des arguments supplémentaires (y compris le niveau de log),
et la gestion des fichiers de configuration.

.PARAMETER Type
Type des programmes (par exemple, api, domaine, orc).

.PARAMETER Names
Liste des noms des programmes Spring Boot à démarrer.

.PARAMETER BasePath
Chemin de base vers les programmes (facultatif, par défaut : répertoire actuel).

.PARAMETER Arguments
Arguments supplémentaires pour les programmes, y compris le niveau de log (par exemple, --logging.level.root=DEBUG).

.PARAMETER JavaPath
Chemin vers l'exécutable java (par défaut : "java").

.EXAMPLE
# Démarrer plusieurs programmes avec le niveau de log DEBUG
Start-SpringBootPrograms -Type "api" -Names @("transfer", "auth") -Arguments "--logging.level.root=DEBUG"

.NOTES
Auteur : NGUIDJOI BELL ALAIN
Version : 1.0
#>