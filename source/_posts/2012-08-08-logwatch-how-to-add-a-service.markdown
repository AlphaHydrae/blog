---
layout: post
title: "Logwatch: how to add a service"
date: 2012-08-08 18:19
comments: false
categories: [logwatch, sysadmin]
---

I use [logwatch](http://sourceforge.net/projects/logwatch/) to monitor disk usage and the everyday break-in attempts on my Fedora and Ubuntu servers. It sends me a daily report by mail. Since I also received separate mails from by backup scripts, I wanted to see if I could include everything into the logwatch report so that I would only have one mail to read per server.

<!--more-->

## Installation

{% codeblock lang:bash %}
# Fedora
yum install logwatch fortune-mod
 
# Ubuntu
apt-get install logwatch fortune-mod
{% endcodeblock %}

I highly recommend including fortune which adds a random quote to every report. Knowing that a possibly funny quote sits at the bottom of the reports is the main reason I manage to scroll through them every day.

## New Service

The goal was to add the logs of my backup scripts in `/var/log/backup/` to the logwatch reports. First you have to define a log file group. This tells logwatch which files to read.

{% codeblock %}
# /etc/logwatch/conf/logfiles/my-backup.conf
 
# The LogFile path is relative to /var/log by default.
# You can change the default by setting LogDir.
LogFile = backup/*.log
  
# This enables searching through zipped archives as well.
Archive = backup/*.gz
   
# Expand the repeats (actually just removes them now).
*ExpandRepeats
{% endcodeblock %}

Next you need to create a service that will use the log file group.

{% codeblock %}
# /etc/logwatch/conf/services/my-backup.conf
 
# The title shown in the report.
Title = "My Backups"
 
# The name of the log file group (file name).
LogFile = my-backup
{% endcodeblock %}

Finally, you need a script to parse the log files. I’ve seen a lot of examples in perl, but I prefer bash for simple scripts. Note that the script has the same name as the service file.

{% codeblock lang:bash %}
#!/usr/bin/env bash
# /etc/logwatch/scripts/services/my-backup
 
# Change the line separator to split by new lines.
OLD_IFS=$IFS
IFS=$'\n'
 
# The contents of the log file are given in stdin.
for LINE in $( cat /dev/stdin ); do
 
    # Only lines matching this regexp will be included.
    if echo $LINE|egrep 'info' &> /dev/null; then
 
        # Every line we echo here will be included in the logwatch report.
        echo $LINE
 
    fi
 
done
 
IFS=$OLD_IFS
{% endcodeblock %}

And you’re done! The contents of the backup log files will show up in the logwatch reports under "My Backups".

## Log Rotation

If you don’t want your logwatch reports to forever grow in size, you also need to rotate the log files. Logrotate will conveniently do that for you with this simple configuration.

{% codeblock %}
# /etc/logrotate.d/backup
 
/var/log/backup/*log {
 
    daily
 
    # keep 10 old logs
    rotate 10
 
    # don't do anything if the log is missing
    missingok
 
    # don't do anything if the log is empty
    notifempty
 
    # zip the archived logs
    compress
}
{% endcodeblock %}

## Meta

* **OS:** Fedora, Ubuntu
* **Logwatch:** 7.3.6 (Ubuntu), 7.4.0 (Fedora)
