-module(dijkstra).
-export([update/4,iterate/3,table/2, route/2]).

entry(_,[]) -> 0;
entry(Node,[{Node, Hops, _}|_]) -> Hops;
entry(Node,[_|Rest]) -> entry(Node,Rest).

replace(Node, N, Gateway, [{Node1, M, Gateway1}|Rest])when N>M , M/=inf-> [{Node1,M,Gateway1}|replace(Node,N,Gateway, Rest)];
replace(Node, N, Gateway, Rest) -> [{Node, N, Gateway}|lists:keydelete(Node,1,Rest)].

update(Node, N, Gateway, Sorted) ->
       	X = entry(Node, Sorted),	
	if 
		X > N -> replace(Node, N, Gateway, Sorted);
		true -> Sorted
	end.

iterate([], _, Table) -> Table;

iterate([{_,inf,_}|_],_,Table) -> Table;

iterate([{Node, N, Gateway}|Rest], Map, Table) ->
	List = map:reachable(Node, Map),
	Updated = lists:foldl((fun(Node1, Sorted) -> update(Node1, N+1, Gateway, Sorted) end), Rest, List),
	iterate(Updated, Map, [{Node,Gateway}|Table]).


table(Gateways, Map) ->
       	Nodes = map:all_nodes(Map),
	DummyList = lists:foldl((fun(Node,List) -> [{Node,inf, unknown}|List] end), [], Nodes),
	InitList = lists:foldl((fun(Gateway, List) -> update(Gateway, 0, Gateway, List) end), DummyList, Gateways),
	iterate(InitList, Map, []).

route(_, []) -> notfound;
route(Node, [{Node, Gateway}|_]) -> {ok, Gateway};
route(Node, [_|List]) -> route(Node, List).

	
