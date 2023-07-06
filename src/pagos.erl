- module(pagos).
- export([authenticate_user/3,get_data/1,auth_test/3,handle_payment_web/3,init_state/0,handle_order/1,find_order/2,init_test/0, handle_requests/1, handle_login/1,remove_order/2,handle_cancel/1,handle_cancel_web/2,get_data_user/1]).

- record(state,{ username, password,orders=[]}). 

init_state()->
    State1 = #state{username = <<"alex">>, password = <<"1234">>, orders = [  {"orden1", "Laptop Dell i5", "500"}, {"orden2", "ASUS E410 14", "1200"}]},
    State2 = #state{username = "user2", password = "password2",  orders = [  {"orden4", "Laptop Dell i5", "500"}, {"orden5", "ASUS E410 14", "1200"}]},
    State3 = #state{username = "user3", password = "password3",  orders = [  {"orden6", "Laptop Dell i5", "500"}, {"orden7", "ASUS E410 14", "1200"}]},
    [State1, State2, State3].

init_test()->
     #state{username = <<"alex">>, password = <<"1234">>, orders = [  {<<"orden1">>, <<"Laptop Dell i5">>, <<"500">>}, {<<"orden2">>, <<"ASUS E410 14">>, <<"1200">>}]}.

get_data(#state{username = User, password = Pass, orders = Ordenes}) ->
    JsonOrders = lists:map(fun({OrderId, Name, Price}) ->
                               #{<<"id">> => OrderId,
                                 <<"nombre">> => Name,
                                 <<"precio">> => Price}
                           end, Ordenes),
    Json = [{<<"username">>, User}, {<<"password">>, Pass}, {<<"orders">>, JsonOrders}],
    Json.


auth_test(Username, Password,#state{username = User,password = Pass}) ->
    User == Username andalso Pass == Password.

handle_requests(State) ->
      Request = string:trim(io:get_line("¿Que desea hacer?: (ver/pagar/cancelar/salir): ")),
    case Request of
        "ver" -> handle_order(State);
        "pagar" -> handle_payment(State);
        "cancelar" -> handle_cancel(State);
        "salir" -> io:format("Sistema de pagos finalizado.~n");
        _ -> io:format("Solicitud no válida. Inténtelo de nuevo.~n")
    end.

handle_login(States) ->
    io:format("Inicie Sesion para Continuar.~n"),
    Username = string:trim(io:get_line("Ingrese su nombre de usuario: ")),
    Password = string:trim(io:get_line("Ingrese su contraseña: ")),
    authenticate_user(Username, Password, States).


find_order(OrderId,#state{orders=Orders}) ->
    case lists:keyfind(OrderId, 1, Orders) of
        false ->
            not_found;
        Order ->
            {ok, Order}
    end.

handle_order(State) ->
    io:format("Ordenes Disponibles:~n"),
    lists:foreach(
        fun({OrderId, Computer, Amount}) ->
            io:format("  - Orden: ~p  Computadora:~p  Precio: ~p~n", [OrderId, Computer, Amount])
        end,
        State#state.orders
    ),
    handle_requests(State).

handle_payment_web(OrderId,PayMethod,State) ->
    io:format("Orden recibida: ~p~n", [OrderId]),
    case find_order(OrderId,State) of
        {ok, Order} ->
            case PayMethod of
                <<"Tarjeta">> ->
                    io:format("Realizando pago con tarjeta para la orden ~p~n", [Order]),
                    remove_order(Order, State);
                <<"Efectivo" >>->
                    io:format("Realizando pago en efectivo para la orden ~p~n", [Order]),
                    remove_order(Order, State);
                _ ->
                    io:format("Método de pago no válido. Inténtelo de nuevo.~n")
            end,
            remove_order(Order, State);
        not_found ->
            io:format("Orden no encontrada. Inténtelo de nuevo.~n")
    end.


handle_payment(State) ->
    OrderId = string:trim(io:get_line("Ingrese el ID de la orden que desea pagar: ")),
    io:format("Orden recibida: ~p~n", [OrderId]),
    case find_order(OrderId,State) of
        {ok, Order} ->
            PayMethod = string:trim(io:get_line("Ingrese el método de pago: ")),
            case PayMethod of
                "Tarjeta" ->
                    io:format("Realizando pago con tarjeta para la orden ~p~n", [Order]),
                    handle_requests(remove_order(Order, State));
                "Efectivo" ->
                    io:format("Realizando pago en efectivo para la orden ~p~n", [Order]),
                    handle_requests(remove_order(Order, State));
                _ ->
                    io:format("Método de pago no válido. Inténtelo de nuevo.~n"),
                    handle_requests(State)
            end,
            handle_requests(remove_order(Order, State));
        not_found ->
            io:format("Orden no encontrada. Inténtelo de nuevo.~n"),
            handle_requests(State)
    end.

handle_cancel(State) ->
    OrderId = io:get_line("Ingrese el ID de la orden que desea cancelar: "),
    case find_order(string:trim(OrderId),State) of
        {ok, Order} ->
            io:format("Cancelando la orden ~p~n", [Order]),
            handle_requests(remove_order(Order, State));
        not_found ->
            io:format("Orden no encontrada. Inténtelo de nuevo.~n"),
            handle_requests(State)
    end.

handle_cancel_web(OrderId,State) ->
    case find_order(string:trim(OrderId),State) of
        {ok, Order} ->
            io:format("Cancelando la orden ~p~n", [Order]),
            remove_order(Order, State);
        not_found ->
            io:format("Orden no encontrada. Inténtelo de nuevo.~n")
    end.

get_data_user(State)->
     JsonState = #{<<"username">> => State#state.username,
                  <<"password">> => State#state.password,
                  <<"orders">> => State#state.orders},
    Json = jsx:encode(JsonState),
    io:format("Estado (JSON): ~s~n", [Json]),
    handle_requests(State).

authenticate_user(Username, Password, States) ->
    {ValidCredentials, _} = lists:foldl(
        fun(State, {Valid, Acc}) ->
            case {State#state.username, State#state.password} of
                {Username, Password} ->
                    io:format("Autenticación exitosa.~n"),
                    {true, handle_requests(State)};
                _ ->
                    {Valid, Acc}
            end
        end,
        {false, ok},
        States
    ),
    case ValidCredentials of
        true ->
            true;
        _ ->
            io:format("Credenciales incorrectas. Inténtelo de nuevo.~n")
    end.

remove_order(Order, State) ->
    State#state{orders = lists:delete(Order, State#state.orders)}.