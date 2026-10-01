# MOFlect — UI demo

Single-file interactive demo of the nanocarrier design platform (NanoCompass Technologies).
Open `index.html` in a browser, use the published artifact link, or deploy it as a static site
(see [Deploying](#deploying)).

## What it does

Assemble a targeted MOF carrier and get a ranked shortlist before anything is synthesised.
The page has three tabs: **Design + screen**, **Results**, and **Design history**.

- **Components (right)** — five dropdowns: MOF carrier, surface layer, peptide, model cargo, and
  target protein (HER2 only for now). The spec sheet for a component appears only while you hover
  it — in a dropdown, on a build chip, or on the part itself in the viewport. Design parameters,
  the feasibility gates and **Save design** sit below the dropdowns in the same column.
- **3D stage (left)** — the construct, rebuilt live, at atomic resolution. **Run screen** sits in
  its top-left corner and opens the Results tab when it finishes. Zn nodes sit on the
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
- **Peptide view** — the `Peptide` tool frames the chain as a residue diagram: one bead per
  residue on a thin thread, three-letter codes, and NH2/COOH termini. Residues are coloured by
  role, following the attachment-architecture figure: **orange** for the designated attachment
  thiol (labelled with its number and its –SH group), **grey** for the engineered handle partner,
  **purple** for structural-disulfide cysteines with the S–S bridge drawn, and the chain colour for
  everything else. Which terminus sits at the surface follows `anchorIdx`, so AHNP-GC's C-terminal
  handle renders reversed against the other two. The carrier fades to a faint shell so the chain reads.
- **Binding-site inspection** — click any gold Cys anchor, or the `Site` tool, to fly into the
  attachment chemistry: a DHI-derived indole-5,6-quinone carrying the cysteine thioether adduct,
  with per-atom labels, bond-length callouts and an Å scale bar. Element labels also appear in
  the particle view once you zoom past ~2.6 world units. `Esc` or **Back to particle** exits.
  The attachment-site readout is pinned over the viewport while Site view is open.
- **Results tab** — every whole design the catalogue can build (MOF × surface layer × peptide ×
  protein, 27 today) ranked together, with interface retention, face exposure, anchor
  feasibility, loading, pH 5.0 release, release selectivity and gates passed beside the score.
  Selecting a row loads that design. Below the table: a technical readout for the loaded design,
  the pH release curves, and the build-ready dossier including the controls the run needs.
- **Design history tab** — designs kept with **Save design**, each with its parameters and the
  numbers predicted when it was saved. Load one back into the designer or delete it. Stored in
  the browser's local storage, so the list is per browser.

## The scoring model

Pre-programmed, deterministic, and calibrated on the HER2/ZIF-8 case study. Interface retention
for the three real designs is fixed at the measured medians — CGLTVSPWY 0.666, AHNP-GC 0.487,
P51 0.264 — and the sliders interpolate around them with modifiers for spacer length, crowding,
shell burial, and attachment chemistry. Two findings from the market research are deliberately
encoded: peptide density has an optimum near 1% rather than "more is better", and thicker
shells only hurt when the spacer is too short to clear them.

Ranking whole designs needs the carrier to count, so the score is the presentation score
multiplied by the carrier's acid-release factor — the same term that scales the pH 5.0 release
rate. It is 1.0 for ZIF-8, 0.85 for MIL-101(Fe) and 0.70 for UiO-66, so ZIF-8 scores are unchanged
and a carrier that holds its cargo at endosomal pH ranks lower. A design that fails any gate is
listed as Blocked below every design that clears them.

The Day 1–3 SEM assessment is wired in too: the carrier diameter reaches 2 µm with a flag above
the sub-200 nm target and a shortcut to the measured 1.31 µm S3 batch, PDA carries its measured
nodule range (64–195 nm, median 84), and free-PDA aggregates appear in the scene as dopamine
load rises — the coating-selectivity problem the report flags as the next optimisation target.

No simulation runs in the page. The banner says so, and the dossier lists what the screen
does not predict (affinity, K_d, conjugation yield, protein corona).

## Deploying

`index.html` is a bare fragment — no `<!doctype>`, `<head>` or `<body>` — because the artifact
publish wraps it in its own. A web host needs a complete document, so `build.sh` wraps it:

```sh
sh build.sh        # writes public/index.html
```

It adds the doctype, charset, viewport, a meta description and the same small reset the artifact
wrapper supplies, and moves the title, icon, fonts and styles into `<head>`. It needs only a POSIX
shell. `public/` is build output and is not committed.

**Render.** `render.yaml` describes a free static site that runs `sh build.sh` and publishes
`public/`. In the Render dashboard choose **New → Blueprint**, connect the
`aiscihub/shellgatedev` repository and apply. Every push to `main` redeploys. To set it up by
hand instead: **New → Static Site**, build command `sh build.sh`, publish directory `public`.

The deployed site is public. The page loads three.js from cdnjs and its two typefaces from Google
Fonts, so it needs internet access; saved designs stay in each visitor's own browser.

Edit `index.html` only — never `public/index.html` — and keep `<div class="shell">` at the start
of a line, since that is where the build splits head from body.

## Structure

Everything is in `index.html` — no package manager, and no build step unless you are deploying.

| Section | What it holds |
|---|---|
| `<style>` blocks | Design tokens for light and dark, layout, components |
| `CAT` | Component catalogue: carriers, coatings, cargo, peptides, proteins, with real specs |
| `S` | Application state |
| `evalDesign` / `gates` / `releaseCurves` | The scoring model; each takes the design it scores |
| `rankDesigns` / `renderRank` / `renderReadout` | Whole-design ranking and the technical readout |
| `renderPick` / `inspHTML` / `showInsp` | Component dropdowns and the hover-only spec sheet |
| `saveDesign` / `renderHist` / `loadDesign` | Design history |
| other `render*` | Build chips, gates, release chart, dossier |
| `build3D` / `init3D` | three.js scene (r128, UMD from cdnjs) |
| `buildFramework` / `SOD` | Atomistic ZIF-8: sodalite net + imidazolate bridges, cut to habit |
| `buildSite` / `AA` | Cys–PDA adduct at true scale; one Å-per-world-unit for all atoms |
| `molGroup` / `VDW` / `BSR` / `ELC` | Shared atom+bond renderer; the three representations |
| `her2Ribbon` / `ribbonGeom` | Cartoon protein: swept arrow ribbons, helices, loop tubes |
| `AA3` / `resLabels` | Three-letter residue codes and the peptide-diagram label layer |
| `updateLabels` / `enterSite` | Projected element labels, scale bar, camera focus animation |

## Iterating

- New component: add an entry to the right group in `CAT`. Its dropdown, the stack, the spec
  sheet, the dossier and the ranked table pick it up with no other change.
- New scoring behaviour: `evalDesign` is the single place scores come from.
- Atomic scale is derived once in `build3D` as `AA = (lattice world size) / 16.99 Å`, so the
  framework and the binding-site fragment share one scale and the Å bar is honest for both.
  Display radii live in `RAD_A`; don't hard-code sizes at call sites.
- Chart colours are validated for colour-vision deficiency in both themes; if you change a
  series colour, re-run the check before shipping it.
