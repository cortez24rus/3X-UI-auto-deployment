#!/usr/bin/env bash

E[0]="Language:\n  1.English (default) \n  2.Русский"
R[0]="${E[0]}"
E[1]="Choose:"
R[1]="Выбери:"
E[2]=" :"
R[2]=" :"

warning()    { echo -e "\033[31m\033[01m$*\033[0m"; }
error()      { echo -e "\033[31m\033[01m$*\033[0m"; }
info()       { echo -e "\033[32m\033[01m$*\033[0m"; }
hint()       { echo -e "\033[33m\033[01m$*\033[0m"; }
reading()    { read -rp "$(info "$1")" "$2"; }
text()       { eval echo "\${${L}[$*]}"; }
text_eval()  { eval echo "\$(eval echo "\${${L}[$*]}")"; }

select_language() {
  L=E && hint " $(text 0) \n" && reading " $(text 4) " LANGUAGE
  [ "$LANGUAGE" = 2 ] && L=R
}

menu() {
	clear
  select_language

	echo -e "======================================================================================================================\n"
}

menu