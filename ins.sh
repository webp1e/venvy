#!/bin/bash

echo "запускайте установщик с root доступом!"
echo "установщик venvy..."

cat > /usr/local/bin/venvy << 'EOF'
#!/bin/bash
exec /bin/bash --rcfile <(echo "PS1='(venv) \[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '"; source /home/sigma/venv/bin/activate)
EOF

chmod +x /usr/local/bin/venvy

echo "установка завершена!"
