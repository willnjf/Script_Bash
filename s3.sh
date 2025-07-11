#!/bin/bash

# Déclaration des varaibles
CHEMIN="/mnt/c/Users/user/Desktop"
DOC_SOURCE="$CHEMIN/DOC_SOURCE"
LOG_FILE="$CHEMIN/log.txt"
ARCHIVE="$CHEMIN/DOC_ARCHIVE"
DATE=$(date "+%Y-¨%m-%d_%H-%M-%S")
ARCHIVE_NAME="archive_$DATE.tar.gz"
DOC_ARCHIVE="$ARCHIVE/$ARCHIVE_NAME"
ARCHIVE_ENCRYPTED="$DOC_ARCHIVE.gpg"
GPG_PASSWORD="TonMotDePasseFort" # Usage réel mettre un mot de passe qui rempli les condition (Au moins 8 caractères melangés avec des chifrres et des caractères spéciaux) 
s3_BUCKET="s3://njftest237"

# Fonction de log
log() {
	echo "[$(date '+%Y-%m-%d_%H-%M-%S')] $1" >> "$LOG_FILE"
}

# Vérifie si le dossier source existe
if [ ! -d "$DOC_SOURCE" ]; then
        log "Le dossier source n'existe" 
        exit 1
fi

# Création de l'archive
tar -czf "$DOC_ARCHIVE" -C "$(dirname "$DOC_SOURCE")" "$(basename "$DOC_SOURCE")"
if [ $? -ne 0 ]; then
        log "Erreur lors de la création de l'archive"
        exit 1
else
        log "Archive créée : $DOC_ARCHIVE"
fi

# Chiffrement de l'archive 
echo "$GPG_PASSWORD" | gpg --batch --yes --passphrase-fd 0 -c "$DOC_ARCHIVE"
if [ $? -ne 0 ]; then
	log "Echec du chiffrement de l'archive"
	exit 1
else
	log "Archive chiffrée : $ARCHIVE_ENCRYPTED"

# Supprimer l'ancien archive non sécurisée
	rm -f "$DOC_ARCHIVE"
	chmod 600 "$ARCHIVE_ENCRYPTED"
fi

# Synchronisation des fichiers DOC_SOURCE vers S3 AWS

log "Début de la sychronisatin $DOC_SOURCE ---> $s3_BUCKET"
aws s3 cp "$DOC_SOURCE/" "$s3_BUCKET/Dossier_Client" --recursive >> "$LOG_FILE" 2>&1
if [ $? -ne 0 ]; then
	log "[$DATE] Erreur de la synchronisation vers s3"
	exit 1
else
	log "Synchronisation vers s3 réuissiée"
fi

