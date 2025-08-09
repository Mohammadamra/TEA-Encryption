module TEA_Top (
    input         clk,
    input         reset_n,
    input         start,
    input  [63:0] plain_text,
    input  [127:0] key,
    output        done,
    output [63:0] cipher_text
);

    wire [31:0] left, right;
    wire [31:0] key1, key2, key3, key4;
    wire [31:0] left_out, right_out;
    wire        round_done;

    // TEA_input no longer outputs mix
    TEA_input u_TEA_input (
        .plain_text(plain_text),
        .left(left),
        .right(right)
    );

    // Key_expansion without mix
    Key_expansion u_Key_expansion (
        .Key(key),
        .key1(key1),
        .key2(key2),
        .key3(key3),
        .key4(key4)
    );

    // Round_fun as before
    Round_fun u_Round_fun (
        .clk(clk),
        .reset_n(reset_n),
        .start(start),
        .left_in(left),
        .right_in(right),
        .key1(key1),
        .key2(key2),
        .key3(key3),
        .key4(key4),
        .left_out(left_out),
        .right_out(right_out),
        .done(round_done)
    );

    assign done = round_done;
    assign cipher_text = {left_out, right_out};

endmodule

