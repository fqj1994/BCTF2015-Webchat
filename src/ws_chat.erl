-module(ws_chat).

-compile([export_all]).

init(_Tranport, _Req, _Opts) ->
    {upgrade, protocol, cowboy_websocket}.

websocket_init(_Type, Req, _) ->
    pg2:join(onlineuser, self()),
    {ok, Req, undefined, 60000, hibernate}.

websocket_info(timeout, Req, _State) ->
    {shutdown, Req};
websocket_info({msg, Data}, Req, State) ->
    {reply, {text, <<"m", Data/binary>>}, Req, State, hibernate}.

filter_msg(Data) ->
    case re:run(Data, "^[a-z0-9]+: [a-z0-9(),' +.;A-Z]*$") of
        {match, _} ->
            match;
        _ ->
            filtered
    end.

websocket_handle({text, Data}, Req, State) ->
    case filter_msg(Data) of 
        filtered ->  
            {reply, {text, <<"eYour nickname or message contains invalid character.">>}, Req, State, hibernate};
        _ ->
            LogResult = emysql:execute(main_pool, <<"INSERT INTO chatlog (content) VALUES('", Data/binary, "');">>),
            case LogResult of
                {ok_packet, _, _, InsertId, _, _, _} ->
                    BInsertId = erlang:integer_to_binary(InsertId),
                    {result_packet, _, _, [[ActualMsg]], _} = emysql:execute(main_pool, <<"SELECT content FROM chatlog WHERE id = ", BInsertId/binary>>),
                    self()! {msg, <<BInsertId/binary, " ", ActualMsg/binary>>},
                    %lists:map(
                    %  fun(P) -> P ! {msg, <<BInsertId/binary, " ", ActualMsg/binary>>} end,
                    %  pg2:get_members(onlineuser)),
                    {reply, {text, <<"s">>}, Req, State, hibernate};
                {error_packet, _, _, _, SErrorMsg}->
                    ErrorMsg = erlang:list_to_binary(SErrorMsg),
                    {reply, {text, <<"eDatabase error: ", ErrorMsg/binary>>}, Req, State, hibernate};
                _ ->
                    {reply, {text, <<"eUnknown error">>}, Req, State, hibernate}

            end
    end.

terminate(_, _, _) -> ok.

websocket_terminate(_, _, _) -> pg2:leave(onlineuser, self()), ok.
