`timescale 1ns / 1ps

module ALU(A, B, C, operation, D);

input [7:0] A, B, C;    // Intrari ALU
input [2:0] operation;  // Operatie de executat

output reg [7:0] D;     // Iesire ALU

reg [7:0] IMM;

always @(*) begin
    case (operation)
        0:  D = (A != 0);       // Verificare impartitor e 0
        1:  D = A << 1;         // Shift la stanga a lui R cu 1
        2:  D = C[B];           // Bit get
        3:  begin               // Bit set
            IMM = A;
            IMM[B] = C;
            D = IMM;
        end
        4:  D = (A >= C);       // Verificare R >= D
        5:  D = A - C;          // Scadere (dintre R si D)
        6:  begin               // Setare bit Q[i] = 1
            IMM = A;
            IMM[B] = 1;
            D = IMM;
        end
        default: D = 0;         // Operatie invalida
    endcase
end

endmodule