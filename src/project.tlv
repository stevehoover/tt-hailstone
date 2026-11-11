\m5_TLV_version 1d --debugSigsYosys --fmtFlatSignals: tl-x.org
\m5
   /**
   This template is for developing Tiny Tapeout designs using Makerchip.
   Verilog, SystemVerilog, and/or TL-Verilog can be used.
   Use of Tiny Tapeout Demo Boards (as virtualized in the VIZ tab) is supported.
   See the corresponding Git repository for build instructions.
   **/

   use(m5-1.0)  // See M5 docs in Makerchip IDE Learn menu.

   // ---SETTINGS---
   var(my_design, tt_um_stevehoover_hailstone)  /// Change tt_um_example to tt_um_<your-github-username>_<name-of-your-project>. (See README.md.)
   var(target, ASIC) /// Use "FPGA" for TT03 Demo Boards (without bidirectional I/Os).
   var(in_fpga, 1)   /// 1 to include the demo board visualization. (Note: Logic will be under /fpga_pins/fpga.)
   var(debounce_inputs, 0)
                     /// Legal values:
                     ///   1: Provide synchronization and debouncing on all input signals.
                     ///   0: Don't provide synchronization and debouncing.
                     ///   m5_if_defined_as(MAKERCHIP, 1, 0, 1): Debounce unless in Makerchip.
   // --------------

   // If debouncing, your top module is wrapped within a debouncing module, so it has a different name.
   var(user_module_name, m5_if(m5_debounce_inputs, my_design, m5_my_design))
   var(debounce_cnt, m5_if_defined_as(MAKERCHIP, 1, 8'h03, 8'hff))
   // No TT lab outside of Makerchip.
   if_defined_as(MAKERCHIP, 1, [''], ['m5_set(in_fpga, 0)'])
\SV
   // Include Tiny Tapeout Lab.
   m4_include_lib(['https:/']['/raw.githubusercontent.com/os-fpga/Virtual-FPGA-Lab/62d6e18bc3d0ca8af451ccaff6d63974a69e645b/tlv_lib/tiny_tapeout_lib.tlv'])

