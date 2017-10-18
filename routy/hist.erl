-module(hist).
-compile(export_all).

new(Name) -> [{Name,0}].

update(Node, N, History) ->
	case lists:keyfind(Node, 1, History) of 
		{Node, M} -> 
			if 
				M>N -> old;
				true -> {new,[{Node,N}| lists:keydelete(Node, 1, History)]}
			end;
		false -> {new,[{Node,0}|History]}
	end.
