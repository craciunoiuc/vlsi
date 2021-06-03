`timescale 1ns / 1ps

module DataPath(CLK, N, D, sel_mux_1, sel_mux_2, sel_mux_3, sel_mux_4, IMM, 
                bit_index, alu_operation, sel_register_A, sel_register_B,
                write_register_A, write_register_B, Q, R, NZ, GE);

// Clock
input CLK;
// Selectia multiplexoarelor cu 2 intrari
input sel_mux_1, sel_mux_4;
// Enable-ul de scriere in A sau B
input write_register_A, write_register_B;
// Selectia registrelor de stocare
input [1:0] sel_register_A, sel_register_B;
// Selectia multiplexoarelor cu 3-4 intrari
input [1:0] sel_mux_2, sel_mux_3;
// Operatia din ALU respectiv bitii de index
input [2:0] alu_operation, bit_index;
// Input-ul circuitului (deimpartit, impartitor si imediat)
input [7:0] N, D, IMM;

// Output-ul circuitului (cat si rest)
output [7:0] R, Q;
// Flag-uri comparatii (in if-uri)
output reg GE, NZ;

// Fire de legatura cu ALU
wire [7:0] alu_input_A, alu_input_C, alu_result;
// Fire de legatura cu registrele
wire [7:0] register_input_A, register_input_B;

// Se instantiaza modulul de ALU ce va fi folosit
ALU aluInstance(.A(alu_input_A), .B({5'b0,bit_index}), .C(alu_input_C),
                .operation(alu_operation), .D(alu_result));

// Se instantiaza modulul de registre ce va fi folosit
RegStorage regInstance(.CLK(CLK), .write_enable_A(write_register_A),
            .write_address_A(sel_register_A), .read_address_A(sel_register_A), 
            .data_input_A(register_input_A),
            .write_enable_B(write_register_B), .write_address_B(sel_register_B),
            .read_address_B(sel_register_B), .data_input_B(register_input_B),
            .data_output_B(R), .data_output_A(Q));

// Output-ul multiplexorului 1 se leaga la ALU in intrarea A
assign alu_input_A = (sel_mux_1 == 0) ? D : R;
// Output-ul multiplexorului 2 se leaga la ALU in intrarea C
assign alu_input_C = (sel_mux_2 == 0) ? N : (sel_mux_2 == 1) ? Q : (sel_mux_2 == 2) ? D : {8{1'bx}};
// Output-ul multiplexorului 3 se leaga la registre in intrarea A
assign register_input_A = (sel_mux_3 == 0) ? N : (sel_mux_3 == 1) ? D : (sel_mux_3 == 2) ? IMM : {8{1'bx}};
// Output-ul multiplexorului 4 se leaga la registre in intrarea B
assign register_input_B = (sel_mux_4 == 0) ? IMM : alu_result;

//Flagurile
always @(*) begin
    GE = (alu_operation == 4) && (alu_result == 1);
    NZ = (alu_operation == 0) && (alu_result == 1);
end

endmodule