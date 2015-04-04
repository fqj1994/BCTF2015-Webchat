-module(webchat_sup).
-behaviour(supervisor).

-export([start_link/0]).
-export([init/1]).

-include("conf.hrl").

start_link() ->
	supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
    pg2:create(onlineuser),
    emysql:add_pool(main_pool, [{size, 50}, {user, ?MYSQL_USER}, {password, ?MYSQL_PASS}, {database, "chatserv"}, {encoding, utf8}]),
    {ok_packet, _, _, _, _, _, _} = emysql:execute(main_pool, <<"CREATE TABLE IF NOT EXISTS chatlog (id INT PRIMARY KEY AUTO_INCREMENT, content text)">>),
    emysql:execute(main_pool, <<"TRUNCATE TABLE chatlog">>),
    DispatchHTTP = cowboy_router:compile([{'_', [{[<<"/">>], cowboy_static, {priv_file, webchat, "static/index.html"}},
                                                 {[<<"/review">>], adm_review, []},
                                                 {[<<"/ws">>], ws_chat, []}
                                                ]}]),
    cowboy:start_http(webchatserv, 100, [{max_connections, 1024}, {port, 9991}], [{env, [{dispatch, DispatchHTTP}]}]),
    VictimProc = spawn(victim, loop, [0]),
    VictimProc ! doit,
	Procs = [],
	{ok, {{one_for_one, 1, 5}, Procs}}.
