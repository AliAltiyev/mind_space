param(
    [string]$ArbFile
)

$json = Get-Content "assets/translations/en.json" -Raw | ConvertFrom-Json
$arb = Get-Content $ArbFile -Raw | ConvertFrom-Json

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
            if (-not $Result.ContainsKey($newKey)) {
                $Result[$newKey] = ($value -join "`n")
            }
        } else {
            if (-not $Result.ContainsKey($newKey)) {
                $Result[$newKey] = $value
            }
        }
    }
}

$allKeys = @{}
Flatten-Json -Data $json -Result $allKeys

# Add missing keys to ARB
foreach ($key in $allKeys.Keys) {
    if (-not $arb.PSObject.Properties.Name.Contains($key)) {
        $arb | Add-Member -NotePropertyName $key -NotePropertyValue $allKeys[$key] -Force
    }
}

# Add metadata for placeholders
$placeholders = @{
    "prompts.ai_empty_data_prompt" = @("type")
    "settings.reminder_time_updated" = @("time")
    "errors.save_error" = @("error")
    "ai.meditation.start_with_duration" = @("duration")
    "database.mood_entry_added" = @("mood", "note", "date")
    "settings.theme_changed" = @("theme")
    "settings.language_changed" = @("language")
    "settings.goal_set" = @("days")
    "profile.member_since" = @("date")
    "profile.image_selection_error" = @("error")
}

foreach ($key in $placeholders.Keys) {
    if ($arb.PSObject.Properties.Name.Contains($key)) {
        $metaKey = "@@$key"
        $meta = @{
            placeholders = @{}
        }
        foreach ($placeholder in $placeholders[$key]) {
            $meta.placeholders[$placeholder] = @{
                type = "String"
            }
        }
        $arb | Add-Member -NotePropertyName $metaKey -NotePropertyValue ($meta | ConvertTo-Json -Depth 10 | ConvertFrom-Json) -Force
    }
}

$arbJson = ($arb | ConvertTo-Json -Depth 100).Replace('\u0027', "'")
[System.IO.File]::WriteAllText($ArbFile, $arbJson, [System.Text.Encoding]::UTF8)

Write-Host "Added missing keys to $ArbFile"

