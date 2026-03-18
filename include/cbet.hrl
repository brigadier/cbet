-export_type([illuminant/0, chromatic_adaptation/0, ictcp_transfer/0,
    color_distance/0, din99_algorithm/0, cbet_color_rec/0, cam16_surround/0,
    nayatani_color_composition/0, hunt_surround/0, cbet_color_other/0, cbet_color/0]).


-define(RGB3X8, 'rgb3x8').
-define(RGBINT, 'rgbint').
-define(RGBHEX, 'rgbhex').

%% =====================================================
%% Transfer functons for ICtCp
%% =====================================================
-define(TRANSFER_PQ, 'PQ').
-define(TRANSFER_HLG, 'HLG').

-type ictcp_transfer() :: ?TRANSFER_PQ| ?TRANSFER_HLG.

%% =====================================================
%% Color distance types
%% =====================================================

-define(DELTA_XYZ, 'ΔXYZ').
-define(DELTA_CIE1976, 'ΔE*ab 1976').
-define(DELTA_CIE94, 'ΔE94').
-define(DELTA_CIEDE2000, 'ΔE00').
-define(DELTA_ITURBT21240, 'ΔE_ITP').
-define(DELTA_OKLAB, 'ΔOK').

-type color_distance() ::
      ?DELTA_XYZ
    | ?DELTA_CIE1976
    | ?DELTA_CIE94
    | ?DELTA_CIEDE2000
    | ?DELTA_ITURBT21240
    | ?DELTA_OKLAB.

%% =====================================================
%% DIN99 Lab types
%% =====================================================

-define(DIN99, 'DIN99').
-define(DIN99d, 'DIN99d').
-define(DIN99o, 'DIN99o').
-define(DIN99c, 'DIN99c').

-type din99_algorithm() ::
      ?DIN99
    | ?DIN99d
    | ?DIN99o
    | ?DIN99c.

%% =====================================================
%% Illuminant Identifiers
%% =====================================================

-define(ILLUM_A,   'A').
-define(ILLUM_B,   'B').
-define(ILLUM_C,   'C').

-define(ILLUM_D50, 'D50').
-define(ILLUM_D55, 'D55').
-define(ILLUM_D60, 'D60').
-define(ILLUM_D63, 'D63').
-define(ILLUM_D65, 'D65').
-define(ILLUM_D70, 'D70').
-define(ILLUM_D75, 'D75').
-define(ILLUM_D93, 'D93').

-define(ILLUM_F1,  'F1').
-define(ILLUM_F2,  'F2').
-define(ILLUM_F3,  'F3').
-define(ILLUM_F4,  'F4').
-define(ILLUM_F5,  'F5').
-define(ILLUM_F6,  'F6').
-define(ILLUM_F7,  'F7').
-define(ILLUM_F8,  'F8').
-define(ILLUM_F9,  'F9').
-define(ILLUM_F10, 'F10').
-define(ILLUM_F11, 'F11').
-define(ILLUM_F12, 'F12').

-define(ILLUM_F13, 'F13').
-define(ILLUM_F14, 'F14').
-define(ILLUM_F15, 'F15').
-define(ILLUM_F16, 'F16').
-define(ILLUM_F17, 'F17').
-define(ILLUM_F18, 'F18').
-define(ILLUM_F19, 'F19').
-define(ILLUM_F20, 'F20').
-define(ILLUM_F21, 'F21').
-define(ILLUM_F22, 'F22').
-define(ILLUM_F23, 'F23').
-define(ILLUM_F24, 'F24').

%% 10°

-define(ILLUM_A_10,   'A/10').
-define(ILLUM_B_10,   'B/10').
-define(ILLUM_C_10,   'C/10').

-define(ILLUM_D50_10, 'D50/10').
-define(ILLUM_D55_10, 'D55/10').
-define(ILLUM_D60_10, 'D60/10').
-define(ILLUM_D63_10, 'D63/10').
-define(ILLUM_D65_10, 'D65/10').
-define(ILLUM_D70_10, 'D70/10').
-define(ILLUM_D75_10, 'D75/10').
-define(ILLUM_D93_10, 'D93/10').

