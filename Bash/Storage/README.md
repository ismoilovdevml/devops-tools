# Top Disk Consumer Report Generator
#### Copyright 2022-2023 Red Hat, Inc.
#### Author: Kimberly Lazarski (klazarsk@redhat.com)

#### [ORIGINAL REPOSITORY](https://github.com/klazarsk/storagetoolkit)

```bash
./topdiskconsumer -l 10
```
```bash
du -hcx --max-depth=6 / 2>/dev/null | sort -rh | head -n 20
```

Top 30 file
```bash
find / -mount -ignore_readdir_race -type f -exec du -h "{}" + 2>&1 \
| sort -rh | head -n 20
```

```bash
find / -mount -ignore_readdir_race -type f -mtime +30 -exec du -h "{}" + 2>&1 \
| sort -rh | head -20
```

```txt
-f --format [format]
	Format headings with the addition of bold markup for use in ticketing system. 

	Valid options:
	 html - format headings with html bold tags
	 bbcode - format headings with bbcode bold tags
	 ansi - [DEFAULT] format headings with ansi bold tags {for terminals and 
	 richtext. This help screen always in ANSI format.}

-p --path [path] explicitly set path to run from (it will identify the mount 
	 hosting the specified directory and run from that mount point. Mutually 
	 exclusive with the -A | --alt-root option.
	

-A --alt-root - treat the specified directory as an alternate root; in other words
	 report the top disk consumers from the specified point, deeper; do not check for
	 the actual mount point. Musually exclusive with --path option. This option is very 
	 when used in combination of a bind mount of / if you suspect mounts are hiding large
	 disk consumers from view.		

-l --limit [number]
	 Report limited to top [number] largest files for each report section [default=20]

-t --timeout [duration] set a timeout for each section of the report. For 
	 example, 60 default time unit is seconds so this would timeout after 60 seconds,
	 30s (for a 30 second timeout), 15m (timeout after 15 minutes), 2h (timeout after
	 2 hours). Accepts same values as _timeout_ command. Please note that specifying a 
	 timeout will result in incomplete and likely inaccurate and misleading results.

-o --skipold skip report of files aged over 30 days 

-d --skipdir skip report of largest directories

-m --skipmeta omit metadata such as reserve blocks, start and end time, duration, etc.

-u --skipunlinked skip report of open handles to deleted files

-f --skipfiles skip report of largest files

-t --temp [directory] Specify an an alternate temp directory when /tmp is too full for temp
	 files to allow report generation.

-v --version display the version number then exit.
```