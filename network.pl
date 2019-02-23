/*
** initialise social network
**	ring
**	fully connected
**	random -- G(N,P) each pair of N nodes in Graph G is connected with probability P
*/

init_socnet( Agents, ring ) :-
        link_neighbours( Agents, Agents ).
init_socnet( Agents, fully_connected ) :-
	link_all2all( Agents, Agents ).
init_socnet( Agents, random ) :-
	link_all2some( Agents, Agents ).

init_socnet( Agents, random1 ) :-
	link_all2some( Agents ),
	at_least1_link( Agents, Agents ).
	

link_neighbours( [], _ ).
link_neighbours( [H|T], Agents ) :-
        neighbours( H, Agents, Prev, Next ),
        add_path_val( H, socnet, Next ),
        add_path_val( H, socnet, Prev ),
        link_neighbours( T, Agents ).

neighbours( A, [A|Rest], Prev, Next ) :-
        !,
        Rest = [Next|_],
        last( Rest, Prev ).
neighbours( A, As, Prev, Next ) :-
        append( _, [Prev,A,Next|_], As ), !.
neighbours( A, [Next|Rest], Prev, Next ) :-
        append( _, [Prev,A], Rest ).


link_all2all( [], _ ).
link_all2all( [A|Rest], Agents ) :-
	link_one2rest( A, Agents ),
	link_all2all( Rest, Agents ).

link_one2rest( _, [] ).
link_one2rest( A, [A|T] ) :-
	link_one2rest( A, T ), !.
link_one2rest( A, [H|T] ) :-
	add_path_val( A, socnet, H ),
	link_one2rest( A, T ).

link_all2some( [] ).
link_all2some( [A|Rest] ) :-
	link_one2some( A, Rest ),
	link_all2some( Rest ).

link_one2some( _, [] ).
link_one2some( A, [H|T] ) :-
	random_link_prob( P ),
	maybe( P ), !,
	link_agents( A, H ),
	link_one2some( A, T ).
link_one2some( A, [_|T] ) :-
	link_one2some( A, T ).

link_agents( A1, A2 ) :-
	get_path_val( A2, socnet, SN ),
	member( A1, SN ), !.
link_agents( A1, A2 ) :-
	add_path_val( A1, socnet, A2 ),
	add_path_val( A2, socnet, A1 ).

random_link_prob( 0.25 ).

	
at_least1_link( [], _ ).
at_least1_link( [A|Rest], Agents ) :-
	get_path_val( A, socnet, [] ), !,
	delete( Agents, A, AgentsNotA ),
	random_member( X, AgentsNotA ),
	link_agents( A, X ),
	at_least1_link( Rest, Agents ).
at_least1_link( [_|Rest], Agents ) :-
	at_least1_link( Rest, Agents ).
