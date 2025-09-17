
`timescale 1ns/1ps

`include "../include/dpram.sv"
`include "../include/twrom.sv"

module testbench;

   localparam FFT_LENGTH = 1024;
   localparam FFT_DW = 16;
   localparam PL_DEPTH = 2;
   localparam FFT_N = $clog2( FFT_LENGTH );   

`include "../include/header.sv"
`include "../include/simtask.sv"

   
   integer i;
   integer inputReal;
   integer inputImag;
   integer fftBfpExp;
   integer output_file;

   localparam EXP = 0.0625;

   initial begin
      rst_reg = 1;
      autorun_reg = 1;
      fin_reg = 0;
      run_reg = 0;
      ifft_reg = 0;
      wait_clk( 10 );
      rst_reg = 0;
      wait_clk( 10 );

      output_file = $fopen("output_testbench.txt", "w");
      $fwrite(output_file, "INPUT DATA:\n");

      for ( i = 0; i < FFT_LENGTH; i++ ) begin
	      sact_istream_reg <= 1'b1;
	      inputReal = ToSignedInt($sin ( 2.0 * M_PI * 8 *  i / FFT_LENGTH ));
	      inputImag = 0;
         $fwrite(output_file, "REAL DATA: %d, IMAGINARY DATA: %d\n", inputReal, inputImag);
	      sdw_istream_real_reg <= inputReal;
	      sdw_istream_imag_reg <= inputImag;
	      wait_clk( 1 );
      end
      
      sact_istream_reg <= 1'b0;

      while ( !done ) begin
	      wait_clk( 1 );
      end

      fftBfpExp = bfpexp;

      // TODO: see what this is doing
      dumpFromDmaBus();

      $fwrite(output_file, "FFT RESULT:\n");
      for ( i = 0; i < FFT_LENGTH; i++ ) begin
	      $fwrite(output_file,  "REAL: %f, IMAGINARY: %f, MAGNITUDE: %f\n", 
		   resultReal[i] * EXP, 
		   resultImag[i] * EXP,
		   $sqrt(
			 1.0 * resultReal[i] * resultReal[i] * EXP * EXP + 
			 1.0 * resultImag[i] * resultImag[i] * EXP * EXP
			 )
		   );
      end
      $fclose(output_file);
      $stop();
   end
   
   
   
   
   
endmodule // testbench



