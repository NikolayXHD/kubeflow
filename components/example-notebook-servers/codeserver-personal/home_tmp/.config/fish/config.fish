set fish_greeting

source $HOME/.config/fish/functions.fish
source $HOME/.config/fish/alias.fish

set user_paths $HOME/.local/bin
for user_path in $user_paths
  contains $user_path $fish_user_paths; or set -Ua fish_user_paths $user_path
end

set -x CDPATH ".:$HOME:$HOME/git:$HOME/git/ml:$HOME/git/dc"
