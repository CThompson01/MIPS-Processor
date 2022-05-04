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

	--used required signals
  signal s_Inst         : std_logic_vector(N-1 downto 0); -- use this signal as the instruction signal 
  signal s_DMemWr       : std_logic; -- use this signal as the final active high data memory write enable signal
  signal s_DMemAddr     : std_logic_vector(N-1 downto 0); -- use this signal as the final data memory address input
  signal s_DMemData     : std_logic_vector(N-1 downto 0); -- use this signal as the final data memory data input
  signal s_DMemOut      : std_logic_vector(N-1 downto 0); -- use this signal as the data memory output
  signal s_IMemAddr     : std_logic_vector(N-1 downto 0); -- Do not assign this signal, assign to s_NextInstAddr instead
  signal s_NextInstAddr : std_logic_vector(N-1 downto 0); -- use this signal as your intended final instruction memory address input.
  signal s_Ovfl         : std_logic;  -- this signal indicates an overflow exception would have been initiated
  signal s_Halt         : std_logic;  -- this signal indicates to the simulation that intended program execution has completed. (Opcode: 01 0100)
  signal s_RegWr        : std_logic; -- use this signal as the final active high write enable input to the register file
  signal s_RegWrAddr    : std_logic_vector(4 downto 0); -- use this signal as the final destination register address input
  signal s_RegWrData    : std_logic_vector(N-1 downto 0); -- use this signal as the final data memory data input

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

  component org2 is
  port(i_A : in std_logic;
	   i_B : in std_logic;
	   o_F : out std_logic);
  end component;

  component register1 is 
  generic (N : integer := N);
  port(we :in std_logic;
       reset :in std_logic; 
       clk :in std_logic;
       data_in :in std_logic_vector(n-1 downto 0);
       data_out :out std_logic_vector(n-1 downto 0));
  end component; 
  
  component mux2t1 is
  port(
		i_D0,i_D1 : in std_logic;
		i_S : in std_logic;
		o_O : out std_logic);
	end component;

--stage1
signal s_pcmux_pc: std_logic_vector(N-1 downto 0); -- signal between pcmux and pc input 
signal s_pcadder_pcmux: std_logic_vector(N-1 downto 0); --pcplus4 signal to pc mux
signal s_orlayer1_orlayer2: std_logic; -- org layer transfer
signal s_orgates_pcmuxselect: std_logic; --org layers output to pcmux select
signal s_imempre_stageinst: std_logic_vector(N-1 downto 0); --imem output to imem register 
signal s_branchbnelogic_pcmux: std_logic_vector(N-1 downto 0); -- branch/bne from andg
signal s_pcadd4register_stage1: std_logic_vector(N-1 downto 0);  --pcadd4 signal stage1

