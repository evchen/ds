-module(routy).

-export([start/2, stop/1, init/1]).

start(Reg,Name) -> 
	register(Reg, spawn(fun()-> init(Name) end)).

stop(Node) ->
	Node !stop,
	unregister(Node).

init(Name) ->
	Intf = interface:new(),
	Map = map:new(),
	Table = dijkstra:table(Intf, Map),
	Hist = hist:new(Name),
	router(Name, 0, Hist, Intf, Table, Map).

router(Name, N, Hist, Intf, Table, Map) ->

	error_logger:info_msg("router ~w~n", [Name]),
	receive

		{links, Node, R, Links} ->
			case hist:update(Node, R, Hist) of 
				{new, Hist1} -> 
					interface:broadcast({links, Node, R, Links}, Intf),
					Map1 = map:update(Node, Links, Map),
					router(Name, N, Hist1, Intf, Table, Map1);
				old ->
					router(Name, N, Hist, Intf, Table, Map)
			end;

		update -> Table1 = dijkstra:table(interface:list(Intf), Map),
			  router(Name, N, Hist, Intf, Table1, Map);

		broadcast ->
			Message= {links, Name, N, interface:list(Intf)},
			interface:broadcast(Message,Intf),
			router(Name, N+1, Hist, Intf, Table, Map);
		debug ->
			io:fwrite("message received~n");

		{add, Node, Pid} ->
			Ref = erlang:monitor(process, Pid),
			Intf1 = interface:add(Node, Ref, Pid, Intf),
			error_logger:info_msg("updated interface: ~w~n", [Intf1]),
			router(Name, N, Hist, Intf1, Table, Map);

		{remove, Node} ->
			{ok, Ref} = interface:ref(Node, Intf),
			erlang:demonitor(Ref),
			Intf1 = interface:remove(Node, Intf),
			router(Name, N, Hist, Intf1, Table, Map);

		{'DOWN', Ref, process, _, _} ->
			{ok, Down} = interface:name(Ref, Intf),
			error_logger:info_msg("~w: exit received from ~w~n", [Name, Down]),
			Intf1 = interface:remove(Down, Intf),
			router(Name, N, Hist, Intf1, Table, Map);

		{status, From} ->
			From ! {status, {Name, N, Hist, Intf, Table, Map}},
			router(Name, N, Hist, Intf, Table, Map);

		stop -> ok
	end.

