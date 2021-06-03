`timescale 1ns / 1ps

module UC(CLK, reset, start, sel_mux_1, sel_mux_2, sel_mux_3, sel_mux_4,
            alu_operation, bit_index, sel_register_A, sel_register_B,
            write_register_A, write_register_B, IMM, NZ, GE, idle, finish);

// Input extern
input CLK, reset, start;
// Input de la DataPath
input NZ, GE;

// Output-ul unitatii de comanda
output reg idle, finish;
// Selectorii multiplexoarelor 1 si 4
output reg sel_mux_1, sel_mux_4;
// Enable-ul de scriere in A sau B
output reg write_register_A, write_register_B;
// Selectorii pentru registre
output reg [1:0] sel_register_A, sel_register_B;
// Selectorii multiplexoarelor 2 si 3
output reg [1:0] sel_mux_2, sel_mux_3;
// Selectorul de operatia ALU si bit-ul de index
output reg [2:0] alu_operation, bit_index;
// Imediatul ce o sa fie folosit in DataPath
output reg [7:0] IMM;

// Iterarea cu i
reg [7:0] bit_index_i;
// Starea curenta si urmatoare pentru primul FSM
reg [3:0] FSM1_current_state, FSM1_next_state;
// Starile posibile ale primului FSM
localparam
    IDLE_STATE = 4'b0001,
    VFIN_STATE = 4'b0010,
    CALC_STATE = 4'b0100,
    FINI_STATE = 4'b1000;

// Starea curenta si urmatoare pentru al doilea FSM
reg [6:0] FSM2_current_state, FSM2_next_state;
// Starile posibile ale FSM-ului al doilea
localparam
    STATE1 = 7'b0000001,
    STATE2 = 7'b0000010,
    STATE3 = 7'b0000100,
    STATE4 = 7'b0001000,
    STATE5 = 7'b0010000,
    STATE6 = 7'b0100000,
    STATE7 = 7'b1000000;

// Se seteaza semnalele pentru calea de date. In functie de starea curenta se
// seteaza semnalele pentru a fi trimise mai departe. Aici se rezolva
// semnalele pentru ambele FSM-uri.
always @(*) begin
    idle = 1; finish = 0;
    sel_mux_1 = 0; sel_mux_2 = 0; sel_mux_3 = 0; sel_mux_4 = 0;
    bit_index = 7; alu_operation = 0; IMM = 0;
    sel_register_A = 0; sel_register_B = 0;
    write_register_A = 0; write_register_B = 0;

    case (FSM1_current_state)
        IDLE_STATE: begin
            idle = 1; finish = 0;
            sel_register_A = 0; sel_register_B = 1;
            alu_operation = 3'bx;
            if (start) begin
                sel_mux_1 = 0; alu_operation = 0;
            end    
        end
        VFIN_STATE: begin
            idle = 0; finish = 0;
            if (NZ) begin
                IMM = 0;
                sel_mux_3 = 2; sel_mux_4 = 0;
                sel_register_A = 0; sel_register_B = 1;
                write_register_A = 1; write_register_B = 1;
            end
        end
        CALC_STATE: begin
            idle = 0; finish = 0;
        end
        FINI_STATE: begin
            idle = 0; finish = 1;
            sel_register_A = 0; write_register_A = 0;
            sel_register_B = 1; write_register_B = 0;

        end
    endcase
    
    if (FSM1_current_state == CALC_STATE) begin
        case (FSM2_current_state)
            STATE1: begin
                alu_operation = 1; // Verificare impartitor zero
                sel_register_B = 1; write_register_B = 1;
                sel_mux_1 = 1; sel_mux_4 = 1;
            end
            STATE2: begin
                alu_operation = 2; bit_index = bit_index_i; // Bit get
                sel_mux_2 = 0; sel_mux_4 = 1;
                sel_register_B = 2; write_register_B = 1;
            end
            STATE3: begin
                alu_operation = 3; bit_index = 0; // Bit set
                sel_mux_1 = 1; sel_mux_2 = 1; sel_mux_4 = 1;
                sel_register_B = 1; write_register_B = 1;
                sel_register_A = 2; write_register_A = 0; // TODO ori nu scrie bine ori nu citeste bine din mem
            end
            STATE4: begin
                alu_operation = 4; // Verificare
                sel_mux_1 = 1; sel_mux_2 = 2;
                sel_register_B = 1; write_register_B = 0;
                write_register_A = 0;
            end
            STATE5: begin
                alu_operation = 5; // Scadere
                sel_mux_1 = 1; sel_mux_2 = 2; sel_mux_4 = 1;
                sel_register_B = 1; write_register_B = 1;
            end
            STATE6: begin
                alu_operation = 6; bit_index = bit_index_i; // Bit set 1
                sel_mux_1 = 1; sel_mux_4 = 1;
                sel_register_B = 0; write_register_B = 1;
            end
            STATE7: begin
                alu_operation = 3'bx; // Stare finala
                sel_register_A = 2'bx; sel_register_B = 2'bx;
                write_register_A = 0; write_register_B = 0;
            end
        endcase
    end
end

// In o executie normala circuitul trece din starea idle in cea de verificare
// a intrarii, apoi in o stare de calcul si apoi intr-o stare finala.
always @(*) begin
    FSM1_next_state = IDLE_STATE;
    case (FSM1_current_state)
        IDLE_STATE: FSM1_next_state = (start == 1) ? VFIN_STATE : IDLE_STATE;
        VFIN_STATE: FSM1_next_state = (NZ == 1) ? CALC_STATE : FINI_STATE;
        CALC_STATE: begin
            if ((bit_index_i == 0) && (FSM2_current_state == STATE7))
                FSM1_next_state = FINI_STATE;
            else
                FSM1_next_state = CALC_STATE;
        end
        FINI_STATE: FSM1_next_state = IDLE_STATE;
        default: FSM1_next_state = IDLE_STATE;
    endcase
end

// In al doilea FSM se parcurg toate starile din interiorul for-ului in
// ordine, luandu-se in considerare salturile conditionale
always @(*) begin
    FSM2_next_state = STATE1;
    case (FSM2_current_state)
        STATE1:  FSM2_next_state = STATE2;
        STATE2:  FSM2_next_state = STATE3;
        STATE3:  FSM2_next_state = STATE4;
        STATE4:  FSM2_next_state = (GE == 1) ? STATE5 : STATE7;
        STATE5:  FSM2_next_state = STATE6;
        STATE6:  FSM2_next_state = STATE7;
        STATE7:  FSM2_next_state = (bit_index_i > 0) ? STATE1 : STATE7;
        default: FSM2_next_state = STATE1;
    endcase
end

// Se actualizeaza starea curenta pentru fiecare FSM pe frontul pozitiv de ceas
always @(posedge CLK) begin
    if (reset) begin
        FSM1_current_state <= IDLE_STATE;
        FSM2_current_state = STATE1;
    end
    else begin
        FSM1_current_state <= FSM1_next_state;
        if (FSM1_current_state == CALC_STATE)
            FSM2_current_state <= FSM2_next_state;
        else
            FSM2_current_state <= STATE1;
    end
end

// I-ul se decrementeaza in starea finala a celui de-al doilea FSM (finalul
// for-ului). Daca for-ul s-a terminat, i-ul reia valoarea initiala.
always @(posedge CLK) begin
    if (reset)
        bit_index_i <= 7;
    else begin
        if ((FSM1_current_state == CALC_STATE) && (FSM2_current_state == STATE7))
            bit_index_i <= bit_index_i - 1;
        if (FSM1_current_state == FINI_STATE)
            bit_index_i <= 7;   
    end
end

endmodule
