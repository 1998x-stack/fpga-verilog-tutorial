// Unsigned combinational 4-bit ALU. op: ADD, AND, XOR, NOT A.
module alu4 (
    input  wire [3:0] a,
    input  wire [3:0] b,
    input  wire [1:0] op,
    output reg  [3:0] result,
    output reg        carry
);
    reg [4:0] ext;
    always @(*) begin
        ext    = 5'b0;
        result = 4'b0;
        carry  = 1'b0;
        case (op)
            2'b00: begin
                ext    = {1'b0, a} + {1'b0, b};
                result = ext[3:0];
                carry  = ext[4];
            end
            2'b01: result = a & b;
            2'b10: result = a ^ b;
            2'b11: result = ~a;
            default: begin
                result = 4'b0;
                carry  = 1'b0;
            end
        endcase
    end
endmodule
