


# CBET (pronounced like 'tsvet')

## LIBRARY SUMMARY
Color Processing Library - Unified Color Space Conversion and Manipulation in Erlang

## DESCRIPTION
The library provides a unified pipeline for color conversion and processing, supporting the following color spaces and color appearance models:

- **RGB Working Spaces** - sRGB, Adobe RGB, Display P3, Rec. 2020, Rec. 709, ProPhoto RGB, Wide Gamut RGB
- **CIE Color Spaces** - XYZ, xyY, Lab, Luv, LCh, LChuv
- **Perceptual and Advanced Color Models** - LogLuv, DIN99, IPT, ICtCp, Oklab, Oklch
- **Cylindrical & User-Oriented Color Models** - HSV, HSL, HSI, HWB, CMY

This library's primary function is `convert`, which transforms colors between different formats and illuminants. The library also provides several simpler functions for basic color manipulation, along with a few more complex ones for calculating correlates of color appearance models such as CAM16, Hunt, Nayatani et al. (95).

## Design Notes

- All formats are represented as typed Erlang records.
- Device-dependent spaces are converted via a linear RGB → XYZ pipeline.
- Polar variants (`LCh`, `LChuv`, `Oklch`) maintain hue in degrees.
- See the section below describing the structures of supported color formats and valid value ranges of each field.
## Types
Most of the important types (records, macros, and related opaque/tagged types) are defined in the header file **`cbet.hrl`**. If you need to use macros, records (most likely you do), or refer to the internal structures in your code (e.g. in match specs, guards, or your own behaviours), include this file in your modules.

#####  Transfer function for ICtCp model:
```erlang
-type ictcp_transfer() :: 'PQ'|'HLG'.
```
Where `'PQ'`: Perceptual Quantizer (ST 2084); `'HLG'`: Hybrid Log-Gamma

#### Color distance metrics:

```erlang
-type color_distance() :: 'ΔXYZ'|'ΔE*ab 1976'|'ΔE94'|'ΔE00'|'ΔE_ITP'|'ΔOK'.
```

| Value | Description |
|--------|------------|
| `'ΔXYZ'` | Euclidean distance in XYZ |
| `'ΔE*ab 1976'` | CIE 1976 ΔE (Lab) |
| `'ΔE94'` | CIE94 |
| `'ΔE00'` | CIEDE2000 |
| `'ΔE_ITP'` | ITU-R BT.2124 ΔE (ICtCp-based) |
| `'ΔOK'` | Oklab Euclidean distance |

##### DIN99 algorithm variants:

```erlang
-type din99_algorithm() :: 'DIN99'|'DIN99d'|'DIN99o'|'DIN99c'.
```
##### Standard 2° and 10° reference illuminants:

```erlang
-type illuminant() :: 'A'|'B'|'C'|'D50'|'D55'|'D60'|'D63'|'D65'|'D70'|'D75'|'D93'|
                      'F1'|'F2'|'F3'|'F4'|'F5'|'F6'|'F7'|'F8'|'F9'|'F10'|'F11'|'F12'|
                      'F13'|'F14'|'F15'|'F16'|'F17'|'F18'|'F19'|'F20'|'F21'|'F22'|'F23'|'F24'|
                      'A/10'|'B/10'|'C/10'|'D50/10'|'D55/10'|'D60/10'|'D63/10'|'D65/10'|'D70/10'|'D75/10'|'D93/10'|
                      'F1/10'|'F2/10'|'F3/10'|'F4/10'|'F5/10'|'F6/10'|'F7/10'|'F8/10'|'F9/10'|'F10/10'|'F11/10'|'F12/10'|
                      'F13/10'|'F14/10'|'F15/10'|'F16/10'|'F17/10'|'F18/10'|'F19/10'|'F20/10'|'F21/10'|'F22/10'|'F23/10'|'F24/10'.
```
##### Chromatic adaptation methods:

```erlang
-type chromatic_adaptation() :: 'Bradford'|'Von Kries'|'CAT02'|'CAT16'|'Sharp'|'Fairchild'|
                                'CMCCAT97'|'CMCCAT2000'|'XYZ Scaling'|'Hunt'|'ZCAM'.
```
##### Surround types for CAM16 model:

```erlang
-type cam16_surround() :: average|dim|dark.
```
##### Nayatani color composition axes:

