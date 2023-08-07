#Get Current dir name
$name = get-location | Select-Object -ExpandProperty Path; $name = $name -Replace ".*\\",""

# Creating structure
$downloadPath = "$env:USERPROFILE\Path\To\Current\Assessments\Folder\$name\Downloads"
    New-Item -Path $downloadPath -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
$screenshotsPath = "$env:USERPROFILE\Path\To\Current\Assessments\Folder\$name\Screenshots"
    New-Item -Path $screenshotsPath -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
$testingNotesPath = "$env:USERPROFILE\Path\To\Current\Assessments\Folder\$name\Testing Notes"
    New-Item -Path $testingNotesPath -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
$reportPath = "$env:USERPROFILE\Path\To\Current\Assessments\Folder\$name\Report"
    New-Item -Path $reportPath -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
#