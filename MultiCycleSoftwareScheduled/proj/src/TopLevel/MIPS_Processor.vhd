-------------------------------------------------------------------------
-- Henry Duwe
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- MIPS_Processor.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a skeleton of a MIPS_Processor  
-- implementation.

-- 01/29/2019 by H3::Design created.
-------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;

library work;
use work.MIPS_types.all;

entity MIPS_Processor is
  generic(N : integer := DATA_WIDTH);
  port(iCLK            : in std_logic;
       iRST            : in std_logic; -- is this exclusivly for register file reset 
       iInstLd         : in std_logic;
       iInstAddr       : in std_logic_vector(N-1 downto 0);
       iInstExt        : in std_logic_vector(N-1 downto 0);
       oALUOut         : out std_logic_vector(N-1 downto 0)); 

end  MIPS_Processor;


architecture structure of MIPS_Processor is

 -- Required register file signals 
  signal s_RegWr        : std_logic; -- use this signal as the final active high write enable input to the register file
  signal s_RegWrAddr    : std_logic_vector(4 downto 0); -- use this signal as the final destination register address input
  signal s_RegWrData    : std_logic_vector(N-1 downto 0); -- use this signal as the final data memory data input

 -- Required halt signal -- for simulation
  signal s_Halt         : std_logic;  -- this signal indicates to the simulation that intended program execution has completed. (Opcode: 01 0100)

  --used required signals
  signal s_Inst         : std_logic_vector(N-1 downto 0); -- use this signal as the instruction signal 
  signal s_DMemWr       : std_logic; -- use this signal as the final active high data memory write enable signal
  signal s_DMemAddr     : std_logic_vector(N-1 downto 0); -- use this signal as the final data memory address input
  signal s_DMemData     : std_logic_vector(N-1 downto 0); -- use this signal as the final data memory data input
  signal s_DMemOut      : std_logic_vector(N-1 downto 0); -- use this signal as the data memory output
  signal s_IMemAddr     : std_logic_vector(N-1 downto 0); -- Do not assign this signal, assign to s_NextInstAddr instead
  signal s_NextInstAddr : std_logic_vector(N-1 downto 0); -- use this signal as your intended final instruction memory address input.
  signal s_Ovfl         : std_logic;  -- this signal indicates an overflow exception would have been initiated

  component mem is
    generic(ADDR_WIDTH : integer;
            DATA_WIDTH : integer);
    port(
          clk          : in std_logic;
          addr         : in std_logic_vector((ADDR_WIDTH-1) downto 0);
          data         : in std_logic_vector((DATA_WIDTH-1) downto 0);
          we           : in std_logic := '1';
          q            : out std_logic_vector((DATA_WIDTH -1) downto 0));
    end component;

  component registerfile is 
  port(
	clk: in std_logic;
	reset: in std_logic;
	we: in std_logic;
	rs: in std_logic_vector(4 downto 0);
	rt: in std_logic_vector(4 downto 0);
	rd: in std_logic_vector(4 downto 0);
	writeport: in std_logic_vector(N-1 downto 0);
	readdata1: out std_logic_vector(N-1 downto 0);
	readdata2: out std_logic_vector(N-1 downto 0));
  end component;

  component extender is
  port(
	Imm: in std_logic_vector(15 downto 0);
	s: in std_logic;
	out_Imm: out std_logic_vector(N-1 downto 0));
  end component;

  component mux2t1_N is
  generic(N : integer := N);
  port(
	i_S: in std_logic;
	i_D0: in std_logic_vector(N-1 downto 0);
	i_D1: in std_logic_vector(N-1 downto 0);
	o_O: out std_logic_vector(N-1 downto 0));
  end component;

  component mux2t1 is 
  port( 
	i_D0,i_D1 : in std_logic;
	i_S : in std_logic;
	o_O : out std_logic);
  end component; 

  component ALU is 
  port( 
	read_data_1: in std_logic_vector(N-1 downto 0);
	read_data_2: in std_logic_vector(N-1 downto 0);
	alu_control: in std_logic_vector(5 downto 0);
	shampt: in std_logic_vector(4 downto 0);
	output: out std_logic_vector(N-1 downto 0); 
	overflow: out std_logic; 
	carryout: out std_logic; 
	zero: out std_logic); 
  end component;

  component programcounter is 
  port(
	i_InstrAddress: in std_logic_vector(31 downto 0);
	clk: in std_logic;
	reset: in std_logic;
	o_InstrAddress: out std_logic_vector(31 downto 0));
  end component;

  component full_adder_N is
	port(i0 : in std_logic_vector(N-1 downto 0);
		i1 : in std_logic_vector(N-1 downto 0);
		cin : in std_logic;
		output : out std_logic_vector(N-1 downto 0);
		overflow: out std_logic;
		cout : out std_logic);
  end component;

  component controllogic is
  port( opcode: in std_logic_vector(5 downto 0);
	functcode: in std_logic_vector(5 downto 0);
	ALUsrc: out std_logic;
	ALUcontrol: out std_logic_vector(5 downto 0);
	MemtoReg: out std_logic;
	Branch: out std_logic;
	Jump: out std_logic;
	MemWrite: out std_logic;
	RegWrite: out std_logic;
	RegDst: out std_logic;
	extendersel: out std_logic; 
	datasel: out std_logic; 
	jaldst: out std_logic;
	jaldata: out std_logic;
	jr: out std_logic;
	halt: out std_logic;
	btype: out std_logic); 
  end component;

  component andg2 is 
  port(i_A          : in std_logic;
       i_B          : in std_logic;
       o_F          : out std_logic);
  end component;

  component org_N is
  port(i_A : in std_logic_vector(N-1 downto 0);
	   i_B : in std_logic_vector(N-1 downto 0);
	   o_O : out std_logic_vector(N-1 downto 0));
  end component;

  component register1 is 
  port(we :in std_logic;
       reset :in std_logic; 
       clk :in std_logic;
       data_in :in std_logic_vector(n-1 downto 0);
       data_out :out std_logic_vector(n-1 downto 0));
  end component; 

