hook global ModuleLoaded x11 %{
    require-module x11-repl
}

provide-module x11-repl %{

declare-option -docstring "id of the REPL" str x11_repl_id

define-command -docstring %{
    x11-repl [<arguments>]: create a new window for repl interaction
    All optional parameters are forwarded to the new window
} \
    -params .. \
    -shell-completion \
    x11-repl %{ x11-terminal sh -c %{
        file="$(mktemp -u -t kak_x11_repl.XXXXX)"
        trap 'rm -f "${file}"' EXIT
        printf "evaluate-commands -try-client $1 \
            'set-option current x11_repl_id ${file}'" | kak -p "$2"
        shift 2
        dtach -c "${file}" -E sh -c "${@:-$SHELL}" || "${@:-$SHELL}"
    } -- %val{client} %val{session} %arg{@}
}

define-command x11-send-text -params 0..1 -docstring %{
        x11-send-text [text]: Send text to the REPL window.
        If no text is passed, then the selection is used
        } %{
    nop %sh{
        printf "%s" "${@:-$kak_selection}" | dtach -p "$kak_opt_x11_repl_id"
    }
}

alias global repl-new x11-repl
alias global repl-send-text x11-send-text

}
