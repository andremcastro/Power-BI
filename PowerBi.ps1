####################################################
#This Sample Code is provided for the purpose of illustration only and is not intended to be used in a production environment.  THIS SAMPLE CODE AND ANY RELATED INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
#EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.  
#We grant You a nonexclusive, royalty-free right to use and modify the Sample Code and to reproduce and distribute the object code form of the Sample Code, provided that You agree: (i) to not use Our name, logo, or trademarks to market Your 
#software product in which the Sample Code is embedded; (ii) to include a valid copyright notice on Your software product in which the Sample Code is embedded; and (iii) to indemnify, hold harmless, and defend Us and Our suppliers from and against any claims or lawsuits, including attorneys’ fees, 
#that arise or result from the use or distribution of the Sample Code.
#Please note: None of the conditions outlined in the disclaimer above will supersede the terms and conditions contained within the Premier Customer Services Description.
####################################################

#Install-Module AzureRM
#Install-Module AzureAD

New-Item -ItemType Directory -Force -Path C:\temp
New-Item -ItemType Directory -Force -Path C:\temp\owners

$clientId = "FILL HERE" 


# Calls the Active Directory Authentication Library (ADAL) to authenticate against AAD
########################################PBI TOKEN#######################################################
function GetAuthTokenPBI
{
    $adal = "${env:ProgramFiles}\WindowsPowerShell\Modules\AzureRM.profile\4.6.0\Microsoft.IdentityModel.Clients.ActiveDirectory.dll"
    
    $adalforms = "${env:ProgramFiles}\WindowsPowerShell\Modules\AzureRM.profile\4.6.0\Microsoft.IdentityModel.Clients.ActiveDirectory.WindowsForms.dll"
 
    [System.Reflection.Assembly]::LoadFrom($adal) | Out-Null

    [System.Reflection.Assembly]::LoadFrom($adalforms) | Out-Null

    $redirectUri = "urn:ietf:wg:oauth:2.0:oob"

    $resourceAppIdURI = "https://analysis.windows.net/powerbi/api"

    $authority = "https://login.microsoftonline.com/common/oauth2/authorize";

    $authContext = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext" -ArgumentList $authority

    $authResult = $authContext.AcquireToken($resourceAppIdURI, $clientId, $redirectUri, "Always")

    return $authResult
}

# Get the auth token from AAD
$tokenPBI = GetAuthTokenPBI

# Building Rest API header with authorization token
$authHeaderPBI = @{
    'Content-Type'='application/json'
    'Authorization'=$tokenPBI.CreateAuthorizationHeader()
 }

 #####################################Graph Token#######################################################
 function GetAuthTokenGraph
{
    $adal = "${env:ProgramFiles}\WindowsPowerShell\Modules\AzureRM.profile\4.6.0\Microsoft.IdentityModel.Clients.ActiveDirectory.dll"
    
    $adalforms = "${env:ProgramFiles}\WindowsPowerShell\Modules\AzureRM.profile\4.6.0\Microsoft.IdentityModel.Clients.ActiveDirectory.WindowsForms.dll"
 
    [System.Reflection.Assembly]::LoadFrom($adal) | Out-Null

    [System.Reflection.Assembly]::LoadFrom($adalforms) | Out-Null

    $redirectUri = "urn:ietf:wg:oauth:2.0:oob"

    $resourceAppIdURI = "https://graph.microsoft.com"

    $authority = "https://login.microsoftonline.com/common/oauth2/authorize";

    $authContext = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext" -ArgumentList $authority

    $authResult = $authContext.AcquireToken($resourceAppIdURI, $clientId, $redirectUri, "Always")

    return $authResult
}

# Get the auth token from AAD
$tokenGraph = GetAuthTokenGraph

# Building Rest API header with authorization token
$authHeaderGraph = @{
    'Content-Type'='application/json'
    'Authorization'=$tokenGraph.CreateAuthorizationHeader()
 }
##########################################################################################################3


# Make the request 
$uriPbi = "https://api.powerbi.com/v1.0/myorg/admin/groups"



#response
try {
    #Get Workspaces
    Invoke-RestMethod -Uri $uriPbi -Headers $authHeaderPBI -Method GET -Verbose -OutFile c:/temp/Workspaces.json
    
    $data = Get-Content -Raw -Path c:/temp/Workspaces.json | ConvertFrom-Json
    $data = $data.Value.Id
    $i = 0
    $output = ""
    #get owners
    while ($i -lt $data.Count)
    {
        
        $aux = $data[$i]
        $uriGraph = "https://graph.microsoft.com/v1.0/groups/$aux/owners"
        Invoke-RestMethod -Uri $uriGraph -Headers $authHeaderGraph -Method GET -Verbose -OutFile c:/temp/Owners/Owner-$aux.json
        $i++
    }

 

} catch {

    $result = $_.Exception.Response.GetResponseStream()
    $reader = New-Object System.IO.StreamReader($result)
    $reader.BaseStream.Position = 0
    $reader.DiscardBufferedData()
    $responseBody = $reader.ReadToEnd();

    Write-Host "StatusCode:" $_.Exception.Response.StatusCode.value__ 
    Write-Host "StatusDescription:" $_.Exception.Response.StatusDescription
    Write-Host "StatusBody:" $responseBody
    
}
