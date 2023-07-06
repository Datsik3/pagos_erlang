-module(login_handler).

-behavior(cowboy_handler).

-export([init/2]).

init(Req0=#{method := <<"GET">>}, State) ->
  FilePath = code:priv_dir(pagos) ++ "/login.html",
  Content = webutil:load_html(FilePath),
  Req = cowboy_req:reply(200,
    #{<<"content-type">> => <<"text/html; charset=UTF-8">>}, Content, Req0),
  {ok, Req, State};

init(Req0=#{method := <<"POST">>}, State) ->
    Init = pagos:init_test(),
    Info = pagos:get_data(Init),
   io:format("Inforecibida: ~p~n", [Info]),
    {ok, [{JString, true}], _} = cowboy_req:read_urlencoded_body(Req0),
    Proplist = jsx:decode(JString),
    Data =  proplists:from_map(Proplist),
    Password = proplists:get_value(<<"password">>, Data),
    Username = proplists:get_value(<<"username">>, Data),
    case pagos:auth_test(Username,Password, Init) of
        true ->
          io:format("Autenticación exitosa.~n"),
          Json = jsx:encode(Info),
          io:format("Estado (JSON): ~s~n", [Json]),
          Response = cowboy_req:reply(200,#{<<"content-type">> => <<"application/json; charset=UTF-8">>},Json,Req0),
          Req = Response;
       false ->
          io:format("Credenciales incorrectas. Inténtelo de nuevo.~n"),
          Response = cowboy_req:reply(401,#{<<"content-type">> => <<"application/json; charset=UTF-8">>},Req0),
          Req = Response
    end,
   
    {ok, Req, State}.




