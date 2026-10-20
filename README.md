# Fields and Radiated Energy of a Solenoid with Time-Varying Current

MATLAB simulation of the electromagnetic fields produced by an infinitely long
solenoid of radius `R` carrying a time-dependent current `I(t)`. The azimuthal
electric field `E_φ` and the axial magnetic field `B_z` are computed in two
ways, and the results are compared:

- **Analytical solution** in the frequency domain, written with Bessel and
  Hankel functions matched at the solenoid surface (`ρ = R`).
- **Numerical solution** with the **FFT**: the transfer functions of the
  system are applied to the Fourier transform of an arbitrary current, so any
  waveform (cosine, Gaussian pulse...) can be studied.

The script also computes the **energy** supplied by the source and the energy
**radiated** through cylinders of different radii, using the Poynting vector.

All quantities are expressed in normalized units (`ε₀ = μ₀ = 1`, so `c = 1`).

## Physical model

- Infinite solenoid of radius `R` with `N` turns per unit length.
- Current `I(t)`, with `I₀` as amplitude.
- Fields in cylindrical coordinates: `E_φ(ρ, t)` and `B_z(ρ, t)`.
- Poynting vector (radial component): `S_ρ = E_φ · B_z / μ₀`.
- Radiated energy per unit length through a cylinder of radius `ρ`:

      E_rad(ρ) = 2πρ · ∫ S_ρ dt

- Energy supplied by the source per unit length:

      E_in = −2πR · ∫ N · I(t) · E_φ(R, t) dt

## Parameters

| Parameter | Value | Meaning |
|---|---|---|
| `P.e0`, `P.mu0` | 1, 1 | Normalized permittivity and permeability |
| `P.I0` | 1 | Current amplitude |
| `P.N` | 10 | Turns per unit length |
| `P.R` | 1 | Solenoid radius |
| `w0` | 5, 0.01 | Angular frequency (radiation / quasi-static regimes) |

## What it does

The script runs five exercises:

1. **Fields vs. radial distance** at `t = π/8`, comparing the analytical and
   numerical solutions for `ω₀ = 5` (radiation regime) and `ω₀ = 0.01`
   (quasi-static regime).
2. **Time evolution** of `E_φ` and `B_z` at `ρ = 0.5, 1.1` and `5`.
3. **Accumulated total energy** for a cosine current: radiated energy as a
   function of `ρ` vs. energy supplied by the source.
4. **Gaussian pulse:** a cosine modulated by a Gaussian envelope. Radiated
   energy vs. `ρ`, input energy, and a surface plot of the field `E(ρ, t)`.
5. **Relative error analysis** between the numerical and analytical solutions
   of exercise 1.

## Usage

1. Open MATLAB and move to the project folder.
2. Run:

```matlab
practica2
```

3. Edit the parameters in the `P` structure at the top of the file, or the
   values of each exercise, to explore other cases.

## Generated files

Figures are saved to the working folder as `.png` files:

| File | Contents |
|---|---|
| `Ejercicio1_CamposEspaciales.png` | Fields vs. `ρ` (analytical vs. numerical) |
| `Ejercicio2_Temporal.png` | Time evolution at three radii |
| `Ejercicio3_EnergiaCoseno.png` | Accumulated energy, cosine current |
| `Ejercicio4_EnergiaGauss.png` | Current and accumulated energy, Gaussian pulse |
| `Ejercicio4_Surf.png` | Surface plot of `E(ρ, t)` for the Gaussian pulse |
| `Ejercicio5_Errores.png` | Relative error of `E_φ` and `B_z` |

<img width="3000" height="1505" alt="Ejercicio1_CamposEspaciales" src="https://github.com/user-attachments/assets/2712bbe9-7bf2-4c3e-9dfe-ce90c3c80224" />

## Requirements

- MATLAB R2019b or later
