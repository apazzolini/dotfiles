#!/bin/sh
echo >> /var/log/tarsnap
echo Running at $(date +%Y-%m-%d_%H-%M-%S) >> /var/log/tarsnap
echo ------------------------------------------------------------------ >> /var/log/tarsnap
/usr/bin/tarsnap -c \
	-f "$(uname -n)-Air-$(date +%Y-%m-%d_%H-%M-%S)" \
	/mnt/d/Air >> /var/log/tarsnap 2>&1
echo ------------------------------------------------------------------ >> /var/log/tarsnap
