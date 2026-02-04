function tmux_auto_home --description "Auto-launch tmux home session"
    status is-interactive; or return
    isatty stdout; or return
    set -q TMUX; and return
    command -q tmux; or return

    set -l session '󱂶 home'
    if tmux has-session -t "$session" 2>/dev/null
        exec tmux attach-session -t "$session"
    else
        exec tmux new-session -s "$session"
    end
end
