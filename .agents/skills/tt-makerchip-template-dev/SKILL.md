---
name: tt-makerchip-template-dev
description: 'Maintaining stevehoover/tt-makerchip-template itself: how it differs from Tiny Tapeout''s templates, its multi-PDK design, syncing from upstream, testing changes, and what the Makerchip extension and TT views rely on. Use only when developing the template (or a fork of it), not when designing a project made from it; for that, see the Makerchip extension''s tiny-tapeout skill.'
---

# Developing tt-makerchip-template

(Projects made from the template inherit this file; it is about the template, not their design.) Using the
template is covered by the README, `BROWSER.md`, and the Makerchip extension's `tiny-tapeout` skill. This file is
the one copy; `.claude/skills/` and `.github/skills/` link to it.

## What it adds to Tiny Tapeout's template

The repo is a Git fork of `TinyTapeout/ttsky-verilog-template` (remote `upstream`). On top of it:

- **TL-Verilog:** `src/project.tlv` is the design source (with the Virtual FPGA Lab's TT demo board for
  Makerchip's VIZ, from `Virtual-FPGA-Lab/tlv_lib/tiny_tapeout_lib.tlv`, pinned by commit). `src/project.sv` is
  generated from it by SandPiper and committed, so TT's checks and flow see plain Verilog and TT's workflows
  need no generation step. `info.yaml` lists `project.sv`; `test/Makefile` sets `PROJECT_SOURCES` and has the
  `verilog` rule.
- **Every PDK from one repo:** `project.pdk` in `info.yaml` (not a TT field), and PDK-generic workflows,
  `test/Makefile`, `test/tb.v` and `src/config.json`. `UPSTREAM.md` is the primary doc for this: which parts are
  PDK-specific, the pinned `tt-gds-action` commit and what it fixes, the TT templates' synced commits, and how to
  update.
- Docs (`README.md`, `BROWSER.md`), `.vscode/extensions.json` recommending the Makerchip extension, and
  `test/test.py` checking the template's all-zero outputs.
- Like TT's, the template leaves the project's identity and docs blank in `info.yaml` and `docs/info.md`, since
  each project must supply them. So its own `gds` and `docs` runs fail TT's checks by design; test on the demo
  project instead (below).

## Design choices and alternatives

- **Committed `.sv` vs. building it in CI.** TT's flow has no front-end hook, so generated Verilog must be one
  or the other. The archived
  [stevehoover/tt10-makerchip-template](https://github.com/stevehoover/tt10-makerchip-template) (and its tt07/tt08
  predecessors) instead built the `.sv` in CI: a "Build Verilog" step (`cd test && make verilog`, installing
  `sandpiper-saas`) before `tt-gds-action` in each workflow, with the `.sv` ignored by Git. That keeps the
  `.tlv` the only source and can't go stale, but every run depends on SandPiper-SaaS and every workflow differs
  from TT's. Committing it was chosen so the workflows stay TT's; staleness is the cost (a hash stamp in the
  `.sv`, ideally added by SandPiper, would let CI detect it).
- **One template vs. one per PDK.** TT keeps one per PDK. One template was chosen (and proven on sky130A,
  gf180mcuD and ihp-sg13cmos5l) so users retarget with one line and the Makerchip changes live once; the cost is
  porting TT's GF and IHP template changes by hand, per `UPSTREAM.md`.
- **Not a TT template.** TT's app checks only the PDK and a passing build, not which template a project came from.

## What other components rely on

- The **Makerchip extension's "Run TT Flow" button** shows on a `.tlv` in `src/` of a project with `info.yaml`
  at its root, writes `src/<name>.sv` beside it, and compiles with SandPiper flags that duplicate the `verilog`
  rule's in `test/Makefile` (`TT_SANDPIPER_ARGS` in the extension's `src/tinyTapeout.ts`); keep them in sync. Its
  pre-flight check mirrors TT's required-info checks.
- The **TT views** (stevehoover/makerchip-tt-views) read the project's GitHub Pages as TT's `viewer` job lays it
  out (`gds_render.png`, `tinytapeout.oas`, and the PDK in the redirect page), and job names (`gds`, `viewer`)
  from the Actions API.
- `project.tlv` uses M5's `MAKERCHIP` to include the lab and stimulus only in Makerchip compiles; the TT compile
  must not define it.

## Testing a change

Test on [stevehoover/tt-makerchip-demo](https://github.com/stevehoover/tt-makerchip-demo), an 8-bit counter
with its project info filled in. It is a clone of this repo, not made with "Use this template", so it shares this
history: in its clone (remote `template` for this repo), `git pull template main` brings in a change. Push it
with `project.pdk` set to each PDK in turn, waiting for each `gds` run to finish, and check that `gds` (with
`precheck`, `gl_test`, `viewer`), `test` and `docs` pass. Each build's `tt_submission/pdk.json` records the PDK and tool
versions it used. Pushes a few minutes apart can collide in their Pages deploys (a `viewer` "in progress"
failure); rerun it.
