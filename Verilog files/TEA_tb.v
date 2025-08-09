`timescale 1ns/1ps

module tb_TEA_Top;

    // Testbench signals
    reg         clk;
    reg         reset_n;
    reg         start;
    reg  [63:0] plain_text;
    reg  [127:0] key;
    wire        done;
    wire [63:0] cipher_text;

    // Instantiate the DUT
    TEA_Top dut (
        .clk(clk),
        .reset_n(reset_n),
        .start(start),
        .plain_text(plain_text),
        .key(key),
        .done(done),
        .cipher_text(cipher_text)
    );

    // Clock generation: 100 MHz (10 ns period)
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Toggle every 5 ns
    end

    // Stimulus
    initial begin
        // Initialize signals
        reset_n     = 0;
        start       = 0;
        plain_text  = 64'h0123456789ABCDEF;  // Example plaintext
        key         = 128'h00112233445566778899AABBCCDDEEFF; // Example key

        // Apply reset
        #20;
        reset_n = 1;

        // Start encryption
        #10;
        start = 1;
        #10;
        start = 0; // Pulse only one clock cycle

        // Wait until encryption finishes
        wait (done);

        // Display result
        $display("Time=%0t ns", $time);
        $display("Plaintext : %h", plain_text);
        $display("Key       : %h", key);
        $display("Ciphertext: %h", cipher_text);

        // End simulation
        #20;
        $stop;
    end

endmodule

