# Backup-vers-s3

# Le script récupère tout ce qui se trouve dans un dossié en local et le copi dans dans le cloud AWS (s3).
# Avant la copi, il va créer une archive du dossier source, le chiffrer et supprimer l'archive non chiffrée 
# Restrindre les droits d'access sur ce dossier 
# Et en fin copier le dossier source vers s3