--stage1
signal s_pcmux_pc: std_logic_vector(N-1 downto 0; -- signal between pcmux and pc input 
signal s_pcadder_pcmux: std_logic_vector(N-1 downto 0); --pcplus4 signal to pc mux
signal s_orlayer1_orlayer2: std_logic; -- org layer transfer
signal s_orgates_pcmuxselect: std_logic; --org layers output to pcmux select
signal s_imempre_stageinst: std_logic_vector(N-1 downto 0); --imem output to imem register 
signal s_branchbnelogic_pcmux: std_logic; -- branch/bne from andg
signal s_pcadd4register_stage1: std_logic_vector(N-1 downto 0);  --pcadd4 signal stage1

--stage2
signal s_cl_branchbne: std_logic; --control logic output signal 
signal s_cl_jr: std_logic; --control logic output signal 
signal s_cl_j: std_logic; --control logic output signal 
signal s_Inst: std_logic_vector(N-1 downto 0); --imem register output into stage 2
signal s_pcadd4register_stage2: std_logic_vector(N-1 downto 0);  --pcadd4 signal stage2
signal s_cl_jaldatamux_stage2: std_logic; --jaldatamux select stage2
signal s_cl_bmuxselect_stage2: std_logic; --bmuxselect stage2
signal s_inst_stage2: std_logic_vector(N-1 downto 0); --instruction stage2
signal s_cl_aluopcode_stage2: std_logic_vector(5 downto 0); --alu op code stage2
signal s_cl_aluopcode: std_logic_vector(5 downto 0); --alu op code 
signal s_extenderoutput: std_logic_vector(N-1 downto 0); --extender component output
signal s_extender_stage2: std_logic_vector(N-1 downto 0); --extender stage2 output
signal s_cl_alusrc: std_logic; --alusrc cl
signal s_cl_alusrc_stage2: std_logic; --alusrc stage2
signal s_rd1: std_logic_vector(N-1 downto 0); --rd1 regfile output
signal s_rd1_stage2: std_logic_vector(N-1 downto 0); --rd1 stage2
signal s_rd2_stage2: std_logic_vector(N-1 downto 0); --rd2 stage2 signal

--stage3
signal s_pcadd4register_stage3: std_logic_vector(N-1 downto 0); --pcadd4 signal stage3
signal s_cl_jaldatamux_stage3: std_logic; --jaldatacl signal stage3
signal s_cl_bmuxselect_stage3: std_logic; --bmuxcl signal stage3
signal s_cl_dmemwr_stage3: std_logic; --dmem signal stage3
signal s_aluouput: std_logic_vector(N-1 downto 0); --aluoutput
signal s_rd2_stage3: std_logic_vector(N-1 downto 0); --rd2 stage3 signal 
signal s_alusrcmux_alu: std_logic_vector(N-1 downto 0); --alusrcmux output to alu

--stage4
signal s_pcadd4register_stage4: std_logic_vector(N-1 downto 0); --pcadd4 signal stage4
signal s_cl_jaldatamux_stage4: std_logic; --jaldatacl signal stage4
signal s_cl_bmuxselect_stage4: std_logic; --bmuxcl signal stage4
signal s_aluoutput_stage4: std_logic_vector(N-1 downto 0); --aluoutput signal stage4
signal s_dmemoutput_stage4: std_logic_vector(N-1 downto 0); --dmemoutput signal stage4

--stage5
signal s_jaldatamux_writeport: std_logic_vector(N-1 downto 0); --signal for jaldatamux to writeport of register file 
signal s_bmuxoutput_jaldatamux: std_logic_vector(N-1 downto 0); --carry signal between bemux output and jaldata mux input0 

begin

  with iInstLd select
    s_IMemAddr <= s_NextInstAddr when '0',
      iInstAddr when others;

  	IMem: mem
    	generic map(ADDR_WIDTH => ADDR_WIDTH,
                DATA_WIDTH => N)
    	port map(clk  => iCLK,
             addr => s_IMemAddr(11 downto 2),
             data => iInstExt,
             we   => iInstLd,
             q    => s_imempre_stageinst
		);
  
	pcmux: mux2t1_N
		port map(
			i_S => s_orgates_pcmuxselect,
			i_D0 => s_pcadder_pcmux,
			i_D1 => s_branchbnelogic_pcmux,
			o_O => s_pcmux_pc
		);
	
	orglayer1: org_N 
		generic map(N => 1)
		port map(
			i_A => s_cl_branchbne,
			i_B => s_cl_jr,
			o_O => s_orlayer1_orlayer2
		);

	orglayer2: org_N 
		generic map(N => 1)
		port map(
			i_A => s_orlayer1_orlayer2, 
			i_B => s_cl_j,
			o_O => s_orgates_pcmuxselect
		);

	pc: programcounter 
		port map(
			i_InstrAddress => s_pcmux_pc,
			clk => iCLK,
			reset => iRST, 
			o_InstrAddress => s_NextInstAddr
		);
	
	pcadd4: full_adder_N
		port map(
			i0 => s_NextInstAddr,
			i1 => x"00000004",
			cin => '0',
			output => s_pcadder_pcmux,
			cout => open 
		);

	imemregiser: register1 
		port map(
			we => '1',
       		reset => '0',
       		clk => iCLK,
       		data_in => s_imempre_stageinst, 
       		data_out => s_Inst
		);
	
	pcplus4regiserstage1: register1 
		port map(
			we => '1',
    		reset => '0',
    		clk => iCLK,
	    	data_in => s_pcadder_pcmux,
    		data_out => s_pcadd4register_stage1
		);
	
	--ID/IF

	control: controllogic --TODO check all control logic signals for their correct size
		port map(
			opcode => s_Inst(31 downto 26), 
			functcode => s_Inst(5 downto 0),
			ALUsrc => s_cl_alusrc,
			ALUcontrol => s_cl_aluopcode,
			MemtoReg => 
			Branch => 
			Jump => s_cl_j,
			MemWrite => 
			RegWrite => 
			RegDst => 
			extendersel => 
			datasel => open, 
			jaldst => 
			jaldata => 
			jr => s_cl_jr,
			halt => 
			btype => 
    	);

	--registermux
	--jalmux
	--extender
	--shiftafterextender
	--pcadd4more
	--muxlayer1
	--muxlayer2
	--muxlayer3
	--shiftfrominst
	--andg
	--registerfile
	--bnecalc
	--branchcalc
	--branch/bnemux

	inststage2register: register1 
		port map(
			we => '1',
			reset => '0',
			clk => iCLK,
			data_in => s_Inst,
			data_out => s_inst_stage2
		);
	
	pcplus4stage2register: register1 
		port map(
			we => '1',
			reset => '0',
			clk => iCLK,
			data_in => s_pcadd4register_stage1
			data_out => s_pcadd4register_stage2
		);

	extenderstage2register: register1 
		port map(
			we => '1',
			reset => '0',
			clk => iCLK,
			data_in => s_extenderoutput,
			data_out => s_extender_stage2
		);

	rd2stage2registerstage2: register1 
		port map(
			we => '1',
			reset => '0',
			clk => iCLK,
			data_in => s_rd2_stage2,
			data_out => s_rd2_stage3
		);

	rd1stage2registerstage2: register1
		port map(
			we => '1',
			reset => '0',
			clk => iCLK,
			data_in => s_rd1,
			data_out => s_rd1_stage2
		);

	alusrcselstage2register: register1 
		generic map(N => 1)
		port map(
			we => '1',
			reset => '0',
			clk => iCLK,
			data_in => s_cl_alusrc,
			data_out => s_cl_alusrc_stage2
		);

	dmemwriteenablestage2register: register1  --TODO
		generic map(N => 1)
		port map(
			we => '1',
			reset => '0',
			clk => iCLK,
			data_in => 
			data_out => 
		);


	bmuxselectstage2register: register1 --TODO
	generic map(N => 1)
		port map(
			we => '1',
			reset => '0',
			clk => iCLK,
			data_in => 
			data_out => 
		);

	jaldatamuxstage2register: register1  --TODO
		generic map(N => 1)
		port map(
			we => '1',
			reset => '0',
			clk => iCLK,
			data_in => 
			data_out => s_cl_jaldatamux_stage2
		);

	aluopstage2register: register1
		generic map(N => 5)
		port map(
			we => '1',
			reset => '0',
			clk => iCLK,
			data_in => s_cl_aluopcode,
			data_out => s_cl_aluopcode_stage2
		);
	
	--ID/EX

	arithmeticlogicalunit: ALU
    	port map(
			read_data_1 => s_rd1_stage2,
			read_data_2 => s_alusrcmux_alu,
			alu_control => s_cl_aluopcode_stage2,
			shampt => s_inst_stage2(10 downto 6),
			output => s_aluouput,
			overflow => s_Ovfl,
			carryout => open, 
			zero => open
    	);
	
	alusrcmux: mux2t1_N 
    	port map(
			i_S => s_cl_alusrc_stage2,
			i_D0 => s_rd2_stage3,
			i_D1 => s_extender_stage2,
			o_O => s_alusrcmux_alu
		);

	readdata2registerstage3: register1 
		port map(
			we => '1',
    		reset => '0',
    		clk => iCLK,
	    	data_in => s_rd2_stage3,
    		data_out => s_DMemData
		);

	aluoutputregisterstage3: register1 
		port map(
			we => '1',
			reset => '0',
			clk => iCLK,
			data_in => s_aluouput,
			data_out => s_DMemAddr
		);

	dmemwrenregisterstage3: register1 
		generic map(N => 1)
		port map(
			we => '1',
			reset => '0',
			clk => iCLK,
			data_in => s_cl_dmemwr_stage3,
			data_out => s_DMemWr
		);

	bmuxselregisterstage3: register1  
		generic map(N => 1)
		port map(
			we => '1',
			reset => '0',
			clk => iCLK,
			data_in => s_cl_bmuxselect_stage2,
			data_out => s_cl_bmuxselect_stage3
		);

	jaldatamuxregisterstage3: register1
		generic map(N => 1)
		port map(
			we => '1',
			reset => '0',
			clk => iCLK,
			data_in => s_cl_jaldatamux_stage2,
			data_out => s_cl_jaldatamux_stage3
		);

	pcplus4registerstage3: register1 
		port map(
			we => '1',
			reset => '0',
			clk => iCLK,
			data_in => s_pcadd4register_stage2,
			data_out => s_pcadd4register_stage3
		);

	--MEM/WB

	DMem: mem
    	generic map(ADDR_WIDTH => ADDR_WIDTH,
                DATA_WIDTH => N)
    	port map(clk  => iCLK,
             addr => s_DMemAddr(11 downto 2),
             data => s_DMemData,
             we   => s_DMemWr,
             q    => s_DMemOut
		);

	pcplus4registerstage4: register1 
		port map(
			we => '1',
    		reset => '0',
    		clk => iCLK,
	    	data_in => s_pcadd4register_stage3,
    		data_out => s_pcadd4register_stage4
		);
		
	dmemregisterstage4: register1  
		port map(
			we => '1',
    		reset => '0',
    		clk => iCLK,
	    	data_in => s_DmemOut,
    		data_out => s_aluoutput_stage4
		);
	
	aluoutputregisterstage4: register1 
		port map(
			we => '1',
    		reset => '0',
    		clk => iCLK,
	    	data_in => s_DMemAddr,
    		data_out => s_aluoutput_stage4
		);
	
	bmuxselectregisterstage4: register1  
		generic map(N => 1)	
		port map(
			we => '1',
    		reset => '0',
    		clk => iCLK,
	    	data_in => s_cl_bmuxselect_stage3,
    		data_out => s_cl_bmuxselect_stage4
		);

	jaldatamuxselectregisterstage4: register1  
		generic map(N => 1)
		port map(
			we => '1',
    		reset => '0',
    		clk => iCLK,
	    	data_in => s_cl_jaldatamux_stage3,
    		data_out => s_cl_jaldatamux_stage4
		);

	--EX/MEM

	backwardsmux: mux2t1_N 
    	port map(
			i_S => s_cl_bmuxselect_stage4,
			i_D0 => s_aluoutput_stage4,
			i_D1 => s_aluoutput_stage4,
			o_O => s_bmuxoutput_jaldatamux
		);

  	jaldatamux: mux2t1_N
	    port map(
			i_S => s_cl_jaldatamux_stage4,
			i_D0 => s_bmuxoutput_jaldatamux,
			i_D1 => s_pcadd4register_stage4,
			o_O => s_jaldatamux_writeport
		);

end structure;