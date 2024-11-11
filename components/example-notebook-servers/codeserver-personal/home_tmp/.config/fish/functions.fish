function reload
  source ~/.config/fish/config.fish
end

function edit
  set num_argv (count $argv)
  if test $num_argv -eq 1
    set parts (string split : $argv[1])
    set num_parts (count $parts)
    if test $num_parts -eq 2
      emacs -nw "+$parts[2]" "$parts[1]"
    else if test $num_parts -eq 3 -o $num_parts -eq 4 -a "$parts[4]" = ""
      emacs -nw "+$parts[2]:$parts[3]" "$parts[1]"
    else
      emacs -nw $argv
    end
  else
    emacs -nw $argv
  end
end

function edits
  set num_argv (count $argv)
  if test $num_argv -eq 1
    set parts (string split : $argv[1])
    set num_parts (count $parts)
    if test $num_parts -eq 2
      emacs -nw "+$parts[2]" /sudo::/"$parts[1]"
    else if test $num_parts -eq 3 -o $num_parts -eq 4 -a "$parts[4]" = ""
      emacs -nw "+$parts[2]:$parts[3]" /sudo::/"$parts[1]"
    else
      emacs -nw /sudo::/$argv
    end
  else
    emacs -nw /sudo::/$argv
  end
end

function editp
  set num_argv (count $argv)
  if test $num_argv -eq 1
    set parts (string split : $argv[1])
    set num_parts (count $parts)
    if test $num_parts -eq 2
      poetry run dotenv run emacs -nw "+$parts[2]" "$parts[1]"
    else if test $num_parts -eq 3 -o $num_parts -eq 4 -a "$parts[4]" = ""
      poetry run dotenv run emacs -nw "+$parts[2]:$parts[3]" "$parts[1]"
    else
      poetry run dotenv run emacs -nw $argv
    end
  else
    poetry run dotenv run emacs -nw $argv
  end
end

function tt
  if test -n "$argv[1]"
    set session "$argv[1]"
  else
    set session default
  end

  if test -n "$argv[2]"
    set target "$argv[2]"
  else
    set target "$HOME"
  end

  tmux attach -t "$session" || tmux new -s "$session" "cd $target; exec $SHELL"
end

function print-cb
  xclip -selection clipboard -t image/png -o | lp
end

function activate
  if test -e ./environment.yml
    conda activate (head -n 1 ./environment.yml | awk '{print $2}')
  else if test -e ./venv/bin/activate.fish
    source ./venv/bin/activate.fish
  else if test -e ./.venv/bin/activate.fish
    source ./.venv/bin/activate.fish
  else if cat pyproject.toml 2> /dev/null | grep -q '\[tool.poetry\]'
    poetry shell
  else
    echo "no virtual environment detected"
  end
end

function deactivate
  if test -n CONDA_DEFAULT_ENV
    conda deactivate
  end
end

function rr
  ranger --choosedir $HOME/.rangerdir; set DIR (cat $HOME/.rangerdir); cd "$DIR"
end

function mc
  if test (count $argv) -eq 0
    set argv . .
  end

  set SHELL_PID %self
  set MC_PWD_FILE "/tmp/mc-$USER/mc.pwd.$SHELL_PID"
  mkdir -p (dirname $MC_PWD_FILE)

  set -l mc (which mc)
  $mc -P $MC_PWD_FILE $argv
  if test -r $MC_PWD_FILE
    set MC_PWD (cat $MC_PWD_FILE)
    if test -n "$MC_PWD"
      and test -d "$MC_PWD"
      cd (cat $MC_PWD_FILE)
    end
    rm $MC_PWD_FILE
  end
end

function acc
  read -slP "Password: " PASS
  set -l WORKDIR "$HOME/shared/kolia/personal"
  if not 7z x "$WORKDIR"/access.7z -o"$WORKDIR" -p"$PASS"
    return
  end
  edit "$WORKDIR"/access.md
  read -lP "Update archive? [y/n]: " ANS
  if test "$ANS" = "y"
    # -sdel to delete source file after compression
    # -mhe=on to hide file names behind password prompt
    7z -sdel a "$WORKDIR"/access.7z "$WORKDIR"/access.md -p"$PASS" -mhe=on
  else
    rm "$WORKDIR"/access.md
  end
end
