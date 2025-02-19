$7zipPath = "$env:ProgramFiles\7-Zip\7z.exe"
if (-not (Test-Path -Path $7zipPath -PathType Leaf)) {
  throw "7 zip file '$7zipPath' not found"
}
Set-Alias Compress-7ZIPPER $7zipPath

$app_dir_name = "ACUIR"
$app_dir = "$PSScriptRoot"
$manifest = "$app_dir\manifest.ini"

$build_dir = "$PSScriptRoot\build"
$build_ver = ((Get-Content $manifest)[2] -split "`"")[1]
$build_code = ((Get-Content $manifest)[3] -split "= ")[1]
$build_code = [int]$build_code + 1
$build_code = [string]$build_code
# $build_ver = $build_code[0] + "." + $build_code[1] + "." + $build_code[2] + "." + $build_code[3] + "-preview" + $build_code[4]
$build_ver = "1.2.0.0-preview" + $build_code[2] + $build_code[3] + $build_code[4]

$date = Get-Date -Format "yyyy-MM-dd"

(Get-Content $manifest) | ForEach-Object { $_ -replace "SCRIPT_VERSION =.+", "SCRIPT_VERSION = `"$build_ver`"" } | Set-Content $manifest
(Get-Content $manifest | ForEach-Object { $_ -replace "VERSION =.+", "VERSION = $build_ver" } | Set-Content $manifest)
(Get-Content $manifest) | ForEach-Object { $_ -replace "
SCRIPT_BUILD_DATE =.+", "SCRIPT_BUILD_DATE = `"$date`"" } | Set-Content $manifest
(Get-Content $manifest) | ForEach-Object { $_ -replace "SCRIPT_VERSION_CODE =.+", "SCRIPT_VERSION_CODE = $build_code" } | Set-Content $manifest

$target_file = "$build_dir\$app_dir_name+_$build_ver.7z"
if (Test-Path $target_file) {
  Remove-Item $target_file
}

Compress-7ZIPPER a -mx=9 $target_file $app_dir