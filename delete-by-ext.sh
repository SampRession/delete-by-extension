#!/usr/bin/bash

### Script de tri pour récupérer et copier les fichiers en fonction de l'extension

zenity_state=false
extensions_file="./allowed_extensions.md"

# Vérif si Zenity est installé
pkg_check_install() {
    if apt list --installed | grep "zenity"; then
        echo "=== Zenity est déjà installé ==="
        zenity_state=true
    else
        echo "=== Zenity n'est pas installé, installation... ==="
        sudo apt-get install zenity
    fi
    echo
}

# Choix du dossier de recherche
search_dir_prompt() {
    echo
    echo "=== Choisir le dossier source pour la recherche des fichiers... ==="
    source_dir=$(zenity --file-selection --directory)
    echo "\nDossier source: $source_dir"
}

# Choix du dossier de sauvegarde
backup_dir_prompt() {
    echo
    echo "Choisir le dossier de destination pour la sauvegarde des fichiers"
    backup_dir=$(zenity --file-selection --directory)
    echo "\nDossier de sauvegarde: $backup_dir"
}

# Construction de la commande find
build_find_cmd() {
    find_cmd="find \"$source_dir\" \( "

    while IFS= read -r ext; do
        find_cmd+="-iname \"*.$ext\" -o "
    done <"$extensions_file"

    find_cmd=${find_cmd% -o }
    find_cmd+=" \)"
}

# Lancement de la commande finale
run_find_cmd() {
    eval $find_cmd | while read -r file; do
        cp $file $backup_dir
        echo "File: \"$file\" saved"
    done
}

# Désinstallation de Zenity si nécessaire
pkg_uninstall() {
    if $zenity_state; then
        echo
        sudo apt-get remove zenity
    fi
}

# Fermeture du programme
quit() {
    echo "=====   FIN DU PROGRAMME   ====="
    echo
    echo "Appuyer sur [ENTRÉE] pour quitter..."
    read -r
}

# Fonction principale
main() {
    echo "=====   RÉCUPÉRATION DES FICHIERS   ====="
    echo
    pkg_check_install
    search_dir_prompt
    backup_dir_prompt
    build_find_cmd
    run_find_cmd
    pkg_uninstall
    quit
}

# Appel de la fonction principale
main