\TLV my_design()

   // ============================================
   // Hailstone: a Collatz-sequence flight recorder.
   //
   // The input switches (*ui_in) give a seed (0 means 256). Each clock cycle, the value takes one
   // Collatz step (n/2 if even, 3n+1 if odd) until it lands at 1. Changing the seed (or reset)
   // launches a new flight.
   //
   // The 7-segment display shows the "altitude" (floor(log2(value))) as a hex digit in flight, and,
   // once landed, the peak altitude of the flight, with the decimal point lit.
   // *uio_out shows the step count.
   // ============================================

   |hail
      @1
         $reset = *reset;
         $ui[7:0] = *ui_in;
         $reload = $reset || ($ui != >>1$ui);
         $seed[8:0] = ($ui == 8'd0) ? 9'd256 : {1'b0, $ui};

         // The flight. (Seeds up to 256 peak at 13120, so 16 bits suffice.)
         $value[15:0] = $reload ? {7'b0, $seed} : >>1$next;
         $landed = $value == 16'd1;
         $next[15:0] = $landed  ? $value :
                       $value[0] ? $value + ($value << 1) + 16'd1 :
                                   $value >> 1;
         $steps[7:0] = $reload     ? 8'd0 :
                       >>1$landed  ? >>1$steps :
                                     >>1$steps + 8'd1;

         // Altitude: the index of the most-significant 1.
         \SV_plus
            always_comb begin
               $$alt[3:0] = 4'd0;
               for (int i = 1; i < 16; i++)
                  if ($value[i]) $alt = i[3:0];
            end
         $peak_alt[3:0] = ($reload || ($alt > >>1$peak_alt)) ? $alt : >>1$peak_alt;

         // 7-segment hex digit (gfedcba).
         $digit[3:0] = $landed ? $peak_alt : $alt;
         $segs[6:0] =
            ($digit == 4'h0) ? 7'h3F : ($digit == 4'h1) ? 7'h06 : ($digit == 4'h2) ? 7'h5B : ($digit == 4'h3) ? 7'h4F :
            ($digit == 4'h4) ? 7'h66 : ($digit == 4'h5) ? 7'h6D : ($digit == 4'h6) ? 7'h7D : ($digit == 4'h7) ? 7'h07 :
            ($digit == 4'h8) ? 7'h7F : ($digit == 4'h9) ? 7'h6F : ($digit == 4'hA) ? 7'h77 : ($digit == 4'hB) ? 7'h7C :
            ($digit == 4'hC) ? 7'h39 : ($digit == 4'hD) ? 7'h5E : ($digit == 4'hE) ? 7'h79 :                   7'h71;

         // Flight plot: log2(value) over the last 128 cycles; the current flight is bright.
         \viz_js
            box: {left: -10, top: -50, width: 532, height: 330, fill: "#101828", strokeWidth: 0},
            init() {
               const ret = {}
               ret.title = new fabric.Text("", {left: 0, top: -42, fontSize: 18, fill: "white", fontFamily: "monospace"})
               // Altitude grid lines.
               for (let a = 0; a <= 14; a += 2) {
                  ret["grid" + a] = new fabric.Line([0, 256 - a * 18, 512, 256 - a * 18], {stroke: "#283048", strokeWidth: 1})
                  ret["lab" + a] = new fabric.Text(a.toString(16), {left: -8, top: 250 - a * 18, fontSize: 10, fill: "#8090b0", fontFamily: "monospace"})
               }
               for (let i = 0; i < 128; i++) {
                  ret["bar" + i] = new fabric.Rect({left: i * 4, top: 256, width: 3.5, height: 0, fill: "#4080ff", strokeWidth: 0})
               }
               return ret
            },
            render() {
               const o = this.obj
               // Find the latest launch; earlier bars are dimmed.
               let lastLaunch = -1
               const r = '$reload'.step(-127)
               for (let i = 0; i < 128; i++) {if (r.inTrace() && r.asBool(false)) {lastLaunch = i}; r.step(1)}
               // Bars: odd values orange, even blue, current white.
               const sig = '$value'.step(-127)
               for (let i = 0; i < 128; i++) {
                  const v = sig.inTrace() ? sig.asInt(0) : 0
                  const h = v > 0 ? Math.log2(v) * 18 + 2 : 0
                  o["bar" + i].set({top: 256 - h, height: h, opacity: (i >= lastLaunch) ? 1 : 0.25,
                                    fill: (i == 127) ? "#ffffff" : (v & 1) ? "#ff8040" : "#4080ff"})
                  sig.step(1)
               }
               o.title.set({text: `seed ${'$seed'.asInt(0)}  step ${'$steps'.asInt(0)}  value ${'$value'.asInt(0)}` +
                                  ('$landed'.asBool(false) ? "  LANDED" : "")})
            },
            where: {left: 0, top: 0, width: 100, height: 62}
      @2
         // Registered outputs.
         *uo_out = {$landed, $segs};
         *uio_out = $steps;
         *uio_oe = 8'hFF;


// Set up the Tiny Tapeout lab environment.
\TLV tt_lab()
   /* verilator lint_off UNOPTFLAT */
   // Connect Tiny Tapeout I/Os to Virtual FPGA Lab.
   m5+tt_connections()

   // Instantiate the Virtual FPGA Lab.
   m5+board(/top, /fpga, 7, $, , my_design)
   // Label the switch inputs [0..7] (1..8 on the physical switch panel) (bottom-to-top).
   m5+tt_input_labels_viz(['"Seed[0]", "Seed[1]", "Seed[2]", "Seed[3]", "Seed[4]", "Seed[5]", "Seed[6]", "Seed[7]"'])

\SV


// ================================================
// Makerchip test bench: flies a few seeds and checks each landing
// (step count, and the peak altitude on the 7-segment display with the decimal point).
// ================================================

module top(input logic clk, input logic reset, input logic [31:0] cyc_cnt, output logic passed, output logic failed);
   // Tiny tapeout I/O signals.
   logic [7:0] ui_in, uio_in, uo_out, uio_out, uio_oe;
   logic ena = 1'b1;
   wire rst_n = ! reset;

   // A new seed every 128 cycles: 27 (111 steps, peak 9232: altitude d), 7 (16 steps, peak 52: altitude 5),
   // and 0, meaning 256 (8 steps, peak 256: altitude 8).
   wire [1:0] phase = cyc_cnt[8:7];
   assign ui_in = (phase == 2'd0) ? 8'd27 : (phase == 2'd1) ? 8'd7 : 8'd0;
   assign uio_in = 8'b0;
   wire [7:0] exp_steps = (phase == 2'd0) ? 8'd111 : (phase == 2'd1) ? 8'd16 : 8'd8;
   wire [7:0] exp_uo    = (phase == 2'd0) ? 8'hDE  : (phase == 2'd1) ? 8'hED : 8'hFF;  // dp + 'd', '5', '8'

   /*
   // Or, to provide specific inputs at specific times...
   // BE SURE TO COMMENT THE ASSIGNMENT OF INPUTS ABOVE.
   // BE SURE TO DRIVE THESE ON THE B-PHASE OF THE CLOCK (ODD STEPS).
   // Driving on the rising clock edge creates a race with the clock that has unpredictable simulation behavior.
   initial begin
      #1  // Drive inputs on the B-phase.
         ui_in = 8'h0;
      #10 // Step past reset.
         ui_in = 8'hFF;
      // ...etc.
   end
   */

   // Instantiate the Tiny Tapeout module.
   m5_my_design tt(.*);

   // Check each landing at the end of its phase.
   wire check = (cyc_cnt[6:0] == 7'd127) && (phase != 2'd3);
   assign passed = cyc_cnt > 3 * 128;
   assign failed = check && ((uio_out != exp_steps) || (uo_out != exp_uo) || (uio_oe != 8'hFF));
endmodule

// Provide a wrapper module to debounce input signals if requested.
// TODO: The debounce module is conditioned for TT03.
m5_if(m5_debounce_inputs, ['m5_tt_top(m5_my_design)'])
// The above macro expands to multiple lines. We enter a new \SV block to reset line tracking.
\SV



// The Tiny Tapeout module.
module m5_user_module_name (
    input  wire [7:0] ui_in,    // Dedicated inputs - connected to the input switches
    output wire [7:0] uo_out,   // Dedicated outputs - connected to the 7 segment display
    input  wire [7:0] uio_in,   // IOs: Bidirectional Input path
    output wire [7:0] uio_out,  // IOs: Bidirectional Output path
    output wire [7:0] uio_oe,   // IOs: Bidirectional Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // will go high when the design is enabled
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

   wire reset = ! rst_n;

   // List all potentially-unused inputs to prevent warnings
   (* keep *) wire _unused = &{ena, clk, reset, ui_in, uio_in, 1'b1};

\TLV
   m5_if(m5_in_fpga, ['m5+tt_lab()'], ['m5+my_design()'])

\SV_plus

   // =========================================
   // If you are using (System)Verilog for your design,
   // your Verilog logic goes here.
   // =========================================

   // ...


   // Connect Tiny Tapeout outputs.
   // Note that my_design will be under /fpga_pins/fpga if m5_in_fpga.
   // Example *uo_out = /fpga_pins/fpga|my_pipe>>3$uo_out;
   // (Hailstone drives its outputs in \TLV my_design().)

endmodule
