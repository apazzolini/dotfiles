#!/usr/bin/python
 
import os
import re
import sys
 
from subprocess import call, Popen, PIPE
 
INACTIVE_THRESHOLD = 1024  # Number of MBs
FREE_THRESHOLD = INACTIVE_THRESHOLD / 2
RE_INACTIVE = re.compile('Pages inactive:\s+(\d+)')
RE_FREE = re.compile('Pages free:\s+(\d+)')
RE_SPECULATIVE = re.compile('Pages speculative:\s+(\d+)')
LOCK_FILE = '/var/tmp/releasemem.lock'
 
 
def acquire_lock():
    try:
        os.open(LOCK_FILE, os.O_CREAT | os.O_EXLOCK | os.O_NDELAY)
    except OSError:
        sys.exit('Could not acquire lock.')
 
 
def pages2mb(page_count):
    return int(page_count) * 4096 / 1024 ** 2
 
 
def free_inactive():
    vmstat = Popen('vm_stat', shell=True, stdout=PIPE).stdout.read()
    inactive = pages2mb(RE_INACTIVE.search(vmstat).group(1))
    free = pages2mb(RE_FREE.search(vmstat).group(1)) + \
            pages2mb(RE_SPECULATIVE.search(vmstat).group(1))
    return free, inactive
 
 
def main():
    acquire_lock()
    free, inactive = free_inactive()
    if (free < FREE_THRESHOLD) and (inactive > INACTIVE_THRESHOLD):
        print("Free: %dmb < %dmb" % (free, FREE_THRESHOLD))
        print("Inactive: %dmb > %dmb" % (inactive, INACTIVE_THRESHOLD))
        print('Purging...')
        call('/usr/bin/purge', shell=True)
 
 
if __name__ == '__main__':
    main()