```erlang
-type nayatani_color_composition() :: r_y|y_g|g_b|b_r.
```
##### Surround types for Hunt color appearance model:

```erlang
-type hunt_surround() :: small_uniform|normal|tv_dim|light_boxes|projected_dark.
```
##### All supported color formats:
```erlang
-type cbet_color() :: #srgb{}|#adobe_rgb{}|#display_p3{}|#rec2020{}|#rec709{}|
                      #prophoto_rgb{}|#wide_gamut_rgb{}|#linear_rgb{}|#xyz{}|#xyy{}|
                      #lab{}|#luv{}|#lchuv{}|#logluv{}|#din99_lab{}|#ipt{}|#ictcp{}|
                      #hsv{}|#hsl{}|#hsi{}|#lch{}|#cmy{}|#hwb{}|#oklab{}|#oklch{}.
```
Detailed descriptions of the individual color format structures are provided in the sections below.
## Color Format Structures
This section describes the supported color format records, their fields, and valid ranges.

Each color format record has a default illuminant, but any other illuminant may be used, even when the format specification includes an explicit illuminant (such as D65 for `sRGB`).  Strictly speaking, such an override means the color space is no longer identical to the original named format (e.g. true `sRGB`), but should be treated as a `"sRGB-like"` variant with matching primaries and transfer function yet adapted to the selected illuminant.

### `#srgb{}` — Standard RGB color
```erlang
-record(srgb, {illum = ?ILLUM_D65, r, g, b}).
```
-   `illum`: `illuminant()` (default `D65`)
-   `r`: `float()` [0.0, 1.0]
-   `g`: `float()` [0.0, 1.0]
-   `b`: `float()` [0.0, 1.0]
- ### `#adobe_rgb{}` — Adobe RGB 1998

```erlang
-record(adobe_rgb, {illum = ?ILLUM_D65, r, g, b}).
```
-   `illum`: `illuminant()` (default `D65`)
-   `r`: `float()` [0.0, 1.0]
-   `g`: `float()` [0.0, 1.0]
-   `b`: `float()` [0.0, 1.0]
### `#display_p3{}` — Display-P3 wide gamut

```erlang
-record(display_p3, {illum = ?ILLUM_D65, r, g, b}).
```
-   `illum`: `illuminant()` (default `D65`)
-   `r`: `float()` [0.0, 1.0]
-   `g`: `float()` [0.0, 1.0]
-   `b`: `float()` [0.0, 1.0]
### `#rec2020{}` — Rec.2020 wide gamut

```erlang
-record(rec2020, {illum = ?ILLUM_D65, r, g, b}).
```
-   `illum`: `illuminant()` (default `D65`)
-   `r`: `float()` [0.0, 1.0]
-   `g`: `float()` [0.0, 1.0]
-   `b`: `float()` [0.0, 1.0]
### `#rec709{}` — Rec.709 / BT.709
```erlang
-record(rec709, {illum = ?ILLUM_D65, r, g, b}).
```
-   `illum`: `illuminant()` (default `D65`)
-   `r`: `float()` [0.0, 1.0]
-   `g`: `float()` [0.0, 1.0]
-   `b`: `float()` [0.0, 1.0]
### `#prophoto_rgb{}` — ProPhoto RGB

```erlang
-record(prophoto_rgb, {illum = ?ILLUM_D50, r, g, b}).
```
-   `illum`: `illuminant()` (default `D50`)
-   `r`: `float()` [0.0, 1.0]
-   `g`: `float()` [0.0, 1.0]
-   `b`: `float()` [0.0, 1.0]
### `#wide_gamut_rgb{}` — Wide Gamut RGB

```erlang
-record(wide_gamut_rgb, {illum = ?ILLUM_D50, r, g, b}).
```
-   `illum`: `illuminant()` (default `D50`)
-   `r`: `float()` [0.0, 1.0]
-   `g`: `float()` [0.0, 1.0]
-   `b`: `float()` [0.0, 1.0]
### `#linear_rgb{}` — Linear RGB (scene-linear)

```erlang
-record(linear_rgb, {illum = ?ILLUM_D65, r, g, b}).
```
-   `illum`: `illuminant()` (default `D65`)
-   `r`: `float()` [0.0, 1.0]
-   `g`: `float()` [0.0, 1.0]
-   `b`: `float()` [0.0, 1.0]
### `#xyz{}` — CIE XYZ (tristimulus values)

