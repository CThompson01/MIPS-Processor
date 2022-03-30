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
       oALUOut         : out std_logic_vector(N-1 downto 0)); -- Hook this up to the output of the ALU. It is important for synthesis that you have this output that can effectively be impacted by all other components so they are not optimized away.

end  MIPS_Processor;


architecture structure of MIPS_Processor is

  -- Required data memory signals
  signal s_DMemWr       : std_logic; -- use this signal as the final active high data memory write enable signal
  signal s_DMemAddr     : std_logic_vector(N-1 downto 0); -- use this signal as the final data memory address input
  signal s_DMemData     : std_logic_vector(N-1 downto 0); -- use this signal as the final data memory data input
  signal s_DMemOut      : std_logic_vector(N-1 downto 0); -- use this signal as the data memory output
 
  -- Required register file signals 
  signal s_RegWr        : std_logic; -- use this signal as the final active high write enable input to the register file
  signal s_RegWrAddr    : std_logic_vector(4 downto 0); -- use this signal as the final destination register address input
  signal s_RegWrData    : std_logic_vector(N-1 downto 0); -- use this signal as the final data memory data input

  -- Required instruction memory signals
  signal s_IMemAddr     : std_logic_vector(N-1 downto 0); -- Do not assign this signal, assign to s_NextInstAddr instead
  signal s_NextInstAddr : std_logic_vector(N-1 downto 0); -- use this signal as your intended final instruction memory address input.
  signal s_Inst         : std_logic_vector(N-1 downto 0); -- use this signal as the instruction signal 

  -- Required halt signal -- for simulation
  signal s_Halt         : std_logic;  -- this signal indicates to the simulation that intended program execution has completed. (Opcode: 01 0100)

  -- Required overflow signal -- for overflow exception detection
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
	Imm: in std_logic_vector(N-1 downto 0);
	s: in std_logic;
	out_Imm: out std_logic_vector(N-1 downto 0));
  end component;

  component mux2t1_N is
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
	in_InstrAddress: in std_logic_vector(31 downto 0);
	clk: in std_logic;
	reset: in std_logic;
	out_InstrAddress: out std_logic_vector(31 downto 0));
  end component;

  component full_adder_N is
	port(i0 : in std_logic_vector(N-1 downto 0);
		i1 : in std_logic_vector(N-1 downto 0);
		cin : in std_logic;
		output : out std_logic_vector(N-1 downto 0);
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
	btype: out std_logic); 
  end component;

  component andg2 is 
  port(i_A          : in std_logic;
       i_B          : in std_logic;
       o_F          : out std_logic);
  end component;

signal s_fmux_alub: std_logic_vector(N-1 downto 0); -- forward mux output to alu input b
signal s_extender_fmux: std_logic_vector(N-1 downto 0); -- extender output to forward mux input D1
signal s_bmux_regfile: std_logic_vector(N-1 downto 0); -- b mux to writeport of register file 
signal s_regfile_alua: std_logic_vector(N-1 downto 0); -- register file read data 1 to alu input a

signal s_alu_overflow: std_logic; --overflow from alu
signal s_alu_zero: std_logic; --zero bit from alu
signal s_alu_carryout: std_logic; --carry out bit from alu

signal s_cl_extendersel_extender: std_logic; -- control signal for extender sel
signal s_cl_alusrc_fmux: std_logic; -- control signal for forward mux alu src
signal s_cl_regdst_rmux: std_logic; -- control signal for register mux rdst
signal s_cl_memtoreg_bmux: std_logic; -- control signal for backwards mux memtoreg
signal s_cl_halt: std_logic; -- control signal from control logic for halt instruction 

signal s_cl_alucontrol: std_logic_vector(5 downto 0); --alu control bits

signal s_inst_shift2: std_logic_vector(N-1 downto 0); --shifting s_Inst for jump mux
signal s_extshift: std_logic_vector(N-1 downto 0); -- shifting extender 2 for left adder

signal s_bnemux_output: std_logic; --output for the mux from which bne is calculated
signal s_and_branchmux: std_logic; --and output to the branch mux select
-- jump and branch signals
signal s_ctl_jump: std_logic; -- jump output from control logic
signal s_ctl_branch: std_logic; -- branch output from control logic
signal s_cl_btype: std_logic; -- bne select from control logic

signal s_jab_add4: std_logic_vector(N-1 downto 0); -- address from add 4 logic
signal s_jab_add4cout: std_logic; -- cout from address add 4 logic

signal s_jab_shiftadd: std_logic_vector(N-1 downto 0); -- address from shift 2 and add logic
signal s_jab_shiftaddcout: std_logic; -- cout from address shift 2 and add logic

