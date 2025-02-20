function Start-SpringBoot {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, HelpMessage="Type des programmes (api, domaine, orc)")]
        [string]$Type,

        [Parameter(Mandatory=$true, ValueFromPipeline=$true, HelpMessage="Liste des noms des programmes Spring Boot")]
        [string[]]$Names,  # Accepte une liste de noms de programmes

        [Parameter(HelpMessage="Chemin de base vers les programmes")]
        [string]$BasePath = $PSScriptRoot,

        [Parameter(HelpMessage="Arguments supplémentaires pour les programmes (incluant le niveau de log)")]
        [string[]]$Arguments = @(),

        [Parameter(HelpMessage="Chemin vers l'exécutable java")]
        [string]$JavaPath = "java"
    )

    Begin {
        Write-Host "Début du processus de démarrage des programmes..."
    }

    Process {
        foreach ($Name in $Names) {
            # Construire le chemin vers le répertoire principal
            $baseDir = Join-Path -Path $BasePath -ChildPath "$Type-$Name"

            # Vérifier si le répertoire existe
            if (-Not (Test-Path $baseDir)) {
                Write-Warning "Le répertoire '$baseDir' n'existe pas. Ignorer le programme $Name."
                continue
            }

            # Vérifier si le programme est déjà en cours d'exécution
            $processes = Get-Process | Where-Object { $_.MainModule.ModuleName -like "*$Name-web-*.jar" }
            if ($processes.Count -gt 0) {
                Write-Warning "Le programme $Name ($Type) est déjà en cours d'exécution. Ignorer le démarrage."
                continue
            }

            # Construire le chemin vers le répertoire target du module Maven
            $moduleDir = Join-Path -Path $baseDir -ChildPath "$Name-web\target"

            # Rechercher le fichier JAR dans le répertoire target
            $jarFile = Get-ChildItem -Path $moduleDir -Filter "$Name-web-*.jar" | Sort-Object LastWriteTime -Descending | Select-Object -First 1

            if (-Not $jarFile) {
                Write-Error "Aucun fichier JAR trouvé pour $Name dans '$moduleDir'. Vérifiez que le build Maven a été effectué."
                continue
            }

            # Construire le chemin vers le répertoire de configuration
            $configDir = Join-Path -Path $baseDir -ChildPath "$Name-web\src\main\conf"

            # Vérifier si le répertoire de configuration existe
            if (-Not (Test-Path $configDir)) {
                Write-Warning "Le répertoire de configuration '$configDir' n'existe pas. Le programme pourrait ne pas fonctionner correctement."
            }

            # Ajouter le chemin de configuration via -Dloader.path
            $loaderPathArgument = "-Dloader.path=$configDir"
            $finalArguments = @($Arguments) + $loaderPathArgument

            # Définir le fichier de log
            $logFile = Join-Path -Path $BasePath -ChildPath "$Name.log"

            # Vérifier si Java est accessible
            if (-Not (Test-Path $JavaPath -PathType Leaf) -and ($JavaPath -ne "java")) {
                Write-Error "L'exécutable Java spécifié ('$JavaPath') n'existe pas. Ignorer le programme $Name."
                continue
            }

            # Construire la commande pour exécuter le JAR avec redirection des logs
            $processInfo = New-Object System.Diagnostics.ProcessStartInfo
            $processInfo.FileName = $JavaPath
            $processInfo.Arguments = "-jar `"$($jarFile.FullName)`" $finalArguments"
            $processInfo.RedirectStandardOutput = $true
            $processInfo.RedirectStandardError = $true
            $processInfo.UseShellExecute = $false
            $processInfo.CreateNoWindow = $true

            # Démarrer le processus
            $process = New-Object System.Diagnostics.Process
            $process.StartInfo = $processInfo

            try {
                $process.Start() | Out-Null

                # Rediriger les logs vers un fichier
                $outputTask = $process.StandardOutput.ReadToEndAsync()
                $errorTask = $process.StandardError.ReadToEndAsync()

                Add-Content -Path $logFile -Value ("$(Get-Date) - Démarrage du programme $Name ($Type)")
                Add-Content -Path $logFile -Value ($outputTask.Result)
                Add-Content -Path $logFile -Value ($errorTask.Result)

                Write-Host "Le programme $Name ($Type) a été démarré avec succès. Logs disponibles dans $logFile."

            } catch {
                Write-Error "Erreur lors du démarrage du programme $Name : $_"
            }
        }
    }

    End {
        Write-Host "Fin du processus de démarrage des programmes."
    }
}