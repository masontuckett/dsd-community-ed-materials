#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

if [[ "$EUID" -ne 0 ]]; then
	echo "This script must be run as root or with sudo privilege." >&2
	echo "Try again: sudo $0" >&2
	exit 1
fi



echo -e "--------------------------\n| ADVANCED USER CREATION |\n--------------------------\n"




read -rp "Enter new username: " newuser
echo

if id "$newuser" &>/dev/null; then
	echo "User '$newuser' already exists."
	exit 0
fi



while :; do
	echo
	read -rp "Enter login shell (leave blank for default): " loginshell
	echo

	if [[ -z "${loginshell:-}" ]] then
		echo -e "Using default login shell.\n"
		break
	fi

	if grep -qx "$loginshell" /etc/shells; then
		echo -e "Using login shell: $loginshell\n"
		break
	else
		echo "Invalid shell: $loginshell"
		cat /etc/shells
		echo -e "\nPlease enter a valid shell (full path), or leave blank for default.\n"
	fi
done

if [[ -n "${loginshell:-}" ]]; then
	args+=(-s "$loginshell")
fi



echo
read -rp "Create home directory? [y/n] " homecase
echo

case "${homecase,,}" in
	y|yes)
		args+=(-m)
		;;
	*)
		echo "Home directory not created."
		echo -e "Considering creating a home directory with: mkhomedir_helper $newuser\n"
		;;
esac



useradd "${args[@]}" "$newuser" &>/dev/null
echo -e "\nCreated user: '$newuser'\n"




echo
read -rp "Set a password? [y/n]: " passwordcase
echo

case "${passwordcase,,}" in
	y|yes)
		passwd "$newuser"
		echo
		;;
	*)
		echo "Password not set."
		echo -e "Consider setting a password with: sudo passwd $newuser\n"
		;;
esac




echo
read -rp "Add '$newuser' to sudo group? [y/n]: " sudocase
echo

case "${sudocase,,}" in
	y|yes)
		usermod -aG sudo "$newuser"
		echo "Added '$newuser' to the sudo group."
		;;
	*)
		echo "No sudo access granted (standard user)."
		echo "Consider adding sudo access with: usermod -aG sudo $newuser" 
		;;
esac




echo -e "\n----------------\n| SANITY CHECK |\n----------------\n"

echo -e "getent passwd $newuser"
getent passwd "$newuser"

echo -e "\nid $newuser"
id "$newuser"

echo -e "\nls -l /home"
ls -l /home | sed "s/$newuser/\x1b[31m&\x1b[0m/g"
echo



echo
read -rp "Delete test user ('$newuser')? [y/n]: " delcase
echo

case "${delcase,,}" in
	y|yes)
		userdel -rf "$newuser"
		echo -e "\nUser '$newuser' deleted."
		;;
	*)
		echo "User '$newuser' not deleted."
		echo -e "Considering deleting if necessary: sudo userdel -rf $newuser"
		;;
esac


echo -e "\n---------------\n| END SCRIPT |\n---------------"
