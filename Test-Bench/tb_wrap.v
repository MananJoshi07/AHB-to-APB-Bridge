`timescale 1ns / 1ps

module tb_wrap;
reg Hclk;
reg Pclk;
reg Hresetn;
reg Presetn;
reg [1:0]   Htrans;          
reg [31:0]   Haddr;          
reg [31:0]   Hwdata;         
reg [1:0]   Hburst;          
reg         Hwrite;          
reg         Hsel;            
reg         Pready;          
reg [31:0]  Prdata;


wire Hreadyout;                                           
wire Psel;                       
wire [31:0] Paddr;               
wire [31:0] Pdata;               
wire [31:0] rdata_temp;          
wire Pwrite;                     
wire Penable;


    WRAP_TOP dut (
                     .Hclk(Hclk), 
                     .Pclk(Pclk), 
                     .Hresetn(Hresetn), 
                     .Presetn(Presetn),
                     .Htrans(Htrans),
                     .Haddr(Haddr),
                     .Hwdata(Hwdata),
                     .Hburst(Hburst),
                     .Hwrite(Hwrite),
                     .Hsel(Hsel),
                     .Pready(Pready),
                     .Prdata(Prdata),
                     .Hreadyout(Hreadyout),
   
                     .Psel(Psel),
                     .Paddr(Paddr),
                     .Pdata(Pdata),
                     .rdata_temp(rdata_temp),
                     .Pwrite(Pwrite),
                     .Penable(Penable)
                    
    );
    
    
    always #5 Hclk = ~Hclk;
    always begin
        #5;
        Pclk = 1;
        #10;
        Pclk = 0;
        #5;
    end
    
    
    always #20 Haddr  = $urandom;
    always #20 Hwdata  = $urandom;
    
    
    initial begin
        Hclk =1'b0;             
        Pclk =1'b0;             
        Hresetn =1'b0;          
        Presetn =1'b0;            
        Htrans ='h0;  
        Haddr ='h0;  
        Hwdata ='h0;  
        Hburst =2'b01;  
        Hwrite =1'b0;  
        Hsel =1'b0;   
        Pready =1'b0;  
        Prdata ='h0;
    end
   
   initial begin
   repeat(30)
       begin
            #50 Htrans = 2'b01;
            #50 Htrans = 2'b10;
            #400 Htrans = 2'b11;
            #400 Htrans = 2'b00;
       end  
   end
   
initial
fork    
    #40 Hresetn = 1'b1;
    #40 Presetn = 1'b1;
    #40 Hsel = 1'b1;
    #40 Hwrite = 1'b1;
    #40 Pready = 1'b1;   
join
                     
endmodule