-define(ILLUM_F1_10,  'F1/10').
-define(ILLUM_F2_10,  'F2/10').
-define(ILLUM_F3_10,  'F3/10').
-define(ILLUM_F4_10,  'F4/10').
-define(ILLUM_F5_10,  'F5/10').
-define(ILLUM_F6_10,  'F6/10').
-define(ILLUM_F7_10,  'F7/10').
-define(ILLUM_F8_10,  'F8/10').
-define(ILLUM_F9_10,  'F9/10').
-define(ILLUM_F10_10, 'F10/10').
-define(ILLUM_F11_10, 'F11/10').
-define(ILLUM_F12_10, 'F12/10').

-define(ILLUM_F13_10, 'F13/10').
-define(ILLUM_F14_10, 'F14/10').
-define(ILLUM_F15_10, 'F15/10').
-define(ILLUM_F16_10, 'F16/10').
-define(ILLUM_F17_10, 'F17/10').
-define(ILLUM_F18_10, 'F18/10').
-define(ILLUM_F19_10, 'F19/10').
-define(ILLUM_F20_10, 'F20/10').
-define(ILLUM_F21_10, 'F21/10').
-define(ILLUM_F22_10, 'F22/10').
-define(ILLUM_F23_10, 'F23/10').
-define(ILLUM_F24_10, 'F24/10').

-type illuminant() ::
      ?ILLUM_A | ?ILLUM_B | ?ILLUM_C
    | ?ILLUM_D50 | ?ILLUM_D55 | ?ILLUM_D60 | ?ILLUM_D63
    | ?ILLUM_D65 | ?ILLUM_D70 | ?ILLUM_D75 | ?ILLUM_D93
    | ?ILLUM_F1  | ?ILLUM_F2  | ?ILLUM_F3  | ?ILLUM_F4
    | ?ILLUM_F5  | ?ILLUM_F6  | ?ILLUM_F7  | ?ILLUM_F8
    | ?ILLUM_F9  | ?ILLUM_F10 | ?ILLUM_F11 | ?ILLUM_F12
    | ?ILLUM_F13 | ?ILLUM_F14 | ?ILLUM_F15 | ?ILLUM_F16
    | ?ILLUM_F17 | ?ILLUM_F18 | ?ILLUM_F19 | ?ILLUM_F20
    | ?ILLUM_F21 | ?ILLUM_F22 | ?ILLUM_F23 | ?ILLUM_F24

    | ?ILLUM_A_10 | ?ILLUM_B_10 | ?ILLUM_C_10
    | ?ILLUM_D50_10 | ?ILLUM_D55_10 | ?ILLUM_D60_10 | ?ILLUM_D63_10
    | ?ILLUM_D65_10 | ?ILLUM_D70_10 | ?ILLUM_D75_10 | ?ILLUM_D93_10
    | ?ILLUM_F1_10  | ?ILLUM_F2_10  | ?ILLUM_F3_10  | ?ILLUM_F4_10
    | ?ILLUM_F5_10  | ?ILLUM_F6_10  | ?ILLUM_F7_10  | ?ILLUM_F8_10
    | ?ILLUM_F9_10  | ?ILLUM_F10_10 | ?ILLUM_F11_10 | ?ILLUM_F12_10
    | ?ILLUM_F13_10 | ?ILLUM_F14_10 | ?ILLUM_F15_10 | ?ILLUM_F16_10
    | ?ILLUM_F17_10 | ?ILLUM_F18_10 | ?ILLUM_F19_10 | ?ILLUM_F20_10
    | ?ILLUM_F21_10 | ?ILLUM_F22_10 | ?ILLUM_F23_10 | ?ILLUM_F24_10.

-define(BRADFORD,      'Bradford').
-define(VON_KRIES,     'Von Kries').
-define(CAT02,         'CAT02').
-define(CAT16,         'CAT16').
-define(SHARP,         'Sharp').
-define(FAIRCHILD,     'Fairchild').
-define(CMCCAT97,      'CMCCAT97').
-define(CMCCAT2000,    'CMCCAT2000').
-define(XYZ_SCALING,   'XYZ Scaling').
-define(HUNT,          'Hunt').
-define(ZCAM,          'ZCAM').