```erlang
-record(xyz, {illum = ?ILLUM_D65, x, y, z}).
```
-   `illum`: `illuminant()` (default `D65`)
-   `x`: `float()` [0.0, ∞]
-   `y`: `float()` [0.0, ∞]
-   `z`: `float()` [0.0, ∞]
### `#xyy{}` — CIE xyY

```erlang
-record(xyy, {illum = ?ILLUM_D65, x, y, luminance}).
```
-   `illum`: `illuminant()` (default `D65`)
-   `x`: `float()` [0.0, 1.0]
-   `y`: `float()` [0.0, 1.0]
-   `luminance`: `float()` [0.0, ∞], "the Y"
### `#lab{}` — CIE L\*a\*b\*

```erlang
-record(lab, {illum = ?ILLUM_D50, l, a, b}).
```
-   `illum`: `illuminant()` (default `D50`)
-   `l`: `float()` [0, 100]
-   `a`: `float()` [-128, 127]
-   `b`: `float()` [-128, 127]
### `#luv{}` — CIE Luv

```erlang
-record(luv, {illum = ?ILLUM_D50, l, u, v}).
```
-   `illum`: `illuminant()` (default `D50`)
-   `l`: `float()` [0, 100]
-   `u`: `float()` [-134, 220] (approx)
-   `v`: `float()` [-134, 220] (approx)
- ### `#lchuv{}` — CIE LCHuv

```erlang
-record(lchuv, {illum = ?ILLUM_D50, l, c, h}).
```
-   `illum`: `illuminant()` (default `D50`)
-   `l`: `float()` [0, 100]
-   `c`: `float()` [0, ∞]
-   `h`: `float()` [0, 360)
### `#logluv{}` — LogLuv

```erlang
-record(logluv, {illum = ?ILLUM_D65, l, u, v}).
```
-   `illum`: `illuminant()` (default `D65`)
-   `l`: `float()` [0, ∞]
-   `u`: `float()` [0, 410]
-   `v`: `float()` [0, 410]
### `#din99_lab{}` — DIN99 Lab

```erlang
-record(din99_lab, {illum = ?ILLUM_D50, l, a, b, variant = ?DIN99d}).
```
-   `illum`: `illuminant()` (default `D50`)
-   `l`: `float()` [0, 100]
-   `a`: `float()` [-100, 100] (approx)
-   `b`: `float()` [-100, 100] (approx)
-   `variant`: `din99_algorithm()` ('DIN99'|'DIN99d'|'DIN99o'|'DIN99c')
### `#ipt{}` — IPT color space

```erlang
-record(ipt, {illum = ?ILLUM_D65, i, p, t}).
```
-   `illum`: `illuminant()` (default `D65`)
-   `i`: `float()` [-∞, ∞], typical [-1, 1]
-   `p`: `float()` [-∞, ∞], typical [-1, 1]
-   `t`: `float()` [-∞, ∞] typical [-1, 1]
### `#ictcp{}` — ICtCp color space, HDR

```erlang
-record(ictcp, {illum = ?ILLUM_D65, i, ct, cp, transfer = ?TRANSFER_PQ}).
```
-   `illum`: `illuminant()` (default `D65`, only D65 supported)
-   `i`: `float()` — intensity / luma (I component)
-   `ct`: `float()` — chromatic component t (Cₜ)
-   `cp`: `float()` — chromatic component p (Cₚ)
-   `transfer`: `ictcp_transfer()` — `'PQ' | 'HLG'`
### `#hsv{}` — HSV color space

```erlang
-record(hsv, {illum = ?ILLUM_D65, h, s, v}).
```
-   `illum`: `illuminant()` (default `D65`)
-   `h`: `float()` [0, 360] — hue
-   `s`: `float()` [0.0, 1.0] — saturation
-   `v`: `float()` [0.0, 1.0] — value
### `#hsl{}` — HSL color space

```erlang
-record(hsl, {illum = ?ILLUM_D65, h, s, l}).
```
-   `illum`: `illuminant()` (default `D65`)
-   `h`: `float()` [0, 360] — hue
-   `s`: `float()` [0.0, 1.0] — saturation
-   `l`: `float()` [0.0, 1.0] — lightness
### `#hsi{}` — HSI color space

