-module(test).

-export([test/0]).

test() -> routy:start(r1, stockholm),
	  routy:start(r2, lund),
	  r2 ! {add, stockholm, {r1,'sweden@192.168.0.5'}}.

