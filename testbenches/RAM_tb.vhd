-- Robert Margelli, 2016

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY RAM_tb IS
END RAM_tb;
 
ARCHITECTURE behavior OF RAM_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT RAM
    PORT(
         clka : IN  std_logic;
         wea : IN  std_logic_vector(0 downto 0);
         addra : IN  std_logic_vector(10 downto 0);
         dina : IN  std_logic_vector(31 downto 0);
         douta : OUT  std_logic_vector(31 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clka : std_logic := '0';
   signal wea : std_logic_vector(0 downto 0) := (others => '0');
   signal addra : std_logic_vector(10 downto 0) := (others => '0');
   signal dina : std_logic_vector(31 downto 0) := (others => '0');

 	--Outputs
   signal douta : std_logic_vector(31 downto 0);

   -- Clock period definitions
   constant clka_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: RAM PORT MAP (
          clka => clka,
          wea => wea,
          addra => addra,
          dina => dina,
          douta => douta
        );

   -- Clock process definitions
   clka_process :process
   begin
		clka <= '0';
		wait for clka_period/2;
		clka <= '1';
		wait for clka_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      wait for clka_period*5;
		addra <= addra + 1;
		      wait for clka_period*5;
		addra <= addra + 1;
				      wait for clka_period*5;
		addra <= addra + 1;
				      wait for clka_period*5;
		addra <= addra + 1;
				      wait for clka_period*5;
		addra <= addra + 1;
				      wait for clka_period*5;
		addra <= (OTHERS => '1');
		

      -- insert stimulus here 

      wait;
   end process;

END;
