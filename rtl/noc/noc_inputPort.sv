/* 
 * Input Port of a router
 *
 * Authors: Joseph Corbisiero, Nina Berg
 * Date: 12/20/12
 *
 */

module inputPort
  (
   input 	 clk,
   input 	 rst,

   input [15:0]  data_i,
   input 	 write_en,
   input 	 shift,

   output [15:0] data_o,
   output logic  read_valid_o
   );

   reg 		 rst_n;
   reg 		 push_n;
   reg 		 pop_n;
   reg 		 empty;
   reg 		 full;

   DW_fifo_s1_sf#(.width(16), .depth(5), .rst_mode(1))  buffer(
		       .clk, .rst_n, 
		       .push_req_n(push_n), .pop_req_n(pop_n),
		       .data_in(data_i),
		       .empty, .full,
		       .data_out(data_o),
		       .error(),
		       .diag_n('1), .almost_empty(),
		       .half_full(), .almost_full()
		      );

   always_comb begin

      if (rst) begin
	 rst_n = 0;
      end else begin
	 rst_n = 1;
      end


      if (write_en == 1 && !full) begin
	 push_n = 0;
      end else begin
	 push_n = 1;
      end


      if (shift) begin
	 assert(!empty);
	 pop_n = 0;
      end else begin
	 pop_n = 1;
      end

      if (!empty) begin
	 read_valid_o = 1;
      end else begin
	 read_valid_o = 0;
      end

   end

endmodule
