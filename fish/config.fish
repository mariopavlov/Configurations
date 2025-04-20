starship init fish | source

if status is-interactive
    # Commands to run in interactive sessions can go here
end

# Set Homebrew paths for Apple Silicon Mac
if test -d /opt/homebrew/bin
    fish_add_path /opt/homebrew/bin
end

# Initialize Homebrew
if test -d /opt/homebrew
    eval (/opt/homebrew/bin/brew shellenv)
else if test -d /usr/local/bin
    eval (/usr/local/bin/brew shellenv)
end

