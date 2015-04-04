-module(adm_review).

-compile([export_all]).

init(_Transport, Req, _) ->
    {ok, Req, undef}.

handle(Req, State) ->
    io:format("Got req review~n"),
    {Password, Req2} = cowboy_req:qs_val(<<"pass">>, Req),
    Password = flag:flagb(),
    {ReviewId, Req3} = cowboy_req:qs_val(<<"id">>, Req2),
    {ok, Req5} = 
    case cowboy_req:peer(Req3) of
        {{{127,_,_,_}, _}, Req4} ->
            {result_packet, _, _, [[ActualMsg]], _} = emysql:execute(main_pool, <<"SELECT content FROM chatlog WHERE id = ", ReviewId/binary>>),
            cowboy_req:reply(200, [
                                   {<<"content-type">>, <<"text/html">>}
                                  ], <<"<html><head><title>Review</title></head><body>Id: ", ReviewId/binary, "<br/>Message:<br/><pre>", ActualMsg/binary, "</pre></body></html>">>, Req4);
        {E, Req4} ->
            io:format("~p", [E]),
            cowboy_req:reply(200, [
                                   {<<"content-type">>, <<"text/html">>}
                                  ], <<"<html><head><title>Review</title></head><body>Only admin in local network with correct password can review chat logs. But you've already had the flag you want,right?</body></html>">>, Req4)
    end,
    {ok, Req5, State}.

terminate(_, _, _) -> ok.
