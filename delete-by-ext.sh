#!/usr/bin/bash

### Script de tri pour récupérer et copier les fichiers en fonction de l'extension

zenity_state=false
extensions_file="./allowed_extensions.md"

# Vérif si Zenity est installé
pkg_check_install() {
    if apt list --installed | grep "zenity"; then
        echo "=== Zenity est déjà installé ==="
    else
        echo "=== Zenity n'est pas installé, installation... ==="
        sudo apt-get install zenity
        zenity_state=true
    fi
    sleep 1.5
    echo
}

# Choix du dossier de recherche
search_dir_prompt() {
    echo
    echo "=== Choisir le dossier source pour la recherche des fichiers... ==="
    echo "Appuyer sur [ENTRÉE] pour ouvrir l'explorateur..."
    read -r
    source_dir=$(zenity --file-selection --directory)
    if [ -z "$source_dir" ]; then
        echo "=== ERREUR: Un dossier source pour la recherche est nécessaire ==="
        sleep 2
        exit 1
    fi
    echo
    echo "Dossier source: $source_dir"
}

# Choix du dossier de sauvegarde
backup_dir_prompt() {
    echo
    echo "=== Choisir le dossier de destination pour la sauvegarde des fichiers ==="
    echo "Appuyer sur [ENTRÉE] pour ouvrir l'explorateur..."
    read -r
    sleep 2
    backup_dir=$(zenity --file-selection --directory)
    if [ -z "$backup_dir" ]; then
        echo "=== ERREUR: Un dossier cible pour la sauvegarde est nécessaire ==="
        sleep 2
        exit 1
    fi
    echo
    echo "Dossier de sauvegarde: $backup_dir"
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
    eval "$find_cmd" | while read -r file; do
        cp "$file" "$backup_dir"
        echo "File: \"$file\" saved"
    done
}

# Désinstallation de Zenity si nécessaire
pkg_uninstall() {
    if $zenity_state; then
        echo
        echo "=== Désinstallation de Zenity ==="
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
