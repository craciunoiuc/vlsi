`timescale 1ns / 1ps

module Divider(CLK, start, reset, idle, finish, N, D, R, Q);

// Semnale input
input CLK, reset, start;
// Intrare deimpartit si impartitor
input [7:0] N, D;
// Semnale output
output idle, finish;
// Iesire cat si rest
output reg [7:0] R, Q;

// Se leaga Unitatea de comanda de Data Path
wire sel_mux_1, sel_mux_4;
wire [1:0] sel_mux_2, sel_mux_3;
wire [2:0] alu_operation, bit_index;
wire [1:0] sel_register_A, sel_register_B;
wire write_register_A, write_register_B;
wire [7:0] IMM;
wire NZ, GE;

// Rezultatele de la data path se copiaza in R si Q
wire [7:0] Q_result, R_result;

// Se initializeaza unitatea de comanda
UC ucInstance(.CLK(CLK), .reset(reset), .start(start), .sel_mux_1(sel_mux_1),
            .sel_mux_2(sel_mux_2), .sel_mux_3(sel_mux_3), .sel_mux_4(sel_mux_4),
            .alu_operation(alu_operation), .bit_index(bit_index),
            .sel_register_A(sel_register_A), .sel_register_B(sel_register_B),
            .write_register_A(write_register_A),
            .write_register_B(write_register_B), .IMM(IMM), .NZ(NZ), .GE(GE),
            .idle(idle), .finish(finish));

// Se initializeaza data path-ul
DataPath dpInstance(.CLK(CLK), .N(N), .D(D), .sel_mux_1(sel_mux_1),
            .sel_mux_2(sel_mux_2), .sel_mux_3(sel_mux_3), .sel_mux_4(sel_mux_4),
            .IMM(IMM), .bit_index(bit_index), .alu_operation(alu_operation),
            .sel_register_A(sel_register_A), .sel_register_B(sel_register_B),
            .write_register_A(write_register_A),
            .write_register_B(write_register_B),
            .Q(Q_result), .R(R_result),
            .NZ(NZ), .GE(GE));

// Se copiaza rezultatul de la data path in Q si R
always @(*) begin
    Q = Q_result;
    R = R_result;
end

endmodule