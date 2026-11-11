![](../../workflows/gds/badge.svg) ![](../../workflows/docs/badge.svg) ![](../../workflows/test/badge.svg) ![](../../workflows/fpga/badge.svg)

# Tiny Tapeout Makerchip Project Template

- [Read the documentation for project](docs/info.md)

This is the [Tiny Tapeout Verilog template](https://github.com/TinyTapeout/ttsky-verilog-template)
streamlined and enriched by [Makerchip](https://makerchip.com), with support for VS Code integration and AI assistance.
One template serves every Tiny Tapeout process (PDK): `pdk` in [info.yaml](info.yaml) selects it, so retargeting
your design to another shuttle's process is a one-line change. (Maintainers: see [UPSTREAM.md](UPSTREAM.md).)

## What is Tiny Tapeout?

Tiny Tapeout is an educational project that aims to make it easier and cheaper than ever to get your digital and analog designs manufactured on a real chip (digital for this repo).

To learn more and get started, visit https://tinytapeout.com.

## Getting started

These instructions assume you have:
- a GitHub account
- (preferred) VS Code with the [Makerchip extension](https://marketplace.visualstudio.com/items?itemName=RedwoodEDA.makerchip)
- (preferred) an AI agent in VS Code (e.g. Copilot or Claude)

The extension adds AI skills, including setup guidance, a button that runs the Tiny Tapeout flow (on GitHub
Actions), and views that show its results.

### 1. Set up your project (once)

Ask your agent to, e.g., "Set up a Tiny Tapeout project with Makerchip," and follow its guidance. It will
create your repo from this template (asking you for its name and where to put it), enable its GitHub Pages, fill in your project's information (asking you for
it, including the shuttle you're targeting), and open `src/project.tlv`, whose title bar has the "Run TT Flow" button. Your agent can help you change these configurations anytime. (To do this by hand instead, or if anything goes awry, see
[BROWSER.md](BROWSER.md#1-set-up-by-hand).)

### 2. Design

Design in [src/project.tlv](src/project.tlv), in Verilog/SystemVerilog/TL-Verilog. (See "logic goes here" comments in the template.) The Makerchip button in its title
bar compiles and simulates it, with the Tiny Tapeout demo board in the VIZ view. Adapt the testbench to your
design (see [test/README.md](test/README.md)), and keep `pinout` and `docs/info.md` up to date.

### 3. Run the Tiny Tapeout flow

Click "Run TT Flow" (the rocket in `src/project.tlv`'s title bar). It checks your project's information,
regenerates `src/project.sv` (the Verilog the flow builds), and commits and pushes it. The push runs the flow on
GitHub Actions, which builds the ASIC with [LibreLane](https://www.zerotoasiccourse.com/terminology/librelane/).
Its progress and layout appear in Makerchip's TT Progress and TT Layout views.

## Resources

- [FAQ](https://tinytapeout.com/faq/)
- [Digital design lessons](https://tinytapeout.com/digital_design/)
- [Learn how semiconductors work](https://tinytapeout.com/siliwiz/)
- [Join the community](https://tinytapeout.com/discord)
- [Build your design locally](https://www.tinytapeout.com/guides/local-hardening/)

## What next?

- [Submit your design to the next shuttle](https://app.tinytapeout.com/).
- Edit [this README](README.md) and explain your design, how it works, and how to test it.
- Share your project on your social network of choice:
  - LinkedIn [#tinytapeout](https://www.linkedin.com/search/results/content/?keywords=%23tinytapeout) [@TinyTapeout](https://www.linkedin.com/company/100708654/)
  - Mastodon [#tinytapeout](https://chaos.social/tags/tinytapeout) [@matthewvenn](https://chaos.social/@matthewvenn)
  - X (formerly Twitter) [#tinytapeout](https://twitter.com/hashtag/tinytapeout) [@tinytapeout](https://twitter.com/tinytapeout)
  - Bluesky [@tinytapeout.com](https://bsky.app/profile/tinytapeout.com)
