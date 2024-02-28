`timescale 1ns / 1ps
 `include "uvm_macros.svh"
    import uvm_pkg::*;
 
////////////////////////////////////////////////////////////////////////////////////
class ahb_apb_config extends uvm_object; /////configuration of env
  `uvm_object_utils(ahb_apb_config)
  
  function new(string name = "ahb_apb_config");
    super.new(name);
  endfunction
    uvm_active_passive_enum is_active = UVM_ACTIVE;
 endclass
 
///////////////////////////////////////////////////////

typedef enum bit [2:0]   {wrsingle = 0, wrincr = 1 , wrincr4 =2 ,wrincr8 =3 , rstdut =4} oper_mode;

//////////////////////////////////////////////////////////////////////////////////
 
class transaction extends uvm_sequence_item;
  
   //input signal
   rand oper_mode   op;
   rand logic [31:0] Haddr;
   rand logic [31:0] Hwdata;
   rand logic [31:0] Prdata;
   rand logic [1:0]  Hburst;
   rand logic [1:0]  Htrans;
   rand logic        Hsel;
   rand logic        Hwrite;
   rand logic        Pclk;
   rand logic        Pready;
   rand logic        Presetn;

   //output signal 
    logic [31:0] Paddr;
    logic [31:0] Pdata;
    logic        Penable;
    logic        Psel;
    logic        Pwrite;
    logic [31:0] rdata_temp;

        `uvm_object_utils_begin(transaction)
        `uvm_field_int  (Haddr,UVM_ALL_ON)
        `uvm_field_int  (Hburst,UVM_ALL_ON)
        `uvm_field_int  (Hsel,UVM_ALL_ON)
        `uvm_field_int  (Htrans,UVM_ALL_ON)
        `uvm_field_int  (Hwdata,UVM_ALL_ON)
        `uvm_field_int  (Hwrite,UVM_ALL_ON)
        `uvm_field_int  (Pclk,UVM_ALL_ON)
        `uvm_field_int  (Prdata,UVM_ALL_ON)
        `uvm_field_int  (Pready,UVM_ALL_ON)
        `uvm_field_int  (Presetn,UVM_ALL_ON)
        `uvm_field_int  (Paddr,UVM_ALL_ON)
        `uvm_field_int  (Pdata,UVM_ALL_ON)
        `uvm_field_int  (Penable,UVM_ALL_ON)  
        `uvm_field_int  (Psel,UVM_ALL_ON)
        `uvm_field_int  (Pwrite,UVM_ALL_ON)
        `uvm_field_int  (rdata_temp,UVM_ALL_ON)         
        `uvm_field_enum (oper_mode, op, UVM_DEFAULT)
        `uvm_object_utils_end
  
  function new(string name = "transaction");
    super.new(name);
  //  $display("--------------- transaction class --------------");
  endfunction
  
 endclass : transaction 
  


