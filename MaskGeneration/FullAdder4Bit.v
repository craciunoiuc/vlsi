module FullAdder(in0, in1, cin, out, cout);
    input in0, in1, cin;
    output out, cout;

    wire xo1, a1, a2;

    xor(out, in0, in1, cin);
    xor(xo1, in0, in1);
    and(a1, xo1, cin);
    and(a2, in0, in1);
    or(cout, a1, a2);

endmodule

module FullAdder4Bit(nr1, nr2, out, cout);
    input [3:0] nr1;
    input [3:0] nr2;

    output [3:0] out;
    output cout;

    wire c1, c2, c3;

    FullAdder fa0(nr1[0], nr2[0], 0, out[0], c1);
    FullAdder fa1(nr1[1], nr2[1], c1, out[1], c2);
    FullAdder fa2(nr1[2], nr2[2], c2, out[2], c3);
    FullAdder fa3(nr1[3], nr2[3], c3, out[3], cout);

endmodule
