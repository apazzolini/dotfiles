awstail() {
  if [ -z "$2" ]
  then
      time=5m
  else
      time=$2
  fi

  awslogs get $1 ALL --start="$time ago" --watch | unbuffer -p cut -d " " -f 3- | bunyan -o short
}
