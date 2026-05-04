#!/usr/bin/env bash

set -e

echo "устанавливаю venvy..."

if [ -n "$PREFIX" ]; then
    bin_dir="$PREFIX/bin"
else
    bin_dir="$HOME/.local/bin"
fi

mkdir -p "$bin_dir"

cat > "$bin_dir/venvy" << 'EOF'
#!/usr/bin/env bash

venvy_home="${VENVY_HOME:-$HOME/.venvy}"
default_env="$venvy_home/default"

mkdir -p "$venvy_home"

create_env() {
    local name="$1"
    local path="$venvy_home/$name"

    if [ ! -d "$path" ]; then
        echo "создаю окружение: $name"
        python3 -m venv "$path"
    fi
}

activate_shell() {
    local path="$1"
    local name="$2"

    exec /bin/bash --rcfile <(
        echo "source \"$path/bin/activate\""
        echo "PS1='(venvy:$name) \u@\h:\w\$ '"
    )
}

case "$1" in
    "" )
        create_env "default"
        activate_shell "$default_env" "default"
        ;;

    use)
        env_name="${2:-default}"
        create_env "$env_name"
        activate_shell "$venvy_home/$env_name" "$env_name"
        ;;

    list)
        ls "$venvy_home"
        ;;

    remove)
        if [ -z "$2" ]; then
            echo "ошибка: нужно указать имя окружения"
            exit 1
        fi
        rm -rf "$venvy_home/$2"
        echo "удалил окружение: $2"
        ;;

    run)
        env_name="${2:-default}"
        shift 2
        create_env "$env_name"
        "$venvy_home/$env_name/bin/python" "$@"
        ;;

    *)
        echo "venvy — менеджер виртуальных окружений"
        echo ""
        echo " venvy открыть окружение 'default'"
        echo " venvy use <name> открыть (или создать) именованное окружение"
        echo " venvy list список всех окружений"
        echo " venvy remove <name> удалить окружение"
        echo " venvy run <name> <скрипт> [args...] запустить скрипт в окружении"
        ;;
esac
EOF

chmod +x "$bin_dir/venvy"

if ! echo "$PATH" | grep -q "$bin_dir"; then
    echo "внимание: нужно добавить в path. добавьте в ~/.bashrc или ~/.zshrc:"
    echo "export PATH=\"$bin_dir:\$PATH\""
fi

export PATH="$bin_dir:$PATH"

echo "готово! установлен в $bin_dir/venvy"
echo "если venvy не находится — перезапусти терминал или выполни: source ~/.bashrc"
