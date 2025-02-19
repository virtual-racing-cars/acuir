$7zipPath = "$env:ProgramFiles\7-Zip\7z.exe"
if (-not (Test-Path -Path $7zipPath -PathType Leaf)) {
  throw "7 zip file '$7zipPath' not found"
}
Set-Alias Compress-7ZIPPER $7zipPath


$app_name = "ACUIR"
$app_full_name = "Assetto Corsa UI Replacement"
$app_author = "Schmawlik"
$csp_required_ver = 3311

$app_dir_name = "ACUIR"
$app_dir = "$PSScriptRoot"
$temp_build_dir = "$app_dir/assettocorsa/apps/lua/$app_name"
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

# $build_ver = "1.2.0.0-preview" + $build_code[2] + $build_code[3] + $build_code[4]

$date = Get-Date -Format "yyyy-MM-dd"

# (Get-Content $manifest) | ForEach-Object { $_ -replace "VERSION =.+", "VERSION = $build_ver" } | Set-Content $manifest
# (Get-Content $manifest) | ForEach-Object { $_ -replace "
# SCRIPT_BUILD_DATE =.+", "SCRIPT_BUILD_DATE = `"$date`"" } | Set-Content $manifest
# (Get-Content $manifest) | ForEach-Object { $_ -replace "VERSION_CODE =.+", "VERSION_CODE = $build_code" } | Set-Content $manifest


$manifest_content[0] = "[ABOUT]"

$line_iter = 1
$app_details = [ordered]@{
    "NAME"  = "ACUIR"
    "FULL_NAME" = "Assetto Corsa UI Replacement"
    "AUTHOR" = "Schmawlik"
    "VERSION" = $build_ver
    "VERSION_CODE" = $build_code
    "VERSION_DATE" = $date
    "REQUIRED_VERSION_STRING" =  "1.80-preview218"
    "REQUIRED_VERSION" = 3311
    "DESCRIPTION" = "Advanced UI replacement"
}

foreach ($key in $app_details.Keys) {
    Write-Host "$line_iter $key : $($app_details[$key])"
    $manifest_content[$line_iter] = "$key = $($app_details[$key])"
    $line_iter += 1
}

Set-Content -Path $manifest -Value $manifest_content


# Define the source and destination directories
$app_dir = "$PSScriptRoot"

Write-host $temp_build_dir

# Ensure the destination directory exists
if (!(Test-Path $temp_build_dir)) {
    New-Item -ItemType Directory -Path $temp_build_dir -Force | Out-Null
}else {
    Remove-Item $temp_build_dir -Recurse -Force
}

# Get all items excluding those that start with ".", are .7z files, or are named "build"
$items = Get-ChildItem -Path $app_dir -Force | Where-Object {
    $_.Name -notmatch '^\.' -and $_.Extension -ne '.7z' -and $_.Extension -ne '.ps1' -and $_.Name -ne 'build' -and $_.Name -ne 'assettocorsa'
}

# Copy the filtered items to the destination
foreach ($item in $items) {
    $destinationPath = Join-Path -Path $temp_build_dir -ChildPath $item.Name
    Copy-Item -Path $item.FullName -Destination $destinationPath -Recurse -Force
}


$target_file = "$build_dir\"+$app_dir_name+"_$build_ver.7z"
if (Test-Path $target_file) {
  Remove-Item $target_file
}

Compress-7ZIPPER a -mx=9 $target_file $app_dir

if ((Test-Path "$app_dir/assettocorsa")) {
    Remove-Item "$app_dir/assettocorsa" -Recurse -Force
}
