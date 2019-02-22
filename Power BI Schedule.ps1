#Install-Module -Name MicrosoftPowerBIMgmt
#Install-Module -Name MicrosoftPowerBIMgmt.Workspaces
#Update-Module -Name MicrosoftPowerBIMgmt

Connect-PowerBIServiceAccount

$array = @()

$workspace = Get-PowerBIWorkspace 
$i = 0
while ($i -lt $workspace.Count)
{
    $workspaceId = $workspace[$i].Id
    $dataset = Get-PowerBIDataset -WorkspaceId $workspaceId

    $z = 0
    while ($z -lt $dataset.Count)
    {
        
        if ($dataset[$z].name -notlike "Report Usage Metrics Model")
        {
            $datasetId = $dataset[$z].Id
            $url = "groups/$workspaceId/datasets/$datasetId/refreshes"
            $refreshHistory = Invoke-PowerBIRestMethod -Url $url -Method Get
            $json = ConvertFrom-Json -InputObject $refreshHistory
            $y = 0
            While($y -lt $json.value.count)
            {
               $Data = [PSCustomObject] @{
               'Workspace' = $null
               'Dataset' = $null
               'Schedule' = $null
               'RefreshType' = $null
               'StartTime' = $null
                'Status' = $null
                }

               $Data.'Workspace' = $workspace[$i].Name
               $Data.'Dataset' = $dataset[$z].name
               $Data.'Schedule' = $json.value.id[$y]
               $Data.'RefreshType' = $json.value.RefreshType[$y]
               $Data.'StartTime' = $json.value.startTime[$y]
               $Data.'Status' = $json.value.status[$y]
               
               $array += $Data
                $Y++
            }
            
        } 
        $z++   
    }
    $i++
}
$array | Export-Csv -Path C:\temp\schedule.csv






