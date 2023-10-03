param(
  [string]$filePath
)

# Parse file information
$fileName = [System.IO.Path]::GetFileNameWithoutExtension($filePath)
$fileExtension = [System.IO.Path]::GetExtension($filePath).Substring(1).Trim()

($fileExtension -eq "db") ? $($fileExtension = "sqlite") : $()

# Construct the CLI command arguments
$arguments = @(
    "-con",
    "driver=$fileExtension|database=$filePath|name=$fileName|folder=$fileName|connect=true",
    "-nosplash",
    "-q"
)

# Start the process
Start-Process -FilePath "X:\Users\X\AppData\Local\DBeaver\dbeaver-cli.exe" -ArgumentList $arguments -WindowStyle Hidden