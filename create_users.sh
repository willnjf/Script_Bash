#!/bin/bash

# ========== Déclaration des variabbles ==========
CHEMIN="/mnt/c/Users/user/Desktop"
BACKUP_FILE="$CHEMIN/backup_users.txt" # Pour récuperer l'utilisateur crée et son nom de passe
LIST_USERS=("franck" "pat" "Louis") # Permet de gérer plusieurs utilisateurs
GROUPE="it" # Organisation par service auquel les utilisateurs seront ajoutés
LOG_FILE="$CHEMIN/log_scirpt_users.txt" # Pour gérer les audits et le script
DATE=$(date "+%Y-%m-%d_%H-%M-%S") # utile pour unifier chaque fichier avec hérodatage

# ========== Function log ==========
function log () {
	echo "[$DATE] $1" >> "$LOG_FILE"
}

# ========== Vérification du groupe ==========
if ! getent group "$GROUPE" &>/dev/null; then
	log "Groupe $GROUPE non trouvé : Création du groupe....."
	sudo groupadd "$GROUPE"
	log "Groupe $GROUPE crée avec succès le $DATE"
else
	log "Groupe $GROUPE existe déjà."
fi

# ========== Vider le fichier ou créer le fichier BACKUP_FILE ==========
> "$BACKUP_FILE"

# ========== Boucler sur la liste pour céer les utilisateur ==========
for user in "${LIST_USERS[@]}"; do
	# ===== Vérifier si l'utilisateur existe =====
	if id "$user" &>/dev/null; then
		log "Utilisateur $user existe déjà"
	else
		# ===== Créer l'utilisateur =====
		sudo useradd "$user"
		# ===== Ajouter l'utilisateur au groupe =====
		sudo usermod -aG "$GROUPE" "$user"
		# ===== Génération de mot de passe aléatoire =====
		MOT_DE_PASSE=$(openssl rand -base64 8)
		# ===== Appliquer le mot de passe aux utilisateurs =====
		echo "$user:$MOT_DE_PASSE" | sudo chpasswd
		# ===== Forcer le mot de passe à la prémière connection =====
		sudo chage -d 0 "$user"
		# ===== Sauvegarder tout dans le fichier BACKUP_FILE =====
		echo "$user:$MOT_DE_PASSE" >> "$BACKUP_FILE"
		log "Utilisateur $user crée avec mot de passe temporaire à la date du $DATE"
	fi 

done