--stage2
signal s_cl_branchbne: std_logic; --control logic output signal 
signal s_cl_jr: std_logic; --control logic output signal 
signal s_cl_j: std_logic; --control logic output signal 
signal s_pcadd4register_stage2: std_logic_vector(N-1 downto 0);  --pcadd4 signal stage2
signal s_cl_jaldatamux_stage2: std_logic_vector(0 downto 0); --jaldatamux select stage2
signal s_cl_jaldatamux: std_logic_vector(0 downto 0); --jaldatamux select cl
signal s_cl_bmuxselect_stage2: std_logic_vector(0 downto 0); --bmuxselect stage2
signal s_cl_bmuxselect: std_logic_vector(0 downto 0); --bmux select
signal s_inst_stage2: std_logic_vector(N-1 downto 0); --instruction stage2
signal s_cl_aluopcode_stage2: std_logic_vector(5 downto 0); --alu op code stage2
signal s_cl_aluopcode: std_logic_vector(5 downto 0); --alu op code 
signal s_extenderoutput: std_logic_vector(N-1 downto 0); --extender component output
signal s_extender_stage2: std_logic_vector(N-1 downto 0); --extender stage2 output
signal s_cl_alusrc: std_logic_vector(0 downto 0); --alusrc cl
signal s_cl_alusrc_stage2: std_logic_vector(0 downto 0); --alusrc stage2
signal s_rd1: std_logic_vector(N-1 downto 0); --rd1 regfile output
signal s_rd1_stage2: std_logic_vector(N-1 downto 0); --rd1 stage2
signal s_rd2_stage2: std_logic_vector(N-1 downto 0); --rd2 stage2 signal
signal s_cl_dmemwrenable: std_logic_vector(0 downto 0); -- dmem write enable
signal s_cl_halt: std_logic_vector(0 downto 0); --halt cl
signal s_branch: std_logic; --branch calculation 
signal s_bne: std_logic; --bne calculation
signal s_cl_extender: std_logic; -- extender cl 
signal s_extshift: std_logic_vector(N-1 downto 0); -- extender output shifted
signal s_inst_shift2: std_logic_vector(N-1 downto 0); --instruction shifted 
signal s_cl_regdst: std_logic; --cl register dst
signal s_regdst_jaldatamux: std_logic_vector(5 downto 0); --regdst to jaldata mux 
signal s_cl_jaldst: std_logic; -- jal dst logic
signal s_cl_btype: std_logic; -- btype cl
signal s_branch_bne: std_logic; -- branchbne mux to andg
signal s_cl_branch: std_logic; -- branch cl 
signal s_branchbne_jump_mux: std_logic_vector(N-1 downto 0); -- connecting signal for 1st and second layer stage2 muxes
signal s_jump_jr_mux: std_logic_vector(N-1 downto 0); -- connecting signal for 2nd and 3rd layer stage2 muxes
signal s_addstage2_branchmux: std_logic_vector(N-1 downto 0); --adding to mux stage 2
signal s_jaldststage2: std_logic_vector(N-1 downto 0); --jal dst 
signal s_regwr_vector: std_logic_vector(0 downto 0);

--stage3
signal s_pcadd4register_stage3: std_logic_vector(N-1 downto 0); --pcadd4 signal stage3
signal s_cl_jaldatamux_stage3: std_logic_vector(0 downto 0); --jaldatacl signal stage3
signal s_cl_bmuxselect_stage3: std_logic_vector(0 downto 0); --bmuxcl signal stage3
signal s_cl_dmemwr_stage3: std_logic_vector(0 downto 0); --dmem signal stage3
signal s_aluouput: std_logic_vector(N-1 downto 0); --aluoutput
signal s_rd2_stage3: std_logic_vector(N-1 downto 0); --rd2 stage3 signal 
signal s_alusrcmux_alu: std_logic_vector(N-1 downto 0); --alusrcmux output to alu
signal s_haltstage3: std_logic_vector(0 downto 0); --halt control signal 
signal s_jaldststage3: std_logic_vector(N-1 downto 0); --jal dst 
signal s_regwrstage3: std_logic_vector(0 downto 0); -- reg wr 

--stage4
signal s_pcadd4register_stage4: std_logic_vector(N-1 downto 0); --pcadd4 signal stage4
signal s_dmemwrfinal: std_logic_vector(0 downto 0); --final singal dmem wr
signal s_cl_jaldatamux_stage4: std_logic_vector(0 downto 0); --jaldatacl signal stage4
signal s_cl_bmuxselect_stage4: std_logic_vector(0 downto 0); --bmuxcl signal stage4
signal s_aluoutput_stage4: std_logic_vector(N-1 downto 0); --aluoutput signal stage4
signal s_dmemoutput_stage4: std_logic_vector(N-1 downto 0); --dmemoutput signal stage4
signal s_haltstage4: std_logic_vector(0 downto 0); --halt control signal 
signal s_jaldststage4: std_logic_vector(N-1 downto 0); --jal dst 
signal s_regwrstage4: std_logic_vector(0 downto 0); -- reg wr 