```erlang
-record(hsi, {illum = ?ILLUM_D65, h, s, i}).
```
-   `illum`: `illuminant()` (default `D65`)
-   `h`: `float()` [0, 360] — hue
-   `s`: `float()` [0.0, 1.0] — saturation
-   `i`: `float()` [0.0, 1.0] — intensity
### `#lch{}` — CIE LCh (from Lab)

```erlang
-record(lch, {illum = ?ILLUM_D65, l, c, h}).
```
-   `illum`: `illuminant()` (default `D65`)
-   `l`: `float()` [0, 100] — lightness
-   `c`: `float()` [0, ∞] — chroma
-   `h`: `float()` [0, 360] — hue
### `#cmy{}` — Cyan-Magenta-Yellow (subtractive, in linear space)

```erlang
-record(cmy, {illum = ?ILLUM_D65, c, m, y}).
```
-   `illum`: `illuminant()` (default `D65`)
-   `c`: `float()` [0.0, 1.0] — cyan
-   `m`: `float()` [0.0, 1.0] — magenta
-   `y`: `float()` [0.0, 1.0] — yellow
### `#hwb{}` — HWB (Hue-Whiteness-Blackness)

```erlang
-record(hwb, {illum = ?ILLUM_D65, h, w, b}).
```
-   `illum`: `illuminant()` (default `D65`)
-   `h`: `float()` [0, 360] — hue
-   `w`: `float()` [0.0, 1.0] — whiteness
-   `b`: `float()` [0.0, 1.0] — blackness
### `#oklab{}` — Oklab (perceptually uniform)

```erlang
-record(oklab, {illum = ?ILLUM_D65, l, a, b}).
```
-   `illum`: `illuminant()` (default `D65`)
-   `l`: `float()` [0.0, 1.0] — lightness
-   `a`: `float()` [-0.5, 0.5] (approx) — green-red axis
-   `b`: `float()` [-0.5, 0.5] (approx) — blue-yellow axis
### `#oklch{}` — Oklch (cylindrical from Oklab)

```erlang
-record(oklch, {illum = ?ILLUM_D65, l, c, h}).
```
-   `illum`: `illuminant()` (default `D65`)
-   `l`: `float()` [0.0, 1.0] — lightness
-   `c`: `float()` [0.0, ~0.5] — chroma (typical 0.0–0.4 in real colors)
-   `h`: `float()` [0.0, 360.0] — hue angle
## Other Structures
### `#cam16{}` — CAM16 color appearance model

```erlang
-record(cam16, {j, c, h_angle, h_quad, m, s, q, a, b, d, f, c_sur, n_c}).
```
-   `j`: `float()` — lightness
-   `c`: `float()` — chroma
-   `h_angle`: `float()` — hue angle
-   `h_quad`: `float()` — hue quadrature
-   `m`: `float()` — colorfulness
-   `s`: `float()` — saturation
-   `q`: `float()` — brightness
-   `a`: `float()` — a-component
-   `b`: `float()` — b-component
-   `d`: `float()` — degree of adaptation
-   `f`: `float()` — surround factor F
-   `c_sur`: `float()` — surround factor c
-   `n_c`: `float()` — surround factor N_c
### `#nayatani{}` — Nayatani et al. color appearance model

```erlang
-record(nayatani, {lstar_p, lstar_n, c, h_angle, s, q, m, h_q, h_c_segment, h_c}).
```
-   `lstar_p`: `float()` — achromatic lightness
-   `lstar_n`: `float()` — normalized achromatic lightness
-   `c`: `float()` — chroma
-   `h_angle`: `float()` — hue angle
-   `s`: `float()` — saturation
-   `q`: `float()` — brightness
-   `m`: `float()` — colorfulness
-   `h_q`: `float()` — hue quadrature
-   `h_c_segment`: `nayatani_color_composition()` — hue composition segment
-   `h_c`: `float()` — hue composition value
### `#hunt{}` — Hunt color appearance model

```erlang
-record(hunt, {j, c, h_angle, s, q, m, h_q, q_wb}).
```
-   `j`: `float()` — lightness
-   `c`: `float()` — chroma
-   `h_angle`: `float()` — hue angle
-   `s`: `float()` — saturation
-   `q`: `float()` — brightness
-   `m`: `float()` — colorfulness
-   `h_q`: `float()` — hue quadrature
-   `q_wb`: `float()` — whiteness / blackness
## Macros

