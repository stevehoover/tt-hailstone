# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, FallingEdge

# 7-segment hex digits (gfedcba).
SEG = [0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x6F, 0x77, 0x7C, 0x39, 0x5E, 0x79, 0x71]


def expected(seed, n):
    """The expected (uo_out, uio_out) for each of the first n steps of seed's flight."""
    v = seed if seed else 256
    steps = 0
    peak_alt = 0
    ret = []
    for _ in range(n):
        landed = v == 1
        alt = v.bit_length() - 1
        peak_alt = max(peak_alt, alt)
        ret.append(((landed << 7) | SEG[peak_alt if landed else alt], steps))
        if not landed:
            v = v // 2 if v % 2 == 0 else 3 * v + 1
            steps += 1
    return ret


def flight_len(seed):
    v = seed if seed else 256
    n = 0
    while v != 1:
        v = v // 2 if v % 2 == 0 else 3 * v + 1
        n += 1
    return n


async def fly(dut, seed, n):
    """Launch seed (by changing ui_in) and check n steps of its flight, cycle by cycle."""
    await FallingEdge(dut.clk)
    dut.ui_in.value = seed
    for step, (uo, uio) in enumerate(expected(seed, n)):
        await FallingEdge(dut.clk)
        assert dut.uo_out.value == uo, f"seed {seed}, step {step}: uo_out {int(dut.uo_out.value):#04x} != {uo:#04x}"
        assert dut.uio_out.value == uio, f"seed {seed}, step {step}: uio_out {int(dut.uio_out.value)} != {uio}"
        assert dut.uio_oe.value == 0xFF


@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")

    # Set the clock period to 10 us (100 KHz)
    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    # Reset
    dut._log.info("Reset")
    dut.ena.value = 1
    dut.ui_in.value = 1
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1

    # Seed 1 is already landed: dp and peak altitude 0.
    await ClockCycles(dut.clk, 2)
    await FallingEdge(dut.clk)
    assert dut.uo_out.value == 0x80 | SEG[0]
    assert dut.uio_out.value == 0

    dut._log.info("Fly 27, 7, and 0 (meaning 256), cycle by cycle")
    for seed in (27, 7, 0):
        await fly(dut, seed, flight_len(seed) + 5)

    dut._log.info("Reset mid-flight relaunches the same seed")
    await fly(dut, 97, 20)
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 3)
    dut.rst_n.value = 1
    for step, (uo, uio) in enumerate(expected(97, 30)):
        await FallingEdge(dut.clk)
        assert dut.uo_out.value == uo and dut.uio_out.value == uio, f"after reset, step {step}"

    dut._log.info("Land every seed")
    for seed in range(256):
        await fly(dut, seed, flight_len(seed) + 1)
