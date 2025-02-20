# Stop-SpringBootProgram.ps1

function Stop-SpringBoot {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, HelpMessage="Nom du programme Spring Boot à arrêter")]
        [string]$Name
    )

    Begin {
        # Initialisation (facultatif)
    }

    Process {
        # Rechercher les processus en cours qui correspondent au nom du programme
        $processes = Get-Process | Where-Object { $_.MainModule.ModuleName -like "*$Name-web-*.jar" }

        if ($processes.Count -eq 0) {
            Write-Host "Aucun programme en cours d'exécution pour $Name."
            return
        }

        foreach ($process in $processes) {
            try {
                # Arrêter le processus
                $process.Kill()
                Write-Host "Le programme $Name a été arrêté avec succès."
            } catch {
                Write-Error "Impossible d'arrêter le programme $Name : $_"
            }
        }
    }

    End {
        # Nettoyage (facultatif)
    }
}