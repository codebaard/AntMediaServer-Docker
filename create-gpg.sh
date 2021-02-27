#!/bin/sh
export GNUPGHOME="$(mktemp -d)"

cat >foo <<EOF
     %echo Generating a basic OpenPGP key to build Tomcat inside Docker Container...
     Key-Type: DSA
     Key-Length: 1024
     Subkey-Type: ELG-E
     Subkey-Length: 1024
     Name-Real: Docker Build
     Name-Email: docker@example.com
     Expire-Date: 0
     Passphrase: abc
     %commit
     %echo done
EOF
gpg --batch --generate-key foo

echo Created GPG Key:

gpg --list-secret-keys