--stage5
signal s_jaldatamux_writeport: std_logic_vector(N-1 downto 0); --signal for jaldatamux to writeport of register file 
signal s_bmuxoutput_jaldatamux: std_logic_vector(N-1 downto 0); --carry signal between bemux output and jaldata mux input0 
signal s_regwr_fromstage5: std_logic_vector(0 downto 0); --reg wr from stage
signal s_haltstage5: std_logic_vector(0 downto 0); -- final halt

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
	
	orglayer1: org2 
		port map(
			i_A => s_cl_branchbne,
			i_B => s_cl_jr,
			o_F => s_orlayer1_orlayer2
		);

	orglayer2: org2 
		port map(
			i_A => s_orlayer1_orlayer2, 
			i_B => s_cl_j,
			o_F => s_orgates_pcmuxselect
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

	control: controllogic 
		port map(
			opcode => s_Inst(31 downto 26), 
			functcode => s_Inst(5 downto 0),
			ALUsrc => s_cl_alusrc(0),
			ALUcontrol => s_cl_aluopcode,
			MemtoReg => s_cl_bmuxselect(0),
			Branch => s_cl_branch,
			Jump => s_cl_j,
			MemWrite => s_cl_dmemwrenable(0),
			RegWrite => s_regwr_vector(0),
			RegDst => s_cl_regdst,
			extendersel => s_cl_extender,
			datasel => open, 
			jaldst => s_cl_jaldst,
			jaldata => s_cl_jaldatamux(0),
			jr => s_cl_jr,
			halt => s_cl_halt(0),
			btype => s_cl_btype
    	);

	registermux: mux2t1_N
	    generic map(N => 5)
    	port map(
			i_S => s_cl_regdst,
			i_D0 => s_Inst(15 downto 11),
			i_D1 => s_Inst(20 downto 16),
			o_O => s_regdst_jaldatamux
		);

	jaldstmux: mux2t1_N 
    	generic map(N => 5)
		port map(
			i_S => s_cl_jaldst,
			i_D0 => s_regdst_jaldatamux,
			i_D1 => "11111",
			o_O => s_jaldststage2
		);

	immediateextender: extender 
    	port map(
			Imm => s_Inst(15 downto 0),
			s => s_cl_extender,
			out_Imm => s_extenderoutput
		);

	s_extshift <= s_extenderoutput(29 downto 0) & "00";

	addinstage2: full_adder_N 
		port map(
			i0 => s_pcadd4register_stage1,
			i1 => s_extshift,
			cin => '0',
			output => s_addstage2_branchmux,
			overflow => open,
			cout => open
		);

	brancbnemux: mux2t1_N 
    	port map(
			i_S => s_cl_branchbne,
			i_D0 => s_pcadd4register_stage1,
			i_D1 => s_addstage2_branchmux,
			o_O => s_branchbne_jump_mux
		);

	jumpmux: mux2t1_N 
    	port map(
			i_S => s_cl_j,
			i_D0 => s_inst_shift2,
			i_D1 => s_branchbne_jump_mux,
			o_O => s_jump_jr_mux
		);

	jrmux: mux2t1_N  
	    port map(
			i_S => s_cl_jr,
			i_D0 => s_jump_jr_mux,
			i_D1 => s_rd1,
			o_O => s_branchbnelogic_pcmux
		);

	s_inst_shift2 <= s_Inst(25 downto 0) & "00"; 

	andg: andg2 
		port map(
			i_A => s_cl_branch,
			i_B => s_branch_bne,
			o_F => s_cl_branchbne
		);

	regfilemap: registerfile 
    	port map(
			clk => iCLK,
			reset => iRST,
			we => s_regwr_fromstage5(0),
			rs => s_Inst(25 downto 21),
			rt => s_Inst(20 downto 16),
			rd => s_RegWrAddr,
			writeport => s_jaldatamux_writeport,
			readdata1 => s_rd1,
			readdata2 => s_rd2_stage2
		);

	s_RegWr <= s_regwr_fromstage5(0);

	s_bne <= '1' when s_rd1 /= s_rd2_stage2 else '0';

	s_branch <= '1' when s_rd1 = s_rd2_stage2 else '0';
	
	branchbnepreandgmux: mux2t1
    	port map(
			i_S => s_cl_btype,
			i_D0 => s_branch, 
			i_D1 => s_bne, 
			o_O => s_branch_bne
		);

	regwrstage2: register1 
		generic map(N => 1)
		port map(
			we => '1',
			reset => '0',
			clk => iCLK,
			data_in => s_regwr_vector,
			data_out => s_regwrstage3
		);

	haltregisterstage2: register1 
		generic map(N => 1)
		port map(
			we => '1',
			reset => '0',
			clk => iCLK,
			data_in => s_cl_halt,
			data_out => s_haltstage3
		);

	registerdststage2: register1 
		port map(
			we => '1',
			reset => '0',
			clk => iCLK,
			data_in => s_jaldststage2,
			data_out => s_jaldststage3
		);

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
			data_in => s_pcadd4register_stage1,
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

	dmemwriteenablestage2register: register1 
		generic map(N => 1)
		port map(
			we => '1',
			reset => '0',
			clk => iCLK,
			data_in => s_cl_dmemwrenable,
			data_out => s_cl_dmemwr_stage3
		);


	bmuxselectstage2register: register1
	generic map(N => 1)
		port map(
			we => '1',
			reset => '0',
			clk => iCLK,
			data_in => s_cl_bmuxselect,
			data_out => s_cl_bmuxselect_stage2
		);

	jaldatamuxstage2register: register1 
		generic map(N => 1)
		port map(
			we => '1',
			reset => '0',
			clk => iCLK,
			data_in => s_cl_jaldatamux,
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

	oALUout <= s_aluouput;
	
	alusrcmux: mux2t1_N 
    	port map(
			i_S => s_cl_alusrc_stage2(0),
			i_D0 => s_rd2_stage3,
			i_D1 => s_extender_stage2,
			o_O => s_alusrcmux_alu
		);

	haltregisterstage3: register1 
		generic map(N => 1)
		port map(
			we => '1',
			reset => '0',
			clk => iCLK,
			data_in => s_haltstage3,
			data_out => s_haltstage4
		);

	regwrstage3: register1 
		generic map(N => 1)
		port map(
			we => '1',
			reset => '0',
			clk => iCLK,
			data_in => s_regwrstage3,
			data_out => s_regwrstage4
		);

	registerdststage3: register1 
		port map(
			we => '1',
			reset => '0',
			clk => iCLK,
			data_in => s_jaldststage3,
			data_out => s_jaldststage4
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
			data_out => s_dmemwrfinal
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

	s_DmemWr <= s_dmemwrfinal(0);

	DMem: mem
    	generic map(ADDR_WIDTH => ADDR_WIDTH,
                DATA_WIDTH => N)
    	port map(clk  => iCLK,
             addr => s_DMemAddr(11 downto 2),
             data => s_DMemData,
             we   => s_DMemWr,
             q    => s_DMemOut
		);

	s_RegWrData <= s_DMemData;

	regwrstage4: register1 
		generic map(N => 1)
		port map(
			we => '1',
			reset => '0',
			clk => iCLK,
			data_in => s_regwrstage4,
			data_out => s_regwr_fromstage5
		);

	registerdststage4: register1 
		port map(
			we => '1',
			reset => '0',
			clk => iCLK,
			data_in => s_jaldststage4,
			data_out => s_RegWrAddr
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

	haltregisterstage4: register1 
		generic map(N => 1)
		port map(
			we => '1',
			reset => '0',
			clk => iCLK,
			data_in => s_haltstage4,
			data_out => s_haltstage5
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
			i_S => s_cl_bmuxselect_stage4(0),
			i_D0 => s_aluoutput_stage4,
			i_D1 => s_aluoutput_stage4,
			o_O => s_bmuxoutput_jaldatamux
		);

  	jaldatamux: mux2t1_N
	    port map(
			i_S => s_cl_jaldatamux_stage4(0),
			i_D0 => s_bmuxoutput_jaldatamux,
			i_D1 => s_pcadd4register_stage4,
			o_O => s_jaldatamux_writeport
		);

	s_Halt <= s_haltstage5(0);







		

end structure;