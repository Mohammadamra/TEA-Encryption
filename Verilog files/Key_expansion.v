module Key_expansion (
    input  [127:0] Key,
    output [31:0]  key1,
    output [31:0]  key2,
    output [31:0]  key3,
    output [31:0]  key4
);
    assign key1 = Key[127:96];
    assign key2 = Key[95:64];
    assign key3 = Key[63:32];
    assign key4 = Key[31:0];
endmodule