The library defines a set of macros for constants used throughout color conversions and appearance models. The main purpose of using macros instead of raw atoms is to enable the compiler to **check the correctness of constant names at compile time**.
These include transfer functions, illuminants, chromatic adaptation methods, DIN99 variants, and CAM16 surrounds.

Below is a summary of the main macro groups; their detailed usage is described in the type definitions above.

#### Transfer functions
```erlang
-define(TRANSFER_PQ, 'PQ').
-define(TRANSFER_HLG, 'HLG').
```
#### Color difference methods
```erlang
-define(DELTA_XYZ, 'ΔXYZ').
-define(DELTA_CIE1976, 'ΔE*ab 1976').
-define(DELTA_CIE94, 'ΔE94').
-define(DELTA_CIEDE2000, 'ΔE00').
-define(DELTA_ITURBT21240, 'ΔE_ITP').
-define(DELTA_OKLAB, 'ΔOK').
```
#### DIN99 variants
```erlang
-define(DIN99, 'DIN99').
-define(DIN99d, 'DIN99d').
-define(DIN99o, 'DIN99o').
-define(DIN99c, 'DIN99c').
```
#### 2° Standard illuminants
```erlang
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
```
#### 10° standard illuminants
```erlang
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
```
#### Chromatic adaptation methods
```erlang
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
```
#### CAM16 surround conditions
```erlang
-define(CAM16_SURROUND_AVERAGE, average).
-define(CAM16_SURROUND_DIM, dim).
-define(CAM16_SURROUND_DARK, dark).
```
#### Hunt surround conditions
```erlang
-define(HUNT_SURROUND_SMALL_UNIFORM, small_uniform).
-define(HUNT_SURROUND_NORMAL, normal).
-define(HUNT_SURROUND_TV_DIM, tv_dim).
-define(HUNT_SURROUND_LIGHT_BOX, light_boxes).
-define(HUNT_SURROUND_PROJECTED_DARK, projected_dark).
```
## Functions

The CBET library provides a set of functions for **color conversion, manipulation, and computation**.  Detailed specifications, argument types, and examples are provided below in alphabetical order.
#### cam16_model/4,5
```erlang
cam16_model(XYZ, WP, L_A, Y_b) -> Result
cam16_model(XYZ, WP, L_A, Y_b, Opts) -> Result
```
Types:
- XYZ : {float(), float(), float()}  %% Object XYZ
- WP  : {float(), float(), float()} | illuminant()  %% White point or illuminant
- L_A : float()  -  Adapting field luminance in cd/m²
- Y_b : float()  - Background relative luminance
- Opts : #{
    surround := cam16_surround(),
    discount_illuminant := boolean(),
    d := undefined | float()
}
- Result : #cam16{} - CAM16 appearance record

Computes the CAM16 appearance model for an object with given XYZ values, white point, adapting luminance L_A, and background relative luminance Y_b.
Optional parameters in Opts allow setting the surround, discounting the illuminant, and specifying the degree of adaptation.
#### convert/2,3
```erlang
convert(From, To) -> Result
convert(From, To, Opts) -> Result
```

Types:
-   From : cbet_color() - source color record
-   To : cbet_color() - target color record type
-   Opts : convert_opts() = #{
    adaptation := chromatic_adaptation(), - Chromatic adaptation method
    clamp := boolean() - Whether to clamp values
    }
-   Result : cbet_color() - converted color record

Converts a color `From` to the format specified by `To`. Optional parameters in `Opts` allow specifying chromatic adaptation method and whether to clamp the result. By default `clamp == true`, `adaptation == 'Bradford'`

**Example**:
```erlang
#lab{} = Lab = cbet:convert(#srgb{r=1.0, g=0.0, b=0.0}, #lab{illum=?D65}, #{adaptation => ?BRADFORD, clamp => true}). %%converts from the sRGB D65(default) to the CIELab D65 structure
```
**Warning:**
- ⚠️This function does **not** check whether record field values are within valid ranges. If any field contains an out-of-range value, the function results in **undefined behavior**.
- ⚠️ If `clamp = false`, the function may return structures with invalid values, such as negative components in RGB records, for example. The presence of such components indicates that the value is **out of gamut** for the target color space.