signal s_jab_branchAddr: std_logic_vector(N-1 downto 0); -- address output from should branch mux
signal s_outInstAddr: std_logic_vector(N-1 downto 0); -- address output from should jump mux

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
             q    => s_Inst);
  
  DMem: mem
    generic map(ADDR_WIDTH => ADDR_WIDTH,
                DATA_WIDTH => N)
    port map(clk  => iCLK,
             addr => s_DMemAddr(11 downto 2),
             data => s_DMemData,
             we   => s_DMemWr,
             q    => s_DMemOut);

  regfilemap: registerfile 
    port map(
	clk => iCLK,
	reset => iRST,
	we => s_RegWr,
	rs => s_Inst(25 downto 21);
	rt => s_Inst(20 downto 16);
	rd => s_RegWrAddr,
	writeport => s_bmux_regfile,
	readdata1 => s_regfile_alua,
	readdata2 => s_DMemData 
	);

  registermux: mux2t1_N
    generic map(N => 5)
    port map(
	i_S => s_cl_regdst_rmux,
	i_D0 => s_Inst(20 downto 16);
	i_D1 => s_Inst(15 downto 11);
	o_O => s_RegWrAddr
	);

  forwardsmux: mux2t1_N 
    port map(
	i_S => s_cl_alusrc_fmux,
	i_D0 => s_DMemData,
	i_D1 =>s_extender_fmux,
	o_O => s_fmux_alub
	);

  backwardsmux: mux2t1_N
    port map(
	i_S => s_cl_memtoreg_bmux,
	i_D0 => s_DMemAddr,
	i_D1 => s_Dmem_out,
	o_O => s_bmux_regfile
	);

  immediateextender: extender
    port map(
	Imm => s_Inst(15 downto 0),
	s => s_cl_extendersel_extender,
	out_Imm => s_extender_fmux
	);

  alu:ALU 
    port map(
	read_data_1 => s_regfile_alua,
	read_data_2 => s_fmux_alub,
	alu_control => s_cl_alucontrol,
	shampt => s_Inst(10 downto 6),
	output => s_DMemAddr,
	overflow => s_alu_overflow,
	carryout => s_alu_carryout,
	zero => s_alu_zero
    );

  pc:programcounter
    port map(
	i_InstrAddress => s_outInstAddr, 
	i_clk => iCLK,
	i_reset => iRST,
	o_InstrAddress => s_NextInstAddr 
	);

  pcadd4: full_adder_N
  	port map(
	i0 => s_NextInstAddr,
	i1 => x"4",
	cin => '0',
	output => s_jab_add4,
	cout => s_jab_add4cout
	);
	
  addaftershift: full_adder
	port map(
	i0 => s_jab_add4cout,
	i1 => s_extshift,
	cin => '0',
	output => s_jab_shiftadd,
	cout => s_jab_shiftaddcout
	);

  branchmux: mux2t1_N
	port map(
	i_S => s_and_branchmux,
	i_D0 => s_jab_add4,
	i_D1 => s_jab_shiftadd,
	o_O => s_jab_branchAddr
	);

  jumpmux: mux2t1_N
	port map(
	i_S => s_ctl_jump,
	i_D0 => s_jab_branchAddr,
	i_D1 => s_jab_jumpShift, 
	o_O => s_outInstAddr
	);

   bne: mux2t1_N
   generic map(N => 1)
	port map(
	i_S => s_cl_btype,
	i_D0 => not(s_alu_zero),
	i_D1 => s_alu_zero,
	o_O => s_bnemux_output
	);

   andg: andg2
	port map(
	i_A => s_ctl_branch,
	i_B => s_bnemux_output,
	o_F => s_and_branchmux
	);
  
   s_inst_shift2 <= s_Inst & "00";
   s_extshift <= s_extender_fmux & "00";

   control: controllogic
	port map(
	opcode => s_Inst(31 downto 26),
	functcode => s_Inst(5 downto 0),
	ALUsrc => s_cl_alusrc_fmux,
	ALUcontrol => s_cl_alucontrol,
	MemtoReg => s_cl_memtoreg_bmux,
	Branch => s_ctl_branch,
	Jump => s_ctl_jump,
	MemWrite => s_DMemWr,
	RegWrite => s_RegWr,
	RegDst => s_cl_regdst_rmux,
	extendersel => s_cl_extendersel_extender,
	datasel => --wtf are these 
	btype => s_cl_btype
        );

	s_RegWrData <= --TODO
		
	s_IMemAddr <= --TODO
	
	s_Halt <= s_cl_halt; 
	
	s_Ovfl <= s_alu_overflow;

	oALUout <= s_DMemAddr;

end structure;

