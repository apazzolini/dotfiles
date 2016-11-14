awstail() {
  if [ -z "$2" ]
  then
      time=5m
  else
      time=$2
  fi

  awslogs get $1 ALL --start="$time ago" --watch --no-color -S -G | bunyan -o short
}
