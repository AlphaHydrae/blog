---
layout: post
title: "God, Unicorns and Nginx"
date: 2013-06-13 12:50
comments: true
categories: [ruby,god,unicorn,nginx]
---

Time to write a little about the tools I use to deploy Ruby on Rails applications.

{% blockquote Unicorn http://unicorn.bogomips.org %}
Unicorn is an HTTP server for Rack applications designed to only serve fast clients on low-latency, high-bandwidth connections and take advantage of features in Unix/Unix-like kernels. Slow clients should only be served by placing a reverse proxy capable of fully buffering both the request and response in between Unicorn and slow clients.
{% endblockquote %}

I used to deploy my Rails applications with [thin](http://code.macournoyer.com/thin/),
which I still use in development, but I now do everything with Unicorn in production.
Why? Because I find it the most convenient server to manage.
It's very fast, the configuration is easy to understand and it supports hot deployment with no downtime out of the box.
It's also built on Unix and can be controlled with signals.

{% blockquote God http://godrb.com %}
God is an easy to configure, easy to extend monitoring framework written in Ruby. Keeping your server processes and tasks running should be a simple part of your deployment process. God aims to be the simplest, most powerful monitoring application available.
{% endblockquote %}

God is the monitoring tool I use to watch my Unicorn processes and restart them if they crash or start consuming too much memory.
I haven't really tried any of the other monitoring tools.
[Bluepill](https://github.com/arya/bluepill) was recommended, and [Monit](http://mmonit.com/monit/) can do a similar job, but I didn't try those as God met my needs (and it sounds cooler).

{% blockquote Nginx http://wiki.nginx.org/ %}
Nginx (pronounced engine-x) is a free, open-source, high-performance HTTP server and reverse proxy, as well as an IMAP/POP3 proxy server. Nginx is known for its high performance, stability, rich feature set, simple configuration, and low resource consumption.
{% endblockquote %}

I switched from [Apache httpd](http://httpd.apache.org) to Nginx on my servers as soon as I saw Nginx's configuration files.
I find the syntax much easier to deal with, and the fact that it's very lightweight suits my needs.

The rest of this post describes a complete Unicorn/God/Nginx configuration for a Rails application.

<!-- more -->

* [Installation](#installation)
* [Unicorn Configuration](#unicorn)
* [God Configuration](#god)
* [Nginx Configuration](#nginx)

<a name="installation"></a>
## Installation

You may install God and Unicorn as gems.

{% codeblock lang:bash %}
gem install god
gem install unicorn
{% endcodeblock %}

Or add them to your application's Gemfile.

Nginx is available in most package managers (yum, aptitude, macports).
It's a fast-moving project though, so you might want to [compile it from source](http://wiki.nginx.org/Install#Building_Nginx_From_Source) for the latest features.

<a name="unicorn"></a>
## Unicorn Configuration

Unicorn runs one master and multiple worker processes.
The master process will receive requests and pass them to the workers for handling.

The following configuration will make Unicorn run 5 workers to serve your application.
Keep in mind that each worker will load your entire app, gems included, into memory.
A worker for one of my apps typically consumes 30MB of RAM, so I have to be careful how many
I use on memory-restricted hosts (some of my cloud servers only have 512MB of RAM).

```rb
# Sample verbose configuration file for Unicorn (not Rack)
#
# This configuration file documents many features of Unicorn
# that may not be needed for some applications. See
# http://unicorn.bogomips.org/examples/unicorn.conf.minimal.rb
# for a much simpler configuration file.
#
# See http://unicorn.bogomips.org/Unicorn/Configurator.html for complete
# documentation.

APP_PATH = "/path/to/app"

# Use at least one worker per core if you're on a dedicated server,
# more will usually help for _short_ waits on databases/caches.
worker_processes 5

# Run the app as an unprivileged user.
user "appuser"

working_directory APP_PATH # available in 0.94.0+

# Listen on a Unix domain socket or a TCP port.
# We use a shorter backlog for quicker failover when busy.
listen "#{APP_PATH}/tmp/sockets/unicorn.sock", :backlog => 64
#listen 8080, :tcp_nopush => true

# Nuke workers after 30 seconds instead of 60 seconds (the default).
timeout 30

# Feel free to point this anywhere accessible on the filesystem.
pid "#{APP_PATH}/tmp/pids/unicorn.pid"

# By default, the Unicorn logger will write to stderr.
# Additionally, ome applications/frameworks log to stderr or stdout,
# so prevent them from going to /dev/null when daemonized here:
stderr_path "#{APP_PATH}/log/unicorn.stderr.log"
stdout_path "#{APP_PATH}/log/unicorn.stdout.log"

# Combine REE with "preload_app true" for memory savings.
# http://rubyenterpriseedition.com/faq.html#adapt_apps_for_cow
preload_app true
GC.respond_to?(:copy_on_write_friendly=) and
  GC.copy_on_write_friendly = true

before_fork do |server, worker|

  # The following is highly recomended for Rails + "preload_app true"
  # as there's no need for the master process to hold a connection.
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!

  # This allows a new master process to incrementally
  # phase out the old master process with SIGTTOU to avoid a
  # thundering herd (especially in the "preload_app false" case)
  # when doing a transparent upgrade.  The last worker spawned
  # will then kill off the old master process with a SIGQUIT.
  old_pid = "#{server.config[:pid]}.oldbin"
  if old_pid != server.pid
    begin
      sig = (worker.nr + 1) >= server.worker_processes ? :QUIT : :TTOU
      Process.kill(sig, File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
    end
  end

  # The following is only recommended for memory/DB-constrained
  # installations.  It is not needed if your system can house
  # twice as many worker_processes as you have configured.
  #
  # Throttle the master from forking too quickly by sleeping.  Due
  # to the implementation of standard Unix signal handlers, this
  # helps (but does not completely) prevent identical, repeated signals
  # from being lost when the receiving process is busy.
  # sleep 1
end

after_fork do |server, worker|

  # Per-process listener ports for debugging/admin/migrations.
  # addr = "127.0.0.1:#{9293 + worker.nr}"
  # server.listen(addr, :tries => -1, :delay => 5, :tcp_nopush => true)

  # The following is *required* for Rails + "preload_app true",
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection

  # If preload_app is true, then you may also want to check and
  # restart any other shared sockets/descriptors such as Memcached,
  # and Redis.  TokyoCabinet file handles are safe to reuse
  # between any number of forked children (assuming your kernel
  # correctly implements pread()/pwrite() system calls).
end
```

### Hot Deployment

When you send a `USR2` signal to the Unicorn master process, it will launch a
new master process which will immediately begin spawning new workers with the
updated code from your application.

The following piece of configuration makes each new worker send a `TTOU` signal
to the old Unicorn master process, which will kill off one of its workers. The
last of the 5 new workers to start will send a `QUIT` signal to the old master
process, gracefully shutting it down.

```rb
# This allows a new master process to incrementally
# phase out the old master process with SIGTTOU to avoid a
# thundering herd (especially in the "preload_app false" case)
# when doing a transparent upgrade.  The last worker spawned
# will then kill off the old master process with a SIGQUIT.
old_pid = "#{server.config[:pid]}.oldbin"
if old_pid != server.pid
  begin
    sig = (worker.nr + 1) >= server.worker_processes ? :QUIT : :TTOU
    Process.kill(sig, File.read(old_pid).to_i)
  rescue Errno::ENOENT, Errno::ESRCH
  end
end
```

As opposed to completely stopping and re-starting your Unicorn processes, this
technique will gradually replace workers and kill the old master process with no
interruption for your users, as there are always 5 workers that are ready to respond.

Of course, you will still need downtime for database migrations, unless you can
adapt your application code to handle the old and new database schemas at the same
time.

### Running Unicorn

You can manually run Unicorn as a daemon with this configuration like this:

```bash
unicorn -c config/unicorn.rb -E production -D
```

Stop it by sending a `QUIT` signal to the master process.
See [Unicorn Signals](http://unicorn.bogomips.org/SIGNALS.html) for more information.

<a name="god"></a>
## God Configuration

On occasion, I've had Unicorn-powered applications die on me due to bugs or memory issues.
My favorite solution is to use God to restart them when that happens.
God will watch the Unicorn master process, start it when it's not running, restart it
when certain conditions are met, and allow you to easily stop/restart when needed.

The following configuration manages this and notifies me by mail when anything goes wrong.
I initially had trouble understanding the God transition syntax, so I added more comments for clarification.

```rb
rails_root = "/path/to/app"
pid_file = "#{rails_root}/tmp/pids/unicorn.pid"

# Notification e-mail configuration.
# Check out the godrb website for more notification options.
God::Contacts::Email.defaults do |d|
  d.from_email = "god@example.com"
  d.from_name = "God"
  d.delivery_method = :sendmail
end

# You can define several people to notify.
# Each transition can be configured to send a notification
# to one person (name) or an entire group (group).
God.contact :email do |c|
  c.name = "You"
  c.group = "developers"
  c.to_email = "you@example.com"
end

God.watch do |w|

  # The name of the process.
  # You can then use it with god commands such as start/stop/restart.
  w.name = "myapp-unicorn"

  # Use the process group if you want to start/stop/restart multiple processes at once.
  w.group = "myapp"

  # Environment variables to set before starting the process.
  w.env = { 'RAILS_ENV' => 'production' }

  # Start, stop and restart commands for the process.
  # Here, we use unicorn to start the app and send signals to stop and restart.
  w.start = "unicorn -c #{rails_root}/config/unicorn.rb -E production -D"
  w.stop = "kill -QUIT `cat #{pid_file}`"
  w.restart = "kill -USR2 `cat #{pid_file}`" # hot deploy

  # Working directory where commands will be run.
  w.dir = rails_root

  # Where unicorn stores its PID file. God uses this to track the process.
  w.pid_file = pid_file

  # Clean stale PID files before starting.
  w.behavior :clean_pid_file

  # How often God will check the process.
  # All transitions defined below are checked at this frequency.
  w.interval = 30.seconds

  # Wait 15 seconds before checking if Unicorn has started or restarted successfully.
  w.start_grace = 15.seconds
  w.restart_grace = 15.seconds

  # Determine the state on startup.
  # When God starts, the watch is in the init state. This and all further transitions
  # are checked every interval to determine whether the state has changed.
  w.transition(:init, { true => :up, false => :start }) do |on|

    # Transition from the init state to the up state if the process is already running,
    # or to the start state if it's not.
    on.condition(:process_running) do |c|
      c.running = true
    end
  end

  # Determine when the process has finished starting:
  w.transition([:start, :restart], :up) do |on|

    # Transition from the start or restart state
    # to the up state if the process is running.
    on.condition(:process_running) do |c|
      c.running = true
    end

    # Try checking the process 3 times then transition
    # to the start state again if it hasn't started.
    on.condition(:tries) do |c|
      c.times = 3
      c.transition = :start
    end

    # With the previous configuration, this will start checking whether the process
    # has started 15 seconds after running the start/restart command (start grace).
    # After the first check, it will try checking two more times over 60 seconds
    # (twice the interval), then transition to the  start state if the process
    # hasn't started.
  end

  # Start the process if it's not running.
  w.transition(:up, :start) do |on|

    # If the process isn't running, notify developers
    # and transition from the up to the start state.
    on.condition(:process_running) do |c|
      c.running = false
      c.notify = 'developers'
    end
  end

  # Restart if memory or cpu is too high.
  w.restart_if do |restart|

    restart.condition(:memory_usage) do |c|
      c.above = 150.megabytes
      c.times = [3, 5] # 3 out of 5 intervals
      c.notify = 'developers'
    end

    restart.condition(:cpu_usage) do |c|
      c.above = 50.percent
      c.times = 5
      c.notify = 'developers'
    end
  end

  # Safeguard against multiple restarts.
  w.lifecycle do |on|

    on.condition(:flapping) do |c|
      c.notify = 'developers'

      # If the process transitions to the start or restart state 5 times within
      # 30 minutes, notify developers and transition to the unmonitored state.
      c.to_state = [:start, :restart]
      c.times = 5
      c.within = 30.minutes
      c.transition = :unmonitored

      # Retry monitoring in 10 minutes.
      c.retry_in = 10.minutes

      # If flapping is detected 5 times within 10 hours, notify developers and
      # give up (the process will have to be restarted manually).
      c.retry_times = 5
      c.retry_within = 10.hours
    end
  end
end
```

In this configuration, I check whether the process has died and needs to be restarted with polling.
But God also has native support for kqueue/netlink events on BSD/Darwin/Linux systems.
Instead of using the process\_running condition to poll for the status of the process,
you can use the process\_exits condition that will be notified immediately upon the exit of the process.
This means less load on your system and shorter downtime after a crash.

```rb
# Start if the process is not running.
w.transition(:up, :start) do |on|
  on.condition(:process_exits)
end
```

To do this, you must run God as root.
In my case, I needed to run God as an unprivileged user so it wasn't an option.

You can run god as a daemon with this configuration like this:

```bash
god -c config/god.rb -l tmp/logs/god.log -P tmp/pids/god.pid
```

<a name="nginx"></a>
## Nginx Configuration

Once you've launched God and it's started your app with Unicorn, you need to expose it to the world.
Unicorn is best at serving local clients, so we'll put Nginx in front of it.
Nginx will take care of buffering the request and response between Unicorn and slows clients.

The following is a complete Nginx configuration with a server definition for the application.

{% codeblock lang:text %}
user nginx;
worker_processes 5;

events {
  worker_connections 1024;
}

http {
  include mime.types;
  default_type application/octet-stream;

  sendfile on;

  keepalive_timeout 65;

  # Unicorn cluster. This is simply the path to the socket.
  # Load balancing is done entirely by the operating system kernel.
  upstream myapp_cluster {
    server unix:/path/to/app/tmp/sockets/unicorn.sock;
  }

  # Serve the app with support for a maintenance page and caching.
  server {

    # SSL configuration.
    listen 443 ssl;
    ssl_certificate /path/to/server.crt;
    ssl_certificate_key /path/to/server.key;

    server_name example.com;
    root /path/to/app/public;

    location / {
      
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header X-Forwarded-Proto https;
      proxy_set_header Host $http_host;
      proxy_redirect off;

      # Set maintenance mode if maintenance directory exists...
      if (-d $document_root/maintenance) {
        set $maintenance 1;
      }
      # but serve everything under the public maintenance directory
      if ( $uri ~ ^/maintenance/ ) {
        set $maintenance 0;
      }
      # and serve everything to users with the bypass_maintenance cookie
      # (use this to be able to access the application during maintenance)
      if ( $http_cookie ~* "bypass_maintenance" ) {
        set $maintenance 0;
      }
      # If maintenance mode is set, serve the maintenance page.
      if ( $maintenance ) {
        rewrite (.*) /maintenance/index.html last;
      }

      # Serve cached index if it exists.
      if (-f cache/$request_filename/index.html) {
        rewrite (.*) $1/index.html break;
      }
      # Serve cached page if it exists.
      if (-f cache/$request_filename.html) {
        rewrite (.*) $1.html break;
      }

      # Pass request to unicorn.
      if (!-f $request_filename) {
        proxy_pass http://myapp_cluster;
        break;
      }
    }
  }
}
{% endcodeblock %}
