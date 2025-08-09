module TEA_input (
    input  [63:0] plain_text,
    output [31:0] left,
    output [31:0] right
);
    assign left  = plain_text[63:32];
    assign right = plain_text[31:0];
endmodule
