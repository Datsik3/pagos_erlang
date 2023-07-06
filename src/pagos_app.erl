%%%-------------------------------------------------------------------
%% @doc pagos public API
%% @end
%%%-------------------------------------------------------------------

-module(pagos_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    Dispatch = cowboy_router:compile([{'_', 
            [
                {"/login", login_handler,[]},
                {"/home", pagos_handler,[]},
                {"/home/payment", pay_handler,[]},
                {"/styles/[...]", cowboy_static, {priv_dir, pagos, "styles"}},
                {"/javascript/[...]", cowboy_static, {priv_dir, pagos, "javascript"}}
        ]}]),
    {ok, _} = cowboy:start_clear(my_http_listener,
        [{port, 8080}],
        #{env => #{dispatch => Dispatch}}
        ),    

    pagos_sup:start_link().

stop(_State) ->
    ok.

%% internal functions