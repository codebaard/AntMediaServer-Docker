#!/bin/sh

cat >foo <<EOF
     %echo Generating a basic OpenPGP key to build Tomcat inside Docker Container...
     Key-Type: DSA
     Key-Length: 1024
     Subkey-Type: ELG-E
     Subkey-Length: 1024
     Name-Real: Docker Tomcat
     Name-Email: dt@example.org
     Expire-Date: 0
     Passphrase: abc
     %commit
     %echo done
EOF
gpg --batch --generate-key foo

echo Created GPG key successfully. 
echo Key created:

gpg --list-secret-keys

