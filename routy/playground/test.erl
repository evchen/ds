-module(test).

-export([replace/1, update/1]).

make_list()-> [{a,1}, {b,2},{c,3}].

replace({Key,Value})->
	lists:keyreplace(Key, 1, make_list(), {Key,Value}).

update_fun(Sum, E) -> Sum+E. 

update(List) ->
	lists:foldl((fun(X,Y)->update_fun(X,Y) end), 0, List).
