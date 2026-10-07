$path = "lib"

$replacements = @{
    "0xFFFF00FF" = "0xFF3882F6" # Magenta -> Light Blue
    "0xFF0000FF" = "0xFF0F4C81" # Royal Blue -> Navy Blue
    "0xFFFFB74D" = "0xFFFFC107" # Peach/Orange -> Amber/Yellow
    "0xFFFFCD91" = "0xFFFFE082" # Light Peach -> Light Yellow
    "0xFFFFF7ED" = "0xFFFFFDE7" # Drawer bg peach -> Very light yellow (White-ish)
    "0xFFFFE7D1" = "0xFFFFF9C4" # Soft yellow-orange -> Soft yellow
    "0xFFEFF8F0" = "0xFFE3F2FD" # Soft mint -> Soft blue
    "Color\(0xFFFF00FF\)" = "Color(0xFF3882F6)"
    "Color\(0xFF0000FF\)" = "Color(0xFF0F4C81)"
}

Get-ChildItem -Path $path -Filter *.dart -Recurse | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    $modified = $false
    
    foreach ($key in $replacements.Keys) {
        if ($content -match $key) {
            $content = $content -replace $key, $replacements[$key]
            $modified = $true
        }
    }
    
    if ($modified) {
        Set-Content -Path $_.FullName -Value $content -NoNewline
        Write-Host "Modified $($_.FullName)"
    }
}
