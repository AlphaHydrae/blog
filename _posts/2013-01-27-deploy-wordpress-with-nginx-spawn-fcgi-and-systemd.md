---
layout: post
title: "Deploy WordPress with nginx, spawn-fcgi and systemd"
date: 2013-01-27 21:19
comments: true
categories: [wordpress, nginx, fcgi, systemd, sysadmin]
---

It's a bit weird to post this now that I've switched to Octopress, but this is
how I deployed the previous WordPress version of this blog.

<!-- more -->

I'm assuming you have **nginx**, **php** and **spawn-fcgi** installed and set up
(you can install all of them with `yum`); and of course, **WordPress** and
**MySQL** (read the [installation
instructions](http://codex.wordpress.org/Installing_WordPress)).

The first thing we need is to spawn PHP processes that we can hook nginx to. We
also want those processes to automatically start on boot, so we'll create a
systemd service file. You need the following information:

* `/path/to/wordpress`: the path to your WordPress installation;
* `wordpressUser`: the system user that you want the processes to run as;
* `wordpressGroup`: the system group that you want the processes to run as;
* `/path/to/pid/file.pid`: where you want to put the PID file;
* `/path/to/socket/file.pid`: where you want to put the socket file;
* the number of processes you want to spawn (I used 3).

Note that the name of the file determines the name of the service. That's the
name you'll have to use with the `systemctl` command to control the service. I
chose `wordpress.service`.

{% highlight conf %}
# File: /etc/systemd/system/wordpress.service
[Unit]
Description=Wordpress Blog
After=syslog.target

[Service]
Type=forking
PIDFile=/path/to/pid/file.pid
# Clean PID file on startup. Note the -f: don't fail if there is no PID file.
ExecStartPre=/bin/rm -f /path/to/pid/file.pid
# Spawn 3 processes (-F 3) with spawn-fcgi.
ExecStart=/bin/spawn-fcgi -u wordpressUser -g wordpressGroup -F 3 -d /path/to/wordpress -s /path/to/socket/file.sock -M 0770 -P /path/to/pid/file.pid -- /bin/php-cgi
Restart=on-abort

[Install]
WantedBy=multi-user.target
{% endhighlight %}

You can now enable your service to start on boot and start it with:

{% highlight bash %}
systemctl enable wordpress.service
systemctl start wordpress.service
{% endhighlight %}

If you check your processes with `ps -ef` or `systemctl status
wordpress.service`, you should see 3 `php-cgi` processes running. Then all you
need to do is point nginx to your WordPress path and socket file. This was my
configuration.

{% highlight nginx %}
# File: /etc/nginx/conf.d/wordpress.conf

# Upstream to backend connection(s) for php
upstream wordpress {
        server unix:/path/to/socket/file.sock;
}

server {
        listen *:80;
        server_name example.com;

        root /path/to/wordpress;
        ## This should be in your http block and if it is, it's not needed here.
        index index.php;

        location = /favicon.ico {
                log_not_found off;
                access_log off;
        }

        location = /robots.txt {
                allow all;
                log_not_found off;
                access_log off;
        }

        location / {
                # This is cool because no php is touched for static content
                try_files $uri $uri/ /index.php;
        }

        location ~ \.php$ {
                #NOTE: You should have "cgi.fix_pathinfo = 0;" in php.ini
                include fastcgi.conf;
                fastcgi_intercept_errors on;
                fastcgi_pass wordpress;
        }

        location ~* \.(js|css|png|jpg|jpeg|gif|ico)$ {
                expires max;
                log_not_found off;
        }
}
{% endhighlight %}

If your main nginx configuration doesn't already load everything in
`/etc/nginx/conf.d`, add a line to include the new configuration.

{% highlight nginx %}
# File: /etc/nginx/nginx.conf
http {

  # ...

  include /etc/nginx/conf.d/wordpress.conf;
}
{% endhighlight %}

**Be forewarned!** My PHP processes regularly died about twice a month and I do
not know whether that was due to the above configurations or to something else.
I did not have enough time to investigate the issue and now that I've switched
to Octopress, I'll probably never know.

Enjoy.

## Meta

* **Fedora:** 17
* **nginx:** 1.0.15
* **php:** 5.4.6
* **spawn-fcgi:** 1.6.3
