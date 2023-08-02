# Hurlui - TUI API Debugging client based on Hurl and Neovim

Hurl is great but having an editor and terminal constantly open and having to switch between them can be a bit unergonomic :/. This TUI client strives to provide excellent user experience via simplicity, ergonomic keybindings and the Neovim editor. The project is under constant development and can be considered as a semi-beta, so there are bugs out there as well as changes that will largely impact even the crucial features.

# Features:
- Workspaces
- Managing requests and subgroups
- Previewing request output, viewing response times
- Snippets (more advanced ones in progress)
- Multiple environments with custom values
- Dark/Light theme with dynamic theme adjustment via nvim remote
- Jwt decoding
- Terminal directory sync.
- Reliable editor history accross sessions using undodir.
- Fast as hell

# See it in action:
script:
enter and create add a new workspace named New Demo
create a new request - sample request
create a new env, add host jsonplaceholder.typicode.com
jump back to runner, press rg enter and enter
add new parameter /{{which}}
add new envspace
add which variable to both
come back to runner
run again
alternate
run again
create new subgroup With Authorization
make a new request there Get Auth
write rp, change add /api/login change host to auth_host using ctrl w
switch to env, write auth_host=hurlui.kuchta.dev
write ab then Winston:bigbrother
run query
show jwt
space w for new workspace
open up and show how the old shitus is there


# Superiority to other rest clients
- No electron, forget about the start time or the 300 MB disk use. Hurlui can be ready to use in less than 25ms. 
- Powered by an actual CI/CD tool. Develop your queries within the project repo and easily keep them in sync with the rest.
- No more constant nagging to log into some sync feature you don’t use. Do the syncing on your terms as everything is file based and easily git-able. For example, if you're developing a Spring Boot microservice, you might want to create a docs/hurl folder and start your workspace there, making the sync convenient.
- No unnecessary branding or buttons that you never touch.

# Install guide (Linux)
1. Install neovim, hurl and jq with the distro's package manager. (Optional) Install jwt-cli for JWT decoding.
2. Clone repository wherever you want ``` git clone https://github.com/Kuchteq/hurlui.git && cd hurlui```
3. Make sure hurlui and executer are executable. ```chmod u+x hurlui executer```
4. Run ./hurlui
5. (Recommended) Add a symlink to path for easy access ``` ln -s "$PWD/hurlui" "~/.local/bin" ``` (or any place that suits you)
6. (Optional) Change variables inside hurlui script. Add your preferred terminal inside HURLUI_TERM, change OUTPUT_BASE to a persistent location or change DEFAULT_ENVSPACE_NAME.

# Install guide (Native Windows)
There was very little testing done on Windows, and it can be a bad experience. For better experience, it is recommended to use WSL. 
1. Clone repository ``` git clone https://github.com/Kuchteq/hurlui.git && cd hurlui```. 
2. Inside powershell run ```.\installer.ps1```. The installer pulls the scoop package manager in case there isn't one and installs the dependencies. Next run hurlui.bat.

# Keybindings
Besides using standard neovim keybindings, Hurlui adds a couple of its own:
- Tab inside the initialized workspace switches between runner tab and env tab. Inside create workspace popup it is used to switch between the two fields.
- *Ctrl-h/j/k/l* make it easy to navigate between panels of a given tab. You can also use F1, F2, F3 to move inside runner panels.
- *Space-w* opens the workspace picker, and inside it pressing *ctrl-n* prompts for creating a new workspace. Outside workspace picker *ctrl-n* prompts for a new request.
- *Enter* inside runner tab runs the given file and inside env tab, selects the environment. *Shift-enter* selects an alternate environment that you can cycle between the regular one using *space-a* (if there is more than one env specified).
- *Ctrl-shift-d* - creates a new subgroup/directory inside the current workspace. 
- *Space-t* - try to decode your unnamed register into a JWT.

# Note
Hurlui is meant to be used in its own, predefined way, though it is based on Neovim, using features that are more advanced than the navigation system can very easily break the app, as it expects some windows and or buffers to be present. However, one of the goals is to allow greater flexibility in how the user can use it. For more feature goals, see issues.

# Contributing
As you can see, Hurlui boosts great features already, but it is a very young project. I want to raise awareness of it at this early stage however to make good decisions EARLY and prevent unnecessary rewrites. I look forward to hearing the community's suggestions, both on the features and on the code structure/quality. This is basically the first lua project I have undertaken besides my neovim config and I believe it shows. Please do point out how I can improve the codebase. I tried making it fairly straightforward and simple, so besides the init.lua file the main "point of start" is in /lua/plugins/workspaces.lua. From there you can try and trace how the program runs. 

I welcome all contributors to join me and build the best rest API client there is (which is a pretty low bar if you ask me). 
