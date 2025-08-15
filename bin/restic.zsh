restic-env() {
  export RESTIC_REPOSITORY="sftp:rsync:data"
  export RESTIC_PASSWORD_COMMAND="security find-generic-password -a $USER -s restic-password -w"
}

restic-master-env() {
  export RESTIC_REPOSITORY="sftp:rs:data"
  export RESTIC_PASSWORD_COMMAND="security find-generic-password -a $USER -s restic-password -w"
}

restic-list() {
  restic-env
  restic --option=rclone.program="ssh rsync" --repo=rclone: snapshots
}

restic-backup() {
  restic-env
  restic --limit-upload 1536 --option=rclone.program="ssh rsync" --repo=rclone: backup \
    "/Users/andre/Library/Mobile Documents/com~apple~CloudDocs/Wiki/" \
    "/Users/andre/.ssh/" \
    "/Users/andre/Library/Keychains/" \
    "/Users/andre/Air" \
}

restic-prune() {
  restic-env
  restic --option=rclone.program="ssh rsync" --repo=rclone: forget \
    --keep-within 14d \
    --keep-hourly 24 \
    --keep-daily 31 \
    --keep-weekly 52
}
