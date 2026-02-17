-define(PRINT(Var), begin io:format("\nDEBUG: ~p:~p~n~tp~n  ~tp~n\n", [?MODULE, ?LINE, ??Var, Var]), Var end).
-define(PRINTS(Var), begin io:format("\nDEBUG: ~p:~p~n~tp~n  ~ts~n\n", [?MODULE, ?LINE, ??Var, Var]), Var end).
-define(DEBUG, io:format("\nDEBUG: ~p:~p~n\n", [?MODULE, ?LINE])).

-define(NOTIMPLEMENTED, exit({notimplemented, lists:flatten(io_lib:format("Function not implemented: [~p, ~p, ~p]", [?MODULE, ?FILE, ?LINE]))})).
-define(_(Var), Var).