<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

Hailstone flies [Collatz sequences](https://en.wikipedia.org/wiki/Collatz_conjecture), also called hailstone
sequences because their values rise and fall like hailstones in a cloud before they land.

The input switches `ui_in` give the seed (0 means 256). Each clock cycle, the value takes one step: halved if
even, or tripled plus one if odd. When it reaches 1, it has landed, and it stays there. Changing the seed (or
resetting) launches a new flight. Values stay below 13,120 for every seed, so a 16-bit register holds them.

- The 7-segment display shows the value's "altitude", floor(log2(value)), as a hex digit (0 to d).
- Once landed, the display shows the flight's peak altitude, with the decimal point lit.
- `uio_out` shows the number of steps taken (up to 127, for seed 231).

The design is in TL-Verilog. In [Makerchip](https://makerchip.com), its visualization plots the flight on the
virtual demo board's chip.

## How to test

Set the clock slowly enough to watch, e.g. 2-10 Hz. Set a seed on the input switches; the flight starts as soon
as the switches change. Watch the altitude climb and fall on the 7-segment display until the decimal point lights,
then read the peak altitude. Read the step count on the bidirectional pins (e.g. with LEDs on a PMOD).

Some flights to try:

| Seed | Steps | Peak value | Peak altitude |
| ---- | ----- | ---------- | ------------- |
| 7    | 16    | 52         | 5             |
| 27   | 111   | 9,232      | d             |
| 231  | 127   | 9,232      | d             |
| 255  | 47    | 13,120     | d             |
| 0    | 8     | 256        | 8             |

Since the seed reloads whenever the switches change, flipping switches one at a time launches a short flight from
each intermediate seed; the last one counts.

## External hardware

None required. Optionally, LEDs on the bidirectional PMOD to show the step count.
