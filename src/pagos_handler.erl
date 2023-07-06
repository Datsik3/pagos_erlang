-module(pagos_handler).

-behavior(cowboy_handler).

-export([init/2]).

init(Req0=#{method := <<"GET">>}, State) ->
  FilePath = code:priv_dir(pagos) ++ "/home.html",
  Content = webutil:load_html(FilePath),
  Req = cowboy_req:reply(200,
    #{<<"content-type">> => <<"text/html; charset=UTF-8">>}, Content, Req0),
  {ok, Req, State};

init(Req0=#{method := <<"POST">>}, State) ->
  {ok, [{OrderId, true}], _} = cowboy_req:read_urlencoded_body(Req0),
  Proplist = jsx:decode(OrderId),
  Data =  proplists:from_map(Proplist),
  Order = proplists:get_value(<<"orderId">>, Data),
  io:format("Orden: ~p ~n",[Order]),
  pagos:handle_cancel_web(Order,pagos:init_test()),
  Req = cowboy_req:reply(200,#{<<"content-type">> => <<"application/json; charset=UTF-8">>},Req0),
  {ok, Req, State}.





