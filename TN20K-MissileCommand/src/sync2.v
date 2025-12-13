// sync re-write for tn20k - pinballwiz.org 2025
module sync2
(
input wire clk_10M,
input wire ce_5M,
input wire reset,
input wire flip, // flip controls sync polarity, not counter direction
output reg h_sync,
output reg v_sync,
output reg h_blank,
output reg v_blank/*verilator public_flat*/,
output wire s_phi_x,
output wire s_3INH,
output reg [8:0] hcnt/*verilator public_flat*/,
output reg [7:0] vcnt/*verilator public_flat*/
);

///// CLOCKS
reg s_A7_1;
reg s_A7_2_n;
reg s_B8;

always @(posedge clk_10M) begin
reg h_sync_last;
reg ce_5M_last;
reg s_1h_last;

if (reset) begin
hcnt <= 0;
vcnt <= 0;
h_sync <= 0;
v_sync <= 0;
h_blank<= 0;
v_blank<= 0;
end else if (ce_5M) begin

///// HORIZONTAL COUNTER AND SYNC // more squashes screen toward center
hcnt <= hcnt + 9'd1;
case (hcnt)
9'd254: h_blank <= 1; //256
9'd275: h_sync <= 1;  //260
9'd285: h_sync <= 0;  //288
9'd325: begin  //319
hcnt <= 0;
h_blank <= 0;
vcnt <= vcnt + 8'd1; // always count up
end
endcase

///// VERTICAL SYNC/BLANK generation // less moves screen down
case (vcnt)
8'd0: v_blank <= 1; //0
8'd25: v_blank <= 0;  //25
8'd0: v_sync <= flip ? 1 : v_sync;  //4
8'd4: v_sync <= flip ? 0 : v_sync;  //8
8'd8: v_sync <= ~flip ? 0 : v_sync;  //16
8'd12: v_sync <= ~flip ? 1 : v_sync;  //20
endcase
end

ce_5M_last <= ce_5M;
if (ce_5M && !ce_5M_last) s_A7_1 <= ~s_3INH;
s_1h_last <= hcnt[0];
if (hcnt[0] && !s_1h_last) s_A7_2_n <= (~hcnt[1] & hcnt[2]);
if (!hcnt[0] && s_1h_last) s_B8 <= s_A7_2_n;
end

assign s_3INH = (vcnt[7:5] == 3'b111);
assign s_phi_x = (~(s_B8 & ~s_A7_1)) & (~(s_A7_1 & hcnt[1]));

endmodule