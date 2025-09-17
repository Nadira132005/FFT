`timescale 1ns/1ps
module testbench;
    reg signed [15:0] A_real;
    reg signed [15:0] B_real;
    reg signed [15:0] A_imag;
    reg signed [15:0] B_imag;
    wire signed [15:0] out_A_real;
    wire signed [15:0] out_A_imag;
    wire signed [15:0] out_B_real;
    wire signed [15:0] out_B_imag;
    reg signed [15:0] twiddle_real;
    reg signed [15:0] twiddle_imag;
    reg [1:0]ictrl = 2'b01;
    wire [1:0]octrl;

    reg [8:0] input_memory_address = 9'd20;
    wire [8:0] output_memory_address;

    wire done;
    reg start = 0;
    reg reset = 0;
    
    reg clk = 0;
    always #10 clk = ~clk;
    
    parameter EXP_IN = 0.015625; // 2^-6
    parameter EXP_OUT = 0.03125; // 2^-5
    parameter EXP_TWIDDLE = 0.000030517578125; // 2^-15

    radix2Butterfly #(.FFT_STAGE(9)) BUTTERFLY (
        .reset(reset),
        .clk(clk),
        .iact(start),
        .ictrl(ictrl),
        .oact(done),
        .octrl(octrl),
        .input_memory_address(input_memory_address),
        .output_memory_address(output_memory_address),
        .A_real(A_real),
        .A_imag(A_imag),
        .B_real(B_real),
        .B_imag(B_imag),
        .twiddle_real(twiddle_real),
        .twiddle_imag(twiddle_imag),
        .out_B_imag(out_B_imag),
        .out_B_real(out_B_real),
        .out_A_imag(out_A_imag),
        .out_A_real(out_A_real)
    );

    integer output_file;

    initial begin
        output_file = $fopen("radix_2_butterfly.output.txt", "w");
        reset = 1;
        #40;
        reset = 0;
        start = 1;
        A_real = 16'b1010_0000_1111_1111;
        B_real = 16'b0100_0000_1111_1111;
        A_imag = 16'b1001_0000_1111_1111;
        B_imag = 16'b0001_1000_1111_1111;

        twiddle_real = 16'b0111_1111_1111_1111;
        twiddle_imag = 16'b1111_1111_1111_1101;


        #120;

        $fwrite(output_file, "A_out: (%f + i%f) + (%f + i%f) = %f + i%f\n", A_real * EXP_IN, A_imag* EXP_IN, B_real* EXP_IN, B_imag* EXP_IN, out_A_real* EXP_IN, out_A_imag* EXP_IN);
        $fwrite(output_file, "diff_real: %f, diff_imag: %f\n", BUTTERFLY.diff_real* EXP_IN, BUTTERFLY.diff_imag* EXP_IN);
        $fwrite(output_file, "B_out: ((%f + i%f) - (%f + i%f)) *(%f + i%f) = %f + i%f (expecting -96.01550 + i-1183.97909)", A_real * EXP_IN, A_imag* EXP_IN, B_real* EXP_IN, B_imag* EXP_IN, twiddle_real * EXP_TWIDDLE, twiddle_imag * EXP_TWIDDLE, out_B_real* EXP_OUT, out_B_imag* EXP_OUT);
        $fclose(output_file);
    end
endmodule