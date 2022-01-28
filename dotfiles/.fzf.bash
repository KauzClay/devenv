# Setup fzf
# ---------
if [[ ! "$PATH" == */home/daisy/.fzf/bin* ]]; then
  export PATH="${PATH:+${PATH}:}/home/daisy/.fzf/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "/home/daisy/.fzf/shell/completion.bash" 2> /dev/null

# Key bindings
# ------------
source "/home/daisy/.fzf/shell/key-bindings.bash"