-type chromatic_adaptation() ::
      ?BRADFORD
    | ?VON_KRIES
    | ?CAT02
    | ?CAT16
    | ?SHARP
    | ?FAIRCHILD
    | ?CMCCAT97
    | ?CMCCAT2000
    | ?XYZ_SCALING
    | ?HUNT
    | ?ZCAM.

-record(srgb, {
    illum = ?ILLUM_D65 :: illuminant(), %% Standard sRGB, display RGB with gamma 2.2
    r     :: float(),                   %% Red channel [0.0, 1.0]
    g     :: float(),                   %% Green channel [0.0, 1.0]
    b     :: float()                    %% Blue channel [0.0, 1.0]
}).

-record(adobe_rgb, {
    illum = ?ILLUM_D65 :: illuminant(), %% Adobe RGB 1998
    r     :: float(),                   %% Red channel [0.0, 1.0]
    g     :: float(),                   %% Green channel [0.0, 1.0]
    b     :: float()                    %% Blue channel [0.0, 1.0]
}).

-record(display_p3, {
    illum = ?ILLUM_D65 :: illuminant(), %% Display-P3, wide gamut
    r     :: float(),
    g     :: float(),
    b     :: float()
}).

-record(rec2020, {
    illum = ?ILLUM_D65 :: illuminant(), %% Rec.2020, wide gamut
    r     :: float(),
    g     :: float(),
    b     :: float()
}).

-record(rec709, {
    illum = ?ILLUM_D65 :: illuminant(), %% Rec.709 / BT.709
    r     :: float(),
    g     :: float(),
    b     :: float()
}).

-record(prophoto_rgb, {
    illum = ?ILLUM_D50 :: illuminant(), %% ProPhoto RGB, linear or gamma-corrected
    r     :: float(),
    g     :: float(),
    b     :: float()
}).

-record(wide_gamut_rgb, {
    illum = ?ILLUM_D50 :: illuminant(), %% Wide Gamut RGB
    r     :: float(),
    g     :: float(),
    b     :: float()
}).

-record(linear_rgb, {
    illum = ?ILLUM_D65 :: illuminant(), %% Linear RGB, scene linear
    r     :: float(),
    g     :: float(),
    b     :: float()
}).


-record(xyz, {
    illum     = ?ILLUM_D65 :: illuminant(), %% CIE XYZ, tristimulus values
    x         :: float(),                   %% X ∈ [0.0, ∞]
    y         :: float(),                   %% Y ∈ [0.0, ∞]
    z         :: float()                    %% Z ∈ [0.0, ∞]
}).

-record(xyy, {
    illum     = ?ILLUM_D65 :: illuminant(), %% CIE xyY
    x         :: float(),                   %% x ∈ [0.0, 1.0]
    y         :: float(),                   %% y ∈ [0.0, 1.0]
    luminance :: float()                    %% Y ∈ [0.0, ∞]
}).

-record(lab, {
    illum = ?ILLUM_D50 :: illuminant(), %% CIE Lab
    l     :: float(),                   %% Lightness L ∈ [0, 100]
    a     :: float(),                   %% a ∈ [-128, 127]
    b     :: float()                    %% b ∈ [-128, 127]
}).

-record(luv, {
    illum = ?ILLUM_D50 :: illuminant(), %% CIE Luv
    l     :: float(),                   %% Lightness L ∈ [0, 100]
    u     :: float(),                   %% u ∈ [-134, 220] (approx)
    v     :: float()                    %% v ∈ [-134, 220] (approx)
}).

-record(lchuv, {
    illum = ?ILLUM_D50 :: illuminant(), %% LCHuv: Lightness, Chroma, Hue
    l     :: float(),                   %% Lightness L ∈ [0, 100]
    c     :: float(),                   %% Chroma C ∈ [0, ∞]
    h     :: float()                    %% Hue H ∈ [0, 360)
}).

