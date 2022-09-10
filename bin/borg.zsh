borg-env() {
  export BORG_REPO="rsync:air"
  export BACKUP_NAME="andre-m1-"
  export BORG_PASSCOMMAND="security find-generic-password -a $USER -s borg-passphrase -w"
  export BORG_RSH="ssh"
}

borg-check() {
  borg-env
  borg check --prefix "$BACKUP_NAME" "$BORG_REPO"
}

borg-list() {
  borg-env
  borg list --prefix "$BACKUP_NAME" "$BORG_REPO"
}

borg-backup() {
  borg-env
  borg create \
    --filter "AME" \
    --list \
    --stats \
    --verbose \
    "$BORG_REPO::$BACKUP_NAME{now:%F-%H%M%S}" \
    "/Users/andre/Library/Mobile Documents/com~apple~CloudDocs/Wiki/" \
    "/Users/andre/.ssh/" \
    "/Users/andre/Library/Keychains/" \
    "/Users/andre/Air/"
}

borg-prune() {
  echo "Pruning with append-only key"
  borg-env
  borg prune \
    --keep-hourly 24 \
    --keep-daily 31 \
    --keep-weekly 52 \
    --keep-monthly -1 \
    --list \
    --prefix "$BACKUP_NAME" \
    --stats \
    "$BORG_REPO"
}

borg-restore() {
  borg-env
  borg extract "$BORG_REPO::$1" "${@:2}"
}
