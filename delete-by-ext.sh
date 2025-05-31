#!/usr/bin/bash

### Script de tri pour récupérer et copier les fichiers en fonction de l'extension

zenity_state=false
extensions_file="./allowed_extensions.md"

# Vérif si Zenity est installé
pkg_check_install() {
    if apt list --installed | grep "zenity" >/dev/null; then
        echo "=== Zenity est déjà installé ==="
    else
        echo "=== Zenity n'est pas installé, installation... ==="
        sudo apt-get install zenity
        zenity_state=true
    fi
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
        exit 1
    fi
    echo "Dossier source: $source_dir"
}

# Choix du dossier de sauvegarde
backup_dir_prompt() {
    echo
    echo "=== Choisir le dossier de destination pour la sauvegarde des fichiers ==="
    echo "Appuyer sur [ENTRÉE] pour ouvrir l'explorateur..."
    read -r

    backup_dir=$(zenity --file-selection --directory)
    if [ -z "$backup_dir" ]; then
        echo "=== ERREUR: Un dossier cible pour la sauvegarde est nécessaire ==="
        exit 1
    fi
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
    echo
    echo "Appuyer sur [ENTRÉE] pour lancer la sauvegarde"
    echo "==== DÉMARRAGE DE LA SAUVEGARDE ===="

    eval "$find_cmd" | while read -r file; do
        cp "$file" "$backup_dir"
        echo "Fichier: \"$file\" sauvegardé"
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
    echo
    echo "=====   FIN DU PROGRAMME   ====="
    echo
    echo "Appuyer sur [ENTRÉE] pour quitter..."
    read -r
}

# Fonction principale
main() {
    echo
    echo "=====   RÉCUPÉRATION DES FICHIERS   ====="
    pkg_check_install
    sleep 1
    search_dir_prompt
    sleep 1.5
    backup_dir_prompt
    sleep 1.5
    build_find_cmd
    run_find_cmd
    sleep 1.5
    pkg_uninstall
    quit
}

# Appel de la fonction principale
main
