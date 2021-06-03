`timescale 1ns / 1ps

module RegStorage(CLK, write_enable_A, write_address_A, read_address_A,
            data_input_A, data_output_A, write_enable_B, write_address_B,
            read_address_B, data_input_B, data_output_B);

//Clock
input CLK;
// Semnale de enable
input write_enable_A, write_enable_B;
// Input de adrese
input [1:0] write_address_A, read_address_A, write_address_B, read_address_B;
// Input de date
input [7:0] data_input_A, data_input_B;

// Output de date
output reg [7:0] data_output_A, data_output_B;

// Registre de stocare
reg [7:0] reg0, reg1, reg2, reg3;

// Citirea pe portul A (se face continuu)
always @(*) begin

    case (read_address_A)
        0:  data_output_A = reg0;
        1:  data_output_A = reg1;
        2:  data_output_A = reg2;
        3:  data_output_A = reg3;
        default: begin
            data_output_A = {8{1'bx}};
        end
    endcase

end

// Citirea pe portul B (se face continuu)
always @(*) begin

    case (read_address_B)
        0:  data_output_B = reg0;
        1:  data_output_B = reg1;
        2:  data_output_B = reg2;
        3:  data_output_B = reg3;
        default: begin
            data_output_B = {8{1'bx}};
        end
    endcase

end

// Scriere pe portul A si B (pe front pozitiv)
always @(posedge CLK) begin

    if (write_enable_A) begin
        case (write_address_A)
            0:  reg0 <= data_input_A;
            1:  reg1 <= data_input_A;
            2:  reg2 <= data_input_A;
            3:  reg3 <= data_input_A;
        endcase
    end

    if (write_enable_B) begin
        case (write_address_B)
            0:  reg0 <= data_input_B;
            1:  reg1 <= data_input_B;
            2:  reg2 <= data_input_B;
            3:  reg3 <= data_input_B;
        endcase
    end

end

endmodule