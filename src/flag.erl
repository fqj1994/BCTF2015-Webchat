-module(flag).

-export([flag/0, flagb/0]).


flag() ->
    <<"BCTF{xss_is_not_that_difficult_right}">>.

flagb() ->
    base64:encode(flag()).
