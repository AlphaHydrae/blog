---
layout: post
title: How to create a temporary directory in a shell script
date: '2021-02-06 14:11:43 +0100'
comments: true
today:
  type: learned
  past: true
categories: programming
tags: bash shell
versions:
  bash: 3.2.57
  mac-os: 10.14.6
---

Sometimes when you write a shell script, you need to temporarily save files
somewhere, temporarily clone a Git repo, etc. This temporary data should be
deleted once the script has completed.

<!-- more -->

## Create a temporary directory

You can use [the `mktemp` command][mktemp] to create a temporary file or
directory in the appropriate location depending on the operating system:

```bash
$> mktemp -d -t my-script
/var/folders/a0/8alqx_yap8dl30000ap/T/my-script.J3Fv0NWl
```

The `-d` option creates a directory instead of a file (the default).

The `-t <prefix>` option specifies a prefix so that your temporary directory is
named after your script and with a random suffix. It will be created in your
operating system's standard location for temporary files (defined by [the
`$TMPDIR` environment variable][tmpdir]).

The directory is created with mode `0700` by default, meaning it should only be
accessible by you:

```bash
$> ls -la "$tmp_dir"
total 0
drwx------   2 you  your-group    64 Feb  6 17:19 .
drwx------@ 98 you  your-group  3136 Feb  6 17:19 ..
```

You can store this temporary directory in a variable:

```bash
tmp_dir=$( mktemp -d -t my-script )
```

## Define a cleanup function

This function will clean up the temporary directory, making sure it exists first
(in case the `mktemp` command failed):

```bash
clean_up() {
  test -d "$tmp_dir" && rm -fr "$tmp_dir"
}
```

## Automatically clean up on exit

You don't want to call this cleanup function manually. Your script could fail
before it is completed. It could receive a signal and exit.

However, you can use [Bash's built-in `trap` command][trap] to catch the `EXIT`
pseudo-signal. Your script will receive this signal when it closes, whether
successfully, unsuccessfully or due to an interrupt (e.g. the user hitting
`Ctrl-C`).

```bash
trap "clean_up $tmp_dir" EXIT
```

## Do the magic

You can now write the rest of your script and put whatever you want in the
temporary directory, safe in the knowledge that it will be automatically cleaned
up at the end.

Here's the complete version:

```bash
#!/usr/bin/env bash

clean_up() {
  test -d "$tmp_dir" && rm -fr "$tmp_dir"
}

tmp_dir=$( mktemp -d -t my-script )
trap "clean_up $tmp_dir" EXIT

echo Do the magic...
```

[mktemp]: https://linux.die.net/man/1/mktemp
[tmpdir]: https://en.wikipedia.org/wiki/TMPDIR
[trap]: https://man7.org/linux/man-pages/man1/trap.1p.html
