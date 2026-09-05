# MOFlect — UI demo

Single-file interactive demo of the nanocarrier design platform (NanoCompass Technologies).
Open `index.html` in a browser, or use the published artifact link.

## What it does

Assemble a targeted MOF carrier and get a ranked shortlist before anything is synthesised.

- **Component library (left)** — MOF carrier, surface/attachment layer, model cargo, targeting
  peptide. Every card is draggable onto the 3D stage and clickable to inspect.
- **3D stage (centre)** — the construct, rebuilt live, at atomic resolution. Zn nodes sit on the
  sodalite net (the 12d sites of Im-3m) bridged by 2-methylimidazolate rings, generated over a
  block and cut to the rhombic dodecahedral habit — about 480 atoms across 72 linkers. PDA is
  edge-weighted surface deposits with free aggregates alongside, cargo is fluorescein in the
  pore, peptides are chains from a gold Cys anchor whose fold-back tracks the accessibility
  score. Orbit by dragging, zoom by scrolling, click any part to select it. `Cutaway` strips the
  coating to inspect the core.
- **Representations** — the bar at the bottom-left switches Solid habit / vdW space-filling /
  ball-and-stick / stick, the way a molecular viewer does. Element colours follow the usual
  convention: olive carbon, periwinkle nitrogen, white hydrogen, green zinc, red oxygen. HER2 is
  drawn as a cartoon — beta strands as flat arrows, helices as coiled ribbons, loops as tubes.
- **Binding-site inspection** — click any gold Cys anchor, or the `Site` tool, to fly into the
  attachment chemistry: a DHI-derived indole-5,6-quinone carrying the cysteine thioether adduct,
  with per-atom labels, bond-length callouts and an Å scale bar. Element labels also appear in
  the particle view once you zoom past ~2.6 world units. `Esc` or **Back to particle** exits.
- **Inspector (right)** — spec sheet for the selected component, four design parameters
  (density, spacer length, shell thickness, carrier diameter) and the four feasibility gates.
- **Screening output (bottom)** — ranked shortlist with predicted presentation, pH release
  curves, and a build-ready design dossier including the controls the run needs.

## The scoring model

Pre-programmed, deterministic, and calibrated on the HER2/ZIF-8 case study. Interface retention
for the three real designs is fixed at the measured medians — CGLTVSPWY 0.666, AHNP-GC 0.487,
P51 0.264 — and the sliders interpolate around them with modifiers for spacer length, crowding,
shell burial, and attachment chemistry. Two findings from the market research are deliberately
encoded: peptide density has an optimum near 1% rather than "more is better", and thicker
shells only hurt when the spacer is too short to clear them.

The Day 1–3 SEM assessment is wired in too: the carrier diameter reaches 2 µm with a flag above
the sub-200 nm target and a shortcut to the measured 1.31 µm S3 batch, PDA carries its measured
nodule range (64–195 nm, median 84), and free-PDA aggregates appear in the scene as dopamine
load rises — the coating-selectivity problem the report flags as the next optimisation target.

No simulation runs in the page. The banner says so, and the dossier lists what the screen
does not predict (affinity, K_d, conjugation yield, protein corona).

## Structure

Everything is in `index.html` — no build step, no package manager.

| Section | What it holds |
|---|---|
| `<style>` blocks | Design tokens for light and dark, layout, components |
| `CAT` | Component catalogue: carriers, coatings, cargo, peptides, with real specs |
| `S` | Application state |
| `evalDesign` / `gates` / `releaseCurves` | The scoring model |
| `render*` | Rails, inspector, ranked table, release chart, dossier |
| `build3D` / `init3D` | three.js scene (r128, UMD from cdnjs) |
| `buildFramework` / `SOD` | Atomistic ZIF-8: sodalite net + imidazolate bridges, cut to habit |
| `buildSite` / `AA` | Cys–PDA adduct at true scale; one Å-per-world-unit for all atoms |
| `molGroup` / `VDW` / `BSR` / `ELC` | Shared atom+bond renderer; the three representations |
| `her2Ribbon` / `ribbonGeom` | Cartoon protein: swept arrow ribbons, helices, loop tubes |
| `updateLabels` / `enterSite` | Projected element labels, scale bar, camera focus animation |

## Iterating

- New component: add an entry to the right group in `CAT`. The rails, stack, inspector and
  dossier pick it up with no other change.
- New scoring behaviour: `evalDesign` is the single place scores come from.
- Atomic scale is derived once in `build3D` as `AA = (lattice world size) / 16.99 Å`, so the
  framework and the binding-site fragment share one scale and the Å bar is honest for both.
  Display radii live in `RAD_A`; don't hard-code sizes at call sites.
- Chart colours are validated for colour-vision deficiency in both themes; if you change a
  series colour, re-run the check before shipping it.
