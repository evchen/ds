-module(test_spawn).
-export([start/0]).


start() -> 
	Pid = spawn(fun()-> server() end),
	Pid ! {hello1,"hello1",self()},
	receive
		_->Pid ! {hello2,"hello2",self()},
		   receive
			   _-> ok 
		   end
	end,
	exit(Pid, end_process).


server() ->
	receive 
		{hello1,Message,Pid} -> io:fwrite("~p", [Message]),
					Pid!{finished};
		{hello2,Message,Pid} -> io:fwrite("~p", [Message]),
					Pid!{finished}
	end,
	server().
