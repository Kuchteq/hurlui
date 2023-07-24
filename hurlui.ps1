$HURLUI_TERM = "wt" # CHANGE THIS if you are using another terminal or set to nothing if you want it to run in the current terminal
$env:OUTPUT_BASE = "C:\Temp\hurlui" # CHANGE THIS if you want your queries to be persistent
$env:DEFAULT_ENVSPACE_NAME = "dev" # CHANGE THIS if you want your queries to be persistent

$env:HURLUI_HOME = "$PSScriptRoot"
$env:XDG_DATA_HOME = "$env:LOCALAPPDATA"
$env:XDG_CACHE_HOME = "$env:LOCALAPPDATA\Temp" 
$env:PATH += ";$env:HURLUI_HOME"

if (!(Test-Path $env:OUTPUT_BASE)) {
    New-Item -ItemType Directory -Path $env:OUTPUT_BASE | Out-Null
}

# Uncomment the following lines if you need to create directories and files for envspace:
# if (!(Test-Path "$PWD\.envs")) {
#     New-Item -ItemType Directory -Path "$PWD\.envs" | Out-Null
# }

# if (!(Test-Path "$PWD\.envs\$env:DEFAULT_ENVSPACE_NAME")) {
#     New-Item -ItemType File -Path "$PWD\.envs\$env:DEFAULT_ENVSPACE_NAME" | Out-Null
# }

# Please note that PowerShell does not support running nvim directly like in the shell script
# The equivalent command in PowerShell is 'nvim' (if you have neovim installed) or 'vim'
# You can adjust the parameters accordingly for your specific use case

& $HURLUI_TERM nvim -u inita.lua $args
