// =============================================================================
// Módulo  : alu
// Archivo : tb_alu.sv
// Fecha   : 2026
// =============================================================================
// PLAN DE PRUEBAS:
//   T1. Suma básica sin carry ni overflow
//   T2. Suma con carry (resultado > 255)
//   T3. Suma con overflow de signo (pos+pos=neg)
//   T4. Resta básica sin borrow
//   T5. Resta con borrow (op_a < op_b)
//   T6. Resta con overflow de signo (neg-pos=pos)
//   T7. AND bit a bit (incluyendo caso todo ceros)
//   T8. OR bit a bit
//   T9. XOR bit a bit
//   T10. Flag ZERO verificado explícitamente
//  T11. Valores extremos con 0 y 0xFF
//

`timescale 1ns/1ps

module tb_alu;

    localparam int DW         = 8;
    localparam     CLK_PERIOD = 10;

    logic [DW-1:0] op_a;
    logic [DW-1:0] op_b;
    logic [1:0]    op_sel;
    logic [DW-1:0] result;
    logic          flag_zero;
    logic          flag_carry;
    logic          flag_neg;
    logic          flag_ovf;

    int unsigned fail_count = 0;

    // Instancia DUT
    alu dut (
        .op_a      (op_a      ),
        .op_b      (op_b      ),
        .op_sel    (op_sel    ),
        .result    (result    ),
        .flag_zero (flag_zero ),
        .flag_carry(flag_carry),
        .flag_neg  (flag_neg  ),
        .flag_ovf  (flag_ovf  )
    );

    // Reloj auxiliar (NOT SYNTHESIZABLE)
    logic clk = 0;
    always #(CLK_PERIOD/2) clk = ~clk;

    // Waveform dump
    initial begin
        $dumpfile("tb_alu.vcd");
        $dumpvars(0, tb_alu);
    end

    // Monitor (NOT SYNTHESIZABLE)
    initial begin
        $monitor("[%0t ns] op_a=%0d op_b=%0d sel=%b | result=%0d zero=%b carry=%b neg=%b ovf=%b",
                 $time, op_a, op_b, op_sel, result,
                 flag_zero, flag_carry, flag_neg, flag_ovf);
    end

    // Macro de verificación
    `define CHECK(signal, expected, msg) \
        if ((signal) !== (expected)) begin \
            $error("[FALLO] %s: obtenido=%0d esperado=%0d (t=%0t)", \
                   msg, signal, expected, $time); \
            fail_count++; \
        end

    // -------------------------------------------------------------------------
    // T1: ADD básico
    // -------------------------------------------------------------------------
    task automatic test_add_basic();
        $display("\n--- T1: ADD básico (3 + 5 = 8) ---");
        op_a = 8'd3; op_b = 8'd5; op_sel = 3'b000; #1;
        `CHECK(result,     8,    "T1 result")
        `CHECK(flag_zero,  1'b0, "T1 zero")
        `CHECK(flag_carry, 1'b0, "T1 carry")
        `CHECK(flag_neg,   1'b0, "T1 neg")
        `CHECK(flag_ovf,   1'b0, "T1 ovf")
        $display("[PASS] T1");
    endtask

    // -------------------------------------------------------------------------
    // T2: ADD con carry
    // -------------------------------------------------------------------------
    task automatic test_add_carry();
        logic [8:0] expected_full;
        $display("\n--- T2: ADD carry (200 + 100 = 300) ---");
        op_a = 8'd200; op_b = 8'd100; op_sel = 3'b000; #1;
        expected_full = 9'd300;
        `CHECK(result,     expected_full[7:0], "T2 result")
        `CHECK(flag_carry, 1'b1,               "T2 carry")
        `CHECK(flag_zero,  1'b0,               "T2 zero")
        $display("[PASS] T2");
    endtask

    // -------------------------------------------------------------------------
    // T3: ADD overflow de signo
    // -------------------------------------------------------------------------
    task automatic test_add_overflow();
        $display("\n--- T3: ADD overflow signo (64 + 80 = 144 = -112 en C2) ---");
        op_a = 8'd64; op_b = 8'd80; op_sel = 3'b000; #1;
        `CHECK(result,     8'd144, "T3 result")
        `CHECK(flag_ovf,   1'b1,   "T3 overflow")
        `CHECK(flag_neg,   1'b1,   "T3 neg")
        `CHECK(flag_carry, 1'b0,   "T3 carry")
        $display("[PASS] T3");
    endtask

    // -------------------------------------------------------------------------
    // T4: SUB básico
    // -------------------------------------------------------------------------
    task automatic test_sub_basic();
        $display("\n--- T4: SUB básico (10 - 3 = 7) ---");
        op_a = 8'd10; op_b = 8'd3; op_sel = 3'b001; #1;
        `CHECK(result,     8'd7,  "T4 result")
        `CHECK(flag_carry, 1'b0,  "T4 borrow")
        `CHECK(flag_zero,  1'b0,  "T4 zero")
        `CHECK(flag_neg,   1'b0,  "T4 neg")
        $display("[PASS] T4");
    endtask

    // -------------------------------------------------------------------------
    // T5: SUB con borrow
    // -------------------------------------------------------------------------
    task automatic test_sub_borrow();
        $display("\n--- T5: SUB borrow (3 - 10 → 249) ---");
        op_a = 8'd3; op_b = 8'd10; op_sel = 3'b001; #1;
        `CHECK(result,     8'd249, "T5 result")
        `CHECK(flag_carry, 1'b1,   "T5 borrow")
        `CHECK(flag_neg,   1'b1,   "T5 neg")
        $display("[PASS] T5");
    endtask

    // -------------------------------------------------------------------------
    // T6: SUB overflow de signo
    // -------------------------------------------------------------------------
    task automatic test_sub_overflow();
        $display("\n--- T6: SUB overflow signo (0x80 - 0x01) ---");
        op_a = 8'h80; op_b = 8'h01; op_sel = 3'b001; #1;
        `CHECK(result,   8'h7F, "T6 result")
        `CHECK(flag_ovf, 1'b1,  "T6 overflow")
        `CHECK(flag_neg, 1'b0,  "T6 neg")
        $display("[PASS] T6");
    endtask

    // -------------------------------------------------------------------------
    // T7: AND
    // -------------------------------------------------------------------------
    task automatic test_and();
        $display("\n--- T7: AND (0xF0 & 0x0F = 0x00) ---");
        op_a = 8'hF0; op_b = 8'h0F; op_sel = 3'b010; #1;
        `CHECK(result,    8'h00, "T7 result")
        `CHECK(flag_zero, 1'b1,  "T7 zero")
        `CHECK(flag_carry,1'b0,  "T7 carry")
        `CHECK(flag_ovf,  1'b0,  "T7 ovf")
        $display("[PASS] T7");
        op_a = 8'hAA; op_b = 8'hFF; #1;
        `CHECK(result, 8'hAA, "T7b AND con 0xFF")
        $display("[PASS] T7b");
    endtask

    // -------------------------------------------------------------------------
    // T8: OR
    // -------------------------------------------------------------------------
    task automatic test_or();
        $display("\n--- T8: OR (0xF0 | 0x0F = 0xFF) ---");
        op_a = 8'hF0; op_b = 8'h0F; op_sel = 3'b011; #1;
        `CHECK(result,   8'hFF, "T8 result")
        `CHECK(flag_neg, 1'b1,  "T8 neg")
        `CHECK(flag_zero,1'b0,  "T8 zero")
        $display("[PASS] T8");
    endtask

    // -------------------------------------------------------------------------
    // T9: XOR
    // -------------------------------------------------------------------------
    task automatic test_xor();
        $display("\n--- T9: XOR (0xF0 ^ 0x0F = 0xFF) ---");
        op_a = 8'h03; op_b = 8'h05; op_sel = 3'b100; #1;
        `CHECK(result,   8'h6, "T9 result")
        `CHECK(flag_neg, 1'b1,  "T9 neg")
        `CHECK(flag_zero,1'b0,  "T9 zero")
        $display("[PASS] T9");
    endtask
    // -------------------------------------------------------------------------
    // T10: Flag ZERO
    // -------------------------------------------------------------------------
    task automatic test_zero_flag();
        $display("\n--- T10: ZERO flag (5 - 5 = 0) ---");
        op_a = 8'd5; op_b = 8'd5; op_sel = 3'b001; #1;
        `CHECK(result,    8'd0, "T10 result")
        `CHECK(flag_zero, 1'b1, "T10 zero")
        `CHECK(flag_carry,1'b0, "T10 borrow")
        $display("[PASS] T10");
    endtask

    // -------------------------------------------------------------------------
    // T11: Valores extremos
    // -------------------------------------------------------------------------
    task automatic test_boundary();
        $display("\n--- T11: Valores extremos ---");
        op_a = 8'hFF; op_b = 8'h01; op_sel = 3'b000; #1;
        `CHECK(result,     8'h00, "T11a result=0")
        `CHECK(flag_carry, 1'b1,  "T11a carry=1")
        `CHECK(flag_zero,  1'b1,  "T11a zero=1")
        op_a = 8'h00; op_b = 8'h00; op_sel = 3'b011; #1;
        `CHECK(result,    8'h00, "T11b OR 0,0=0")
        `CHECK(flag_zero, 1'b1,  "T11b zero=1")
        $display("[PASS] T11");
    endtask

    // =========================================================================
    // Hilo principal
    // =========================================================================
    initial begin
        $display("========================================");
        $display("  Testbench ALU — inicio de simulación");
        $display("========================================");
        op_a = '0; op_b = '0; op_sel = '0; #5;

        test_add_basic();
        test_add_carry();
        test_add_overflow();
        test_sub_basic();
        test_sub_borrow();
        test_sub_overflow();
        test_and();
        test_or();
        test_xor();
        test_zero_flag();
        test_boundary();

        $display("\n========================================");
        if (fail_count == 0)
            $display("  RESULTADO FINAL: PASS ✓ (0 fallos)");
        else
            $display("  RESULTADO FINAL: FAIL ✗ (%0d fallos)", fail_count);
        $display("========================================");
        $finish;
    end

endmodule : tb_alu
