//file name: sim_tb.v
//function : testbench file
//author   : HateHanzo

`timescale 1ns/10ps
module sim_tb();

//parametr
parameter DLY         = 1              ;
parameter WIDTH_FIFO  = 8              ;


//-----------------------------
//--signal
//-----------------------------
reg                       clk_w       ;
reg                       clk_r       ;
reg                       rst_n       ;
reg                       wen         ;
reg                       ren         ;
reg   [WIDTH_FIFO-1:0]    wdata       ;
reg   [WIDTH_FIFO-1:0]    rdata_test  ;
wire  [WIDTH_FIFO-1:0]    rdata       ;


//-----------------------------
//--instance
//-----------------------------
asyn_fifo asyn_fifo(
        .clk_w (clk_w ), 
        .clk_r (clk_r ), 
        .rst_n (rst_n ), 
        .wen   (wen   ), 
        .ren   (ren   ), 
        .wdata (wdata ), 
                      
        .rdata (rdata ), 
        .empty ( ), 
        .full  ( )
);

//-----------------------------
//--initial
//-----------------------------
initial  begin
  clk_w = 1'b0 ;
  clk_r = 1'b0 ;

  wen   = 1'b0 ;
  ren   = 1'b0 ;

  rst_n = 1'b1 ;
#1  rst_n = 1'b0 ;
#1  rst_n = 1'b1 ;
end

//-----------------------------
//--gennerate clk
//-----------------------------
always #(20)  clk_w = !clk_w ;
always #(5) clk_r = !clk_r ;

//-----------------------------
//--test pat
//-----------------------------
initial begin
  IOW(8'h03);
  IOW(8'h04);
  IOW(8'h05);
  IOW(8'h06);
  IOW(8'h07);
  IOW(8'h08);
  IOW(8'h09);
  IOW(8'h0a);
  IOR(rdata_test);
  IOR(rdata_test);
  IOR(rdata_test);
  IOR(rdata_test);
  IOR(rdata_test);
  IOR(rdata_test);
  IOR(rdata_test);
  IOR(rdata_test);

  # 10000;
  # 10000;
$stop  ;//for modelsim
end

//-----------------------------
//--task define
//-----------------------------
task IOW(input [7:0] din);
  begin

    @(negedge clk_w)
    wait(rst_n)
    begin
      # 1 ;
      wdata = din ;
      wen = 1'b1  ;
    end
    @(posedge clk_w)
    wait(rst_n)
    begin
      # 1 ;
      wen = 1'b0   ;
      $display("write fifo,wdata = %h",din); 
    end

  end
endtask


task IOR(output [7:0] dout);
  begin

    @(negedge clk_r)
    wait(rst_n)
    begin
      # 1 ;
      ren = 1'b1  ;
    end
    @(posedge clk_r)
    wait(rst_n)
    begin
      # 1 ;
      ren = 1'b0   ;
      # 1 ;
      dout = rdata ;
      $display("read fifo,rdata = %h",dout); 
    end

  end
endtask

endmodule