-record(logluv, {
    illum = ?ILLUM_D65 :: illuminant(), %% LogLuv: log luminance + chroma coords
    l     :: float(),                   %% log luminance L ∈ [0, ∞]
    u     :: float(),                   %% chroma coordinate u ∈ [0, 410]
    v     :: float()                    %% chroma coordinate v ∈ [0, 410]
}).

-record(din99_lab, {
    illum   = ?ILLUM_D50 :: illuminant(), %% DIN99 Lab
    l       :: float(),                   %% Lightness L ∈ [0, 100]
    a       :: float(),                   %% a ∈ [-100, 100] (approx)
    b       :: float(),                   %% b ∈ [-100, 100] (approx)
    variant = ?DIN99d   :: din99_algorithm() %% 'DIN99'|'DIN99d'|'DIN99o'|'DIN99c'
}).

-record(ipt, {
    illum  = ?ILLUM_D65 :: illuminant(),  %% IPT, uses D65 by default
    i     :: float(),                     %% I ∈ [-∞, ∞] normalized, typical [-1, 1]
    p     :: float(),                     %% P ∈ [-∞, ∞] normalized, typical [-1, 1]
    t     :: float()                      %% T ∈ [-∞, ∞] normalized, typical [-1, 1]
}).

-record(ictcp, {
    illum    = ?ILLUM_D65          :: illuminant(),       %% Но иллюминант только D65
    i        :: float(),           %% Intensity / Luma (I component)
    ct       :: float(),           %% Chromatic component t (C_t)
    cp       :: float(),           %% Chromatic component p (C_p)
    transfer = ?TRANSFER_PQ       :: ictcp_transfer() %% 'PQ' или 'HLG' для трансфера яркости
}).

-record(hsv, {
    illum = ?ILLUM_D65 :: illuminant(), %% HSV
    h     :: float(),                   %% Hue H ∈ [0, 360]
    s     :: float(),                   %% Saturation S ∈ [0.0, 1.0]
    v     :: float()                    %% Value V ∈ [0.0, 1.0]
}).

-record(hsl, {
    illum = ?ILLUM_D65 :: illuminant(), %% HSL
    h     :: float(),                   %% Hue H ∈ [0, 360]
    s     :: float(),                   %% Saturation S ∈ [0.0, 1.0]
    l     :: float()                    %% Lightness L ∈ [0.0, 1.0]
}).

-record(hsi, {
    illum = ?ILLUM_D65 :: illuminant(), %% HSI
    h     :: float(),                   %% Hue H ∈ [0, 360]
    s     :: float(),                   %% Saturation S ∈ [0.0, 1.0]
    i     :: float()                    %% Intensity I ∈ [0.0, 1.0]
}).

-record(lch, {
    illum = ?ILLUM_D65 :: illuminant(), %% LCH (CIE LCh from Lab)
    l     :: float(),                   %% Lightness L ∈ [0, 100]
    c     :: float(),                   %% Chroma C ∈ [0, ∞]
    h     :: float()                    %% Hue H ∈ [0, 360]
}).

-record(cmy, {
    illum = ?ILLUM_D65 :: illuminant(), %% Cyan-Magenta-Yellow, subtractive color model
    c     :: float(),                   %% Cyan C ∈ [0.0, 1.0]
    m     :: float(),                   %% Magenta M ∈ [0.0, 1.0]
    y     :: float()                    %% Yellow Y ∈ [0.0, 1.0]
}).

-record(hwb, {
    illum = ?ILLUM_D65 :: illuminant(), %% HWB: Hue-Whiteness-Blackness
    h     :: float(),                   %% Hue H ∈ [0, 360]
    w     :: float(),                   %% Whiteness W ∈ [0.0, 1.0]
    b     :: float()                    %% Blackness B ∈ [0.0, 1.0]
}).
-record(oklab, {
    illum = ?ILLUM_D65 :: illuminant(), %% Oklab, perceptually uniform
    l     :: float(),                   %% Lightness L ∈ [0.0 .. 1.0]
    a     :: float(),                   %% green-red axis, typ. ≈ [-0.5 .. 0.5]
    b     :: float()                    %% blue-yellow axis, typ. ≈ [-0.5 .. 0.5]
}).

