if ((Get-Command scoop -ErrorAction SilentlyContinue) -eq $null){
	"Scoop is missing!"
	$ans= Read-Host -Prompt "Would you like the script to install it? (y/n)"
}

if ($ans -eq "y") {
	Set-ExecutionPolicy RemoteSigned -Scope CurrentUser # Optional: Needed to run a remote script the first time
	irm get.scoop.sh | iex
}

$progs=@("hurl","nvim","file","git","neovide")
$progsScoop=@("hurl","neovim","file","git","extras/neovide")


For ($i=0;$i -lt $progs.Length;$i++){
	if ((Get-Command $progs[$i] -ErrorAction SilentlyContinue) -eq $null){
		if($progs[$i] -eq "neovide")
		{
			scoop bucket add extras
		}
		$progs[$i] + " is missing, installing"
		scoop install $progs[$i]
	 }
	 else {
		$progs[$i] + " is installed, make sure it is up to date though"
	 }
}

mkdir "$HOME/scoop/apps/hurlui/current"
cd "$HOME/scoop/apps/hurlui/current"
git clone "https://github.com/Kuchteq/hurlui"
git checkout windows

"Creating link" 

$ShortcutPath = "$HOME/Desktop/Hurlui.lnk"
$IconLocation = "$HOME/scoop/apps/hurlui/current/ScratchLogo.ico"
$IconArrayIndex = 27
$Shell = New-Object -ComObject ("WScript.Shell")
$Shortcut = $Shell.CreateShortcut($ShortcutPath)
$Shortcut.TargetPath = "$HOME/scoop/apps/hurlui/current/hurlui.bat"
$Shortcut.IconLocation = "$IconLocation"
$Shortcut.Save()
