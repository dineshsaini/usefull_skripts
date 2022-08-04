#!/usr/bin/env bash

# make tracker3 daemon non workable & idompotent
# this script will reset its settings, and configure tracker3 daemon, to not let it do anyting.
# if other code has dependency on this tracker, then it will not break, but we also do achieve our goal.

# interpretation  for org.freedesktop.Tracker3.Miner.Files enable-monitor from this file 
# https://gitlab.gnome.org/GNOME/tracker-miners/-/blob/master/src/miners/fs/tracker-config.c

#Time in seconds before crawling filesystem (0->1000)
# looking at source code https://gitlab.gnome.org/GNOME/tracker-miners/-/blob/master/src/miners/fs/tracker-main.c#L406
# it seems like -ve value will starts it right away, so giving max value will make it to wait max before failing
gsettings set org.freedesktop.Tracker3.Miner.Files initial-sleep 1000

# Set to false to completely disable any monitoring
gsettings set org.freedesktop.Tracker3.Miner.Files enable-monitors false

# Sets the indexing speed (0->20, where 20=slowest speed)
gsettings set org.freedesktop.Tracker3.Miner.Files throttle 20

# Set to true to index while running on battery
gsettings set org.freedesktop.Tracker3.Miner.Files index-on-battery false

# Set to true to index while running on battery for the first time only
gsettings set org.freedesktop.Tracker3.Miner.Files index-on-battery-first-time false

#Set to true to enable traversing mounted directories for removable devices (this includes optical discs)
gsettings set org.freedesktop.Tracker3.Miner.Files index-removable-devices false

# Set to true to enable traversing CDs, DVDs, and generally optical media 
# (if removable devices are not indexed, optical discs won't be either)
gsettings set org.freedesktop.Tracker3.Miner.Files index-optical-discs false

# Pause indexer when disk space is <= this value
# (0->100, value is in % of $HOME file system, -1=disable pausing)
# hmm, seems like this line https://gitlab.gnome.org/GNOME/tracker-miners/-/blob/master/src/miners/fs/tracker-main.c#L124
# is misleading, as used by some blog, -ve value disable pausing of tracker, rather then tracker itself,
# and 100 will make it idompotent as any other value is always < 100%
gsettings set org.freedesktop.Tracker3.Miner.Files low-disk-space-limit 100

#  List of directories to crawl recursively for indexing (separator=;)
# Special values include: (see /etc/xdg/user-dirs.defaults & $HOME/.config/user-dirs.default)
#   &DESKTOP\n"
#   &DOCUMENTS\n"
#   &DOWNLOAD\n"
#   &MUSIC\n"
#   &PICTURES\n"
#   &PUBLIC_SH
#   &TEMPLATES\n"
#   &VIDEOS\n"
# If $HOME is the default below, it is because $HOME/.config/user-dirs.default was missing.

# hmm, i think emptying its value will make it work on all dirs, i probably seen that check somewhere
# anyways, redirecting to nonexistent directory will mislead and stop its loop furthur
gsettings set org.freedesktop.Tracker3.Miner.Files index-recursive-directories "['nonexistentdir1']"

# List of directories to index but not sub-directories for changes (separator=;)\n"
# Special values used for IndexRecursiveDirectories can also be used here"

# same with this, as was with index-recursive-directories, but these dirs are removed from index-recursive-directories
# so giving it diff value will be more idompotent to this
gsettings set org.freedesktop.Tracker3.Miner.Files index-single-directories "['nonexixtentdir2']"

# List of directories to NOT crawl for indexing (separator=;)"
# this uses regex, patterns so * will match to everything
gsettings set org.freedesktop.Tracker3.Miner.Files ignored-directories "['*']"

# List of directories to NOT crawl for indexing based on child files (separator=;)"
# this uses regex, patterns so *, *.*, .* will matches to everything
gsettings set org.freedesktop.Tracker3.Miner.Files ignored-directories-with-content "['*', '*.*', '.*']"

# List of files to NOT index (separator=;)"
# this uses regex, patterns so *, *.*, .* will matches to everything
gsettings set org.freedesktop.Tracker3.Miner.Files ignored-files "['*','*.*','.*']"

# Interval in days to check the filesystem is up to date in the database,
# maximum is 365, default is -1.
#   -2 = crawling is disabled entirely
#   -1 = crawling *may* occur on startup (if not cleanly shutdown)
#    0 = crawling is forced
gsettings set org.freedesktop.Tracker3.Miner.Files crawling-interval -2

# Threshold in days after which files from removables devices
# will be removed from database if not mounted. 
#  0 means never, 
#  maximum is 365.
# so, 1 will clear everything, if its stored, daily
gsettings set org.freedesktop.Tracker3.Miner.Files removable-days-threshold  1

# hmm, it didn't explain this key behaviour, so i think making it false will be better, 
# then its default true, As this will disable application indexing
gsettings set org.freedesktop.Tracker3.Miner.Files index-applications false


# explaination based on this file: 
# https://gitlab.gnome.org/GNOME/tracker-miners/-/blob/master/src/libtracker-miners-common/tracker-fts-config.c

# Flag to enable word stemming utility (default=FALSE)
gsettings set  org.freedesktop.Tracker3.FTS enable-stemmer false

# Flag to enable word unaccenting (default=TRUE)
gsettings set  org.freedesktop.Tracker3.FTS enable-unaccent false

# Flag to ignore numbers in FTS (default=TRUE)
gsettings set  org.freedesktop.Tracker3.FTS ignore-numbers true

# Flag to ignore stop words in FTS (default=TRUE)
gsettings set  org.freedesktop.Tracker3.FTS ignore-stop-words true


# explaination based on this file: 
# https://gitlab.gnome.org/GNOME/tracker-miners/-/blob/master/src/tracker-extract/tracker-config.c

# Maximum number of UTF-8 bytes to extract per file [0->10485760]
# min ==> 0 ==> 0b
# max ==> 1024 * 1024 * 10 ==>  10 Mb
# default ==> 1024 * 1024  ==> 1Mb
gsettings set org.freedesktop.Tracker3.Extract  max-bytes 0

# Filename patterns for plain text documents that should be indexed
# empty, as these are whitelisting pattern, or maybe never existent filename pattern
# will also work, like filename that contains new line in it, will make it to never match
# to anything.
gsettings set org.freedesktop.Tracker3.Extract  text-allowlist '[]'

# Wait for FS miner to be done before extracting
# %TRUE to wait for tracker-miner-fs is done before extracting. %FAlSE otherwise
# hmm, true will make it less aggressive, as it will wait for miner to finish which
# itself has 1000s initial delay.
gsettings set org.freedesktop.Tracker3.Extract  wait-for-miner-fs true


# disable its settings in gnome settings also
# populate disable list, disable all apps, and location
gsettings set org.gnome.desktop.search-providers disabled "['org.gnome.Terminal.desktop', 'org.gnome.Settings.desktop', 'org.gnome.Photos.desktop', 'org.gnome.clocks.desktop', 'org.gnome.Calendar.desktop', 'org.gnome.Calculator.desktop', 'org.gnome.Nautilus.desktop']"

# clear enable list
gsettings set org.gnome.desktop.search-providers enabled "[]"

# search path setting is already cleared in "index-recursive-directories"

# disable gnome search indexing itself
gsettings set org.gnome.desktop.search-providers disable-external true


# and finally,
# Application Options:
#  -s, --filesystem     Remove filesystem indexer database
#  -r, --rss            Remove RSS indexer database

tracker3 reset -s -r

# and kill it brutally
tracker3 daemon --kill
