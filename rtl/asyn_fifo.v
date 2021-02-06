//file name: asyn_fifo.v
//function : asyn fifo for CDC
//author   : HateHanzo
module asyn_fifo(
        clk_w , 
        clk_r , 
        rst_n , 
        wen   , 
        ren   , 
        wdata , 
       
        rdata , 
        empty , 
        full  
);

//parametr
parameter DLY         = 1              ;
parameter WIDTH_FIFO  = 8              ;
parameter ADDR_FIFO   = 3              ;
parameter DEPTH_FIFO  = 1 << ADDR_FIFO ;

//input output
input                      clk_w  ;
input                      clk_r  ;
input                      rst_n  ;
input                      wen    ;
input                      ren    ;
input  [WIDTH_FIFO-1:0]    wdata  ;

output [WIDTH_FIFO-1:0]    rdata  ;
output                     empty  ;
output                     full   ;

//-----------------------------
//--signal
//-----------------------------
reg    [ADDR_FIFO:0]    wbin                ; 
reg    [ADDR_FIFO:0]    wgray               ;
reg    [ADDR_FIFO:0]    wgray_d1            ;
reg    [ADDR_FIFO:0]    wgray_d2            ;
reg    [ADDR_FIFO:0]    rbin                ;
reg    [ADDR_FIFO:0]    rgray               ;
reg    [ADDR_FIFO:0]    rgray_d1            ;
reg    [ADDR_FIFO:0]    rgray_d2            ;
reg    [WIDTH_FIFO-1:0] mem[DEPTH_FIFO-1:0] ;


//-----------------------------
//--main circuit
//-----------------------------

//------------------
//write clock domain
//------------------

wire wbin_next = ( wen && (!full) ) ? (wbin + {{{ADDR_FIFO}{1'b0}},1'b1}) ;
wire wgray_next = ( wbin_next >> 1 ) ^ wbin_next ;

always@(posedge clk_w or negedge rst_n)
begin
	if(!rst_n) begin
		wbin  <= #DLY { {ADDR_FIFO+1}{1'b0} } ;
		wgray <= #DLY { {ADDR_FIFO+1}{1'b0} } ;
	end
	else begin
		wbin  <= #DLY wbin_next  ;
		wgray <= #DLY wgray_next ;
	end
end

//write data
always@(posedge clk_w)
  if(wen && (!full))
    mem[wbin[ADDR_FIFO-1:0]] <= #DLY wdata;
  else ;

//use 2 dff sync rgray from clk_r
always@(posedge clk_w or negedge rst_n)
begin
	if(!rst_n) begin
		rgray_d1  <= #DLY { {ADDR_FIFO+1}{1'b0} } ;
		rgray_d2  <= #DLY { {ADDR_FIFO+1}{1'b0} } ;
	end
	else begin
		rgray_d1  <= #DLY rgray      ;
		rgray_d2  <= #DLY rgray_d1   ;
	end
end

//gen full,the MSB and second MSB both different between wgray and
//rgray_d2,the rest same
wire full = (wgray == {~rgray_d2[ADDR_FIFO:ADDR_FIFO-1],rgray_d2[ADDR_FIFO-2:0});

//-----------------
//read clock domain
//-----------------

wire rbin_next = ( ren && (!full) ) ? (rbin + {{{ADDR_FIFO}{1'b0}},1'b1}) ;
wire rgray_next = ( rbin_next >> 1 ) ^ rbin_next ;

always@(posedge clk_r or negedge rst_n)
begin
	if(!rst_n) begin
		rbin  <= #DLY { {ADDR_FIFO+1}{1'b0} } ;
		rgray <= #DLY { {ADDR_FIFO+1}{1'b0} } ;
	end
	else begin
		rbin  <= #DLY rbin_next  ;
		rgray <= #DLY rgray_next ;
	end
end


//read data
always@(posedge clk_r)
  if(ren && (!empty))
    rdata <= #DLY mem[wbin[ADDR_FIFO-1:0]] ;
  else ;

//use 2 dff sync wgray from clk_w
always@(posedge clk_r or negedge rst_n)
begin
	if(!rst_n) begin
		wgray_d1  <= #DLY { {ADDR_FIFO+1}{1'b0} } ;
		wgray_d2  <= #DLY { {ADDR_FIFO+1}{1'b0} } ;
	end
	else begin
		wgray_d1  <= #DLY wgray      ;
		wgray_d2  <= #DLY wgray_d1   ;
	end
end

//gen empty,the wgray and rgray_d2 the same
wire empty = (rgray == wgray_d2);


endmodule





