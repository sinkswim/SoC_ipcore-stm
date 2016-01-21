library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

ENTITY Self_Test_Module IS
	PORT(
		Clock : IN STD_LOGIC;
		Car_power_on : IN STD_LOGIC;
		Ok_status : OUT STD_LOGIC;
		Fault_status : OUT STD_LOGIC;
		Debug_port : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END Self_Test_Module;

ARCHITECTURE Behavioral OF Self_Test_Module IS

-- Component declarations
COMPONENT RAM
  PORT (
	 clka : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  );
END COMPONENT;

COMPONENT ROM
	PORT(
    clka : IN STD_LOGIC;
    addra : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	 );
END COMPONENT;

COMPONENT ECU
	PORT(
	Clock: IN STD_LOGIC;
	Car_power_on: IN STD_LOGIC;
	-- log lines
	Ok_status: OUT STD_LOGIC;
	Fault_status: OUT STD_LOGIC;
	Debug_port: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
	-- RAM lines
	WEA: OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
	Addr_RAM: OUT STD_LOGIC_VECTOR(10 DOWNTO 0);	-- 2048 words
	Dout_RAM: IN STD_LOGIC_VECTOR(31 DOWNTO 0);	-- receive data from RAM
	Din_RAM: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);	-- put data in RAM
	-- ROM lines
	Addr_ROM: OUT STD_LOGIC_VECTOR(11 DOWNTO 0);		-- 4096 words
	Dout_ROM: IN STD_LOGIC_VECTOR(31 DOWNTO 0);	-- receive data from ROM
	-- multiplier core lines
	A: OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
	B: OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
	P: IN STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT multiplier
  PORT (
    clk : IN STD_LOGIC;
    a : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    b : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    p : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  );
END COMPONENT;

-- Signal declarations
-- RAM
SIGNAL WEA : STD_LOGIC_VECTOR(0 DOWNTO 0);
SIGNAL Addr_RAM : STD_LOGIC_VECTOR(10 DOWNTO 0);
SIGNAL Din_RAM : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL Dout_RAM : STD_LOGIC_VECTOR(31 DOWNTO 0);
-- ROM
SIGNAL Addr_ROM : STD_LOGIC_VECTOR(11 DOWNTO 0);
SIGNAL Dout_ROM : STD_LOGIC_VECTOR(31 DOWNTO 0);
-- multiplier
SIGNAL A : STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL B : STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL P : STD_LOGIC_VECTOR(31 DOWNTO 0);

BEGIN
-- Component instantiations
ram_ut:	RAM PORT MAP(Clock, WEA, Addr_RAM, Din_RAM, Dout_RAM);
rom_ut:	ROM PORT MAP(Clock, Addr_ROM, Dout_ROM);
ecu_ut:	ECU PORT MAP(Clock, Car_power_on, Ok_status, Fault_status, Debug_port, 
								WEA, Addr_RAM, Dout_RAM, Din_RAM, 
								Addr_ROM, Dout_ROM,
								A, B, P);
multiplier_ut:	multiplier PORT MAP(Clock, A, B, P);
END Behavioral;

