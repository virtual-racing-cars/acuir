$7zipPath = "$env:ProgramFiles\7-Zip\7z.exe"
if (-not (Test-Path -Path $7zipPath -PathType Leaf)) {
  throw "7 zip file '$7zipPath' not found"
}
Set-Alias Compress-7ZIPPER $7zipPath

$app_dir_name = "ACUIR"
$app_dir = "$PSScriptRoot"
$temp_build_root_dir = "$app_dir/assettocorsa"
$temp_build_dir = "$app_dir/assettocorsa/apps/lua/$app_dir_name"
$manifest = "$app_dir/manifest.ini"
$manifest_content = Get-Content $manifest

$build_dir = "$PSScriptRoot\.build"
$build_ver = ($manifest_content[4] -split "`"")[1]
$build_code = ($manifest_content[5] -split "= ")[1] -as [int]

$build_code++

$build_ver = [string]$build_code

if ($build_code -lt 1000) {
    $build_ver = "0"+$build_ver
}

$build_ver = ($build_ver -split '' -ne '') -join '.'
$date = Get-Date -Format "yyyy-MM-dd"

$line_iter = 1
$app_details = [ordered]@{
    "NAME"  = "ACUIR"
    "FULL_NAME" = "Assetto Corsa UI Replacement"
    "AUTHOR" = "Schmawlik"
    "VERSION" = $build_ver
    "VERSION_CODE" = $build_code
    "VERSION_DATE" = $date
    "REQUIRED_VERSION" = 3455
    "DESCRIPTION" = "Advanced UI replacement"
}

$manifest_content[0] = "[ABOUT]"
foreach ($key in $app_details.Keys) {
    Write-Host "$line_iter $key : $($app_details[$key])"
    $manifest_content[$line_iter] = "$key = $($app_details[$key])"
    $line_iter += 1
}

Set-Content -Path $manifest -Value $manifest_content

(Get-Content $manifest) | ForEach-Object { $_ -replace "DEBUG_MODE =.+", "DEBUG_MODE = 0" } | Set-Content $manifest

$app_dir = "$PSScriptRoot"
if (!(Test-Path $temp_build_dir)) {
    New-Item -ItemType Directory -Path $temp_build_dir -Force | Out-Null
}else {
    Remove-Item $temp_build_dir -Recurse -Force
}

$items = Get-ChildItem -Path $app_dir -Force | Where-Object {
    $_.Name -notmatch '^\.' -and $_.Extension -ne '.7z' -and $_.Extension -ne '.ps1' -and $_.Name -ne 'build' -and $_.Name -ne 'assettocorsa'
}

foreach ($item in $items) {
    $destinationPath = Join-Path -Path $temp_build_dir -ChildPath $item.Name
    Copy-Item -Path $item.FullName -Destination $destinationPath -Recurse -Force
}

$target_file = "$build_dir\"+$app_dir_name+"_$build_ver.7z"
if (Test-Path $target_file) {
  Remove-Item $target_file
}

Compress-7ZIPPER a -t7z -mx9 -m0=LZMA2 -md=64m -mfb=273 -ms=on $target_file $temp_build_root_dir

if ((Test-Path "$app_dir/assettocorsa")) {
    Remove-Item "$app_dir/assettocorsa" -Recurse -Force
}

(Get-Content $manifest) | ForEach-Object { $_ -replace "DEBUG_MODE =.+", "DEBUG_MODE = 1" } | Set-Content $manifest