#### distance/3
```erlang
distance(Color1, Color2, Algo) -> Result
```
Types:
-   Color1 : cbet_color() = first color record
-   Color2 : cbet_color() = second color record
-   Algo : color_distance() = distance metric to use (`?DELTA_XYZ`, `?DELTA_CIE1976`, etc.)
-   Result : float() = computed color distance

Computes the color difference between `Color1` and `Color2` using the specified distance algorithm.

**Example:**
```erlang
Distance = cbet:distance(#lab{l=50, a=20, b=30}, #srgb{r=0.1, g=0.2, b=0.3}, ?DELTA_OKLAB).
```
**Notes**:
- Illuminants are chosen per algorithm (`D65` for XYZ, Oklab, ITU; `D50` for Lab-based distances).
- This function automatically converts any supported input color structure to the required color space for the algorithm.
- `ΔE00` computation handles hue angle wrapping, chroma correction, and weighting factors as per CIEDE2000 standard.
- ⚠️`ΔE_ITP` is designed for HDR colors using PQ/HLG transfer functions. This library operates in SDR, so linear RGB values here may not match the same colors in HDR. Use ΔE_ITP in SDR with caution — the result may differ from true HDR perceptual differences.
- ⚠️This function does **not** check whether record field values are within valid ranges. If any field contains an out-of-range value, the function results in **undefined behavior**.
#### hextosrgb/1,2
```erlang
hextosrgb(Hex) -> Result
hextosrgb(Hex, Opts) -> Result
```
Types:
-   Hex : binary() - color in hexadecimal notation
-   Opts : hextosrgb_opts() = #{
    prefixes := [binary()], - list of allowed prefixes (default: <<"0x">>, <<"0X">>, <<"#">>, <<"16#">>)
    allow_short := boolean() - whether short form like "#f00" is allowed (default: true)
    }
-   Result : #srgb{} = resulting sRGB color record

Parses a hexadecimal color string into an `#srgb{}` record. Optional parameters in `Opts` allow customizing allowed prefixes and enabling short form notation.

Example:
```erlang
%% all valid
C1 = cbet:hextosrgb("0xff0000").
C2 = cbet:hextosrgb("f00").
C3 = cbet:hextosrgb("prefix00ff00", #{allow_short => false, prefixes => [<<"prefix">>, <<"#">>]}).
```
#### hunt_model/5,6
```erlang
hunt_model(XYZ, WP, BgP, L_A, Surround) -> Result
hunt_model(XYZ, WP, BgP, L_A, Surround, Opts) -> Result
```
Types:
-   XYZ : {float(), float(), float()} = object XYZ coordinates
-   WP : {float(), float(), float()} | illuminant() = white point or illuminant
-   BgP : {float(), float(), float()} | illuminant() = background XYZ or illuminant
-   L_A : float() = adapting field luminance in cd/m²
-   Surround : hunt_surround() | {float(), float()} | {float(), float(), float() | undefined, float() | undefined} = surround specification
-   Opts : #{
    helson_judd_effect := boolean(),
    discount_illuminant := boolean(),
    xyz_p := {float(), float(), float()} | illuminant(),
    p := float() | undefined,
    l_as := float() | undefined,
    cct_w := float() | undefined,
    s := float() | undefined,
    s_w := float() | undefined
    }
-   Result : #hunt{} = Hunt appearance model record

Computes the Hunt color appearance model for an object with the given XYZ, white point, background, adapting luminance L_A, and surround. Optional parameters in `Opts` allow further customization of the model behaviour. Some of parameters in `Opts` are correlated with each other, the lib throws an error when the combination is invalid.
#### interpolate/5
```erlang
interpolate(Color1, Color2, Space, Steps, ResultSpace) -> {ok, ResultList}
```
Types:
-   Color1 : cbet_color() = starting color
-   Color2 : cbet_color() = ending color
-   Space : #lab{} = intermediate color space (currently only Lab is supported)
-   Steps : pos_integer() = number of steps in interpolation (≥ 2)
-   ResultSpace : cbet_color() = color structure in which results are returned
-   ResultList : [cbet_color()] = list of interpolated colors, including endpoints


