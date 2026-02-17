%%%-------------------------------------------------------------------
%%% @author evgeny
%%% @copyright (C) 2026, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 17. февр. 2026 18:04
%%%-------------------------------------------------------------------
-module(cbet_math).
-author("evgeny").
-include("cbet_matrix.hrl").

%% API
-export([mulv/2, mulm/2, transpose/1, diag/1, diag/3, identity/0, inverse/1,
	frexp/1, safe_pow/2, sign/1, sign_pow/2, scalev/2, divv/2, addv/2, subv/2,
	degrees/1, floor_mod/2, radians/1, applyv/2]).


applyv(?VECTOR3(V1, V2, V3), Fun) ->
	?VECTOR3( Fun(V1), Fun(V2), Fun(V3)).


divv(?VECTOR3(V11, V12, V13), ?VECTOR3(V21, V22, V23)) ->
	?VECTOR3(V11 / V21, V12 / V22, V13 / V23).


scalev(?VECTOR3(V1, V2, V3), S)->
	?VECTOR3(V1*S, V2 *S, V3 *S).


addv(?VECTOR3(V11, V12, V13), ?VECTOR3(V21, V22, V23)) ->
	?VECTOR3(V11 + V21, V12 + V22, V13 + V23).


subv(?VECTOR3(V11, V12, V13), ?VECTOR3(V21, V22, V23)) ->
	?VECTOR3(V11 - V21, V12 - V22, V13 - V23).


mulv(
	?MATRIX33(
		A11, A12, A13,
		A21, A22, A23,
		A31, A32, A33
	),
	?VECTOR3(V1, V2, V3)) ->
	?VECTOR3(
		A11 * V1 + A12 * V2 + A13 * V3,
		A21 * V1 + A22 * V2 + A23 * V3,
		A31 * V1 + A32 * V2 + A33 * V3
	);

mulv(?VECTOR3(V11, V12, V13), ?VECTOR3(V21, V22, V23)) ->
	?VECTOR3(V11 * V21, V12 * V22, V13 * V23).


mulm(
	?MATRIX33(
		A11, A12, A13,
		A21, A22, A23,
		A31, A32, A33
	),
	?MATRIX33(
		B11, B12, B13,
		B21, B22, B23,
		B31, B32, B33
	)) ->
	?MATRIX33(
		A11 * B11 + A12 * B21 + A13 * B31,
		A11 * B12 + A12 * B22 + A13 * B32,
		A11 * B13 + A12 * B23 + A13 * B33,

		A21 * B11 + A22 * B21 + A23 * B31,
		A21 * B12 + A22 * B22 + A23 * B32,
		A21 * B13 + A22 * B23 + A23 * B33,

		A31 * B11 + A32 * B21 + A33 * B31,
		A31 * B12 + A32 * B22 + A33 * B32,
		A31 * B13 + A32 * B23 + A33 * B33
	).


transpose(
	?MATRIX33(
		A11, A12, A13,
		A21, A22, A23,
		A31, A32, A33
	)
) ->
	?MATRIX33(
		A11, A21, A31,
		A12, A22, A32,
		A13, A23, A33
	).


diag(?VECTOR3(D1, D2, D3)) ->
	diag(D1, D2, D3).

diag(D1, D2, D3) ->
    ?MATRIX33(
        D1, 0,  0,
        0,  D2, 0,
        0,  0,  D3
    ).


identity() ->
    ?MATRIX33(
        1.0, 0.0, 0.0,
        0.0, 1.0, 0.0,
        0.0, 0.0, 1.0
    ).


inverse(
	?MATRIX33(
		A11, A12, A13,
		A21, A22, A23,
		A31, A32, A33
	) = M) ->
	Det = A11 * (A22 * A33 - A23 * A32)
		- A12 * (A21 * A33 - A23 * A31)
		+ A13 * (A21 * A32 - A22 * A31),

	if
		abs(Det) < ?EPSILON ->
			error({singular_matrix, M});
		true ->
			InvDet = 1.0 / Det,

			?MATRIX33(
				(A22 * A33 - A23 * A32) * InvDet,
				(A13 * A32 - A12 * A33) * InvDet,
				(A12 * A23 - A13 * A22) * InvDet,

				(A23 * A31 - A21 * A33) * InvDet,
				(A11 * A33 - A13 * A31) * InvDet,
				(A13 * A21 - A11 * A23) * InvDet,

				(A21 * A32 - A22 * A31) * InvDet,
				(A12 * A31 - A11 * A32) * InvDet,
				(A11 * A22 - A12 * A21) * InvDet
			)
	end.


frexp(X) when X >= -0.0, X =< 0.0 ->
	{0.0, 0};

frexp(X) ->
	A = abs(X),
    E = math:floor(math:log2(A)),
    F = (A / math:pow(2, E)) / 2,
    {F * (X / A), trunc(E + 1)}.


safe_pow(Value, _Exp) when abs(Value) < 1.0e-5 -> 0;

safe_pow(Value, Exp) -> math:pow(Value, Exp).


sign_pow(Value, Exp) when Value < 0 ->
	-sign_pow(Value*-1, Exp);

sign_pow(Value, Exp) ->
	math:pow(Value, Exp).

sign(X) when is_number(X)->
	if
		X >= 0 -> 1;
		true -> -1
	end.

degrees(Rad) ->
	Rad * 180.0 / math:pi().

radians(Deg) ->
	Deg * math:pi() / 180.0.

floor_mod(X, Y) when is_number(X), is_number(Y) ->
    X - Y * math:floor(X / Y).