-module(victim).

-export([loop/1]).


process([[NewId, NewMsg] | Tail]) ->
    case NewMsg of
        undefined ->
            ok;
        _ ->
            io:format("process: init: ~p ~p~n", [NewId, NewMsg]),
            case re:run(NewMsg, "^[a-z0-9(),' +.;A-Z:]*$") of
                {match, _} ->
                    if 
                        NewId rem 10 =:= 0 ->
                            BNewId = integer_to_binary(NewId),
                            lists:map(
                              fun(P) -> P ! {msg, <<"&lt;Notice&gt; Admin has reviewed up to message ", BNewId/binary>>} end,
                              pg2:get_members(onlineuser));
                        true ->
                            ok
                    end;
                _ ->
                    io:format("process: browser: ~p ~p~n", [NewId, NewMsg]),
                    Password = flag:flagb(),
                    Ret = os:cmd("timeout -s KILL 10 xvfb-run firefox \"http://127.0.0.1:9991/review?pass=" ++ binary_to_list(Password) ++ "&id=" ++ integer_to_list(NewId) ++ "\" 2>&1"),
                    io:format("browser ret: ~p~n", [Ret]),
                    os:cmd("killall -9 chromium")
                    %BNewId = integer_to_binary(NewId),
                    %lists:map(
                    %  fun(P) -> P ! {msg, <<"&lt;Notice&gt; Admin has reviewed up to message ", BNewId/binary>>} end,
                    %  pg2:get_members(onlineuser))

            end
    end,
    if 
        length(Tail) > 0 ->
            process(Tail);
        true -> 
            NewId
    end.

loop(Id) ->
    BId = integer_to_binary(Id),
    NewId = receive 
        doit ->
            case emysql:execute(main_pool, <<"select id, content from chatlog where id >", BId/binary>>) of
            %case emysql:execute(main_pool, <<"select max(id), content from chatlog where id >", BId/binary, " group by content order by id;">>) of
                {result_packet, _, _, Results, _} ->
                    if
                        length(Results) > 0 ->
                            NNId = process(Results),
                            self() ! doit,
                            NNId;
                        true ->
                            timer:send_after(1000, doit),
                            Id
                    end;
                _ ->
                    timer:send_after(1000, doit),
                    Id
            end
    end,
    loop(NewId).
