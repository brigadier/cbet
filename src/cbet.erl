-module(cbet).

-export([adapt/4, convert/2, convert/3,
	srgbtohex/1, srgbtohex/2, srgbto8bit/1, hextosrgb/1,
	hextosrgb/2, distance/3, interpolate/5, named_color/2,
	cam16_model/5, cam16_model/4, nayatani_model/5, nayatani_model/6,
	chromaticity/1,
	hunt_model/5,
	hunt_model/6, lrv/1]).

-include("cbet_debug.hrl").
-include("cbet.hrl").
-include("cbet_matrix.hrl").
-include_lib("eunit/include/eunit.hrl").

-export_type([convert_opts/0, srgbtohex_opts/0, hextosrgb_opts/0]).

illum(?ILLUM_A) -> ?ILLUM_A_M;
illum(?ILLUM_D50) -> ?ILLUM_D50_M;
illum(?ILLUM_D55) -> ?ILLUM_D55_M;
illum(?ILLUM_D60) -> ?ILLUM_D60_M;
illum(?ILLUM_D65) -> ?ILLUM_D65_M;
illum(?ILLUM_D75) -> ?ILLUM_D75_M;
illum(?ILLUM_B) -> ?ILLUM_B_M;
illum(?ILLUM_C) -> ?ILLUM_C_M;

illum(?ILLUM_F1) -> ?ILLUM_F1_M;
illum(?ILLUM_F2) -> ?ILLUM_F2_M;
illum(?ILLUM_F3) -> ?ILLUM_F3_M;
illum(?ILLUM_F4) -> ?ILLUM_F4_M;
illum(?ILLUM_F5) -> ?ILLUM_F5_M;
illum(?ILLUM_F6) -> ?ILLUM_F6_M;
illum(?ILLUM_F7) -> ?ILLUM_F7_M;
illum(?ILLUM_F8) -> ?ILLUM_F8_M;
illum(?ILLUM_F9) -> ?ILLUM_F9_M;
illum(?ILLUM_F10) -> ?ILLUM_F10_M;
illum(?ILLUM_F11) -> ?ILLUM_F11_M;
illum(?ILLUM_F12) -> ?ILLUM_F12_M;

illum(?ILLUM_D63) -> ?ILLUM_D63_M;
illum(?ILLUM_D70) -> ?ILLUM_D70_M;
illum(?ILLUM_D93) -> ?ILLUM_D93_M;

illum(?ILLUM_F13) -> ?ILLUM_F13_M;
illum(?ILLUM_F14) -> ?ILLUM_F14_M;
illum(?ILLUM_F15) -> ?ILLUM_F15_M;
illum(?ILLUM_F16) -> ?ILLUM_F16_M;
illum(?ILLUM_F17) -> ?ILLUM_F17_M;
illum(?ILLUM_F18) -> ?ILLUM_F18_M;
illum(?ILLUM_F19) -> ?ILLUM_F19_M;
illum(?ILLUM_F20) -> ?ILLUM_F20_M;
illum(?ILLUM_F21) -> ?ILLUM_F21_M;
illum(?ILLUM_F22) -> ?ILLUM_F22_M;
illum(?ILLUM_F23) -> ?ILLUM_F23_M;
illum(?ILLUM_F24) -> ?ILLUM_F24_M;

%% 10°

illum(?ILLUM_A_10) -> ?ILLUM_A_10_M;
illum(?ILLUM_D50_10) -> ?ILLUM_D50_10_M;
illum(?ILLUM_D55_10) -> ?ILLUM_D55_10_M;
illum(?ILLUM_D60_10) -> ?ILLUM_D60_10_M;
illum(?ILLUM_D65_10) -> ?ILLUM_D65_10_M;
illum(?ILLUM_D75_10) -> ?ILLUM_D75_10_M;
illum(?ILLUM_B_10) -> ?ILLUM_B_10_M;
illum(?ILLUM_C_10) -> ?ILLUM_C_10_M;

illum(?ILLUM_F1_10) -> ?ILLUM_F1_10_M;
illum(?ILLUM_F2_10) -> ?ILLUM_F2_10_M;
illum(?ILLUM_F3_10) -> ?ILLUM_F3_10_M;
illum(?ILLUM_F4_10) -> ?ILLUM_F4_10_M;
illum(?ILLUM_F5_10) -> ?ILLUM_F5_10_M;
illum(?ILLUM_F6_10) -> ?ILLUM_F6_10_M;
illum(?ILLUM_F7_10) -> ?ILLUM_F7_10_M;
illum(?ILLUM_F8_10) -> ?ILLUM_F8_10_M;
illum(?ILLUM_F9_10) -> ?ILLUM_F9_10_M;
illum(?ILLUM_F10_10) -> ?ILLUM_F10_10_M;
illum(?ILLUM_F11_10) -> ?ILLUM_F11_10_M;
illum(?ILLUM_F12_10) -> ?ILLUM_F12_10_M;

illum(?ILLUM_D63_10) -> ?ILLUM_D63_10_M;
illum(?ILLUM_D70_10) -> ?ILLUM_D70_10_M;
illum(?ILLUM_D93_10) -> ?ILLUM_D93_10_M;

illum(?ILLUM_F13_10) -> ?ILLUM_F13_10_M;
illum(?ILLUM_F14_10) -> ?ILLUM_F14_10_M;
illum(?ILLUM_F15_10) -> ?ILLUM_F15_10_M;
illum(?ILLUM_F16_10) -> ?ILLUM_F16_10_M;
illum(?ILLUM_F17_10) -> ?ILLUM_F17_10_M;
illum(?ILLUM_F18_10) -> ?ILLUM_F18_10_M;
illum(?ILLUM_F19_10) -> ?ILLUM_F19_10_M;
illum(?ILLUM_F20_10) -> ?ILLUM_F20_10_M;
illum(?ILLUM_F21_10) -> ?ILLUM_F21_10_M;
illum(?ILLUM_F22_10) -> ?ILLUM_F22_10_M;
illum(?ILLUM_F23_10) -> ?ILLUM_F23_10_M;
illum(?ILLUM_F24_10) -> ?ILLUM_F24_10_M;
illum(?VECTOR3(IX, IY, IZ) = Illum) when is_number(IX), is_number(IY), is_number(IZ) -> Illum.

-spec chromaticity(XYZ :: {float(), float(), float()}) -> {float(), float()}.
chromaticity(?VECTOR3(X, Y, Z) = _XYZ) ->
	Tol = 1.0e-6,

	if
		X + Y + Z =< Tol ->
			{0.0, 0.0};
		true -> {
			X / (X + Y + Z),
			Y / (X + Y + Z)
		}
	end.



adapt(XYZ, White, White, _) -> XYZ;

adapt(?VECTOR3(_X, _Y, _Z) = XYZ, SourceWhiteName, TargetWhiteName, Type) ->
	%% Выбираем матрицу CAT
	{M_CAT, M_CAT_INV} =
		case Type of
			?BRADFORD -> {?BRADFORD_M, ?BRADFORD_MI};
			?VON_KRIES -> {?VON_KRIES_M, ?VON_KRIES_MI};
			?CAT02 -> {?CAT02_M, ?CAT02_MI};
			?SHARP -> {?SHARP_M, ?SHARP_MI};
			?FAIRCHILD -> {?FAIRCHILD_M, ?FAIRCHILD_MI};
			?CMCCAT97 -> {?CMCCAT97_M, ?CMCCAT97_MI};
			?CMCCAT2000 -> {?CMCCAT2000_M, ?CMCCAT2000_MI};
			?XYZ_SCALING -> {?XYZ_SCALING_M, ?XYZ_SCALING_MI};
			?HUNT -> {?HUNT_M, ?HUNT_MI};
			?ZCAM -> {?ZCAM_M, ?ZCAM_MI};
			?CAT16 -> {?CAT16_M, ?CAT16_MI}
		end,

	%% Получаем белые точки по имени
	SourceWhite = illum(SourceWhiteName),
	TargetWhite = illum(TargetWhiteName),

	%% Белые точки -> LMS
	?VECTOR3(SourceA1, SourceA2, SourceA3) = cbet_math:mulv(M_CAT, SourceWhite),
	?VECTOR3(TargetA1, TargetA2, TargetA3) = cbet_math:mulv(M_CAT, TargetWhite),

	%% Diagonal scaling matrix
	D = cbet_math:diag(
		TargetA1 / SourceA1,
		TargetA2 / SourceA2,
		TargetA3 / SourceA3
	),

	%% Итоговая матрица адаптации
	M_Adapt = cbet_math:mulm(
		cbet_math:mulm(M_CAT_INV, D),
		M_CAT
	),

	%% Применяем к XYZ
	cbet_math:mulv(M_Adapt, XYZ).


-type convert_opts() :: #{adaptation := chromatic_adaptation(), clamp := boolean()}.

