-module(map).
-export([new/0,update/3, reachable/2, all_nodes/1]).

new()-> [].

update(Node, Links, []) -> [ {Node, Links} ];

update(Node, Links, [ {Node, _} | R ]) -> [ {Node, Links} | R ];

update(Node, Links, [E|Rest]) -> [E|update(Node, Links, Rest)].

reachable(Node, Map) ->
	case lists:keysearch(Node, 1, Map) of
		false -> [];
		{value,{_,Result}} -> Result
	end.
insert_no_dupe(E, []) -> [E];
insert_no_dupe(E, [E|List]) -> [E|List];
insert_no_dupe(E, [E1|List]) -> [E1|insert_no_dupe(E, List)].
merge_no_dupe(List1, List2) -> 
	lists:foldl((fun(X,Y)->insert_no_dupe(X,Y) end), List2, List1).

all_nodes([]) -> [];

all_nodes([{Node, Links}|Rest]) ->
	merge_no_dupe([Node|Links], all_nodes(Rest)).