//--------------------------------------------------------------------------------------------------------//
////////////////////////         reset_operation          /////////////////////////////////////////// 
   class rst_dut extends uvm_sequence#(transaction);
      `uvm_object_utils(rst_dut)
	   transaction tr;
	   
	   function new(string name = "rst_dut");
	     super.new(name);
		endfunction
		
  virtual task body();
    repeat(15)
	 begin 
	 tr = transaction::type_id::create("tr");       
        start_item(tr);
        assert(tr.randomize);
        tr.op = rstdut;
       // $display("rst seq called");
        finish_item(tr);
	 end 
	 endtask 
	 
endclass 

//-----------------------------------------------------------------------------------------------//
/////////////////////////////////////        single              //////////////////////////////////
 
   class write_single extends uvm_sequence#(transaction);
    `uvm_object_utils(write_single)
     transaction tr;

    function new(string name = "write_single");
    super.new(name);
    endfunction 

    virtual task body();
    repeat(50)
    begin
         tr = transaction::type_id::create("tr");
		`uvm_info("SEQ", "Running Single mode Transfer", UVM_LOW);
		 start_item(tr);
		 assert(tr.randomize);
		 tr.op = wrsingle;
		 //setting-up constraint
		 tr.Hburst = 0;
		 tr.Hsel = 1;
		 tr.Pready = 1;
		// $display("single seq called");
		 finish_item(tr);
    end
	endtask 
endclass 

//-----------------------------------------------------------------------------------------//
/////////////////////////////         incr                         //////////////////////////

   class write_incr extends uvm_sequence#(transaction);
    `uvm_object_utils(write_incr)
     transaction tr;

     function new(string name = "write_incr");
     super.new(name);
     endfunction 

     virtual task body();
     repeat(60)
     begin
		`uvm_info("SEQ", "Running Incr mode Transfer", UVM_LOW)
	    tr = transaction::type_id::create("tr");
		
		start_item(tr);
		assert(tr.randomize);
	    tr.op = wrincr;
		//setting-up constraint
		tr.Hburst = 1;
		tr.Hsel = 1;
		tr.Pready = 1;
		//$display("incr seq called");  
		finish_item(tr);
		end
	endtask 
endclass 

//-----------------------------------------------------------------------------------------//
///////////////////////////           Incr4               //////////////////////////////////

   class write_incr4 extends uvm_sequence#(transaction);
    `uvm_object_utils(write_incr4)
     transaction tr;

    function new(string name = "write_incr4");
    super.new(name);
    endfunction 

    virtual task body();
    repeat(60)
        begin
		  `uvm_info("SEQ", "Running Incr4 mode Transfer", UVM_LOW)
	       tr = transaction::type_id::create("tr");
		   start_item(tr);
               assert(tr.randomize);
               tr.op = wrincr4;
               //setting-up constraint
               tr.Hburst = 2;
               tr.Hsel = 1;
               tr.Pready = 1;
            //   $display("incr4 seq called");
		   finish_item(tr);
		end
	endtask 
endclass 

//-----------------------------------------------------------------------------------------------//
////Incr8

   class write_incr8 extends uvm_sequence#(transaction);
   `uvm_object_utils(write_incr8)
    transaction tr;

    function new(string name = "write_incr8");
        super.new(name);
    endfunction 

