-- Robert Margelli, 2016

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
 
ENTITY STM_tb IS
END STM_tb;
 
ARCHITECTURE behavior OF STM_tb IS 
 
    -- Component Declaration FOR the Unit Under Test (UUT)
    COMPONENT Self_Test_Module
    PORT(
         Clock : IN  STD_LOGIC;
         Car_power_on : IN  STD_LOGIC;
         Ok_status : OUT  STD_LOGIC;
         Fault_status : OUT  STD_LOGIC;
         Debug_port : OUT  STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
    END COMPONENT;
    

   --Inputs
   SIGNAL Clock : STD_LOGIC := '0';
   SIGNAL Car_power_on : STD_LOGIC := '0';

 	--Outputs
   SIGNAL Ok_status : STD_LOGIC;
   SIGNAL Fault_status : STD_LOGIC;
   SIGNAL Debug_port : STD_LOGIC_VECTOR(31 DOWNTO 0);

   -- Clock period definition
   CONSTANT Clock_period : TIME := 6.67 ns;	-- 150 MHz clock SIGNAL
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: Self_Test_Module PORT MAP (
          Clock => Clock,
          Car_power_on => Car_power_on,
          Ok_status => Ok_status,
          Fault_status => Fault_status,
          Debug_port => Debug_port
        );

   -- Clock PROCESS definitions
   Clock_PROCESS :PROCESS
   BEGIN
		Clock <= '0';
		WAIT FOR Clock_period/2;
		Clock <= '1';
		WAIT FOR Clock_period/2;
   END PROCESS;
 

   -- Stimulus PROCESS
   stim_proc: PROCESS
   BEGIN		
		Car_power_on <= '0';
      WAIT FOR 10 ns;	
		Car_power_on <= '1';
		WAIT FOR 2 us;
		Car_power_on <= '0';
      WAIT;
   END PROCESS;

END;