Computes a linear interpolation between `Color1` (any space) and `Color2` (any space as well) in the specified intermediate `Space`.
The result is returned as a list of colors in `ResultSpace`.

Useful for generating smooth transitions between colors, such as gradients, animations, or color palettes.
Interpolation in a perceptually uniform space like `Lab` ensures visually even steps between colors.

**Warning:**
- ⚠️This function does **not** check whether record field values are within valid ranges. If any field contains an out-of-range value, the function results in **undefined behavior**.
#### lrv/1
```erlang
lrv(Color) -> LRV
```
Types:
-   Color : cbet_color()
-   LRV : float() - computed LRV

Computes the Light Reflectance Value (LRV) of a color. In essence, it is the Y component of CIE XYZ under Illuminant C.

#### named_color/2
```erlang
named_color(Name, Format) -> {ok, Color} | {error, not_found}
```
Types:
-   Name : binary() = name of the color, e.g., <<"red">>
-   Format : hex | '8byte' | srgb
-   Color :
    -   `hex` -> binary(), hexadecimal representation
    -   `'8byte'` -> {float(), float(), float()}, 8-bit RGB tuple
    -   `srgb` -> #srgb{} structure with components normalized to [0.0, 1.0]

Looks up a color by `Name` and returns it in the specified `Format`.
If the color name is not found, returns `{error, not_found}`.

 **Example**:
```erlang
% Standard CSS/X11 color names
1> cbet:named_color(<<"red">>, hex).
{ok, <<"#ff0000">>}

2> cbet:named_color(<<"forestgreen">>, '8byte').
{ok, {34, 139, 34}}

3> cbet:named_color(<<"cadetblue">>, srgb).
{ok, #srgb{r=0.37255, g=0.50980, b=0.62745}}

```
#### nayatani_model/5,6
```erlang
nayatani_model(XYZ, WP, Yo, Eo, Eor) -> Result
nayatani_model(XYZ, WP, Yo, Eo, Eor, Opts) -> Result
```
Types:
-   XYZ : {float(), float(), float()} %% Object XYZ
-   WP : {float(), float(), float()} | illuminant() %% White point or illuminant
-   Yo : float() %% Luminance factor, typical range [0.18, 1.0]
-   Eo : float() %% Illuminance in lux
-   Eor : float() %% Normalizing illuminance in lux
-   Opts : #{n := number()} %% Noise term (optional)
-   Result : #nayatani{} %% Nayatani appearance model record

Computes the Nayatani color appearance model for an object with given `XYZ` values, adapting white point, luminance factor, and illuminances. Optional `n` in `Opts` allows specifying a noise term.
#### srgbto8bit/1
```erlang
srgbto8bit(SRGB) -> {R8, G8, B8}
```
Types:
-   SRGB : #srgb{} %% Input sRGB color
-   R8 : pos_integer() %% Red channel [0, 255]
-   G8 : pos_integer() %% Green channel [0, 255]
-   B8 : pos_integer() %% Blue channel [0, 255]

Converts an sRGB color with float channels in [0.0, 1.0] to 8-bit integer representation in [0, 255].
Only D65 illuminant is supported.

#### srgbtohex/1,2
```erlang
srgbtohex(SRGB) -> Hex
srgbtohex(SRGB, Opts) -> Hex
```
Types:
-   SRGB : #srgb{} %% Input sRGB color
-   Opts : #{prefix := binary()} %% Optional hex prefix (default: <<"">>)
-   Hex : binary() %% Hexadecimal representation, e.g. <<"ff0000">>

Converts an sRGB color (D65 only) to a hexadecimal string.
The `prefix` option allows adding a string like <<"0x">> or <<"#">> before the hex digits.

## Files and Modules

- **cbet.hrl** – Contains macros, types, and definitions of all color structures.
- **cbet.erl** – Main interface module exposing all public functions for color conversions, distances, and models.
- **cbet_matrix.hrl** – Defines vectors, matrices, and related constants abd macroses for linear algebra operations, used by `cbet_math` too.
- **cbet_math.erl** – Provides mathematical functions, primarily for vector and matrix manipulation.
## TODO

- Add support for HDR color spaces and transfer functions (PQ, HLG for scene-referred data).
- Implement parsing of CSS Color Module Levels 4 and 5 specifications color notation.
- Support for spectral data and spectral-to-RGB conversions.

