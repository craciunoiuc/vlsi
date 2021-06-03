`timescale 1ns / 1ps

module CircuitTB();

// Ceas
reg CLK;
// Semnale input
reg start, reset;
// Numere de procesat
reg [7:0] N, D;

// Rezultate impartire
wire [7:0] R, Q;
// Semnale output
wire idle, finish;

Divider dividerInstance(.CLK(CLK), .start(start), .reset(reset), .idle(idle),
                        .finish(finish), .N(N), .D(D), .R(R), .Q(Q));

    initial begin
        // Init
        #1 CLK = 0; reset = 0; start = 0;

        // Circuit reset
        @(negedge CLK); #5 reset = 1; @(negedge CLK); #5 reset = 0;
        
        // Se salveaza semnalele
        $dumpfile("divider_tb.vcd");
        $dumpvars(0, CircuitTB);

        // Test 0: Se verifica impartirea la 0
        @(negedge CLK); start = 1; N = 128; D = 0; @(negedge CLK); start = 0;
        $display("Input Test 0: N = %d D = %d", N, D);
       
        // Test 0: Terminare si afisare
        @(posedge finish);
        #1 $display("Output Test 0: Q = %d R = %d\n", Q, R);
        @(negedge CLK); @(negedge CLK); @(negedge CLK);


        // Test 1: Se verifica impartirea cu rezultat cat si rest                      
        @(negedge CLK); start = 1; N = 128; D = 3; @(negedge CLK); start = 0;
        $display("Input Test 1: N = %d D = %d", N, D);
        
        // Test 1: Terminare algoritm si afisare
        @(posedge finish);
        #1 $display("Output Test 1: Q = %d R = %d\n", Q, R);
        @(negedge CLK); @(negedge CLK); @(negedge CLK);


        // Test 2: Se verifica impartirea cu cat si fara rest
        @(negedge CLK); start = 1; N = 4; D = 2; @(negedge CLK); start = 0;
        $display("Input Test 2: N = %d D = %d", N, D);
       
        // Test 2: Terminare si afisare
        @(posedge finish);
        #1 $display("Output Test 2: Q = %d R = %d\n", Q, R);
        @(negedge CLK); @(negedge CLK); @(negedge CLK);


        // Test 3: Se verifica impartirea cu rest si fara cat
        @(negedge CLK); start = 1; N = 17; D = 31; @(negedge CLK); start = 0;
        $display("Input Test 3: N = %d D = %d", N, D);
       
        // Test 3: Terminare si afisare
        @(posedge finish);
        #1 $display("Output Test 3: Q = %d R = %d\n", Q, R);
        @(negedge CLK); @(negedge CLK); @(negedge CLK);

        #1 $finish;    
    end

    always begin
        #1 CLK = ~CLK;
    end

endmodule