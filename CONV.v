
`timescale 1ns/10ps

module  CONV(
  input		clk,
  input		reset,
  output	reg	busy,	
  input		ready,	  
  output reg	[11:0] iaddr,
  input		[19:0] idata,	

  output	reg  	cwr,
  output	reg [11:0]	caddr_wr,
  output	reg [19:0] 	cdata_wr,

  output	reg crd,
  output	reg[11:0] 	caddr_rd,
  input	  [19:0]	cdata_rd,

  output	reg[2:0] 	csel
);

parameter K0_00 = 20'h0A89E;  
parameter K0_01 = 20'h092D5;    
parameter K0_02 = 20'h06D43;    
parameter K0_10 = 20'h01004;    
parameter K0_11 = 20'hF8F71;    
parameter K0_12 = 20'hF6E54;    
parameter K0_20 = 20'hFA6D7;    
parameter K0_21 = 20'hFC834;    
parameter K0_22 = 20'hFAC19;    
                  
parameter K1_00 = 20'hFDB55;
parameter K1_01 = 20'h02992;
parameter K1_02 = 20'hFC994;
parameter K1_10 = 20'h050FD;
parameter K1_11 = 20'h02F20;
parameter K1_12 = 20'h0202D;
parameter K1_20 = 20'h03BD7;
parameter K1_21 = 20'hFD369;
parameter K1_22 = 20'h05E68;

parameter B0 = 20'h01310;
parameter B1 = 20'hF7295;

integer i;

reg [19:0]kernel1[8:0];
reg [19:0]kernel2[8:0];

reg [3:0]layer0_state;
reg [19:0]layer0_window[8:0];
reg [6:0]layer0_row;
reg [6:0]layer0_col;
reg [2:0]layer0_count;
reg layer0_write_window;
reg [3:0]layer0_write_index;
reg [39:0]layer0_product1[8:0];
reg [39:0]layer0_product2[8:0];
reg [39:0]layer0_ans1_ur;
reg [39:0]layer0_ans2_ur;
reg [19:0]layer0_ans1;
reg [19:0]layer0_ans2;
reg [1:0]convo_cal_state;
reg [1:0]layer0_store_state;
reg flag;
reg layer0_fin;

reg [2:0]layer1_state;
reg [10:0]layer1_write_index;
reg [11:0]layer1_addr_head;
reg [19:0]layer1_max;
reg layer1_ker_sel;
reg layer1_fin;

reg layer2_ker_sel;
reg [1:0]layer2_state;
reg [11:0]layer2_write_index;
reg [11:0]layer2_read_index;
reg layer2_flag;
reg layer2_fin;

initial begin
    busy = 0;
    kernel1[0] = K0_00;
    kernel1[1] = K0_01;
    kernel1[2] = K0_02;
    kernel1[3] = K0_10;
    kernel1[4] = K0_11;
    kernel1[5] = K0_12;
    kernel1[6] = K0_20;
    kernel1[7] = K0_21;
    kernel1[8] = K0_22;
    kernel2[0] = K1_00;
    kernel2[1] = K1_01;
    kernel2[2] = K1_02;
    kernel2[3] = K1_10;
    kernel2[4] = K1_11;
    kernel2[5] = K1_12;
    kernel2[6] = K1_20;
    kernel2[7] = K1_21;
    kernel2[8] = K1_22;
end


always@(posedge clk or negedge reset)begin
    if(reset)begin
      layer0_ans1_ur <= 0;
      layer0_ans2_ur <= 0;
      layer1_write_index <= 0;
      layer1_ker_sel <= 0;
      layer0_fin <= 0;
      layer0_col <= 0;
      layer0_row <= 0;
      convo_cal_state <= 0;
      layer0_store_state <= 0;
      layer0_count <= 0;
      layer0_write_window <= 0;
      layer0_state <= 0;
      busy <= 1;
      layer1_state <= 0;
      layer1_max <= 0;
      layer1_addr_head <= 0;
      layer1_fin <= 0;
      layer2_state <= 0;
      layer2_ker_sel <= 0;
      layer2_fin <= 0;
      layer2_write_index <= 4095;
      layer2_read_index <= 4095;
      layer2_flag <= 1;
    end else  if(layer2_fin)begin
      busy <= 0;
    end else begin
      
    end
end


// layer0
always@(posedge clk)begin
  if(!layer0_fin)begin
    case (layer0_state)
      4'b0000:begin
        layer0_state <= layer0_state + 1;
      end
      4'b0001:
        begin
          if(layer0_row == 0)begin
            if(layer0_count == 0)begin
              layer0_window[0] <= 0;
              layer0_window[1] <= 0;
              layer0_window[2] <= 0;
              layer0_window[3] <= 0;
              layer0_window[6] <= 0;
              layer0_count <= layer0_count + 1;
            end else if(layer0_count == 5)begin
              layer0_state <= 2;
              layer0_count <= 0;
            end else begin
              if(layer0_count == 1)begin
                iaddr <= 0;
                layer0_write_index <= 4;
                layer0_count <= layer0_count + 1;
                layer0_write_window <= 1;
              end else if(layer0_count == 2)begin
                iaddr <= 1;
                layer0_write_index <= 5;
                layer0_count <= layer0_count + 1;
                layer0_write_window <= 1;
              end else if(layer0_count == 3)begin
                iaddr <= 64;
                layer0_write_index <= 7;
                layer0_count <= layer0_count + 1;
                layer0_write_window <= 1;
              end else if(layer0_count == 4)begin
                iaddr <= 65;
                layer0_write_index <= 8;
                layer0_count <= layer0_count + 1;
                layer0_write_window <= 1;
              end else begin
                layer0_count <= 0;
              end
            end
          end else if(layer0_row == 63)begin
            if(layer0_count == 0)begin
              layer0_window[0] <= 0;
              layer0_window[7] <= 0;
              layer0_window[8] <= 0;
              layer0_window[3] <= 0;
              layer0_window[6] <= 0;
              layer0_count <= layer0_count + 1;
            end else if(layer0_count == 5)begin
              layer0_state <= 2;
              layer0_count <= 0;
            end else begin
              if(layer0_count == 1)begin
                iaddr <= 3968;
                layer0_write_index <= 1;
                layer0_count <= layer0_count + 1;
                layer0_write_window <= 1;
              end else if(layer0_count == 2)begin
                iaddr <= 3969;
                layer0_write_index <= 2;
                layer0_count <= layer0_count + 1;
                layer0_write_window <= 1;
              end else if(layer0_count == 3)begin
                iaddr <= 4032;
                layer0_write_index <= 4;
                layer0_count <= layer0_count + 1;
                layer0_write_window <= 1;
              end else if(layer0_count == 4)begin
                iaddr <= 4033;
                layer0_write_index <= 5;
                layer0_count <= layer0_count + 1;
                layer0_write_window <= 1;
              end else begin
                layer0_count <= 0;
              end
            end
          end else begin
            // general case, get six element
            if(layer0_count == 0)begin
              layer0_window[0] <= 0;
              layer0_window[3] <= 0;
              layer0_window[6] <= 0;
              layer0_count <= layer0_count + 1;
            end else if(layer0_count == 7)begin
              layer0_state <= 2;
              layer0_count <= 0;
            end else begin
              if(layer0_count == 1)begin
                iaddr <= 64 * (layer0_row-1);
                layer0_write_index <= 1;
                layer0_count <= layer0_count + 1;
                layer0_write_window <= 1;
              end else if(layer0_count == 2)begin
                iaddr <= 64 * (layer0_row-1) + 1;
                layer0_write_index <= 2;
                layer0_count <= layer0_count + 1;
                layer0_write_window <= 1;
              end else if(layer0_count == 3)begin
                iaddr <= 64 * (layer0_row + 1-1);
                layer0_write_index <= 4;
                layer0_count <= layer0_count + 1;
                layer0_write_window <= 1;
              end else if(layer0_count == 4)begin
                iaddr <= 64 * (layer0_row + 1-1) + 1;
                layer0_write_index <= 5;
                layer0_count <= layer0_count + 1;
                layer0_write_window <= 1;
              end else if(layer0_count == 5)begin
                iaddr <= 64 * (layer0_row + 2-1);
                layer0_write_index <= 7;
                layer0_count <= layer0_count + 1;
                layer0_write_window <= 1;
              end else if(layer0_count == 6)begin
                iaddr <= 64 * (layer0_row + 2-1) + 1;
                layer0_write_index <= 8;
                layer0_count <= layer0_count + 1;
                layer0_write_window <= 1;
              end else begin
                layer0_count <= 0;
              end
            end
          end
        end 
      4'b0010: 
      // convolution
      begin
        if(convo_cal_state == 0)begin
          for(i = 0 ; i < 9; i = i + 1)begin
            layer0_product1[i] <= $signed(layer0_window[i])*$signed(kernel1[i]);
            layer0_product2[i] <= $signed(layer0_window[i])*$signed(kernel2[i]);
          end
          convo_cal_state <= convo_cal_state + 1;
        end else if(convo_cal_state == 1)begin        
          layer0_ans1_ur <= $signed(layer0_product1[0])+$signed(layer0_product1[1])+
                        $signed(layer0_product1[2])+$signed(layer0_product1[3])+
                        $signed(layer0_product1[4])+$signed(layer0_product1[5])+
                        $signed(layer0_product1[6])+$signed(layer0_product1[7])+
                        $signed(layer0_product1[8])+{{4{B0[19]}},B0,16'h0000};
          layer0_ans2_ur <= $signed(layer0_product2[0])+$signed(layer0_product2[1])+
                        $signed(layer0_product2[2])+$signed(layer0_product2[3])+
                        $signed(layer0_product2[4])+$signed(layer0_product2[5])+
                        $signed(layer0_product2[6])+$signed(layer0_product2[7])+
                        $signed(layer0_product2[8])+{{4{B1[19]}},B1,16'h0000};
          convo_cal_state <= convo_cal_state + 1;
        end else begin
            layer0_ans1 <= (layer0_ans1_ur[15:0]>16'h8000)?layer0_ans1_ur[35:16]+1:layer0_ans1_ur[35:16];
            layer0_ans2 <= (layer0_ans2_ur[15:0]>16'h8000)?layer0_ans2_ur[35:16]+1:layer0_ans2_ur[35:16];  
            convo_cal_state <= 0;
            layer0_state <= layer0_state + 1;
        end
      end
      4'b0011:
      // reLU
        begin
          layer0_ans1 <= ($signed(layer0_ans1)>0)?layer0_ans1:0;
          layer0_ans2 <= ($signed(layer0_ans2)>0)?layer0_ans2:0;
          layer0_state <= layer0_state + 1;
        end
      4'b0100:
      // store
        begin
          if(layer0_store_state == 0)begin
            csel <= 1;
            cwr <= 1;
            crd <= 0;
            cdata_wr <= layer0_ans1;
            caddr_wr <= layer0_row*64+layer0_col;
            layer0_store_state <= layer0_store_state + 1;
          end else begin
            cwr <= 1;
            crd <= 0;
            cdata_wr <= layer0_ans2;
            caddr_wr <= layer0_row*64+layer0_col;
            csel <= 2;
            layer0_store_state <= 0;
            layer0_state <= layer0_state + 1;
          end
        end
      4'b0101:
        begin
          layer0_window[0] <= layer0_window[1];
          layer0_window[1] <= layer0_window[2];
          layer0_window[3] <= layer0_window[4];
          layer0_window[4] <= layer0_window[5];
          layer0_window[6] <= layer0_window[7];
          layer0_window[7] <= layer0_window[8];
          layer0_state <= layer0_state + 1;
        end
      4'b0110:
        begin
          if(layer0_col == 63 && layer0_row == 63)begin
          // layer0 finish
            // busy <= 0;
            layer0_state <= 4'b1111;
            layer0_fin <= 1;
          end
          else if(layer0_col > 63)begin
          // update window coordinates
            layer0_row <= layer0_row + 1;
            layer0_col <= 0;
            layer0_state <= 1;
          end else begin
            layer0_col <= layer0_col + 1;
            layer0_state <= 7;
          end
        end
      4'b0111:
        begin
          if(layer0_col == 63)begin
            layer0_state <= 2; 
            layer0_window[2] <= 0;
            layer0_window[5] <= 0;
            layer0_window[8] <= 0;
          end else if(layer0_row == 0)begin
            // take two element
            case (layer0_count)
              3'b000:begin
                iaddr <= 64*layer0_row+layer0_col-65+64+2;
                layer0_count <= layer0_count + 1;
                layer0_write_index <= 5;
                layer0_write_window <= 1;
              end 
              3'b001:begin
                iaddr <= 64*layer0_row+layer0_col-65+64+64+2;
                layer0_count <= 0;
                layer0_write_index <= 8;
                layer0_write_window <= 1;     
                layer0_state <= 2;           
              end
              default: begin
              end
            endcase
          end else if(layer0_row == 63)begin
            // take two element
            case (layer0_count)
              3'b000:begin
                iaddr <= 64*layer0_row+layer0_col-65+2;
                layer0_count <= layer0_count + 1;
                layer0_write_index <= 2;
                layer0_write_window <= 1;
              end 
              3'b001:begin
                iaddr <= 64*layer0_row+layer0_col-65+64+2;
                layer0_count <= 0;
                layer0_write_index <= 5;
                layer0_write_window <= 1;
                layer0_state <= 2; 
              end
              default: begin

              end
            endcase
          end else begin
            // take three element
            case (layer0_count)
              3'b000:begin
                iaddr <= 64*layer0_row+layer0_col-65+2;
                layer0_count <= layer0_count + 1;
                layer0_write_index <= 2;
                layer0_write_window <= 1;
              end
              3'b001:begin
                iaddr <= 64*layer0_row+layer0_col-65+64+2;
                layer0_count <= layer0_count + 1;
                layer0_write_index <= 5;
                layer0_write_window <= 1;
              end
              3'b010:begin
                iaddr <= 64*layer0_row+layer0_col-65+64+64+2;
                layer0_count <= 0;
                layer0_write_index <= 8;
                layer0_write_window <= 1;
                layer0_state <= 2;
              end 
              default: begin
              end
            endcase
          end
        end
      default: begin
      end
    endcase
  end
end

// layer1
always@(posedge clk)begin
  if(layer0_fin)begin
    case (layer1_state)
      3'b000:begin
        crd <= 1;
        cwr <= 0;
        csel <= layer1_ker_sel==0?1:2;
        caddr_rd <= layer1_addr_head;
        layer1_state <= layer1_state + 1;
      end
      3'b001:begin
        layer1_max <= $signed(layer1_max)>$signed(cdata_rd)?layer1_max:cdata_rd;
        crd <= 1;
        cwr <= 0;
        csel <= layer1_ker_sel==0?1:2;
        caddr_rd <= layer1_addr_head+1;
        layer1_state <= layer1_state + 1;
      end 
      3'b010:begin
        layer1_max <= $signed(layer1_max)>$signed(cdata_rd)?layer1_max:cdata_rd;
        crd <= 1;
        cwr <= 0;
        csel <= layer1_ker_sel==0?1:2;
        caddr_rd <= layer1_addr_head+64;
        layer1_state <= layer1_state + 1;
      end
      3'b011:begin
        layer1_max <= $signed(layer1_max)>$signed(cdata_rd)?layer1_max:cdata_rd;
        crd <= 1;
        cwr <= 0;
        csel <= layer1_ker_sel==0?1:2;
        caddr_rd <= layer1_addr_head+65;
        layer1_state <= layer1_state + 1;
      end
      3'b100:begin
        layer1_max <= $signed(layer1_max)>$signed(cdata_rd)?layer1_max:cdata_rd;      
        layer1_state <= layer1_state + 1;
        layer1_addr_head <= (layer1_addr_head%64==62)?(layer1_ker_sel?layer1_addr_head + 66:layer1_addr_head):(layer1_ker_sel?layer1_addr_head + 2:layer1_addr_head);
      end
      3'b101:begin
      // store and switch sel
        csel <= layer1_ker_sel==0?3:4;
        cdata_wr <= layer1_max;
        layer1_write_index <= layer1_ker_sel?layer1_write_index + 1:layer1_write_index;
        cwr <= 1;
        crd <= 0;
        caddr_wr <= layer1_write_index;
        layer1_state <= (layer1_write_index==1023)?(layer1_ker_sel?6:0):0;
        layer1_ker_sel <= ~layer1_ker_sel;
        layer1_max <= 0;
      end
      3'b110:begin
      // max pooling finish, layer1 complete
        layer1_fin <= 1;
        //busy <= 0;
      end
      default: begin
      end
    endcase
  end
end

// layer2
always@(posedge clk)begin
  if(layer0_fin&&layer1_fin)begin
    case (layer2_state)
      3'b000:begin
        layer2_fin <= (layer2_write_index==2049)?1:0;
        cwr <= 0;
        csel <= ~layer2_ker_sel?3:4;
        crd <= 1;
        caddr_rd <= layer2_read_index;
        layer2_state <= layer2_state + 1; 
      end
      3'b001:begin
        csel <= 5;
        cwr <= 1;
        crd <= 0;
        caddr_wr <= layer2_write_index-1;
        cdata_wr <= cdata_rd;
        layer2_write_index <= layer2_write_index+1;
        layer2_read_index <= layer2_ker_sel?layer2_read_index+1:layer2_read_index;
        layer2_ker_sel <= ~layer2_ker_sel;
        layer2_state <= 0;
      end
 /*     3'b010:begin

      end
      3'b011:begin

      end*/
      default: begin
      end
    endcase
  end
end

always@(negedge clk)begin
  if(layer0_write_window)begin
    #1;
    layer0_window[layer0_write_index] <= idata;
    layer0_write_window <= 0;
  end
end

endmodule




