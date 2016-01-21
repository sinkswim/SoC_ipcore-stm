-- Robert Margelli, 2016

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;
USE std.textio.all;
USE ieee.std_logic_textio.all;
 
ENTITY tb_multiplier IS
END tb_multiplier;
 
ARCHITECTURE behavior OF tb_multiplier IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT multiplier
    PORT(
         clk : IN  std_logic;
         a : IN  std_logic_vector(15 downto 0);
         b : IN  std_logic_vector(15 downto 0);
         p : OUT  std_logic_vector(31 downto 0)
        );
    END COMPONENT;
	 
-- function to convert vector to string
FUNCTION vec2str(vec : std_logic_vector) RETURN string IS
	VARIABLE stmp : string(vec'LEFT+1 DOWNTO 1);
	BEGIN
		FOR i IN vec'REVERSE_RANGE LOOP
			IF vec(i) = '1' THEN
			stmp(i+1) := '1';
			ELSIF vec(i) = '0' THEN
			stmp(i+1) := '0';
			ELSE
			stmp(i+1) := 'X';
			END IF;
		END LOOP;
		RETURN stmp;
END vec2str;
    

   --Inputs
   signal clk : std_logic := '0';
   signal a : std_logic_vector(15 downto 0) := (others => '0');
   signal b : std_logic_vector(15 downto 0) := (others => '0');

 	--Outputs
   signal p : std_logic_vector(31 downto 0);

   -- Clock period definitions
   constant clk_period : time := 6.67 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: multiplier PORT MAP (
          clk => clk,
          a => a,
          b => b,
          p => p
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
	FILE  datafile: TEXT;
	variable line1: LINE;
	begin		
		  FILE_OPEN(datafile,"data_stimuli.txt",WRITE_MODE);
		  wait for clk_period;
		  
		  for i in 0 to 2047 loop	-- first write input patterns in first half of rom
				a <= a + 1;
				b <= b + 1;
				wait for clk_period;		
				write(line1,vec2str(a) & vec2str(b) & ",");
				writeline(datafile,line1); 		
		 end loop;
		 
		 a <= (others => '0');
		 b <= (others => '0');
		 wait for clk_period;
			
		for i in 0 to 2047 loop		-- then write golden output patterns in second half
			a <= a + 1;
			b <= b + 1;
			wait for clk_period;			
			write(line1,vec2str(p) & ",");
			writeline(datafile,line1); 		
		end loop;
	 

		wait;
   end process;

END;
