#Need to install both modules

#Install-Module AzureRM
#Install-Module AzureAD

$clientId = "CHANGE TO YOUR CLIENT ID" 


# Calls the Active Directory Authentication Library (ADAL) to authenticate against AAD

function GetAuthToken
{
    $adal = "${env:ProgramFiles}\WindowsPowerShell\Modules\AzureRM.profile\4.6.0\Microsoft.IdentityModel.Clients.ActiveDirectory.dll"
    
    $adalforms = "${env:ProgramFiles}\WindowsPowerShell\Modules\AzureRM.profile\4.6.0\Microsoft.IdentityModel.Clients.ActiveDirectory.WindowsForms.dll"
 
    [System.Reflection.Assembly]::LoadFrom($adal) | Out-Null

    [System.Reflection.Assembly]::LoadFrom($adalforms) | Out-Null

    $redirectUri = "urn:ietf:wg:oauth:2.0:oob"

    $resourceAppIdURI = "https://analysis.windows.net/powerbi/api"

    $authority = "https://login.microsoftonline.com/common/oauth2/authorize";

    $authContext = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext" -ArgumentList $authority

    $authResult = $authContext.AcquireToken($resourceAppIdURI, $clientId, $redirectUri, "Auto")

    return $authResult
}

# Get the auth token from AAD
$token = GetAuthToken

# Building Rest API header with authorization token
$authHeader = @{
    'Content-Type'='application/json'
    'Authorization'=$token.CreateAuthorizationHeader()
 }


#  request 
$uri = "https://api.powerbi.com/v1.0/myorg/admin/groups"


# response
try {
   
    Invoke-RestMethod -Uri $uri -Headers $authHeader -Method GET -Verbose -OutFile c:/temp/Workspaces.json
  
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