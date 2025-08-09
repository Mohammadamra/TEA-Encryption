// Performs 32 TEA rounds on (left_in,right_in) using keys key1..key4.
// Handshake: assert `start` (pulse) to begin. `done` pulses high for one clock
// cycle when ciphertext available on left_out/right_out.

module Round_fun (
    input  wire         clk,
    input  wire         reset_n,
    input  wire         start,       // pulse to start encryption (ignored while busy)
    input  wire [31:0]  left_in,
    input  wire [31:0]  right_in,
    input  wire [31:0]  key1,
    input  wire [31:0]  key2,
    input  wire [31:0]  key3,
    input  wire [31:0]  key4,
    output reg  [31:0]  left_out,
    output reg  [31:0]  right_out,
    output reg          done         // 1-cycle pulse when output valid
);

    // Parameters
    localparam integer ROUNDS = 32;
    localparam [31:0] DELTA = 32'h9E3779B9;

    // FSM states
    localparam IDLE    = 2'b00;
    localparam ENCRYPT = 2'b01;
    localparam DONE    = 2'b10;

    // State registers
    reg [1:0] state, next_state;

    // Data path registers
    reg [31:0] v_left, v_right;
    reg [31:0] sum;
    reg [5:0]  round;            // enough bits for 0..31

    // Internal wires for next values (combinational)
    wire [31:0] sum_next;
    wire [31:0] left_next;
    wire [31:0] right_next;

    // --- Combinational datapath logic (no side-effects) ---
    // sum is incremented first each round
    assign sum_next  = sum + DELTA;

    // new left uses right and new sum (matches reference TEA)
    assign left_next = v_left + ( ((v_right << 4) + key1) 
                                ^ (v_right + sum_next)
                                ^ ((v_right >> 5) + key2) );

    // new right uses new left and new sum
    assign right_next = v_right + ( ((left_next << 4) + key3)
                                  ^ (left_next + sum_next)
                                  ^ ((left_next >> 5) + key4) );

    // --- Sequential logic ---
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            state     <= IDLE;
            v_left    <= 32'd0;
            v_right   <= 32'd0;
            sum       <= 32'd0;
            round     <= 6'd0;
            left_out  <= 32'd0;
            right_out <= 32'd0;
            done      <= 1'b0;
        end else begin
            state <= next_state;

            // default done low; will be asserted in DONE state for 1 cycle
            done <= 1'b0;

            case (state)
                IDLE: begin
                    // On start from IDLE latch inputs and initialize counters
                    if (start) begin
                        v_left  <= left_in;
                        v_right <= right_in;
                        sum     <= 32'd0;
                        round   <= 6'd0;
                    end
                end

                ENCRYPT: begin
                    // perform one TEA round per clock
                    // if round < ROUNDS, apply round update
                    if (round < 32) begin
                        sum     <= sum_next;
                        v_left  <= left_next;
                        v_right <= right_next;
                        round   <= round + 1'b1;
                    end else begin
                        // this is the final (ROUNDS-1) iteration: update registers and move to DONE next cycle
                        sum     <= sum_next;
                        v_left  <= left_next;
                        v_right <= right_next;
                        round   <= round + 1'b1; // reach ROUNDS
                    end
                end

                DONE: begin
                    // Latch outputs and pulse done for one cycle
                    left_out  <= v_left;
                    right_out <= v_right;
                    done      <= 1'b1;
                    // outputs will remain stable until next IDLE start
                end

                default: begin
                    // safety fallback
                    v_left  <= v_left;
                    v_right <= v_right;
                end
            endcase
        end
    end

    // --- Next-state (combinational) ---
    always @(*) begin
        case (state)
            IDLE: begin
                // Accept start only when in IDLE and start asserted
                if (start)
                    next_state = ENCRYPT;
                else
                    next_state = IDLE;
            end

            ENCRYPT: begin
                // After performing ROUNDS rounds (round == ROUNDS), move to DONE
                // Note: round counts up to ROUNDS value inside sequential block,
                // so we check here for round == ROUNDS to transition.
                if (round == ROUNDS - 1)
                    next_state = DONE;
                else
                    next_state = ENCRYPT;
            end

            DONE: begin
                // After a single-cycle DONE pulse, go back to IDLE and accept next start
                next_state = IDLE;
            end

            default: next_state = IDLE;
        endcase
    end

endmodule


