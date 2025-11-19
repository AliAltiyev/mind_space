param(
    [string]$InputFile,
    [string]$OutputFile
)

$json = Get-Content $InputFile -Raw | ConvertFrom-Json
$arb = @{
    "@@locale" = "en"
    "@@last_modified" = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
}

function Flatten-Json {
    param(
        [object]$Data,
        [string]$Prefix = "",
        [hashtable]$Result
    )
    
    foreach ($key in $Data.PSObject.Properties.Name) {
        $newKey = if ($Prefix) { "$Prefix.$key" } else { $key }
        $value = $Data.$key
        
        if ($value -is [System.Collections.Hashtable] -or $value -is [PSCustomObject]) {
            Flatten-Json -Data $value -Prefix $newKey -Result $Result
        } elseif ($value -is [System.Array]) {
            $Result[$newKey] = ($value -join "`n")
        } else {
            $Result[$newKey] = $value
        }
    }
}

Flatten-Json -Data $json -Result $arb

$arbJson = $arb | ConvertTo-Json -Depth 100
[System.IO.File]::WriteAllText($OutputFile, $arbJson, [System.Text.Encoding]::UTF8)

Write-Host "Converted $InputFile to $OutputFile"

