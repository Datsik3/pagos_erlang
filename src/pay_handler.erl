-module(pay_handler).

-behavior(cowboy_handler).

-export([init/2]).

init(Req0=#{method := <<"POST">>}, State) ->
  {ok, [{Data, true}], _} = cowboy_req:read_urlencoded_body(Req0),
  Proplist = jsx:decode(Data),
  Object =  proplists:from_map(Proplist),
  Metodo = proplists:get_value(<<"metodo">>, Object),
  OrderId = proplists:get_value(<<"orderId">>, Object),
  io:format("Orden: ~p ~n",[Object]),
  pagos:handle_payment_web(OrderId,Metodo,pagos:init_test()),
  Req = cowboy_req:reply(200,#{<<"content-type">> => <<"application/json; charset=UTF-8">>},Req0),
  {ok, Req, State}.





