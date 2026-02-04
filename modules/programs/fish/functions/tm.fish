function tm --description "Enhanced tmux session manager"
    if set -q TMUX
        set -l change switch-client
    else
        set -l change attach-session
    end

    if not command -q tmux
        echo "tmux not found" >&2
        return 2
    end

    if test -n "$argv[1]"
        set -l session_name $argv[1]
        if tmux has-session -t "$session_name" 2>/dev/null
            tmux $change -t "$session_name"
        else
            tmux new-session -d -s "$session_name"; and tmux $change -t "$session_name"
        end
        return $status
    end

    if command -q fzf
        set -l session (tmux list-sessions -F "#{session_name}" 2>/dev/null | fzf --exit-0)
        and tmux $change -t "$session"
        or echo "No sessions found."
    else
        echo "No session name provided and fzf not found" >&2
        return 2
    end
end