virtual task body();
repeat(60)
    begin
		`uvm_info("SEQ", "Running incr8 mode Transfer", UVM_LOW)
	     tr = transaction::type_id::create("tr");
		 start_item(tr);
             assert(tr.randomize);
             tr.op = wrincr8;
             //setting-up constraint
             tr.Hburst = 3;
             tr.Hsel = 1;
             tr.Pready = 1;
         //    $display("incr8 seq called");
		finish_item(tr);
    end
endtask 

endclass 

//----------------------------------------------------------------------------------------------------------------------//
class driver extends uvm_driver #(transaction);
	`uvm_component_utils(driver)
     virtual ahb_inf vif;
	 transaction tr;

	function new(string name = "Drv", uvm_component parent = null);
	super.new(name, parent);
	endfunction
	
	//build phase
	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		//$display("build phase called");
		tr = transaction::type_id::create("tr"); 
		
		if(!uvm_config_db#(virtual ahb_inf)::get(this,"","vif",vif))//uvm_test_top.env.agent.drv.aif
	    `uvm_error("drv","Unable to access Virtual inf");
    endfunction
	
	//reset task in starting
	task reset_dut(); 
    begin
        `uvm_info("DRV", "System Reset : Start of Simulation", UVM_MEDIUM);
        vif.Hsel       <= 0;
        vif.Hburst     <= 0;
        vif.Haddr      <= 0;
        vif.Hwdata     <= 0;
        vif.Htrans     <= 0;
        vif.Hwrite     <= 0;
        vif.Pready     <= 0; 
        @(posedge vif.Hclk);
    end
	endtask
	
	task drive();
		reset_dut();	
		forever begin
			seq_item_port.get_next_item(tr);
			if(tr.op == rstdut)
			begin
                vif.Hresetn    <= 0;
                vif.Hsel       <= 0;
                vif.Hburst     <= 0;
                vif.Haddr      <= 0;
                vif.Hwdata     <= 0;
                vif.Htrans     <= 0;
                vif.Hwrite     <= 0;
                vif.Pready     <= 0; 
                
                @(posedge vif.Hclk);
                vif.Hresetn     <=1; 
			end
			//single transfer mode
			else if (tr.op == wrsingle)
			begin
			//$display("single seq called");
			vif.Hsel       <= 1;
			vif.Hburst     <= 0;
			vif.Htrans    <= tr.Htrans;
			vif.Hwrite    <= 1;
			vif.Pready    <= 1;
			@(posedge vif.Hclk)
			vif.Haddr     <= tr.Haddr;
			@(posedge vif.Hclk)
			vif.Hwdata    <= tr.Hwdata;
			`uvm_info("DRV", $sformatf("mode = %0s, Haddr = %0h, Hwdata = %0h", tr.op, tr.Haddr, tr.Hwdata), UVM_NONE)
			end
			
			
			//incr mode
			else if (tr.op == wrincr)
			begin
		   // $display("incr seq called");
			vif.Hsel       <= 1;
			vif.Hburst     <= 1; 
			vif.Hwrite    <= 1;
			vif.Pready    <= 1;
			@(posedge vif.Hclk)			
			vif.Haddr     <= tr.Haddr;
			@(posedge vif.Hclk)
			vif.Hwdata    <= tr.Hwdata;
			vif.Htrans    <= 3;

			`uvm_info("DRV", $sformatf("mode = %0s, Haddr = %0h, Hwdata = %0h", tr.op, tr.Haddr, tr.Hwdata), UVM_NONE)
			end
			
			
			//incr4 mode
			else if (tr.op == wrincr4)
			begin
		    $display("incr4 seq called");
			vif.Hsel       <= 1;
			vif.Hburst     <= 2; 
			vif.Hwrite    <= 1;
			vif.Pready    <= 1;
	        @(posedge vif.Hclk)
			vif.Haddr     <= tr.Haddr;
			@(posedge vif.Hclk)
			vif.Hwdata    <= tr.Hwdata;
			vif.Htrans    <= 3;
			`uvm_info("DRV", $sformatf("mode = %0s, Haddr = %0h, Hwdata = %0h", tr.op, tr.Haddr, tr.Hwdata), UVM_NONE)
			end
			
			
			//incr8 mode
			else if (tr.op == wrincr8)
			begin
			vif.Hsel       <= 1;
			vif.Hburst     <= 3;
            vif.Hwrite    <= 1;
			vif.Pready    <= 1;
	        @(posedge vif.Hclk)
			vif.Haddr     <= tr.Haddr;
			@(posedge vif.Hclk)
			vif.Hwdata    <= tr.Hwdata;
			vif.Htrans    <= 3;
			`uvm_info("DRV", $sformatf("mode = %0s, Haddr = %0h, Hwdata = %0h", tr.op, tr.Haddr, tr.Hwdata), UVM_NONE);
			end
			seq_item_port.item_done();
		end
	endtask
	//run-phase
	
	
	  virtual task run_phase(uvm_phase phase);
    drive();
  endtask
endclass

//-------------------------------------------------------------------------------------------------------------------//
/*
 class mon extends uvm_monitor;
   `uvm_component_utils(mon)

	 transaction tr;
     virtual ahb_inf vif;
     
     logic[31:0] arr[128];
     logic [1:0] wrres;
     logic       resp;
     
     int err =0;

	function new(input string inst = "mon", uvm_component parent = null);
	   super.new(inst, parent);
	endfunction
	
   virtual function void build_pahse(uvm_phase phase);
      super.build_phase(phase);
      tr = transaction::type_id::create("tr");
      if(!uvm_config_db#(virtual ahb_inf)::get(this,"","vif",vif))  //uvm_test_topr.env.agent.drv.aif
     `uvm_error("MON", "UNABLE TO ACCESS INTERFACE");
  endfunction
   
   virtual task run_phase(uvm_phase phase);
  // super.run_phase(phase);
    forever 
	 begin 
	 @(posedge vif.Hclk);
	  if(!vif.Hresetn)
	     begin 
	      tr.op = rstdut;
		  `uvm_info("MON", "SYSTEM RESET DETECTED", UVM_NONE);
		  send.write(tr);
		end 
		  
		 
	  else if ((tr.op == wrsingle) && (vif.Hwrite && vif.Hsel) && (vif.Htrans == 2 || vif.Htrans == 3))
	      begin 
		    @(posedge vif.Pready);
		    tr.op = wrsingle;
			tr.Hwrite = vif.Hwrite;
			tr.Haddr = vif.Haddr;
		   `uvm_info("MON", $sformatf("DATA WRITE SINGLE addr:%0d data:%0d",tr.Haddr,tr.Hwdata), UVM_NONE);
            send.write(tr);
		  end 
      else if ((tr.op == 2'b01) && (vif.Hwrite && vif.Hsel) && (vif.Htrans == 2 || vif.Htrans == 3))
	      begin 
		   @(posedge vif.Pready);
		    tr.op = wrincr;
			tr.Hwrite = vif.Hwrite;
			tr.Haddr = vif.Haddr;
		   `uvm_info("MON", $sformatf("DATA WRITE INCR addr:%0d data:%0d",tr.Haddr,tr.Hwdata), UVM_NONE)
            send.write(tr);
		  end 
       else if ((tr.op == 2'b10) && (vif.Hwrite && vif.Hsel) && (vif.Htrans == 2 || vif.Htrans == 3))
	      begin 
		   @(posedge vif.Pready);
		    tr.op = wrincr4;
			tr.Hwrite = vif.Hwrite;
			tr.Haddr = vif.Haddr;
		   `uvm_info("MON", $sformatf("DATA WRITE INCR4 addr:%0d data:%0d",tr.Haddr,tr.Hwdata), UVM_NONE)
            send.write(tr);
		  end 
	  else if ((tr.op == 2'b11) && (vif.Hwrite && vif.Hsel) && (vif.Htrans == 2 || vif.Htrans == 3))
	      begin 
		   @(posedge vif.Pready);
		    tr.op = wrincr8;
			tr.Hwrite = vif.Hwrite;
			tr.Haddr = vif.Haddr;
		   `uvm_info("MON", $sformatf("DATA WRITE INCR8 addr:%0d data:%0d",tr.Haddr,tr.Hwdata), UVM_NONE)
            send.write(tr);
		  end 
	 end 
	 endtask 
	 
endclass 

//---------------------------------------------------------------------------------------------------------------------//
 
 
 class sco extends uvm_scoreboard;
   `uvm_component_utils(sco)
   
    uvm_analysis_imp#(transaction, sco) recv;
	
  bit [31:0] arr[32]    = '{default:0};
  bit [31:0] addr       = 0;
  bit [31:0] data_write = 0;
  
    function new(input string inst = "sco", uvm_component parent = null);
    super.new(inst,parent);
    endfunction
    
    virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    recv = new("recv", this);
    endfunction

   virtual function void write(transaction tr);
     forever
	    begin 
     if(tr.op == rstdut)
              begin
                `uvm_info("SCO", "SYSTEM RESET DETECTED", UVM_NONE)
              end  
              
     else if (tr.op == wrsingle)
	     begin 
		  arr[addr] = tr.Hwrite;
	       `uvm_info("SCO", $sformatf("DATA WRITE OP  addr:%0d, wdata:%0d and arr_data:%0d",tr.Haddr,tr.Hwrite,arr[tr.Paddr]), UVM_NONE)
	       data_write = arr[addr];
           if (data_write == tr.Hwrite)	
              `uvm_info("SCO", $sformatf("DATA MATCHED"),UVM_NONE)
           else 
              `uvm_info("SCO", $sformatf("DATA NOT MATCHED"),UVM_NONE)  			  
          end 
       end
	$display("-------------------------------------------------------------------------");
	
    endfunction 
   endclass 
*/
//--------------------------------------------------------------------------------------------------------------------//

class agent extends uvm_agent;
    `uvm_component_utils(agent)
     ahb_apb_config cfg;//type of agent
 
     function new(input string inst = "agent", uvm_component parent = null);
     super.new(inst,parent);
     endfunction
 
     driver d;
     uvm_sequencer#(transaction) seqr;
     // mon m;
 
    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
       cfg =  ahb_apb_config::type_id::create("cfg"); 
    // m = mon::type_id::create("m",this);
  
      if(cfg.is_active == UVM_ACTIVE)
       begin   
        d = driver::type_id::create("d",this);
        seqr = uvm_sequencer#(transaction)::type_id::create("seqr", this);
       end
 
    endfunction
 
     virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      if(cfg.is_active == UVM_ACTIVE) begin  
      d.seq_item_port.connect(seqr.seq_item_export);
     end
     endfunction
 
     endclass



//---------------------------------------------------------------------------------------------------------------------//
class env extends uvm_env;
`uvm_component_utils(env)
 
    function new(input string inst = "env", uvm_component c);
      super.new(inst,c);
    endfunction
 
    agent a;
    // sco s;
 
     virtual function void build_phase(uvm_phase phase);
       super.build_phase(phase);
        a = agent::type_id::create("a",this);
  //    s = sco::type_id::create("s", this);
     endfunction
 
//     virtual function void connect_phase(uvm_phase phase);
//        super.connect_phase(phase);
//        a.m.send.connect(s.recv);
//     endfunction
 
endclass
  
//-----------------------------------------------------------------------------------------------------//
class test extends uvm_test;
`uvm_component_utils(test)
 
    function new(input string inst = "test", uvm_component c);
    super.new(inst,c);
    endfunction
 
        env e;
        write_single wrs;
        write_incr wri;
        write_incr4 wri4;
        write_incr8 wri8;  
        rst_dut rstdut;  
  
    virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
          e      = env::type_id::create("env",this);
          wrs    = write_single::type_id::create("wrs");
          wri    = write_incr::type_id::create("wri");
          wri4   = write_incr4::type_id::create("wri4");
          wri8   = write_incr8::type_id::create("wri8");
          rstdut = rst_dut::type_id::create("rstdut");
    endfunction
 
       virtual task run_phase(uvm_phase phase);
      // super.run_phase(phase);
            phase.raise_objection(this);
               wrs.start(e.a.seqr);
               #10
//             wri.start(e.a.seqr);
               #10
//             wri4.start(e.a.seqr);
//             #10
//             wri8.start(e.a.seqr);
//             #10
           phase.drop_objection(this);
        endtask
endclass

//-------------------------------------------------------------------------------------------------------------//
module TOP1;
  
  
  ahb_inf vif();
  
  WRAP_TOP dut(.Hclk(vif.Hclk), .Hresetn(vif.Hresetn), .Haddr(vif.Haddr), .Hwdata(vif.Hwdata), .Hburst(vif.Hburst), .Hsel(vif.Hsel), .Htrans(vif.Htrans), .Hwrite(vif.Hwrite), .Pclk(vif.Pclk),.Prdata(vif.Prdata), .Pready(vif.Pready), .Presetn(vif.Presetn), .Paddr(vif.Paddr), .Pdata(vif.Pdata), .Penable(vif.Penable), .Psel(vif.Psel), .Pwrite(vif.Pwrite));
  
  initial
   begin
        vif.Hclk <= 1;
        vif.Pclk <= 1;
        vif.Hresetn <= 0;
        vif.Presetn <= 0;  
        vif.Pwrite <= 0;
        #10 vif.Pwrite <= 1;
        #10 vif.Hresetn <= 1;
        #10 vif.Presetn <= 1;
           forever
           begin
               #10 vif.Htrans <= 0;
               #50 vif.Htrans <= 1;
               #200 vif.Htrans <= 2;
               #200 vif.Htrans <= 3;
          end
   end
   
   always #5 vif.Hclk <= ~vif.Hclk;
   always #10 vif.Pclk <= ~vif.Pclk;
  
  initial begin
    uvm_config_db#(virtual ahb_inf)::set(null, "*", "vif", vif);
    run_test("test");
   end
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end 
endmodule