-record(oklch, {
    illum = ?ILLUM_D65 :: illuminant(), %% Oklch (cylindrical from Oklab)
    l     :: float(),                   %% Lightness L ∈ [0.0 .. 1.0]
    c     :: float(),                   %% Chroma C ∈ [0.0 .. ~0.5] (often 0..0.4 in real colors)
    h     :: float()                    %% Hue angle H ∈ [0.0 .. 360.0]
}).


-type cbet_color_other() :: ?RGB3X8 | ?RGBINT | ?RGBHEX.

-type cbet_color_rec() ::
      #srgb{}
    | #adobe_rgb{}
    | #display_p3{}
    | #rec2020{}
    | #rec709{}
    | #prophoto_rgb{}
    | #wide_gamut_rgb{}
    | #linear_rgb{}
    | #xyz{}
    | #xyy{}
    | #lab{}
    | #luv{}
    | #lchuv{}
    | #logluv{}
    | #din99_lab{}
    | #ipt{}
    | #ictcp{}
    | #hsv{}
    | #hsl{}
    | #hsi{}
    | #lch{}
    | #cmy{}
    | #hwb{}
    | #oklab{}
    | #oklch{}.

-type cbet_color() :: cbet_color_rec() | cbet_color_other().

-define(ILLUMINANT(Rec), element(2, Rec)).

-define(CAM16_SURROUND_AVERAGE, average).
-define(CAM16_SURROUND_DIM, dim).
-define(CAM16_SURROUND_DARK, dark).
-type cam16_surround() :: ?CAM16_SURROUND_AVERAGE| ?CAM16_SURROUND_DIM| ?CAM16_SURROUND_DARK.



-record(cam16, {
    j :: float(),      %% Lightness
    c :: float(),      %% Chroma
    h_angle :: float(),      %% Hue angle
	h_quad :: float(),      %% Hue quadrature
    m :: float(),      %% Colorfulness
    s :: float(),      %% Saturation
	q :: float(),      %% Brightness
    a :: float(),      %% a-component
    b :: float(),      %% b-component
    d :: float(),      %% Degree of adaptation
    f :: float(),      %% Surround factor F
    c_sur :: float(),  %% Surround factor c
    n_c :: float()     %% Surround factor N_c
}).

-type nayatani_color_composition() :: r_y | y_g | g_b | b_r.


-record(nayatani,{
    lstar_p :: float(),     %% Achromatic Lightness
    lstar_n :: float(),     %% Normalised achromatic Lightness
    c :: float(),           %% chroma
    h_angle :: float(),     %% Hue angle
    s :: float(),           %% Saturation
    q :: float(),           %% Brightness
    m :: float(),           %% Colorfullness
    h_q :: float(),         %% Hue quadrature
    h_c_segment :: nayatani_color_composition(),  %% Hue composition segment
    h_c :: float()          %% Hue composition value

}).




-define(HUNT_SURROUND_SMALL_UNIFORM, small_uniform).
-define(HUNT_SURROUND_NORMAL, normal).
-define(HUNT_SURROUND_TV_DIM, tv_dim).
-define(HUNT_SURROUND_LIGHT_BOX, light_boxes).
-define(HUNT_SURROUND_PROJECTED_DARK, projected_dark).
-type hunt_surround() ::
?HUNT_SURROUND_SMALL_UNIFORM
    | ?HUNT_SURROUND_NORMAL
    | ?HUNT_SURROUND_TV_DIM
    | ?HUNT_SURROUND_LIGHT_BOX
    | ?HUNT_SURROUND_PROJECTED_DARK.


-record(hunt,{
    j :: float(), %% Lightness
    c :: float(), %% Chroma
    h_angle :: float(), %% Hue angle
    s :: float(), %% Saturation
    q ::  float(), %% Brightness
    m :: float(), %% Colorfullness
    h_q :: float(), %% Hue quadrature
    q_wb :: float() %% whiteness/blackness
}).