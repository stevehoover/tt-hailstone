# Setting up by hand, and using Makerchip in your browser

The [README](README.md) assumes VS Code with the Makerchip extension and an AI agent. This covers doing the same
by hand: setup, with or without the extension, and the whole flow with Makerchip in your browser. Either way the
flow runs on GitHub Actions.

## 1. Set up by hand

1. Create your repo from this template (it must be public): "Use this template" on GitHub, or
   `gh repo create <name> --template stevehoover/tt-makerchip-template --public --clone`. Clone it.
2. [Enable GitHub Pages](https://tinytapeout.com/faq/#my-github-action-is-failing-on-the-pages-part) with
   GitHub Actions as its source, for the layout viewer.
3. Fill in your project's information, which the template leaves blank for you. Until it is filled, the `gds`
   and `docs` runs fail Tiny Tapeout's checks.
   - [info.yaml](info.yaml): `title`, `author`, `description`, `pinout`, and `top_module`, which must match
     `my_design` in `src/project.tlv` and the module instantiated in `test/tb.v`. Also set `pdk` to your
     shuttle's process (it defaults to `sky130A`).
   - [docs/info.md](docs/info.md): the "How it works" and "How to test" sections.

With the extension, then open `src/project.tlv` in VS Code (its title bar has the "Run TT Flow" button) and
continue with the README.

## 2. Design in your browser

In [Makerchip](https://makerchip.com), open `src/project.tlv` (under "Project" menu). (This requires a Chromium-based browser that permits file operations; otherwise cut-n-paste code.) Adapt the testbench to your design (see [test/README.md](test/README.md)), and
keep `pinout` and `docs/info.md` up to date.

## 3. Run the flow without the extension

Regenerate `src/project.sv`, the Verilog the flow builds, with `cd test && make verilog` (needs
[SandPiper-SaaS](https://pypi.org/project/sandpiper-saas/): `pipx install sandpiper-saas`). Commit it with
`src/project.tlv`, and push. Follow the run in your repo's Actions tab; when the `gds` workflow completes, its
layout is in TT's 3D viewer at your repo's GitHub Pages URL (`https://<owner>.github.io/<repo>/`).
