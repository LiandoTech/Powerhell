Function Get-LocalGroupInfo
{
    param (
        [Parameter(mandatory)][String]$ComputerName
    )

    # Connexion à l'hôte distant via ADSI
    $remoteHost = [ADSI]"WinNT://$ComputerName, computer"

    # Initialisation d'un tableau pour stocker les informations des groupes locaux
    $localGroupInfo = @()

    # Parcours de tous les groupes locaux
    foreach ($child in $remoteHost.psbase.children)
    {
        # Vérifier si l'élément est un groupe
        if ($child.psbase.schemaClassName -eq 'group')
        {
            # Récupération des informations du groupe
            $Group = [ADSI]$child.PsBase.Path

            # Récupération des membres du groupe
            $members = $Group.PsBase.Invoke("Members")
            
            # Parcours des membres du groupe
            foreach ($member in $members)
            {
                # Récupération du nom de l'utilisateur
                $User = $member.GetType().InvokeMember("Name", 'GetProperty', $null, $member, $null)

                # Création d'un objet personnalisé pour chaque utilisateur et groupe
                $UserInfo = [PSCustomObject][Ordered]@{
                    'Group' = [System.String]$Group.Name
                    'Member'  = $User
                }

                # Ajout des informations à la liste des groupes locaux
                $localGroupInfo += $UserInfo
            }
        }
    }

    # Retourne les informations collectées
    Return $localGroupInfo
}