-spec convert(From :: cbet_color(), To :: cbet_color()) -> cbet_color().
convert(From, To) ->
	convert(From, To, #{}).

-spec convert(From :: cbet_color(), To :: cbet_color(), Opts :: convert_opts()) -> cbet_color().
convert(From, To, _) when element(1, From) == element(1, To) andalso ?ILLUMINANT(From) == ?ILLUMINANT(To) ->
	From;

convert(From, To, Opts) ->
	Adaptation = maps:get(adaptation, Opts, ?BRADFORD),
	Clamp = maps:get(clamp, Opts, true),

	Intermediate = intermediate(From, To),

	Result = case Intermediate of
				 xyz ->
					 %% Приводим From к XYZ
					 XYZ1 = to_xyz(From),
					 %% Применяем адаптацию белой точки, если нужно
					 XYZ2 = adapt(XYZ1, ?ILLUMINANT(From), ?ILLUMINANT(To), Adaptation),
					 %% Приводим XYZ к целевому формату
					 from_xyz(XYZ2, To);

				 linear_rgb ->
					 %% Прямое преобразование через линейный RGB
					 Linear = to_linear_rgb(From),
					 from_linear_rgb(Linear, To);

				 lab ->
					 %% Прямое преобразование через Lab
					 Lab = to_lab(From),
					 from_lab(Lab, To);

				 oklab ->
					 %% Прямое преобразование через OKLab
					 Lab = to_oklab(From),
					 from_oklab(Lab, To);

				 luv ->
					 %% Прямое преобразование через Luv
					 Luv = to_luv(From),
					 from_luv(Luv, To)
			 end,
	case Clamp of
		true -> clamp_color(Result);
		false -> Result
	end.


intermediate(#srgb{}) ->
	linear_rgb;
intermediate(#ictcp{}) ->
	linear_rgb;
intermediate(#linear_rgb{}) ->
	linear_rgb;
intermediate(#hsv{}) ->
	linear_rgb;
intermediate(#hsl{}) ->
	linear_rgb;
intermediate(#hsi{}) ->
	linear_rgb;
intermediate(#cmy{}) ->
	linear_rgb;
intermediate(#hwb{}) ->
	linear_rgb;

intermediate(#lab{}) ->
	lab;
intermediate(#din99_lab{}) ->
	lab;
intermediate(#lch{}) ->
	lab;

intermediate(#luv{}) ->
	luv;
intermediate(#lchuv{}) ->
	luv;

intermediate(#oklab{}) ->
	oklab;
intermediate(#oklch{}) ->
	oklab;

intermediate(_) ->
	xyz.


intermediate(From, To) when ?ILLUMINANT(From) =/= ?ILLUMINANT(To) ->
	xyz;

intermediate(From, To) ->
	case intermediate(From) of
		xyz -> xyz;
		Else ->
			case intermediate(To) of
				Else -> Else;
				_ -> xyz
			end
	end.


%% Luv -> Luv
to_luv(#luv{l = L, u = U, v = V}) ->
	%% Уже в Luv, возвращаем как вектор {L,U,V} для дальнейших конверсий
	?VECTOR3(L, U, V);

%% LCHuv -> Luv
to_luv(#lchuv{l = L, c = C, h = H}) ->
	%% H в градусах -> радианы
	HRad = H * math:pi() / 180.0,
	U = C * math:cos(HRad),
	V = C * math:sin(HRad),
	?VECTOR3(L, U, V).


%% Luv -> Luv
from_luv(?VECTOR3(L, U, V), #luv{} = To) ->
	To#luv{l = L, u = U, v = V};

%% Luv -> LCHuv
from_luv(?VECTOR3(L, U, V), #lchuv{} = To) ->
	%% Chroma C = sqrt(U^2 + V^2)
	C = math:sqrt(U * U + V * V),

	Tol = 1.0e-6,

	%% Hue H = atan2(V,U) в градусах [0..360)
	H = if
			L > 99.999 -> 0.0;
			C < Tol -> 0.0;
			true -> math:atan2(V, U) * 180.0 / math:pi()
		end,
	HNorm = normalize_360(H),
	To#lchuv{l = L, c = C, h = HNorm}.


to_lab(#lab{l = L, a = A, b = B}) ->
	?VECTOR3(L, A, B);

to_lab(#lch{l = L, c = C, h = H}) ->
	%% LCH -> Lab
	Hr = H * math:pi() / 180.0,
	A = C * math:cos(Hr),
	B = C * math:sin(Hr),
	?VECTOR3(L, A, B);


to_lab(#din99_lab{l = L99, a = A99, b = B99, variant = Variant}) ->
	{C1, C2, C3, C4, C5, C6, C7, C8} = din99lab_coeffs(Variant),
	Ke = 1.0,
	Kch = 1.0,
	Rad = math:pi() / 180,
	Cos3 = math:cos(C3 * Rad),
	Sin3 = math:sin(C3 * Rad),

	C99 = math:sqrt(A99 * A99 + B99 * B99),
	H99 = math:atan2(B99, A99) - C7 * Rad,

	G = (math:exp((C8 * C99 * Kch * Ke) / C5) - 1) / C6,

	E = G * math:cos(H99),
	F = G * math:sin(H99),

	A = E * Cos3 - (F / C4) * Sin3,
	B = E * Sin3 + (F / C4) * Cos3,

	L = (math:exp(L99 * Ke / C1) - 1) / C2,
	?VECTOR3(L, A, B).


from_lab(?VECTOR3(L, A, B), #lab{} = To) ->
	%% Прямое возвращение в Lab
	To#lab{l = L, a = A, b = B};

from_lab(?VECTOR3(L, A, B), #lch{} = To) ->

	C = math:sqrt(A * A + B * B),            %% Хрома

	Tol = 1.0e-4,

	H = if
			C < Tol ->
				0.0;
			true ->
				HRaw = math:atan2(B, A) * 180.0 / math:pi(), %% Hue в градусах
				normalize_360(HRaw)
		end,
	To#lch{l = L, c = C, h = H};



from_lab(?VECTOR3(L, A, B), #din99_lab{variant = Variant} = To) ->
	{C1, C2, C3, C4, C5, C6, C7, C8} = din99lab_coeffs(Variant),
	Ke = 1.0,
	Kch = 1.0,
	Rad = math:pi() / 180,
	Cos3 = math:cos(C3 * Rad),
	Sin3 = math:sin(C3 * Rad),

	E = Cos3 * A + Sin3 * B,
	F = C4 * (-Sin3 * A + Cos3 * B),

	G = math:sqrt(E * E + F * F),
	H_ef = math:atan2(F, E) + C7 * Rad,

	L99 = C1 * math:log(1 + C2 * L) * Ke,
	C99 = C5 * math:log(1 + C6 * G) / (C8 * Kch * Ke),

	A99 = C99 * math:cos(H_ef),
	B99 = C99 * math:sin(H_ef),
	To#din99_lab{l = L99, a = A99, b = B99}.


to_oklab(#oklab{l = L, a = A, b = B}) ->
	?VECTOR3(L, A, B);

to_oklab(#oklch{l = L, c = C, h = Hdeg}) ->
	Hrad = Hdeg * math:pi() / 180.0,

	A = C * math:cos(Hrad),
	B = C * math:sin(Hrad),

	?VECTOR3(L, A, B).

from_oklab(?VECTOR3(L, A, B), #oklab{} = To) ->
	%% Прямое возвращение в OkLab
	To#oklab{l = L, a = A, b = B};

from_oklab(?VECTOR3(L, A, B), #oklch{} = To) ->
	%% Chroma
	C = math:sqrt(A * A + B * B),

	Tol = 1.0e-4,

	%% Hue (в радианах)
	Hrad =
		case C < Tol of
			true -> 0.0;   %% hue неопределён, но convention = 0
			false -> math:atan2(B, A)
		end,

	%% в градусы
	Hdeg0 = Hrad * 180.0 / math:pi(),

	%% нормализация в [0..360)
	Hdeg = normalize_360(Hdeg0),

	To#oklch{l = L, c = C, h = Hdeg}.

to_linear_rgb(#srgb{r = R, g = G, b = B}) ->
	?VECTOR3(srgb_comp_to_linear(R),
		srgb_comp_to_linear(G),
		srgb_comp_to_linear(B));

to_linear_rgb(#ictcp{i = I, ct = Ct, cp = Cp, transfer = Transfer}) ->
%% 1. ICtCp -> LMS nonlinear
	Matrix = case Transfer of
				 ?TRANSFER_PQ -> ?ICTCP_ICTCP_TO_LMS_PQ_M;
				 ?TRANSFER_HLG -> ?ICTCP_ICTCP_TO_LMS_HLG_M
			 end,
	?VECTOR3(L_nl, M_nl, S_nl) = cbet_math:mulv(Matrix, ?VECTOR3(I, Ct, Cp)),


	%% 2. Inverse nonlinear transfer
	?VECTOR3(L, M, S) = unwind_ictcp_transfer(L_nl, M_nl, S_nl, Transfer),
	%% 3. LMS -> linear BT.2020
	?VECTOR3(Rbt, Gbt, Bbt) = cbet_math:mulv(?LMS_TO_BT2020_M, ?VECTOR3(L, M, S)),
	%% 4. linear BT.2020 -> linear sRGB
	cbet_math:mulv(?BT2020_TO_LINEAR_SRGB_M, ?VECTOR3(Rbt, Gbt, Bbt));

to_linear_rgb(#adobe_rgb{r = R, g = G, b = B}) ->
	?VECTOR3(adobe_rgb_comp_to_linear(R),
		adobe_rgb_comp_to_linear(G),
		adobe_rgb_comp_to_linear(B));

to_linear_rgb(#display_p3{r = R, g = G, b = B}) ->
	?VECTOR3(display_p3_comp_to_linear(R),
		display_p3_comp_to_linear(G),
		display_p3_comp_to_linear(B));

%% Rec. 2020
to_linear_rgb(#rec2020{r = R, g = G, b = B}) ->
	?VECTOR3(rec2020_comp_to_linear(R),
		rec2020_comp_to_linear(G),
		rec2020_comp_to_linear(B));

%% Rec. 709
to_linear_rgb(#rec709{r = R, g = G, b = B}) ->
	?VECTOR3(rec709_comp_to_linear(R),
		rec709_comp_to_linear(G),
		rec709_comp_to_linear(B));

%% ProPhoto RGB
to_linear_rgb(#prophoto_rgb{r = R, g = G, b = B}) ->
	?VECTOR3(prophoto_rgb_comp_to_linear(R),
		prophoto_rgb_comp_to_linear(G),
		prophoto_rgb_comp_to_linear(B));

%% Wide Gamut RGB
to_linear_rgb(#wide_gamut_rgb{r = R, g = G, b = B}) ->
	?VECTOR3(wide_gamut_rgb_comp_to_linear(R),
		wide_gamut_rgb_comp_to_linear(G),
		wide_gamut_rgb_comp_to_linear(B));

to_linear_rgb(#cmy{c = C, m = M, y = Y}) ->
	?VECTOR3(
		1.0 - C,
		1.0 - M,
		1.0 - Y
	);

to_linear_rgb(#hwb{h = H, w = W, b = B}) ->
	hwb_to_linear_rgb(H, W, B);

to_linear_rgb(#hsv{h = H, s = S, v = V}) ->
	hsv_to_linear_rgb(H, S, V);

to_linear_rgb(#hsl{h = H, s = S, l = L}) ->
	hsl_to_linear_rgb(H, S, L);

to_linear_rgb(#hsi{h = H, s = S, i = I}) ->
	hsi_to_linear_rgb(H, S, I);

to_linear_rgb(#linear_rgb{r = R, g = G, b = B}) ->
	?VECTOR3(R, G, B).


%% sRGB
from_linear_rgb(?VECTOR3(R, G, B), #srgb{} = To) ->
	To#srgb{
		r = srgb_comp_from_linear(R),
		g = srgb_comp_from_linear(G),
		b = srgb_comp_from_linear(B)
	};

from_linear_rgb(?VECTOR3(R, G, B), #ictcp{transfer = Transfer} = To) ->
	%% 1. Linear sRGB -> linear BT.2020
	?VECTOR3(Rbt, Gbt, Bbt) = cbet_math:mulv(?LINEAR_SRGB_TO_BT2020_M, ?VECTOR3(R, G, B)),
	%% 2. BT.2020 -> LMS
	?VECTOR3(L, M, S) = cbet_math:mulv(?BT2020_TO_LMS_M, ?VECTOR3(Rbt, Gbt, Bbt)),
	%% 3. Apply nonlinear transfer (PQ)
	LMS_nl = apply_ictcp_transfer(L, M, S, Transfer),
	%% 4. LMS -> ICtCp
	Matrix = case Transfer of
				 ?TRANSFER_PQ -> ?ICTCP_LMS_TO_ICTCP_PQ_M;
				 ?TRANSFER_HLG -> ?ICTCP_LMS_TO_ICTCP_HLG_M
			 end,

	?VECTOR3(I, Ct, Cp) = cbet_math:mulv(Matrix, LMS_nl),

	To#ictcp{
		i = I,
		ct = Ct,
		cp = Cp
	};

%% Adobe RGB
from_linear_rgb(?VECTOR3(R, G, B), #adobe_rgb{} = To) ->
	To#adobe_rgb{
		r = adobe_rgb_comp_from_linear(R),
		g = adobe_rgb_comp_from_linear(G),
		b = adobe_rgb_comp_from_linear(B)
	};

%% Display P3
from_linear_rgb(?VECTOR3(R, G, B), #display_p3{} = To) ->
	To#display_p3{
		r = display_p3_comp_from_linear(R),
		g = display_p3_comp_from_linear(G),
		b = display_p3_comp_from_linear(B)
	};

%% Rec. 2020
from_linear_rgb(?VECTOR3(R, G, B), #rec2020{} = To) ->
	To#rec2020{
		r = rec2020_comp_from_linear(R),
		g = rec2020_comp_from_linear(G),
		b = rec2020_comp_from_linear(B)
	};

%% Rec. 709
from_linear_rgb(?VECTOR3(R, G, B), #rec709{} = To) ->
	To#rec709{
		r = rec709_comp_from_linear(R),
		g = rec709_comp_from_linear(G),
		b = rec709_comp_from_linear(B)
	};

%% ProPhoto RGB
from_linear_rgb(?VECTOR3(R, G, B), #prophoto_rgb{} = To) ->
	To#prophoto_rgb{
		r = prophoto_rgb_comp_from_linear(R),
		g = prophoto_rgb_comp_from_linear(G),
		b = prophoto_rgb_comp_from_linear(B)
	};

%% Wide Gamut RGB
from_linear_rgb(?VECTOR3(R, G, B), #wide_gamut_rgb{} = To) ->
	To#wide_gamut_rgb{
		r = wide_gamut_rgb_comp_from_linear(R),
		g = wide_gamut_rgb_comp_from_linear(G),
		b = wide_gamut_rgb_comp_from_linear(B)
	};

from_linear_rgb(?VECTOR3(R, G, B), #cmy{} = To) ->
	To#cmy{
		c = 1.0 - R,
		m = 1.0 - G,
		y = 1.0 - B
	};

from_linear_rgb(?VECTOR3(_R, _G, _B) = RGB, #hsv{} = To) ->
	from_linear_rgb_to_hsv(RGB, To);

from_linear_rgb(?VECTOR3(_R, _G, _B) = RGB, #hsl{} = To) ->
	from_linear_rgb_to_hsl(RGB, To);

from_linear_rgb(?VECTOR3(_R, _G, _B) = RGB, #hsi{} = To) ->
	from_linear_rgb_to_hsi(RGB, To);

from_linear_rgb(?VECTOR3(_R, _G, _B) = RGB, #hwb{} = To) ->
	from_linear_rgb_to_hwb(RGB, To);

from_linear_rgb(?VECTOR3(R, G, B), #linear_rgb{} = To) ->
	To#linear_rgb{r = R, g = G, b = B}.


to_xyz(#linear_rgb{r = R, g = G, b = B}) ->
	?VECTOR3(X, Y, Z) = cbet_math:mulv(?SRGB_TO_XYZ_M, ?VECTOR3(R, G, B)),
	?VECTOR3(X * 100.0, Y * 100.0, Z * 100.0);

to_xyz(#srgb{} = S) ->
	RGB = to_linear_rgb(S),
	?VECTOR3(X, Y, Z) = cbet_math:mulv(?SRGB_TO_XYZ_M, RGB),
	?VECTOR3(X * 100.0, Y * 100.0, Z * 100.0);

to_xyz(#adobe_rgb{} = A) ->
	RGB = to_linear_rgb(A),
	?VECTOR3(X, Y, Z) = cbet_math:mulv(?ADOBE_RGB_TO_XYZ_M, RGB),
	?VECTOR3(X * 100.0, Y * 100.0, Z * 100.0);

to_xyz(#display_p3{} = P3) ->
	?VECTOR3(R, G, B) = to_linear_rgb(P3),
	?VECTOR3(X, Y, Z) = cbet_math:mulv(?DISPLAY_P3_TO_XYZ_M, ?VECTOR3(R, G, B)),
	?VECTOR3(X * 100.0, Y * 100.0, Z * 100.0);

to_xyz(#rec2020{} = R) ->
	RGB = to_linear_rgb(R),
	?VECTOR3(X, Y, Z) = cbet_math:mulv(?REC2020_TO_XYZ_M, RGB),
	?VECTOR3(X * 100.0, Y * 100.0, Z * 100.0);

to_xyz(#rec709{} = R) ->
	RGB = to_linear_rgb(R),
	?VECTOR3(X, Y, Z) = cbet_math:mulv(?REC709_TO_XYZ_M, RGB),
	?VECTOR3(X * 100.0, Y * 100.0, Z * 100.0);

to_xyz(#prophoto_rgb{} = P) ->
	RGB = to_linear_rgb(P),
	?VECTOR3(X, Y, Z) = cbet_math:mulv(?PROPHOTO_RGB_TO_XYZ_M, RGB),
	?VECTOR3(X * 100.0, Y * 100.0, Z * 100.0);

to_xyz(#wide_gamut_rgb{} = W) ->
	RGB = to_linear_rgb(W),
	?VECTOR3(X, Y, Z) = cbet_math:mulv(?WIDE_GAMUT_RGB_TO_XYZ_M, RGB),
	?VECTOR3(X * 100.0, Y * 100.0, Z * 100.0);

to_xyz(#cmy{} = CMY) ->
	RGB = to_linear_rgb(CMY),
	?VECTOR3(X, Y, Z) = cbet_math:mulv(?SRGB_TO_XYZ_M, RGB),
	?VECTOR3(X * 100.0, Y * 100.0, Z * 100.0);

to_xyz(#xyz{x = X, y = Y, z = Z}) ->
	?VECTOR3(X, Y, Z);

to_xyz(#xyy{x = X, y = Y_ratio, luminance = L}) ->

	Tol = 1.0e-12,
	if
		Y_ratio =< Tol ->
			?VECTOR3(0.0, 0.0, 0.0);
		true ->
			X_val = (X / Y_ratio) * L,
			Y_val = L,
			Z_val = ((1.0 - X - Y_ratio) / Y_ratio) * L,
			?VECTOR3(X_val, Y_val, Z_val)
	end;

%% Lab -> XYZ
to_xyz(#lab{l = L, a = A, b = B, illum = Illum}) ->
	%% белая точка в диапазоне [0,100]
	?VECTOR3(Xn, Yn, Zn) = illum(Illum),

	Fy = (L + 16.0) / 116.0,
	Fx = A / 500.0 + Fy,
	Fz = Fy - B / 200.0,

	Fx3 = Fx * Fx * Fx,
	Fz3 = Fz * Fz * Fz,

	Xr = if Fx3 > 0.008856 -> Fx3; true -> (Fx - 16.0 / 116.0) / 7.787 end,
	Yr = if L > (903.3 * 0.008856) -> cbet_math:safe_pow(Fy, 3); true -> L / 903.3 end,
	Zr = if Fz3 > 0.008856 -> Fz3; true -> (Fz - 16.0 / 116.0) / 7.787 end,

	?VECTOR3(Xr * Xn, Yr * Yn, Zr * Zn);

%% Luv -> XYZ
to_xyz(#luv{l = L, u = U, v = V, illum = Illum}) ->
	?VECTOR3(Xn, _, Zn) = illum(Illum),
	Yn = 100.0,

	U_prime_n = 4.0 * Xn / (Xn + 15.0 * Yn + 3.0 * Zn),
	V_prime_n = 9.0 * Yn / (Xn + 15.0 * Yn + 3.0 * Zn),

	Tol = 1.0e-12,

	if L =< Tol -> ?VECTOR3(0.0, 0.0, 0.0);
		true ->
			U_prime = U / (13.0 * L) + U_prime_n,
			V_prime = V / (13.0 * L) + V_prime_n,
			Yr = if L > 8.0 -> cbet_math:safe_pow((L + 16.0) / 116.0, 3); true -> L / 903.3 end,
			Y_abs = Yn * Yr,
			X = Y_abs * 9.0 * U_prime / (4.0 * V_prime + Tol),
			Z = Y_abs * (12.0 - 3.0 * U_prime - 20.0 * V_prime) / (4.0 * V_prime + Tol),
			?VECTOR3(X, Y_abs, Z)
	end;

to_xyz(#lchuv{l = L, c = C, h = H, illum = Illum}) ->
	HRad = H * math:pi() / 180.0,
	U = C * math:cos(HRad),
	V = C * math:sin(HRad),
	to_xyz(#luv{l = L, u = U, v = V, illum = Illum});

to_xyz(#logluv{l = Le, u = U, v = V, illum = Illum}) ->
	%% Восстанавливаем Y из логарифма
	%% Y = 2^(Le - 64)
	Y = math:pow(2, Le - 64),

	Tol = 1.0e-12,

	%% Проверяем, является ли цвет ахроматическим
	IsAchromatic = (abs(U) < Tol) andalso (abs(V) < Tol),

	if
	%% ахроматический цвет (серый, белый, черный)
		IsAchromatic ->
			?VECTOR3(Xw, Yw, Zw) = illum(Illum),
			%% X и Z пропорциональны Y (соотношение как у точки белого)
			%% Для D65: X = 0.95047 * Y, Z = 1.08883 * Y
			%% Для других illuminant нужно подставлять правильные коэффициенты
			%% X и Z пропорциональны Y с соотношением опорного белого
			%% X : Y : Z = Xw : Yw : Zw
			X = Xw * (Y / Yw),
			Z = Zw * (Y / Yw),
			?VECTOR3(X, Y, Z);

	%% хроматический цвет
		true ->
			%% Восстанавливаем u', v' из масштабированных значений
			U_prime = U / 410.0,
			V_prime = V / 410.0,

			%% Восстанавливаем X и Z из u', v' и Y
			%% Из формул:
			%%   u' = 4X / (X + 15Y + 3Z)  => X = u' * denom / 4
			%%   v' = 9Y / (X + 15Y + 3Z)  => denom = 9Y / v'
			%%

			Denom = 9 * Y / V_prime,
			X = U_prime * Denom / 4,
			Z = (Denom - X - 15 * Y) / 3,

			?VECTOR3(X, Y, Z)
	end;


to_xyz(#din99_lab{illum = Illum} = Din99) ->
	?VECTOR3(L, A, B) = to_lab(Din99),
	to_xyz(#lab{l = L, a = A, b = B, illum = Illum});

to_xyz(#ipt{i = I, p = P, t = T}) ->
	%% IPT -> LMS' (используем ?XYZ_FROM_IPT_M для перевода IPT -> LMS')
	?VECTOR3(Lp, Mp, Sp) = cbet_math:mulv(?XYZ_FROM_IPT_M, ?VECTOR3(I, P, T)),
	%% LMS' -> LMS (возводим в степень 1/0.43)
	L = cbet_math:safe_pow(Lp, 1.0 / 0.43),
	M = cbet_math:safe_pow(Mp, 1.0 / 0.43),
	S = cbet_math:safe_pow(Sp, 1.0 / 0.43),
	%% LMS -> XYZ (используем ?LMS_TO_XYZ_M)
	?VECTOR3(X, Y, Z) = cbet_math:mulv(?LMS_TO_XYZ_M, ?VECTOR3(L, M, S)),
	%% Масштабируем к диапазону 0-100 (как в оригинале)
	?VECTOR3(X * 100.0, Y * 100.0, Z * 100.0);

%%не лучший способ вероятно
to_xyz(#ictcp{illum = ?ILLUM_D65} = ICTCP) ->
	?VECTOR3(R, G, B) = to_linear_rgb(ICTCP),
	LinearRGB = #linear_rgb{r = R, g = G, b = B},
	to_xyz(LinearRGB);


to_xyz(#hsv{h = H, s = S, v = V}) ->
	?VECTOR3(R, G, B) = hsv_to_linear_rgb(H, S, V),
	?VECTOR3(X, Y, Z) = cbet_math:mulv(?SRGB_TO_XYZ_M, ?VECTOR3(R, G, B)),
	?VECTOR3(X * 100, Y * 100, Z * 100);

to_xyz(#hsl{h = H, s = S, l = L}) ->
	?VECTOR3(R, G, B) = hsl_to_linear_rgb(H, S, L),
	?VECTOR3(X, Y, Z) = cbet_math:mulv(?SRGB_TO_XYZ_M, ?VECTOR3(R, G, B)),
	?VECTOR3(X * 100, Y * 100, Z * 100);

to_xyz(#hsi{h = H, s = S, i = I}) ->
	?VECTOR3(R, G, B) = hsi_to_linear_rgb(H, S, I),
	?VECTOR3(X, Y, Z) = cbet_math:mulv(?SRGB_TO_XYZ_M, ?VECTOR3(R, G, B)),
	?VECTOR3(X * 100, Y * 100, Z * 100);

to_xyz(#lch{illum = Illum} = LCh) ->
	?VECTOR3(L, A, B) = to_lab(LCh),
	to_xyz(#lab{l = L, a = A, b = B, illum = Illum});

to_xyz(#hwb{h = H, w = W, b = Bl}) ->
	?VECTOR3(R, G, B) = hwb_to_linear_rgb(H, W, Bl),
	?VECTOR3(X, Y, Z) = cbet_math:mulv(?SRGB_TO_XYZ_M, ?VECTOR3(R, G, B)),
	?VECTOR3(X * 100, Y * 100, Z * 100);

to_xyz(#oklab{l = L, a = A, b = B}) ->
	?VECTOR3(L1, M1, S1) = cbet_math:mulv(?LMS_FROM_OKLAB_M, ?VECTOR3(L, A, B)),
	LMS = ?VECTOR3(L1 * L1 * L1, M1 * M1 * M1, S1 * S1 * S1),
	?VECTOR3(X, Y, Z) = cbet_math:mulv(?XYZ_FROM_LMS_OKLAB_M, LMS),
	?VECTOR3(X * 100, Y * 100, Z * 100);

to_xyz(#oklch{illum = Illum} = Oklch) ->
	?VECTOR3(L, A, B) = to_oklab(Oklch),
	to_xyz(#oklab{l = L, a = A, b = B, illum = Illum}).


from_xyz(?VECTOR3(X, Y, Z), #linear_rgb{} = To) ->
	XYZ_norm = ?VECTOR3(X / 100.0, Y / 100.0, Z / 100.0),
	?VECTOR3(R, G, B) = cbet_math:mulv(?SRGB_FROM_XYZ_M, XYZ_norm),
	To#linear_rgb{r = R, g = G, b = B};

from_xyz(?VECTOR3(X, Y, Z), #srgb{} = To) ->
	XYZ_norm = ?VECTOR3(X / 100.0, Y / 100.0, Z / 100.0),
	from_linear_rgb(
		cbet_math:mulv(?SRGB_FROM_XYZ_M, XYZ_norm),
		To);

from_xyz(?VECTOR3(X, Y, Z), #adobe_rgb{} = To) ->
	XYZ_norm = ?VECTOR3(X / 100.0, Y / 100.0, Z / 100.0),
	from_linear_rgb(
		cbet_math:mulv(?ADOBE_RGB_FROM_XYZ_M, XYZ_norm),
		To);

from_xyz(?VECTOR3(X, Y, Z), #display_p3{} = To) ->
	XYZ_norm = ?VECTOR3(X / 100.0, Y / 100.0, Z / 100.0),
	from_linear_rgb(cbet_math:mulv(?DISPLAY_P3_FROM_XYZ_M, XYZ_norm), To);

from_xyz(?VECTOR3(X, Y, Z), #rec2020{} = To) ->
	XYZ_norm = ?VECTOR3(X / 100.0, Y / 100.0, Z / 100.0),
	from_linear_rgb(cbet_math:mulv(?REC2020_FROM_XYZ_M, XYZ_norm), To);

from_xyz(?VECTOR3(X, Y, Z), #rec709{} = To) ->
	XYZ_norm = ?VECTOR3(X / 100.0, Y / 100.0, Z / 100.0),
	from_linear_rgb(cbet_math:mulv(?REC709_FROM_XYZ_M, XYZ_norm), To);

from_xyz(?VECTOR3(X, Y, Z), #prophoto_rgb{} = To) ->
	XYZ_norm = ?VECTOR3(X / 100.0, Y / 100.0, Z / 100.0),
	from_linear_rgb(cbet_math:mulv(?PROPHOTO_RGB_FROM_XYZ_M, XYZ_norm), To);

from_xyz(?VECTOR3(X, Y, Z), #wide_gamut_rgb{} = To) ->
	XYZ_norm = ?VECTOR3(X / 100.0, Y / 100.0, Z / 100.0),
	from_linear_rgb(cbet_math:mulv(?WIDE_GAMUT_RGB_FROM_XYZ_M, XYZ_norm), To);

from_xyz(?VECTOR3(X, Y, Z), #cmy{} = To) ->
	XYZ_norm = ?VECTOR3(X / 100.0, Y / 100.0, Z / 100.0),
	from_linear_rgb(cbet_math:mulv(?SRGB_FROM_XYZ_M, XYZ_norm), To);

from_xyz(?VECTOR3(X, Y, Z), #xyz{} = To) ->
	To#xyz{x = X, y = Y, z = Z};

from_xyz(?VECTOR3(X, Y, Z), #xyy{} = To) ->
	Sum = X + Y + Z,

	Tol = 1.0e-12,

	if
		Sum =< Tol ->
			% если сумма нулевая, задаём стандартные значения
			To#xyy{x = 0.0, y = 0.0, luminance = 0.0};
		true ->
			X_val = X / Sum,
			Y_val = Y / Sum,
			L = Y,
			To#xyy{x = X_val, y = Y_val, luminance = L}
	end;

%% XYZ -> Lab
from_xyz(?VECTOR3(X, Y, Z), #lab{illum = Illum} = To) ->
	?VECTOR3(Xn, Yn, Zn) = illum(Illum),
	Xr = X / Xn,
	Yr = Y / Yn,
	Zr = Z / Zn,

	Fx = if Xr > 0.008856 -> cbet_math:safe_pow(Xr, 1.0 / 3.0); true -> 7.787 * Xr + 16.0 / 116.0 end,
	Fy = if Yr > 0.008856 -> cbet_math:safe_pow(Yr, 1.0 / 3.0); true -> 7.787 * Yr + 16.0 / 116.0 end,
	Fz = if Zr > 0.008856 -> cbet_math:safe_pow(Zr, 1.0 / 3.0); true -> 7.787 * Zr + 16.0 / 116.0 end,

	L = 116.0 * Fy - 16.0,
	A = 500.0 * (Fx - Fy),
	B = 200.0 * (Fy - Fz),
	To#lab{l = L, a = A, b = B};

%% XYZ -> Luv
from_xyz(?VECTOR3(X, Y, Z), #luv{illum = Illum} = To) ->
	?VECTOR3(Xn, _, Zn) = illum(Illum),
	Yn = 100.0,

	U_prime_n = 4.0 * Xn / (Xn + 15.0 * Yn + 3.0 * Zn),
	V_prime_n = 9.0 * Yn / (Xn + 15.0 * Yn + 3.0 * Zn),

	Tol = 1.0e-12,

	U_prime = 4.0 * X / (X + 15.0 * Y + 3.0 * Z + Tol),  % +EPSILON чтобы избежать деления на 0
	V_prime = 9.0 * Y / (X + 15.0 * Y + 3.0 * Z + Tol),

	Yr = Y / Yn,
	L = if Yr > 0.008856 -> 116.0 * cbet_math:safe_pow(Yr, 1.0 / 3.0) - 16.0; true -> 903.3 * Yr end,
	U = 13.0 * L * (U_prime - U_prime_n),
	V = 13.0 * L * (V_prime - V_prime_n),
	To#luv{l = L, u = U, v = V};

%% Luv -> LCHuv
from_xyz(XYZ, #lchuv{illum = Illum} = To) ->
	#luv{l = L, u = U, v = V} = from_xyz(XYZ, #luv{illum = Illum}),
	from_luv(?VECTOR3(L, U, V), To);

from_xyz(?VECTOR3(X, Y, Z), #logluv{} = To) ->
	%% Защита от Y=0: заменяем на минимальное значение
	Y_safe = if
				 Y > 0 -> Y;
				 true -> 1.0e-6
			 end,

	%% Логарифмируем
	Le = math:log(Y_safe) / math:log(2) + 64,

	%% Для u',v' используем исходный Y (даже если 0)
	%% Потому что при Y=0 цветности все равно нет
	Denom = X + 15 * Y + 3 * Z,

	Tol = 1.0e-12,

	if
		Denom =< Tol; Y =< 0 ->
			To#logluv{l = Le, u = 0.0, v = 0.0};
		true ->
			U_prime = 4 * X / Denom,
			V_prime = 9 * Y / Denom,
			To#logluv{l = Le, u = U_prime * 410, v = V_prime * 410}
	end;


from_xyz(XYZ, #din99_lab{illum = Illum} = To) ->
	#lab{l = L, a = A, b = B} = from_xyz(XYZ, #lab{illum = Illum}),
	from_lab(?VECTOR3(L, A, B), To);


from_xyz(?VECTOR3(X, Y, Z), #ipt{} = To) ->
	%% XYZ -> LMS (используем ?LMS_FROM_XYZ_M)
	XYZ1 = {X / 100.0, Y / 100.0, Z / 100.0},
	?VECTOR3(L, M, S) = cbet_math:mulv(?LMS_FROM_XYZ_M, XYZ1),
	%% LMS -> LMS' (возводим в степень 0.43)
	Lp = cbet_math:safe_pow(L, 0.43),
	Mp = cbet_math:safe_pow(M, 0.43),
	Sp = cbet_math:safe_pow(S, 0.43),
	%% LMS' -> IPT (используем ?IPT_FROM_XYZ_M)
	?VECTOR3(I, P, T) = cbet_math:mulv(?IPT_FROM_XYZ_M, ?VECTOR3(Lp, Mp, Sp)),
	To#ipt{i = I, p = P, t = T};

%%не лучший способ вероятно
from_xyz(XYZ, #ictcp{illum = ?ILLUM_D65} = To) ->
	#linear_rgb{r = R, g = G, b = B} = from_xyz(XYZ, #linear_rgb{}),
	from_linear_rgb(?VECTOR3(R, G, B), To);

from_xyz(?VECTOR3(X, Y, Z), #hsv{} = To) ->
	XYZ_norm = ?VECTOR3(X / 100.0, Y / 100.0, Z / 100.0),
	?VECTOR3(R, G, B) = cbet_math:mulv(?SRGB_FROM_XYZ_M, XYZ_norm),
	from_linear_rgb_to_hsv(?VECTOR3(R, G, B), To);

from_xyz(?VECTOR3(X, Y, Z), #hsl{} = To) ->
	XYZ_norm = ?VECTOR3(X / 100.0, Y / 100.0, Z / 100.0),
	?VECTOR3(R, G, B) = cbet_math:mulv(?SRGB_FROM_XYZ_M, XYZ_norm),
	from_linear_rgb_to_hsl(?VECTOR3(R, G, B), To);

from_xyz(?VECTOR3(X, Y, Z), #hsi{} = To) ->
	XYZ_norm = ?VECTOR3(X / 100.0, Y / 100.0, Z / 100.0),
	?VECTOR3(R, G, B) = cbet_math:mulv(?SRGB_FROM_XYZ_M, XYZ_norm),
	from_linear_rgb_to_hsi(?VECTOR3(R, G, B), To);

from_xyz(?VECTOR3(X, Y, Z), #hwb{} = To) ->
	XYZ_norm = ?VECTOR3(X / 100.0, Y / 100.0, Z / 100.0),
	?VECTOR3(R, G, B) = cbet_math:mulv(?SRGB_FROM_XYZ_M, XYZ_norm),
	from_linear_rgb_to_hwb(?VECTOR3(R, G, B), To);


from_xyz(XYZ, #lch{} = To) ->
	#lab{l = L, a = A, b = B} = from_xyz(XYZ, #lab{illum = To#lch.illum}),
	from_lab(?VECTOR3(L, A, B), To);

from_xyz(?VECTOR3(X, Y, Z), #oklab{} = To) ->
	XYZ_norm = ?VECTOR3(X / 100.0, Y / 100.0, Z / 100.0),
	?VECTOR3(L0, M0, S0) = cbet_math:mulv(?XYZ_TO_LMS_OKLAB_M, XYZ_norm),

	L1 = cbet_math:sign(L0) * math:pow(abs(L0), 1.0 / 3.0),
	M1 = cbet_math:sign(M0) * math:pow(abs(M0), 1.0 / 3.0),
	S1 = cbet_math:sign(S0) * math:pow(abs(S0), 1.0 / 3.0),

	?VECTOR3(L, A, B) = cbet_math:mulv(?LMS_TO_OKLAB_M, ?VECTOR3(L1, M1, S1)),

	To#oklab{l = L, a = A, b = B};

from_xyz(XYZ, #oklch{illum = Illum} = To) ->
	#oklab{l = L, a = A, b = B} = from_xyz(XYZ, #oklab{illum = Illum}),
	from_oklab(?VECTOR3(L, A, B), To).


srgb_comp_to_linear(C) when C =< 0.04045 ->
	C / 12.92;
srgb_comp_to_linear(C) ->
	cbet_math:safe_pow((C + 0.055) / 1.055, 2.4).

%% -----------------------------
%% Adobe RGB (gamma 2.2)
adobe_rgb_comp_to_linear(C) ->
	cbet_math:safe_pow(C, 2.2).

%% -----------------------------
%% Display P3 (Apple, gamma 2.2)
display_p3_comp_to_linear(C) ->
	cbet_math:safe_pow(C, 2.2).

%% -----------------------------

rec2020_comp_to_linear(C) when C < 4.5 * 0.0181 ->
	C / 4.5;
rec2020_comp_to_linear(C) ->
	cbet_math:safe_pow(
		(C + (1.099 - 1.0)) / 1.099,
		1.0 / 0.45
	).

%% -----------------------------
%% Rec. 709 (gamma 2.222 OETF)
rec709_comp_to_linear(C) when C < 0.081 ->
	C / 4.5;
rec709_comp_to_linear(C) ->
	cbet_math:safe_pow((C + 0.099) / 1.099, 2.222).

%% -----------------------------
%% ProPhoto RGB (gamma 1.8, linear segment for negative)
prophoto_rgb_comp_to_linear(C) when C =< 0.0 ->
	0.0;
prophoto_rgb_comp_to_linear(C) when C < 1.0 / 512.0 ->
	16.0 * C;
prophoto_rgb_comp_to_linear(C) ->
	cbet_math:safe_pow(C, 1.8).

%% -----------------------------
%% Wide Gamut RGB (gamma ~2.2)
wide_gamut_rgb_comp_to_linear(C) ->
	cbet_math:safe_pow(C, 563 / 256).


%% -----------------------------
%% sRGB (обратная к to_linear)
srgb_comp_from_linear(C) when C =< 0.0031308 ->
	12.92 * C;
srgb_comp_from_linear(C) ->
	1.055 * cbet_math:safe_pow(C, 1.0 / 2.4) - 0.055.

%% -----------------------------
%% Adobe RGB (gamma 2.2)
adobe_rgb_comp_from_linear(C) ->
	cbet_math:safe_pow(C, 1.0 / 2.2).

%% -----------------------------
%% Display P3 (gamma 2.2)`
display_p3_comp_from_linear(C) ->
	cbet_math:safe_pow(C, 1.0 / 2.2).

%% -----------------------------
%% Rec. 2020 (piecewise)
rec2020_comp_from_linear(C) when C < 0.0181 ->
	4.5 * C;
rec2020_comp_from_linear(C) ->
	1.099 * cbet_math:safe_pow(C, 1.0 / 2.2222) - 0.099.

%% -----------------------------
%% Rec. 709 (piecewise)
rec709_comp_from_linear(C) when C < 0.018 ->
	4.5 * C;
rec709_comp_from_linear(C) ->
	1.099 * cbet_math:safe_pow(C, 1.0 / 2.222) - 0.099.

%% -----------------------------
%% ProPhoto RGB (gamma 1.8, линейный сегмент)
prophoto_rgb_comp_from_linear(C) when C =< 0.0 ->
	0.0;
prophoto_rgb_comp_from_linear(C) when C < 16.0 / 512.0 ->
	C / 16.0;
prophoto_rgb_comp_from_linear(C) ->
	cbet_math:safe_pow(C, 1.0 / 1.8).

%% -----------------------------
%% Wide Gamut RGB (gamma ~2.2)
wide_gamut_rgb_comp_from_linear(C) ->
	cbet_math:safe_pow(C, 256 / 563.0).


hwb_to_linear_rgb(H, W, B) ->
	%% Hue остаётся как есть
	HNorm = normalize_360(H),
	%% Value/brightness для HSB/HSV
	V = 1.0 - B,

	Tol = 1.0e-6,

	%% Saturation для HSB
	S = if
			V =< Tol -> 0.0;
			true -> 1.0 - W / V
		end,
	%% Используем готовую функцию HSV/HSB -> linear RGB
	hsv_to_linear_rgb(HNorm, S, V).

from_linear_rgb_to_hwb(?VECTOR3(Rlin, Glin, Blin), #hwb{} = To) ->
	%% 1. Переводим обратно в sRGB
	R = srgb_comp_from_linear(Rlin),
	G = srgb_comp_from_linear(Glin),
	B = srgb_comp_from_linear(Blin),

	Max = lists:max([R, G, B]),
	Min = lists:min([R, G, B]),
	Delta = Max - Min,

	Tol = 1.0e-6,

	%% Hue (как в HSL)
	H = if
			Delta =< Tol -> 0.0;
			Max == R -> 60.0 * ((G - B) / Delta);
			Max == G -> 60.0 * ((B - R) / Delta + 2.0);
			Max == B -> 60.0 * ((R - G) / Delta + 4.0)
		end,
	HNorm = normalize_360(H),

	%% Whiteness и Blackness
	W = Min,
	Bl = 1.0 - Max,

	To#hwb{h = HNorm, w = W, b = Bl}.

%% -----------------------------
%% Linear RGB -> HSV
from_linear_rgb_to_hsv(?VECTOR3(Rlin, Glin, Blin), #hsv{} = To) ->
	% 1. Обратно в sRGB-пространство (gamma-коррекция)
	R = srgb_comp_from_linear(Rlin),
	G = srgb_comp_from_linear(Glin),
	B = srgb_comp_from_linear(Blin),

	Max = lists:max([R, G, B]),
	Min = lists:min([R, G, B]),
	Delta = Max - Min,

	Tol = 1.0e-6,

	%% Hue
	H = if
			Delta =< Tol -> 0.0;
			Max == R -> 60.0 * ((G - B) / Delta);
			Max == G -> 60.0 * ((B - R) / Delta + 2.0);
			Max == B -> 60.0 * ((R - G) / Delta + 4.0)
		end,

	HNorm = normalize_360(H),

	%% Saturation
	S = if
			Max =< Tol -> 0.0;
			true -> Delta / Max
		end,

	%% Value = max (уже в sRGB-пространстве)
	V = Max,

	To#hsv{h = HNorm, s = S, v = V}.


%% -----------------------------
%% Linear RGB -> HSL
from_linear_rgb_to_hsl(?VECTOR3(Rlin, Glin, Blin), #hsl{} = To) ->
	% 1. Обратно в sRGB-пространство
	R = srgb_comp_from_linear(Rlin),
	G = srgb_comp_from_linear(Glin),
	B = srgb_comp_from_linear(Blin),

	Max = lists:max([R, G, B]),
	Min = lists:min([R, G, B]),
	Delta = Max - Min,

	%% Lightness
	L = (Max + Min) / 2.0,

	Tol = 1.0e-6,

	%% Saturation
	S = if
			Delta =< Tol -> 0.0;
			L < 0.5 -> Delta / (Max + Min);
			true -> Delta / (2.0 - Max - Min)
		end,

	%% Hue
	H = if
			Delta =< Tol -> 0.0;
			Max == R -> 60.0 * ((G - B) / Delta);
			Max == G -> 60.0 * ((B - R) / Delta + 2.0);
			Max == B -> 60.0 * ((R - G) / Delta + 4.0)
		end,
	HNorm = normalize_360(H),

	To#hsl{h = HNorm, s = S, l = L}.


hsv_to_linear_rgb(H, S, V) ->
	% HSV -> sRGB-пространство
	C = V * S,
	H_ = H / 60.0,
	X = C * (1 - abs(math:fmod(H_, 2) - 1)),
	M = V - C,
	?VECTOR3(R1, G1, B1) = case trunc(H_) of
							   0 -> ?VECTOR3(C, X, 0);
							   1 -> ?VECTOR3(X, C, 0);
							   2 -> ?VECTOR3(0, C, X);
							   3 -> ?VECTOR3(0, X, C);
							   4 -> ?VECTOR3(X, 0, C);
							   5 -> ?VECTOR3(C, 0, X);
							   _ -> ?VECTOR3(0, 0, 0)
						   end,
	?VECTOR3(Rs, Gs, Bs) = ?VECTOR3(R1 + M, G1 + M, B1 + M),

	% sRGB -> linear
	?VECTOR3(srgb_comp_to_linear(Rs),
		srgb_comp_to_linear(Gs),
		srgb_comp_to_linear(Bs)).


hsl_to_linear_rgb(H, S, L) ->
	% H в градусах -> нормализуем в [0, 360)
	HNorm = normalize_360(H),
	Hdiv = HNorm / 60.0,

	% Chroma (C)
	C = (1 - abs(2 * L - 1)) * S,

	% X = C * (1 - |Hdiv mod 2 - 1|)
	X = C * (1 - abs(math:fmod(Hdiv, 2) - 1)),

	% m = L - C/2
	M = L - C / 2.0,

	% RGB в sRGB-пространстве (гамма)
	?VECTOR3(R1, G1, B1) = case trunc(Hdiv) of
							   0 -> ?VECTOR3(C, X, 0);
							   1 -> ?VECTOR3(X, C, 0);
							   2 -> ?VECTOR3(0, C, X);
							   3 -> ?VECTOR3(0, X, C);
							   4 -> ?VECTOR3(X, 0, C);
							   5 -> ?VECTOR3(C, 0, X);
							   _ -> ?VECTOR3(0, 0, 0)
						   end,

	Rs = R1 + M,
	Gs = G1 + M,
	Bs = B1 + M,

	% Переводим из sRGB-гамма в линейный RGB
	?VECTOR3(
		srgb_comp_to_linear(Rs),
		srgb_comp_to_linear(Gs),
		srgb_comp_to_linear(Bs)
	).


hsi_to_linear_rgb(H, S, I) ->
	HNorm = normalize_360(H),
	Hrad = HNorm * math:pi() / 180.0,

	Tol = 1.0e-12,

	% Вычисляем R,G,B в sRGB-гамма пространстве
	?VECTOR3(R, G, B) = case HNorm of
							H1 when H1 < 120.0 ->
								B_val = I * (1.0 - S),
								R_val = I * (1.0 + S * math:cos(Hrad) /
									(math:cos(math:pi() / 3 - Hrad) + Tol)),
								G_val = 3.0 * I - (R_val + B_val),
								?VECTOR3(R_val, G_val, B_val);

							H1 when H1 < 240.0 ->
								H2 = Hrad - 2.0 * math:pi() / 3.0,
								R_val = I * (1.0 - S),
								G_val = I * (1.0 + S * math:cos(H2) /
									(math:cos(math:pi() / 3 - H2) + Tol)),
								B_val = 3.0 * I - (R_val + G_val),
								?VECTOR3(R_val, G_val, B_val);

							_ ->
								H3 = Hrad - 4.0 * math:pi() / 3.0,
								G_val = I * (1.0 - S),
								B_val = I * (1.0 + S * math:cos(H3) /
									(math:cos(math:pi() / 3 - H3) + Tol)),
								R_val = 3.0 * I - (G_val + B_val),
								?VECTOR3(R_val, G_val, B_val)
						end,

	% Теперь из sRGB-гамма в linear
	?VECTOR3(
		srgb_comp_to_linear(R),
		srgb_comp_to_linear(G),
		srgb_comp_to_linear(B)
	).


from_linear_rgb_to_hsi(?VECTOR3(Rlin, Glin, Blin), #hsi{} = To) ->

	%% 1. gamma
	R = srgb_comp_from_linear(Rlin),
	G = srgb_comp_from_linear(Glin),
	B = srgb_comp_from_linear(Blin),

	%% 2. Intensity
	I = (R + G + B) / 3.0,

	MinRGB = lists:min([R, G, B]),

	%% Числовые допуски
	Tol = 1.0e-6,

	%% 3. Saturation (устойчиво)
	S =
		case I < Tol of
			true ->
				0.0;
			false ->
				1.0 - (MinRGB / I)
		end,

	%% 4. Hue (вычисляем только если цвет не ахроматический)
	H =
		case S < Tol of
			true ->
				0.0;
			false ->
				Numer = 0.5 * ((R - G) + (R - B)),
				Denom0 =
					math:sqrt(
						(R - G) * (R - G) +
							(R - B) * (G - B)
					),

				%% защита от деления на 0
				case Denom0 < Tol of
					true ->
						0.0;
					false ->
						Ratio0 = Numer / Denom0,

						%% защита acos от выхода за [-1,1]
						Ratio =
							case Ratio0 > 1.0 of
								true -> 1.0;
								false ->
									case Ratio0 < -1.0 of
										true -> -1.0;
										false -> Ratio0
									end
							end,

						Theta = math:acos(Ratio),

						Angle =
							case B =< G of
								true -> Theta;
								false -> 2.0 * math:pi() - Theta
							end,

						Angle * 180.0 / math:pi()
				end
		end,

	To#hsi{
		h = normalize_360(H),
		s = S,
		i = I
	}.

%% Приводит все компоненты цвета в допустимый диапазон.
%% По умолчанию жёсткий clamp [0,1] для display-referred,
%% для scene-referred (linear_rgb, prophoto) — оставляет как есть.
clamp_color(Color) ->
	clamp_color(Color, true).

clamp_color(Color, false) -> Color;   % без клиппинга

clamp_color(#linear_rgb{r = R, g = G, b = B} = C, _DoClamp) ->
	C#linear_rgb{r = clamp01(R), g = clamp01(G), b = clamp01(B)};

clamp_color(#srgb{} = C, true) -> clamp_rgb_record(C);
clamp_color(#adobe_rgb{} = C, true) -> clamp_rgb_record(C);
clamp_color(#display_p3{} = C, true) -> clamp_rgb_record(C);
clamp_color(#rec2020{} = C, true) -> clamp_rgb_record(C);
clamp_color(#rec709{} = C, true) -> clamp_rgb_record(C);
clamp_color(#prophoto_rgb{} = C, _) -> C;   % scene-referred — не клиппим
clamp_color(#wide_gamut_rgb{} = C, _) -> C;

clamp_color(#oklab{l = L, a = A, b = B} = Color, true) ->
	L1 = clamp01(L),
	A1 = clampr(A, -0.5, 0.5),
	B1 = clampr(B, -0.5, 0.5),
	Color#oklab{l = L1, a = A1, b = B1};

clamp_color(#oklch{l = L, c = C, h = H} = Color, true) ->
	L1 = clamp01(L),
	C1 = max(0.0, min(0.5, C)),
	H1 = math:fmod(H, 360.0),
	Color#oklch{l = L1, c = C1, h = H1};

clamp_color(#hsv{h = H, s = S, v = V} = Color, true) ->
	H1 = math:fmod(H, 360.0),  %% дробный остаток
	H2 = normalize_360(H1),
	S1 = clamp01(S),
	V1 = clamp01(V),
	Color#hsv{h = H2, s = S1, v = V1};

clamp_color(#hsl{h = H, s = S, l = L} = Color, true) ->
	H1 = math:fmod(H, 360.0),
	H2 = normalize_360(H1),
	S1 = clamp01(S),
	L1 = clamp01(L),
	Color#hsl{h = H2, s = S1, l = L1};

clamp_color(#hsi{h = H, s = S, i = I} = Color, true) ->
	H1 = math:fmod(H, 360.0),
	H2 = normalize_360(H1),
	S1 = clamp01(S),
	I1 = clamp01(I),
	Color#hsi{h = H2, s = S1, i = I1};


clamp_color(#ipt{i = I, p = P, t = T} = Color, true) ->
	I1 = clampr(I, -1.0, 1.0),
	P1 = clampr(P, -1.0, 1.0),
	T1 = clampr(T, -1.0, 1.0),
	Color#ipt{i = I1, p = P1, t = T1};

clamp_color(#ictcp{i = I, ct = P, cp = T} = Color, true) ->
	I1 = clampr(I, -1.0, 1.0),
	P1 = clampr(P, -1.0, 1.0),
	T1 = clampr(T, -1.0, 1.0),
	Color#ictcp{i = I1, ct = P1, cp = T1};

clamp_color(#xyz{x = X, y = Y, z = Z} = C, true) ->
	C#xyz{x = max(0.0, X), y = max(0.0, Y), z = max(0.0, Z)};

clamp_color(Color, _) -> Color.   % остальные пространства (Lab, Luv, HSV и т.д.) не клиппим

clamp_rgb_record(#srgb{r = R, g = G, b = B} = Rec) ->
	Rec#srgb{r = clamp01(R), g = clamp01(G), b = clamp01(B)};

clamp_rgb_record(#adobe_rgb{r = R, g = G, b = B} = Rec) ->
	Rec#adobe_rgb{r = clamp01(R), g = clamp01(G), b = clamp01(B)};

clamp_rgb_record(#display_p3{r = R, g = G, b = B} = Rec) ->
	Rec#display_p3{r = clamp01(R), g = clamp01(G), b = clamp01(B)};

clamp_rgb_record(#rec2020{r = R, g = G, b = B} = Rec) ->
	Rec#rec2020{r = clamp01(R), g = clamp01(G), b = clamp01(B)};

clamp_rgb_record(#rec709{r = R, g = G, b = B} = Rec) ->
	Rec#rec709{r = clamp01(R), g = clamp01(G), b = clamp01(B)};

clamp_rgb_record(#prophoto_rgb{r = R, g = G, b = B} = Rec) ->
	Rec#prophoto_rgb{r = clamp01(R), g = clamp01(G), b = clamp01(B)};

clamp_rgb_record(#wide_gamut_rgb{r = R, g = G, b = B} = Rec) ->
	Rec#wide_gamut_rgb{r = clamp01(R), g = clamp01(G), b = clamp01(B)};

clamp_rgb_record(#cmy{c = C, m = M, y = Y} = Rec) ->
	Rec#cmy{c = clamp01(C), m = clamp01(M), y = clamp01(Y)};

clamp_rgb_record(#linear_rgb{r = R, g = G, b = B} = Rec) ->
	Rec#linear_rgb{r = clamp01(R), g = clamp01(G), b = clamp01(B)}.

clampr(V, Min, Max) -> max(Min, min(Max, V)).

clamp01(V) -> clampr(V, 0.0, 1.0).

normalize_360(H) ->
	H - 360.0 * math:floor(H / 360.0).


din99lab_coeffs(?DIN99) -> {105.509, 0.0158, 16.0, 0.70, 1.0, 0.045, 0.0, 0.045};
din99lab_coeffs(?DIN99c) -> {317.65, 0.0037, 0.0, 0.94, 23.0, 0.066, 0.0, 1.0};
din99lab_coeffs(?DIN99d) -> {325.22, 0.0036, 50.0, 1.14, 22.5, 0.06, 50.0, 1.0};
din99lab_coeffs(?DIN99o) ->
	{303.67, 0.0039, 26.0, 0.83, 23.0, 0.075, 26.0, 1.0}.  % = DIN99b по Cui, официально DIN99o по DIN 6176



pq_encode(L) when L >= 0 ->
	M1 = 2610 / 16384,
	M2 = 2523 / 32,
	C1 = 3424 / 4096,
	C2 = 2413 / 128,
	C3 = 2392 / 128,
	Nit = 10000,
	Lm1 = math:pow(L / Nit, M1),
	math:pow(
		(C1 + C2 * Lm1) /
			(1 + C3 * Lm1),
		M2).

pq_decode(V) when V >= 0 ->
	M1 = 2610 / 16384,
	M2 = 2523 / 32,
	C1 = 3424 / 4096,
	C2 = 2413 / 128,
	C3 = 2392 / 128,
	Nit = 10000,

	V1 = cbet_math:sign_pow(V, 1 / M2),
	cbet_math:sign_pow(
		max(V1 - C1, 0) /
			(C2 - C3 * V1),
		1 / M1) * Nit.

hlg_encode(L0) when L0 >= 0 ->
	A = 0.17883277,
	B = 0.28466892,
	C = 0.55991073,
	L1 = 12 * L0,
	if
		L1 =< 1 ->
			0.5 * cbet_math:sign_pow(L1, 0.5);
		true ->
			A * math:log(L1 - B) + C
	end.

hlg_decode(V) when V >= 0 ->
	A = 0.17883277,
	B = 0.28466892,
	C = 0.55991073,

	case V =< 0.5 of
		true ->
			(V * V) / 3.0;
		false ->
			(math:exp((V - C) / A) + B) / 12.0
	end.

unwind_ictcp_transfer(L, M, S, ?TRANSFER_PQ) ->
	?VECTOR3(pq_decode(L),
		pq_decode(M),
		pq_decode(S));

unwind_ictcp_transfer(L, M, S, ?TRANSFER_HLG) ->
	?VECTOR3(hlg_decode(L),
		hlg_decode(M),
		hlg_decode(S)).

apply_ictcp_transfer(L, M, S, ?TRANSFER_PQ) ->
	?VECTOR3(pq_encode(L),
		pq_encode(M),
		pq_encode(S));

apply_ictcp_transfer(L, M, S, ?TRANSFER_HLG) ->
	?VECTOR3(hlg_encode(L),
		hlg_encode(M),
		hlg_encode(S)).


-spec distance(Color1 :: cbet_color(),
	Color2 :: cbet_color(),
	Algo :: color_distance()) -> float().
%%Иллюминант D65
distance(Color1, Color2, ?DELTA_XYZ) ->
	#xyz{x = X1, y = Y1, z = Z1} = convert(Color1, #xyz{illum = ?ILLUM_D65}),
	#xyz{x = X2, y = Y2, z = Z2} = convert(Color2, #xyz{illum = ?ILLUM_D65}),
	DX = X2 - X1, DY = Y2 - Y1, DZ = Z2 - Z1,
	math:sqrt(
		DX * DX + DY * DY + DZ * DZ
	);

%%Иллюминант D50
distance(Color1, Color2, ?DELTA_CIE1976) ->
	#lab{l = L1, a = A1, b = B1} = convert(Color1, #lab{illum = ?ILLUM_D50}),
	#lab{l = L2, a = A2, b = B2} = convert(Color2, #lab{illum = ?ILLUM_D50}),
	DL = L2 - L1, DA = A2 - A1, DB = B2 - B1,
	math:sqrt(
		DL * DL + DA * DA + DB * DB
	);

%%Иллюминант D50
distance(Color1, Color2, ?DELTA_CIE94) ->
	#lab{l = L1, a = A1, b = B1} = convert(Color1, #lab{illum = ?ILLUM_D50}),
	#lab{l = L2, a = A2, b = B2} = convert(Color2, #lab{illum = ?ILLUM_D50}),
	C1 = math:sqrt(A1 * A1 + B1 * B1),
	C2 = math:sqrt(A2 * A2 + B2 * B2),
	DL = L2 - L1,
	DC = C2 - C1,
	DH_sq = (A2 - A1) * (A2 - A1) + (B2 - B1) * (B2 - B1) - DC * DC,
	DH = math:sqrt(max(0.0, DH_sq)),
	KL = 1.0, KC = 1.0, KH = 1.0,
	SL = 1.0,
	SC = 1.0 + 0.045 * C1,
	SH = 1.0 + 0.015 * C1,
	math:sqrt(
		(DL / (KL * SL)) * (DL / (KL * SL)) +
			(DC / (KC * SC)) * (DC / (KC * SC)) +
			(DH / (KH * SH)) * (DH / (KH * SH))
	);

%%Иллюминант D50
distance(Color1, Color2, ?DELTA_CIEDE2000) ->
	#lab{l = L1, a = A1, b = B1} = convert(Color1, #lab{illum = ?ILLUM_D50}),
	#lab{l = L2, a = A2, b = B2} = convert(Color2, #lab{illum = ?ILLUM_D50}),

	%% Chroma
	C1 = math:sqrt(A1 * A1 + B1 * B1),
	C2 = math:sqrt(A2 * A2 + B2 * B2),
	CBar = (C1 + C2) / 2.0,

	%% Коррекция a'
	G = 0.5 * (1 - math:sqrt(math:pow(CBar, 7) / (math:pow(CBar, 7) + math:pow(25, 7)))),
	A1p = (1 + G) * A1,
	A2p = (1 + G) * A2,

	%% Chroma после коррекции
	C1p = math:sqrt(A1p * A1p + B1 * B1),
	C2p = math:sqrt(A2p * A2p + B2 * B2),
	CpBar = (C1p + C2p) / 2.0,

	%% Hue angles в градусах
	H1pRaw = math:atan2(B1, A1p) * 180 / math:pi(),
	H2pRaw = math:atan2(B2, A2p) * 180 / math:pi(),
	H1p = normalize_360(H1pRaw),
	H2p = normalize_360(H2pRaw),

	%% ΔL и ΔC
	DeltaL = L2 - L1,
	DeltaC = C2p - C1p,

	%% ΔH'
	Tol = 1.0e-6,
	DeltaHRaw =
		if
			C1p * C2p =< Tol -> 0;
			abs(H2p - H1p) =< 180 -> H2p - H1p;
			H2p - H1p > 180 -> H2p - H1p - 360;
			true -> H2p - H1p + 360
		end,
	DeltaH = 2 * math:sqrt(C1p * C2p) * math:sin(math:pi() * DeltaHRaw / 360.0),

	%% Средние значения
	LpBar = (L1 + L2) / 2.0,
	SumH = H1p + H2p,
	HpBar =
		if
			C1p * C2p =< Tol -> SumH;
			abs(H1p - H2p) =< 180 -> SumH / 2.0;
			SumH < 360 -> (SumH + 360) / 2.0;
			true -> (SumH - 360) / 2.0
		end,

	%% Трансформация H'
	T = 1 - 0.17 * math:cos(math:pi() * (HpBar - 30) / 180) +
		0.24 * math:cos(math:pi() * (2 * HpBar) / 180) +
		0.32 * math:cos(math:pi() * (3 * HpBar + 6) / 180) -
		0.20 * math:cos(math:pi() * (4 * HpBar - 63) / 180),

	DeltaTheta = 30 * math:exp(-math:pow((HpBar - 275) / 25, 2)),
	RC = 2 * math:sqrt(math:pow(CpBar, 7) / (math:pow(CpBar, 7) + math:pow(25, 7))),

	SL = 1 + ((0.015 * math:pow(LpBar - 50, 2)) / math:sqrt(20 + math:pow(LpBar - 50, 2))),
	SC = 1 + 0.045 * CpBar,
	SH = 1 + 0.015 * CpBar * T,
	RT = -math:sin(math:pi() * 2 * DeltaTheta / 180) * RC,

	%% Финальный ΔE00
	math:sqrt(
		(DeltaL / SL) * (DeltaL / SL) +
			(DeltaC / SC) * (DeltaC / SC) +
			(DeltaH / SH) * (DeltaH / SH) +
			RT * (DeltaC / SC) * (DeltaH / SH)
	);

%%Иллюминант D65
distance(Color1, Color2, ?DELTA_ITURBT21240) ->
	#ictcp{i = I1, ct = P1, cp = T1} =
		convert(Color1,
			#ictcp{illum = ?ILLUM_D65, transfer = ?TRANSFER_PQ}),
	#ictcp{i = I2, ct = P2, cp = T2} =
		convert(Color2,
			#ictcp{illum = ?ILLUM_D65, transfer = ?TRANSFER_PQ}),
	DI = I2 - I1, DP = P2 - P1, DT = T2 - T1,
	math:sqrt(
		DI * DI + DP * DP + DT * DT
	);


%%Иллюминант D65
distance(Color1, Color2, ?DELTA_OKLAB) ->
	#lab{l = L1, a = A1, b = B1} = convert(Color1, #oklab{illum = ?ILLUM_D65}),
	#lab{l = L2, a = A2, b = B2} = convert(Color2, #oklab{illum = ?ILLUM_D65}),
	DL = L2 - L1, DA = A2 - A1, DB = B2 - B1,
	math:sqrt(
		DL * DL + DA * DA + DB * DB
	).


-spec interpolate(
	Color1 :: cbet_color(),
	Color2 :: cbet_color(),
	Space :: #lab{},        %% промежуточное пространство на данный момент поддерживается только Lab
	Steps :: pos_integer(), %% ≥2
	ResultSpace :: cbet_color()   %% структура, в которой хотим получить результат
) -> {ok, [cbet_color()]}.

interpolate(Color1, Color2, #lab{} = Space,
	Steps, ResultSpace) when is_integer(Steps), Steps >= 2 ->

	#lab{l = L1, a = A1, b = B1} = convert(Color1, Space),
	#lab{l = L2, a = A2, b = B2} = convert(Color2, Space),

	Result = lists:map(
		fun(I) ->
			Factor = I / (Steps - 1),

			% Интерполяция с возможным ограничением значений
			L = clampr(L1 + (L2 - L1) * Factor, 0, 100),
			A = clampr(A1 + (A2 - A1) * Factor, -128, 127),
			B = clampr(B1 + (B2 - B1) * Factor, -128, 127),

			convert(Space#lab{l = L, a = A, b = B}, ResultSpace)
		end,
		lists:seq(0, Steps - 1)
	),

	{ok, Result}.



-spec srgbtohex(SRGB :: #srgb{}) -> binary().
srgbtohex(SRGB) ->
	srgbtohex(SRGB, #{}).

-type srgbtohex_opts() :: #{prefix := binary}.

-spec srgbtohex(SRGB :: #srgb{}, Opts :: srgbtohex_opts()) -> binary().
%%только D65
srgbtohex(#srgb{r = R, g = G, b = B, illum = ?ILLUM_D65}, Opts) ->
	Prefix = maps:get(prefix, Opts, <<"">>),
	Hex = binary:encode_hex(<<
		(round(R * 255)):8,
		(round(G * 255)):8,
		(round(B * 255)):8
	>>),
	<<Prefix/binary, Hex/binary>>.

-spec srgbto8bit(SRGB :: #srgb{}) -> {pos_integer(), pos_integer(), pos_integer()}.
srgbto8bit(#srgb{r = R, g = G, b = B, illum = ?ILLUM_D65}) ->
	{round(R * 255), round(G * 255), round(B * 255)}.


-spec hextosrgb(Hex :: binary()) -> #srgb{}.
hextosrgb(Hex) ->
	hextosrgb(Hex, #{}).

-type hextosrgb_opts() :: #{
prefixes := [binary()], %% список допустимых префиксов, по умолчанию <<"0x">>, <<"0X">>, <<"#">>, <<"16#">>
allow_short := boolean() %% разрешать короткую запись типа "#f00" (по умолч. true)
}.

-spec hextosrgb(Hex :: binary(), Opts :: hextosrgb_opts()) -> #srgb{}.
hextosrgb(Hex, Opts) ->
	ValidPrefixes = maps:get(prefixes, Opts,
		[<<"#">>, <<"0x">>, <<"0X">>, <<"16#">>]),
	AllowShort = maps:get(allow_short, Opts, true),

	F = fun
			F(X, []) -> X;
			F(X, [Pref | Rest]) ->
				case string:prefix(X, Pref) of
					nomatch -> F(X, Rest);
					Else -> Else
				end
		end,
	Hex1 = F(Hex, ValidPrefixes),
	case Hex1 of
		<<RB:2/binary, GB:2/binary, BB:2/binary>> ->
			#srgb{
				r = erlang:binary_to_integer(RB, 16) / 255.0,
				g = erlang:binary_to_integer(GB, 16) / 255.0,
				b = erlang:binary_to_integer(BB, 16) / 255.0
			};
		<<RB:1/binary, GB:1/binary, BB:1/binary>> when AllowShort ->
			RB1 = erlang:binary_to_integer(RB, 16),
			GB1 = erlang:binary_to_integer(GB, 16),
			BB1 = erlang:binary_to_integer(BB, 16),
			#srgb{
				r = ((RB1 bsl 4) + RB1) / 255.0,
				g = ((GB1 bsl 4) + GB1) / 255.0,
				b = ((BB1 bsl 4) + BB1) / 255.0
			}
	end.


-spec named_color(Name :: binary(),
	Format :: hex | '8byte' | srgb) -> {ok, #srgb{}|{integer(), integer(), integer()|binary()}} | {error, not_found}.
named_color(Name, Format) ->
	case  cbet_named_colors:named_color(Name) of
		{Hex, {R, G, B}} ->
			case Format of
				hex -> {ok, Hex};
				'8byte' -> {ok, {R, G, B}};
				srgb -> {ok, #srgb{r = R / 255.0, g = G / 255.0,
					b = B / 255.0}}
			end;
		Else -> Else
	end.


-spec lrv(Color :: cbet_color()) -> float().

lrv(Color) ->
	#xyz{y = Y} = convert(Color, #xyz{illum = ?ILLUM_C}),
	Y.


%%=====================================================================
%%                              CAM 16
%%				similar to the one in the python lib colour
%%=====================================================================
-spec cam16_model(
	{float(), float(), float()},  %% XYZ объекта
	{float(), float(), float()} | illuminant(),  %% White XYZ
	float(),                      %% L_A (cd/m²)
	float()                     %% Y_b (относительная яркость фона)
) -> #cam16{}.
cam16_model(XYZ, WP, L_A, Y_b) ->
	cam16_model(XYZ, WP, L_A, Y_b, #{}).

-spec cam16_model(
	{float(), float(), float()},  %% XYZ объекта
	{float(), float(), float()} | illuminant(),  %% White XYZ
	float(),                      %% L_A (cd/m²)
	float(),                      %% Y_b (относительная яркость фона)
	#{surround := cam16_surround(),
	discount_illuminant := boolean(),
	d := undefined|float()}                         %% Opts
) -> #cam16{}.
cam16_model(?VECTOR3(_, _, _) = XYZ, WP, L_A, Y_b, Opts) ->
	?VECTOR3(_X_w, Y_w, _Z_w) = illum(WP),

	%% --- Surround preset ---
	SurroundPreset = maps:get(surround, Opts, ?CAM16_SURROUND_AVERAGE),
	{F, C_sur, N_c} = cam16_in_surround(SurroundPreset),

	%% --- Discount illuminant ---
	DiscountIlluminant = maps:get(discount_illuminant, Opts, false),

	%%	 D (степень адаптации)
	D_override = maps:get(d, Opts, undefined),
	?assert((D_override == undefined) orelse
		(D_override >= 0.0 andalso D_override =< 1.0)),
	D = case DiscountIlluminant of
			true -> 1.0;
			false ->
				case D_override of
					undefined -> cam16_compute_D(F, L_A);
					D_val -> D_val
				end
		end,

	%% Вычисление опорной яркости, фонового фактора
	{N, N_bb, N_cb, Zfactor} = cam16_background_factors(Y_b, Y_w, L_A),

	F_L = cam16_F_L(L_A),
	RGB_w = cbet_math:mulv(?CAT16_M, WP),

	D_RGB = cam16_compute_d_rgb(D, Y_w, RGB_w),

	RGB_wc = cbet_math:mulv(D_RGB, RGB_w),


	%%компрессия
	RGB_aw = cam16_non_linear_RGB(
		RGB_wc, F_L
	),

	A_w = cam16_achromatic_response_forward(RGB_aw, N_bb),

	%%Sharpened RGB
	RGB = cbet_math:mulv(?CAT16_M, XYZ),

	RGB_c = cbet_math:mulv(D_RGB, RGB),

	RGB_a = cam16_non_linear_RGB(
		RGB_c, F_L
	),

	{A_raw, B} = cam16_RGB_to_ab(RGB_a),

	H = cam16_hue_angle(A_raw, B),

	A = cam16_achromatic_response_forward(RGB_a, N_bb),

	Hq = cam16_hue_quad(H),

	J = cam16_lightness(A, A_w, C_sur, Zfactor),
	C = cam16_chroma(A_raw, B, N_cb, N_c, RGB_a, J, N, H),
	M = cam16_colorfulness(C, F_L),
	Q = cam16_brightness(C_sur, J, A_w, F_L),
	S = cam16_saturation(M, Q),

	#cam16{
		j = J,
		c = C,
		h_angle = H,

		m = M,
		s = S,
		q = Q,
		h_quad = Hq,
		a = A,
		b = B,
		d = D,
		f = F,
		c_sur = C_sur,
		n_c = N_c
	}.



cam16_in_surround(?CAM16_SURROUND_AVERAGE) -> {1.0, 0.69, 1.0};
cam16_in_surround(?CAM16_SURROUND_DIM) -> {0.9, 0.59, 0.9};
cam16_in_surround(?CAM16_SURROUND_DARK) -> {0.8, 0.525, 0.8};
cam16_in_surround({F1, C1, N1} = Presets) when is_float(F1), is_float(C1), is_float(N1) ->
	Presets.

-spec cam16_compute_D(F :: float(), L_A :: float()) -> float().
cam16_compute_D(F, L_A) ->
	RawD = F * (1.0 - (1.0 / 3.6) * math:exp(-(L_A + 42.0) / 92.0)),
	%% Ограничение на диапазон 0..1
	clamp01(RawD).


%%---------------------------------------------------
%% CAM16 вспомогательные функции
%%---------------------------------------------------

%% Нелинейное преобразование яркости (response compression)
-spec cam16_non_linear_RGB({float(), float(), float()}, float()) ->
	{float(), float(), float()}.
cam16_non_linear_RGB(?VECTOR3(L, M, S) = _LMS, F_L) ->
	Compress = fun(V) ->
		Vp = (F_L * V / 100.0),
		400.0 * cbet_math:safe_pow(Vp, 0.42) / (cbet_math:safe_pow(Vp, 0.42) + 27.13)
			+ 0.1
			   end,
	?VECTOR3(Compress(L), Compress(M), Compress(S)).

%% Фоновый фактор: N_bb, N_cb, Z
-spec cam16_background_factors(float(), float(), float()) -> {float(), float(), float()}.
cam16_background_factors(Y_b, Y_w, L_A) when Y_b > 0, Y_w > 0, L_A > 0 ->
	N = Y_b / Y_w,

	N_bb = 0.725 * cbet_math:safe_pow(1.0 / N, 0.2),
	N_cb = N_bb,

	Z = 1.48 + math:sqrt(N),
	{N, N_bb, N_cb, Z}.

-spec cam16_RGB_to_ab({float(), float(), float()}) -> {float(), float()}.
cam16_RGB_to_ab(?VECTOR3(L_c, M_c, S_c) = _LMS_c) ->
	A = L_c - 12.0 * M_c / 11.0 + S_c / 11.0,
	B = (L_c + M_c - 2.0 * S_c) / 9.0,
	{A, B}.

%% Hue angle (H) в градусах
-spec cam16_hue_angle(float(), float()) -> float().
cam16_hue_angle(A, B) ->
	H_rad = math:atan2(B, A),
	H_deg = H_rad * 180.0 / math:pi(),
	%% нормализуем в [0, 360]
	normalize_360(H_deg).

%% Функция для F_L (фактор нелинейной яркости)
-spec cam16_F_L(float()) -> float().
cam16_F_L(L_A) ->
	K = 1.0 / (5.0 * L_A + 1.0),
	KPow4 = K * K * K * K,
	0.2 * KPow4 * (5.0 * L_A) +
		0.1 * cbet_math:safe_pow(1 - KPow4, 2) * cbet_math:safe_pow(5 * L_A, 1 / 3).


%% Chroma (C)
-spec cam16_chroma(float(), float(), float(), float(), float(), float(), float(), float()) -> float().
cam16_chroma(A_raw, B, N_cb, N_c, ?VECTOR3(Ra, Ga, Ba) = _RGB_a, J, N, H) ->
	Et = 0.25 * (math:cos(2 + H * math:pi() / 180.0) + 3.8),
	T = ((50000 / 13) * N_c * N_cb) *
		(Et * cbet_math:sign_pow(math:pow(A_raw, 2) + math:pow(B, 2), 0.5)) /
		(Ra + Ga + 21 * Ba / 20),
	cbet_math:sign_pow(T, 0.9) *
		cbet_math:sign_pow(J / 100, 0.5) *
		cbet_math:sign_pow(1.64 - math:pow(0.29, N), 0.73).

%% Lightness (J)
-spec cam16_lightness(float(), float(), float(), float()) -> float().
cam16_lightness(A, A_w, C_sur, Z) ->
	%% Формула CAM16 для J
	J_ratio = A / A_w,
	J = 100.0 * cbet_math:safe_pow(J_ratio, C_sur * Z),
	J.

%% Colorfulness (M)
-spec cam16_colorfulness(float(), float()) -> float().
cam16_colorfulness(C, F_L) ->
	cbet_math:safe_pow(F_L, 0.25) * C.

-spec cam16_brightness(float(), float(), float(), float()) -> float().
cam16_brightness(C, J, A_w, F_L) ->
	(4 / C) * math:sqrt(J / 100) * (A_w + 4) * cbet_math:sign_pow(F_L, 0.25).

%% Saturation (s)
-spec cam16_saturation(float(), float()) -> float().
cam16_saturation(M, Q) ->
	100.0 * cbet_math:sign_pow(M / Q, 0.5).

normalize_deg(Deg) ->
	D0 = Deg - 360.0 * math:floor(Deg / 360.0),
	case D0 < 0.0 of
		true -> D0 + 360.0;
		false -> D0
	end.

-spec cam16_hue_quad(float()) -> float().
cam16_hue_quad(H0) ->
	H = normalize_deg(H0),
	{{II_h, II_e, II_H}, {II_h1, II_e1, _}} =
		if
			H >= 20.14, H < 90.0 -> {{20.14, 0.8, 0.0}, {90.00, 0.7, 100.0}};
			H >= 90.0, H < 164.25 -> {{90.00, 0.7, 100.0}, {164.25, 1.0, 200.0}};
			H >= 164.25, H < 237.53 -> {{164.25, 1.0, 200.0}, {237.53, 1.2, 300.0}};
			true -> {{237.53, 1.2, 300.0}, {380.14, 0.8, 400.0}}
		end,

	Hq1 = II_H + ((100 * (H - II_h) / II_e) / ((H - II_h) / II_e + (II_h1 - H) / II_e1)),
	if
		H =< 20.14 -> 385.9 + (14.1 * H / 0.856) / (H / 0.856 + (20.14 - H) / 0.8);
		H >= 237.53 -> II_H + ((85.9 * (H - II_h) / II_e) / ((H - II_h) / II_e + (360 - H) / 0.856));
		true -> Hq1
	end.


-spec cam16_achromatic_response_forward({float(), float(), float()}, float()) -> float().
cam16_achromatic_response_forward(?VECTOR3(R, G, B), N_bb) ->
	(2.0 * R + G + 0.05 * B - 0.305) * N_bb.


cam16_compute_d_rgb(D, Y_w, {Rw, Gw, Bw}) ->
	D3 = {D, D, D},
	cbet_math:addv(
		cbet_math:mulv(D3, {Y_w / Rw, Y_w / Gw, Y_w / Bw}),
		cbet_math:subv({1.0, 1.0, 1.0}, D3)
	);

cam16_compute_d_rgb(Ds, Y_w, RGB_w) when is_list(Ds) ->
	[cam16_compute_d_rgb(D, Y_w, RGB_w) || D <- Ds].


%%=====================================================================
%%                           Nayatani et al.
%%			similar to the one in the python lib colour
%%=====================================================================

-spec nayatani_model(
	{float(), float(), float()},  %% XYZ объекта
	{float(), float(), float()} | illuminant(),  %% White XYZ
	float(),                      %% Yo luminance factor  [0.18, 1.0]
	float(),                      %% Eo Illuminance in lux
	float()                      %% Eor normalising illuminance in lux
) -> #nayatani{}.

nayatani_model(XYZ, WP, Yo, Eo, Eor) ->
	nayatani_model(XYZ, WP, Yo, Eo, Eor, #{}).

-spec nayatani_model(
	{float(), float(), float()},  %% XYZ объекта
	{float(), float(), float()} | illuminant(),  %% White XYZ
	float(),                      %% Yo luminance factor  [0.18, 1.0]
	float(),                      %% Eo Illuminance in lux
	float(),                      %% Eor normalising illuminance in lux
	#{n := number()} %%Noise term                         %% Opts
) -> #nayatani{}.

nayatani_model(?VECTOR3(_, _, _) = XYZ,
	WP, Yo, Eo, Eor, Opts) ->
	WP1 = illum(WP),
	N = maps:get(n, Opts, 1.0),

	Lor = nayatani_adapting_luminance(Yo, Eor),

	{Xw, Yw} = chromaticity(WP1),

	{Xi, Eta, _Zeta} = IntrVals = nayatani_eta_zeta(Xw, Yw),

	RGBo = nayatani_spectral_to_rgb_mono(Yo, Eo, IntrVals),

	{R, G, _B} = RGB = cbet_math:mulv(?VON_KRIES_M, XYZ),

	BRGBo = nayatani_exponential_factors(RGBo),
	BLor = nayatani_beta_1(Lor),

	ER = nayatani_scaling_coefficient(R, Xi),
	EG = nayatani_scaling_coefficient(G, Eta),

	Qresp = nayatani_achromatic_response(RGB, BRGBo, IntrVals, BLor, ER, EG, N),

	Tresp = nayatani_tritanopic_response(RGB, BRGBo, IntrVals, N),

	Presp = nayatani_protanopic_response(RGB, BRGBo, IntrVals, N),

	Br = nayatani_brightness(BRGBo, BLor, Qresp),
	BrW = nayatani_brightness_ideal_white(BRGBo, IntrVals, BLor, N),

	LstP = Qresp + 50,
	LstN = 100 * (Br / BrW),

	Theta = cbet_math:floor_mod(cbet_math:degrees(math:atan2(Presp, Tresp)), 360),

	{S_RG, S_YB} = nayatani_saturation_components(Theta, BLor, Tresp, Presp),

	S = nayatani_saturation(S_RG, S_YB),

	C = nayatani_chroma(LstP, S),

	HQ = nayatani_hue_quad(Theta),
	{HC_segment, HC} = nayatani_hue_composition(Theta, S_RG, S_YB),

	M = nayatani_colorfullness(C, BrW),


	#nayatani{
		lstar_p = LstP,
		lstar_n = LstN,
		c = C,
		h_angle = Theta,
		s = S,
		q = Br,
		m = M,
		h_q = HQ,         %% Hue quadrature
		h_c_segment = HC_segment,
		h_c = HC          %% Hue composition
	}.

%%


nayatani_adapting_luminance(Y, E) ->
	Y * E / (100 * math:pi()).

nayatani_eta_zeta(Xw, Yw) ->
	{
		(0.48105 * Xw + 0.78841 * Yw - 0.08081) / Yw,
		(-0.27200 * Xw + 1.11962 * Yw + 0.04570) / Yw,
		(0.91822 * (1 - Xw - Yw)) / Yw
	}.

nayatani_spectral_to_rgb_mono(Y, E, ?VECTOR3(Rf, Gf, Bf)) ->
	Const = 100.0 * math:pi(),
	Scale = (Y * E) / Const,
	cbet_math:scalev(?VECTOR3(Rf, Gf, Bf), Scale).

nayatani_exponential_factors(?VECTOR3(Ro, Go, Bo) = _RGBo) ->
	?VECTOR3(
		nayatani_beta_1(Ro),
		nayatani_beta_1(Go),
		nayatani_beta_2(Bo)
	).


nayatani_beta_1(X) ->
	(6.469 + 6.362 * cbet_math:sign_pow(X, 0.4495)) /
		(6.469 + cbet_math:sign_pow(X, 0.4495)).

nayatani_beta_2(X) ->
	0.7844 * (8.414 + 8.091 * cbet_math:sign_pow(X, 0.5128)) /
		(8.414 + cbet_math:sign_pow(X, 0.5128)).


nayatani_scaling_coefficient(X, Y) ->
	if
		X >= (20 * Y) -> 1.758;
		true -> 1.0
	end.

nayatani_achromatic_response(?VECTOR3(R, G, _B) = _RGB,
	?VECTOR3(BRo, BGo, _BBo) = _BRGBo,
	?VECTOR3(Xi, Eta, _Zeta) = _IntrVals, BLor, ER, EG, N) ->

	(
		(2 / 3) * BRo * ER * math:log10((R + N) / (20 * Xi + N)) +
			(1 / 3) * BGo * EG * math:log10((G + N) / (20 * Eta + N))
	) * 41.69 / BLor.

nayatani_tritanopic_response(?VECTOR3(R, G, B) = _RGB,
	?VECTOR3(BRo, BGo, BBo) = _BRGBo,
	?VECTOR3(Xi, Eta, Zeta) = _IntrVals, N) ->

	BRo * math:log10((R + N) / (20 * Xi + N)) -
		(12 / 11) * BGo * math:log10((G + N) / (20 * Eta + N)) +
		(1 / 11) * BBo * math:log10((B + N) / (20 * Zeta + N)).


nayatani_protanopic_response(?VECTOR3(R, G, B) = _RGB,
	?VECTOR3(BRo, BGo, BBo) = _BRGBo,
	?VECTOR3(Xi, Eta, Zeta) = _IntrVals, N) ->

	(1 / 9) * BRo * math:log10((R + N) / (20 * Xi + N)) +
		(1 / 9) * BGo * math:log10((G + N) / (20 * Eta + N)) -
		(2 / 9) * BBo * math:log10((B + N) / (20 * Zeta + N)).


nayatani_brightness(?VECTOR3(BRo, BGo, _BBo) = _BRGBo, BLor, Qresp) ->
	(50 / BLor) * ((2 / 3) * BRo + (1 / 3) * BGo) + Qresp.


nayatani_brightness_ideal_white(?VECTOR3(BRo, BGo, _BBo) = _BRGBo,
	?VECTOR3(Xi, Eta, _Zeta) = _IntrVals, BLor, N) ->

	(
		(2 / 3) * BRo * 1.758 * math:log10((100 * Xi + N) / (20 * Xi + N)) +
			(1 / 3) * BGo * 1.758 * math:log10((100 * Eta + N) / (20 * Eta + N))
	) * 41.69 / BLor +
		(50 / BLor) * (2 / 3) * BRo +
		(50 / BLor) * (1 / 3) * BGo.


nayatani_saturation_components(Theta, BLor, Tresp, Presp) ->
	ThetaRad = cbet_math:radians(Theta),
	Es = 0.9394 - 0.2478 * math:sin(ThetaRad) - 0.0743 * math:sin(2 * ThetaRad)
		+ 0.0666 * math:sin(3 * ThetaRad) - 0.0186 * math:sin(4 * ThetaRad)
		- 0.0055 * math:cos(1 * ThetaRad) - 0.0521 * math:cos(2 * ThetaRad)
		- 0.0573 * math:cos(3 * ThetaRad) - 0.0061 * math:cos(4 * ThetaRad),
	{
		(488.93 / BLor) * Es * Tresp,
		(488.93 / BLor) * Es * Presp
	}.


nayatani_saturation(SRG, SYB) ->
	math:sqrt(SRG * SRG + SYB * SYB).


nayatani_chroma(LstP, S) ->
	cbet_math:sign_pow(LstP / 50, 0.7) * S.


nayatani_colorfullness(C, BrW) ->
	C * BrW / 100.

nayatani_hue_quad(H) ->
	{{II_h, II_e, II_H}, {II_h1, _II_e1, II_H1}} =
		if
			H >= 0.0, H < 90.0 -> {{0.0, 0.0, 0.8}, {90.0, 100.0, 0.7}};
			H >= 90.0, H < 180.0 -> {{90.0, 100.0, 0.7}, {180.0, 200.0, 1.0}};
			H >= 180.0, H < 270.0 -> {{180.0, 200.0, 1.0}, {270.0, 300.0, 1.2}};
			true -> {{270.0, 300.0, 1.2}, {360.0, 400.0, 0.8}}
		end,

	Num = 100.0 * (H - II_h),
	Den = (H - II_h) +
		(II_H / II_H1) * (II_h1 - H),
	II_e + Num / Den.

nayatani_hue_composition(H, S_RG, S_YB) ->
	Segment = if
				  H >= 0.0, H < 90 -> r_y;
				  H >= 90, H < 180 -> y_g;
				  H >= 180, H < 270 -> g_b;
				  true -> b_r
			  end,
	Sum = S_RG + S_YB,

	Tol = 1.0e-7,

	if
		abs(Sum) =< Tol -> {Segment, 0.0};
		true -> {Segment, S_YB / Sum}
	end.


%%=====================================================================
%%                           Hunt
%% 			similar to the one in the python lib 'colourmath',
%% 						with a fixed bug (Zp)
%%=====================================================================
-spec hunt_model(
	{float(), float(), float()},  %% XYZ объекта
	{float(), float(), float()} | illuminant(),  %% White XYZ
	{float(), float(), float()} | illuminant(),  %% Backgrpund XYZ
	float(),                      %% L_A (cd/m²)
	hunt_surround() | {float(), float()} |{float(), float(), float() | undefined, float() | undefined}
) -> #hunt{}.

hunt_model(XYZ,  WP, BgP, La, Surround) ->
	hunt_model(XYZ,  WP, BgP, La, Surround, #{}).

-spec hunt_model(
	{float(), float(), float()},  %% XYZ объекта
	{float(), float(), float()} | illuminant(),  %% White XYZ
	{float(), float(), float()} | illuminant(),  %% Backgrpund XYZ
	float(),                      %% L_A (cd/m²)
	hunt_surround() | {float(), float()} |{float(), float(), float() | undefined, float() | undefined},
	#{
		helson_judd_effect := boolean(),
		discount_illuminant := boolean(),
		xyz_p := {float(), float(), float()} | illuminant(),
		p := float() | undefined,
		l_as := float() | undefined,
		cct_w := float() | undefined,
		s := float() | undefined,
		s_w := float() | undefined
	}
) -> #hunt{}.

hunt_model(?VECTOR3(_X, Y, _Z) = XYZ, WP, BgP, La, SurroundPreset, Opts) ->
	?VECTOR3(_Xw, Yw, _Zw) = XYZw = illum(WP),
	?VECTOR3(_Xb, Yb, _Zb) = XYZb = illum(BgP),

	%%0опциональные параметры
	HelsonJudd = maps:get(helson_judd_effect, Opts, true),
	DiscountIlluminant = maps:get(discount_illuminant, Opts, false),
	XYZp = illum(maps:get(xyz_p, Opts, XYZb)),
	P = maps:get(p, Opts, undefined),

	DefaultNcbNbb = 0.725 * cbet_math:sign_pow(Yw / Yb, 0.2),
	{Nc, Nb, Ncb, Nbb} = hunt_in_surround(SurroundPreset, DefaultNcbNbb),

	LAS = case Opts of
			  #{l_as := LASv} when LASv =/= undefined ->
				  LASv;
			  #{cct_w := CCTw} when CCTw =/= undefined -> 
				  hunt_illuminant_scotopic_luminance(La, CCTw);
			  _ ->
				  error({badarg, <<"Either l_as or cct_w must be specified">>})
		  end,

	S_  = maps:get(s, Opts, undefined),
	Sw_ = maps:get(s_w, Opts, undefined),

	{Sp, Swp} = case {S_, Sw_} of
					{undefined, undefined} ->
						{Y, Yw};
					{S1, Sw1} when S1 =/= undefined, Sw1 =/= undefined ->
						{S1, Sw1};
					_ ->
						error({badarg, <<"Either both s and s_w must be undefined (not specified) or neither of them">>})
				end,


	FL = hunt_luminance_level_adaptation_factor(La),

	RGBa = hunt_chromatic_adaptation(
        XYZ,
        XYZw,
        XYZb,
        La,
        FL,
        XYZp,
        P,
        HelsonJudd,
        DiscountIlluminant
    ),

	RGBaw = hunt_chromatic_adaptation(
		XYZw,
		XYZw,
		XYZb,
		La,
		FL,
		XYZp,
		P,
		HelsonJudd,
		DiscountIlluminant
	),

	Aa = hunt_achromatic_post_adaptation_signal(RGBa),
	Aaw = hunt_achromatic_post_adaptation_signal(RGBaw),

	C = hunt_colour_difference_signals(RGBa),
	Cw = hunt_colour_difference_signals(RGBaw),

	%%	Hue angle
	H = hunt_hue_angle(C),

	Hq = hunt_hue_quad(H),

	Es = hunt_eccentricity_factor(H),

	%%low luminance tritanopia factor
	Ft = La / (La + 0.1),

	Myb = hunt_yb_response(C, Es, Nc, Ncb, Ft),
	Mrg = hunt_rg_response(C, Es, Nc, Ncb),

	MybW = hunt_yb_response(Cw, Es, Nc, Ncb, Ft),
	MrgW = hunt_rg_response(Cw, Es, Nc, Ncb),

	M = hunt_overall_chromatic_response(Myb, Mrg),
	Mw = hunt_overall_chromatic_response(MybW, MrgW),

	S = hunt_saturation(M, RGBa),

	A = hunt_achromatic_signal(LAS, Sp, Swp, Nbb, Aa),
	Aw = hunt_achromatic_signal(LAS, Swp, Swp, Nbb, Aaw),
	Q = hunt_brightness(A, Aw, M, Nb),
    Qw = hunt_brightness(Aw, Aw, Mw, Nb),

	%%	whiteness-blackness
	Qwb = 100.0 * Q / Qw,


	J = hunt_lightness(Yb, Yw, Q, Qw),

	Chroma = hunt_chroma(S, Yb, Yw, Q, Qw),

	Colorfulness = cbet_math:sign_pow(FL, 0.15) * Chroma,

	#hunt{
		j = J,
		c = Chroma,
		h_angle = H,
		s = S,
		q = Q,
		m = Colorfulness,
		h_q = Hq,
		q_wb = Qwb
	}.


%%nc, Nb, Ncb, Nbb
hunt_in_surround(?HUNT_SURROUND_SMALL_UNIFORM, Default) ->
	{1, 300, Default, Default};
hunt_in_surround(?HUNT_SURROUND_NORMAL, Default) ->
	{1, 75, Default, Default};
hunt_in_surround(?HUNT_SURROUND_TV_DIM, Default) ->
	{1, 25, Default, Default};
hunt_in_surround(?HUNT_SURROUND_LIGHT_BOX, Default) ->
	{0.7, 25, Default, Default};
hunt_in_surround(?HUNT_SURROUND_PROJECTED_DARK, Default) ->
	{0.7, 10, Default, Default};
hunt_in_surround({X, Y} = _Surround, Default) ->
	{X, Y, Default, Default};
hunt_in_surround({X, Y, undefined, undefined} = _Surround, Default) ->
	{X, Y, Default, Default};
hunt_in_surround({X, Y, Ncb, undefined} = _Surround, Default) ->
	{X, Y, Ncb, Default};
hunt_in_surround({X, Y, undefined, Nbb} = _Surround, Default) ->
	{X, Y, Default, Nbb};
hunt_in_surround({_X, _Y, _Ncb, _Nbb} = Surround, _Default) ->
	Surround.




hunt_illuminant_scotopic_luminance(La, CCT) ->
	2.26 * La * cbet_math:sign_pow((CCT / 4000) - 0.4, 1 / 3).

hunt_luminance_level_adaptation_factor(La) ->
	K = 1.0 / (5.0 * La + 1.0),
	0.2 * math:pow(K, 4) * La +
		0.1 * math:pow(1.0 - math:pow(K, 4), 2) * cbet_math:sign_pow(5.0 * La, 1.0 / 3.0).

hunt_chromatic_adaptation(
	 XYZ, ?VECTOR3(_Xw, Yw, _Zw) = XYZw,
	?VECTOR3(_Xb, Yb, _Zb) = _XYZb,
	La, FL, XYZp, P, HelsonJudd, DiscountIlluminant) ->
	?VECTOR3(R, G, B) = Rgb = cbet_math:mulv(?HUNT_M, XYZ),
	Rgbw = cbet_math:mulv(?HUNT_M, XYZw),

	SumRGB = R + G + B,
	HRgb = ?VECTOR3(
		3 * R / SumRGB, 3 * G / SumRGB, 3 * B / SumRGB
	),

	FRgb = hunt_frgb(La, HRgb, DiscountIlluminant),

	DRgb = hunt_helson_judd_effect(Yb, Yw, FL, FRgb, HelsonJudd),

	BRgb = hunt_cone_bleach_factors(La,  XYZw),

	Rgbw1 = hunt_adjusted_reference_white(XYZp, BRgb, Rgbw, P),

	hunt_adapted_cone_response(BRgb, FL, FRgb, Rgb, Rgbw1, DRgb).


hunt_frgb(_La, _HRgb, true)->
	?VECTOR3(1.0, 1.0, 1.0);
hunt_frgb(La, ?VECTOR3(HR, HG, HB) = _HRgb, false) ->
	Lap = cbet_math:sign_pow(La, 1 / 3),
	?VECTOR3(
		(1.0 + Lap + HR) / (1.0 + Lap + 1.0 / HR),
		(1.0 + Lap + HG) / (1.0 + Lap + 1.0 / HG),
		(1.0 + Lap + HB) / (1.0 + Lap + 1.0 / HB)
	).


hunt_helson_judd_effect(Yb, Yw, FL, ?VECTOR3(FR, FG, FB) = _FRgb, true) ->
	Yn = (Yb / Yw) * FL,
	?VECTOR3(
		hunt_f_nonlinear_response(Yn * FG) - hunt_f_nonlinear_response(Yn * FR),
		hunt_f_nonlinear_response(Yn * FG) - hunt_f_nonlinear_response(Yn * FG),
		hunt_f_nonlinear_response(Yn * FG) - hunt_f_nonlinear_response(Yn * FB)
	);
hunt_helson_judd_effect(_Yb, _Yw, _FL, _FRgb, false) ->
	?VECTOR3(0.0, 0.0, 0.0).


hunt_f_nonlinear_response(X) ->
    Xp = cbet_math:sign_pow(X, 0.73),
    40.0 * (Xp / (Xp + 2.0)).


hunt_cone_bleach_factors(La, XYZw) ->
	cbet_math:applyv(
		XYZw,
		fun(X) ->
			1.0e7 / (1.0e7 + 5.0 * La * (X / 100.0))
		end
	).

hunt_adjusted_reference_white(_XYZp, _BRgb, Rgbw, undefined) ->
	Rgbw;
hunt_adjusted_reference_white(XYZp,
	BRgb, ?VECTOR3(Rw, Gw, Bw) = _Rgbw, P) ->
	Rgbp = cbet_math:mulv(?HUNT_M, XYZp),
	Prgb = cbet_math:divv(Rgbp, BRgb),

	?VECTOR3(NumR, NumG, NumB) =
		cbet_math:applyv(
			Prgb,
			fun(X) ->
				cbet_math:sign_pow((1.0 - P) * X + (1.0 + P) / X, 0.5)
			end
		),

	?VECTOR3(DenR, DenG, DenB) =
		cbet_math:applyv(
			Prgb,
			fun(X) ->
				cbet_math:sign_pow((1.0 + P) * X + (1.0 - P) / X, 0.5)
			end
		),

	?VECTOR3(
		Rw * NumR / DenR,
		Gw * NumG / DenG,
		Bw * NumB / DenB
	).



hunt_adapted_cone_response(
	?VECTOR3(BR, BG, BB) = _BRgb, FL,
	?VECTOR3(FR, FG, FB) = _FRgb, ?VECTOR3(R, G, B) = _Rgb,
	?VECTOR3(Rw, Gw, Bw) = _Rgbw, ?VECTOR3(DR, DG, DB) = _DRgb) ->

	?VECTOR3(
		1.0 + BR * (hunt_f_nonlinear_response(FL * FR * R / Rw) + DR),
		1.0 + BG * (hunt_f_nonlinear_response(FL * FG * G / Gw) + DG),
		1.0 + BB * (hunt_f_nonlinear_response(FL * FB * B / Bw) + DB)
	).


hunt_achromatic_post_adaptation_signal(?VECTOR3(R, G, B) = _RGB) ->
	 2 * R + G + 0.05 * B - 3.05 + 1.


hunt_colour_difference_signals(?VECTOR3(R, G, B) = _RGB) ->
	?VECTOR3(R - G, G - B, B - R).


hunt_hue_angle(?VECTOR3(C1, C2, C3) = _C) ->
	Y = 0.5 * (C2 - C3) / 4.5,
    X = C1 - (C2 / 11.0),
    Hue = math:atan2(Y, X) * 180.0 / math:pi(),
    cbet_math:floor_mod(Hue, 360.0).


hunt_hue_quad(H0) ->
	H = normalize_deg(H0),
	{{II_h, II_e, II_H}, {II_h1, II_e1, _}} =
		if
			H >= 20.14, H < 90.0 -> {{20.14, 0.8, 0.0}, {90.00, 0.7, 100.0}};
			H >= 90.0, H < 164.25 -> {{90.00, 0.7, 100.0}, {164.25, 1.0, 200.0}};
			H >= 164.25, H < 237.53 -> {{164.25, 1.0, 200.0}, {237.53, 1.2, 300.0}};
			true -> {{237.53, 1.2, 300.0}, {380.14, 0.8, 400.0}}
		end,

	%% линейная интерполяция между узлами
    HC1 = II_H + ((100.0 * (H - II_h) / II_e) / ((H - II_h) / II_e + (II_h1 - H) / II_e1)),

    %% граничные условия для крайних диапазонов Hue
    case H of
        Hn when Hn =< 20.14 ->
            385.9 + (14.1 * Hn / 0.856) / (Hn / 0.856 + (20.14 - Hn) / 0.8);
        Hn when Hn >= 237.53 ->
            II_H + ((85.9 * (Hn - II_h) / II_e) / ((Hn - II_h) / II_e + (360.0 - Hn) / 0.856));
        _ ->
            HC1
    end.


hunt_eccentricity_factor(H0) ->
	Hn = normalize_deg(H0),

    %% Таблица HQ (Pointer/Hunt)
    HS = [20.14, 90.0, 164.25, 237.53],
    ES = [0.8, 0.7, 1.0, 1.2],

    %% 1. Интерполяция
    X = interp(Hn, HS, ES),

	if
		Hn < 20.14 -> 0.856 - (Hn / 20.14) * 0.056;
		Hn > 237.53 -> 0.856 + 0.344 * (360.0 - Hn) / (360.0 - 237.53);
		true -> X
	end.


interp(H, [H1, H2 | _], [E1, E2 | _]) when H >= H1, H =< H2 ->
	%% интерполяция между H1 и H2
	E1 + (E2 - E1) * (H - H1) / (H2 - H1);
interp(H, [_H1, H2 | Hs], [_E1, E2 | Es]) ->
	%% рекурсивно ищем интервал
	interp(H, [H2 | Hs], [E2 | Es]);
interp(_, [_], [E1]) ->
	%% если вышли за пределы таблицы, возвращаем крайнее значение
	E1.


hunt_yb_response(?VECTOR3(_C1, C2, C3) = _C, Es, Nc, Ncb, Ft) ->
	100 * (0.5 * (C2 - C3) / 4.5) * (Es * (10 / 13) * Nc * Ncb * Ft).


hunt_rg_response(?VECTOR3(C1, C2, _C3) = _C, Es, Nc, Ncb) ->
	100 * (C1 - (C2 / 11)) * (Es * (10 / 13) * Nc * Ncb).


hunt_overall_chromatic_response(Myb, Mrg) ->
	cbet_math:sign_pow(Myb*Myb + Mrg*Mrg, 0.5).


hunt_saturation(M, ?VECTOR3(R, G, B) = _RGBa) ->
	50 * M / (R + G + B).

hunt_achromatic_signal(LAS, S, Sw, Nbb, Aa) ->
	K = (5.0 * LAS / 2.26),
	    J = 0.00001 / (K + 0.00001),
	J2 = J * J,
	F_LS = 3800.0 * J2 * K + 0.2 * cbet_math:sign_pow(1.0 - J2, 0.4)
          * cbet_math:sign_pow(K, 1.0 / 6.0),

    %% cone bleach factor
    B_S = 0.5 / (1.0 + 0.3 * cbet_math:sign_pow(K * (S / Sw), 0.3))
        + 0.5 / (1.0 + 5.0 * K),

	%%	adapted scotopic signal
	A_S = hunt_f_nonlinear_response(F_LS * S / Sw) * 3.05 * B_S + 0.3,

	%%	achromatic signal
	Nbb * (Aa - 1.0 + A_S - 0.3 + math:sqrt(1.0 + (0.3 * 0.3))).





hunt_brightness(A, Aw, M, Nb) ->
	N1 =  cbet_math:sign_pow(7.0 * Aw, 0.5) / (5.33 * cbet_math:sign_pow(Nb, 0.13)),

	N2 = (7.0 * Aw * cbet_math:sign_pow(Nb, 0.362)) / 200.0,

	cbet_math:sign_pow(7.0 * (A + (M / 100.0)), 0.6) * N1 - N2.

hunt_lightness(Yb, Yw, Q, Qw) ->
	100 * cbet_math:sign_pow(Q / Qw, 1 + cbet_math:sign_pow(Yb / Yw, 0.5)).

hunt_chroma(S, Yb, Yw, Q, Qw) ->
	2.44 * cbet_math:sign_pow(S, 0.69)
		* (cbet_math:sign_pow(Q / Qw, Yb / Yw))
		* (1.64 - cbet_math:sign_pow(0.29, Yb / Yw)).

