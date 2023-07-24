param (
    [string]$inputFile,
    [string]$serverAddress,
    [string]$variablesFile = $null
)

if (-not (Test-Path $inputFile -PathType Leaf)) { exit 1 }

$INCLUDED_ENVIRON = ""
if ($variablesFile -and (Test-Path $variablesFile -PathType Leaf)) {
    $INCLUDED_ENVIRON = "--variables-file '$variablesFile'"
}
$STUPID_TEMP= New-TemporaryFile # TODO, for whatever reason we need to have the output at least temporarily in a file for split to work
$OUTPUT = hurl $INCLUDED_ENVIRON -i "$inputFile" -o "$STUPID_TEMP"
$HTTP_HEADERS = $OUTPUT -split '(?m)^$' -ne '' | Select-Object -First 1
$RESPONSE_BODY = ((Get-Content $STUPID_TEMP -Raw) -split '(?:\r?\n){2,}')[1]
$FIRST_LINE = $HTTP_HEADERS -split [Environment]::NewLine | Select-Object -First 1

switch -Wildcard ($FIRST_LINE) {
    '*error*' { $FIRST_LINE = 'Http error' }
}

$EXTENSION = ($RESPONSE_BODY | file --mime-type -b -) -replace '.*\/'
$BASENAME = Split-Path -Leaf $inputFile
$BASENAME = $BASENAME -replace '\..*'
$DESTFOLDER = Join-Path $env:OUTPUT_BASE $BASENAME

if (-not (Test-Path $DESTFOLDER -PathType Container)) { mkdir $DESTFOLDER | Out-Null }

$DEST = (Join-Path $DESTFOLDER "$(Get-Date -Format 'HH_mm_ss-d-M-yyyy').$EXTENSION").Replace("\","\\")

if ($EXTENSION -eq 'json') {
    $RESPONSE_BODY | Out-File $DEST -Encoding UTF8
}
elseif ($EXTENSION -eq 'octet-stream') {
    "$HTTP_HEADERS $RESPONSE_BODY" | Out-File $DEST -Encoding UTF8
}
else {
    $RESPONSE_BODY | Out-File $DEST -Encoding UTF8
}

$nvimCommand = "<cmd>lua RECEIVE_OUTPUT('$DEST','$FIRST_LINE')<CR>"
nvim --server "$serverAddress" --remote-send "$nvimCommand"
