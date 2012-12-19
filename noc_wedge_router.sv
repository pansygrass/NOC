module router#(	parameter XCOORD = 1111,
		parameter YCOORD = 1111)
(
	ifc.router N_ifc,
	ifc.router S_ifc,
	ifc.router E_ifc,
	ifc.router L_ifc,
	ifc.control control
);

//wires

wire N_pop;
wire S_pop;
wire E_pop;
wire L_pop;

wire [15:0] N_rcvd_data;
wire [15:0] S_rcvd_data;
wire [15:0] E_rcvd_data;
wire [15:0] L_rcvd_data;

wire N_rcvd_valid;
wire S_rcvd_valid;
wire E_rcvd_valid;
wire L_rcvd_valid;

wire [15:0] N_send_data;
wire [15:0] S_send_data;
wire [15:0] E_send_data;
wire [15:0] L_send_data;

wire N_send_enable;
wire S_send_enable;
wire E_send_enable;
wire L_send_enable;

wire N_full;
wire S_full;
wire E_full;
wire L_full;

wire [4:0] N_turn;
wire [4:0] S_turn;
wire [4:0] E_turn;
wire [4:0] L_turn;

wire [2:0] N_port_select;
wire [2:0] S_port_select;
wire [2:0] E_port_select;
wire [2:0] L_port_select;


//Ports

	inputPort nInPort(.clk(control.clk),
				.rst(control.rst), 
				.data_i(N_ifc.data_i), 
				.write_en(N_ifc.valid_i),
				.shift(N_pop),
				.data_o(N_rcvd_data),
				.read_valid_o(N_rcvd_valid));

	outputPort nOutPort(.clk(control.clk),
				.rst(control.rst),
				.data_i(N_send_data),
				.port_en(N_send_enable),
				.inc_credit_i(N_ifc.credit_i),
				.data_o(N_ifc.data_o),
				.send_data(N_ifc.enable_o),
				.full(N_full));


	inputPort sInPort(.clk(control.clk),
				.rst(control.rst), 
				.data_i(S_ifc.data_i), 
				.write_en(S_ifc.valid_i),
				.shift(S_pop),
				.data_o(S_rcvd_data),
				.read_valid_o(S_rcvd_valid));

	outputPort sOutPort(.clk(control.clk),
				.rst(control.rst),
				.data_i(S_send_data),
				.port_en(S_send_enable),
				.inc_credit_i(S_ifc.credit_i),
				.data_o(S_ifc.data_o),
				.send_data(S_ifc.enable_o),
				.full(S_full));

	inputPort eInPort(.clk(control.clk),
				.rst(control.rst), 
				.data_i(E_ifc.data_i), 
				.write_en(E_ifc.valid_i),
				.shift(E_pop),
				.data_o(E_rcvd_data),
				.read_valid_o(E_rcvd_valid));

	outputPort eOutPort(.clk(control.clk),
				.rst(control.rst),
				.data_i(E_send_data),
				.port_en(E_send_enable),
				.inc_credit_i(E_ifc.credit_i),
				.data_o(E_ifc.data_o),
				.send_data(E_ifc.enable_o),
				.full(E_full));


inputPort lInPort(.clk(control.clk),
			.rst(control.rst), 
			.data_i(L_ifc.data_i), 
			.write_en(L_ifc.valid_i),
			.shift(L_pop),
			.data_o(L_rcvd_data),
			.read_valid_o(L_rcvd_valid));

outputPort lOutPort(.clk(control.clk),
			.rst(control.rst),
			.data_i(L_send_data),
			.port_en(L_send_enable),
			.inc_credit_i(L_ifc.credit_i),
			.data_o(L_ifc.data_o),
			.send_data(L_ifc.enable_o),
			.full(L_full));


//Routing Logic
routeLogic#(.XCOORD(XCOORD), .YCOORD(YCOORD)) route
(		.N_data_i(N_rcvd_data[7:0]),
		.S_data_i(S_rcvd_data[7:0]),
		.E_data_i(E_rcvd_data[7:0]),
		.W_data_i(0),
		.L_data_i(L_rcvd_data[7:0]),
		.N_valid_i(N_rcvd_valid),
		.S_valid_i(S_rcvd_valid),
		.E_valid_i(E_rcvd_valid),
		.W_valid_i(0),
		.L_valid_i(L_rcvd_valid),
		.N_port_full(N_full),
		.S_port_full(S_full),
		.E_port_full(E_full),
		.W_port_full(0),
		.L_port_full(L_full),
		.N_turn(N_turn),
		.S_turn(S_turn),
		.E_turn(E_turn),
		.W_turn(0),
		.L_turn(L_turn),
		.N_port_select(N_port_select),
		.S_port_select(S_port_select),
		.E_port_select(E_port_select),
		.W_port_select(),
		.L_port_select(L_port_select),
		.N_port_remove(N_pop),
		.S_port_remove(S_pop),
		.E_port_remove(E_pop),
		.W_port_remove(),
		.L_port_remove(L_pop),
		.N_port_enable(N_send_enable),
		.S_port_enable(S_send_enable),
		.E_port_enable(E_send_enable),
		.W_port_enable(),
		.L_port_enable(L_send_enable),
		.N_credit_inc(N_ifc.credit_o),
		.S_credit_inc(S_ifc.credit_o),
		.E_credit_inc(E_ifc.credit_o),
		.W_credit_inc(),
		.L_credit_inc(L_ifc.credit_o));

//Arbiter
arbiter arb(.clk(control.clk), 
	.rst(control.rst),
	.N_turn_o(N_turn),
	.S_turn_o(S_turn),
	.E_turn_o(E_turn),
	.W_turn_o(),
	.L_turn_o(L_turn));


//Switch
crossbarSwitch switch (
			.N_data_i(N_rcvd_data),
			.S_data_i(S_rcvd_data),
			.E_data_i(E_rcvd_data),
			.W_data_i(0),
			.L_data_i(L_rcvd_data),
			.N_port_select(N_port_select),
			.S_port_select(S_port_select),
			.E_port_select(E_port_select),
			.W_port_select(),
			.L_port_select(L_port_select),
			.N_data_o(N_send_data),
			.S_data_o(S_send_data),
			.E_data_o(E_send_data),
			.W_data_o(),
			.L_data_o(L_send_data));

endmodule