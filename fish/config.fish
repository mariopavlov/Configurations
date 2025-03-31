source /usr/share/cachyos-fish-config/cachyos-config.fish
starship init fish | source

if status is-interactive
    keychain --quiet --eval ~/.ssh/id_ed25519 | source
end

# Better ls command using exa
alias ls='exa --icons --group-directories-first'
alias ll='exa -l --icons --group-directories-first'
alias la='exa -la --icons --group-directories-first'

# Better cat using bat
alias cat='bat --style=auto'

# Initialize zoxide (better cd command)
zoxide init fish | source

# overwrite greeting
# potentially disabling fastfetch
#function fish_greeting
#    # smth smth
#end
