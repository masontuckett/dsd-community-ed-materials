#!/bin/bash
set -euo pipefail

read -p "Enter new username: " newuser

sudo useradd -m "$newuser"

echo -e "\nCreated user '$newuser'" 

echo -e "\ncat /etc/passwd"
cat /etc/passwd | grep "$user"
