-- Robert Margelli, 2016

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY ECU IS
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
END ECU;

ARCHITECTURE OneProcessFSM OF ECU IS
	-- type declarations
	TYPE State_type IS (S0, S1, S2, S3, S4, S5, S6, S7, S8, S8_1, S9, S10, S10_1, S11, S11_1, S12, SEND);
	-- signal declarations
	SIGNAL State: State_type := SEND;
	SIGNAL tmp_sig : STD_LOGIC_VECTOR(31 DOWNTO 0);
	
BEGIN
	-- FSM
	one_proc_FSM: PROCESS(Clock)
			VARIABLE num_faults : INTEGER := 0;	-- used as fault counter and as index in ram
			VARIABLE counter : NATURAL := 0;		-- delay counter
			VARIABLE Addr_int : STD_LOGIC_VECTOR(11 DOWNTO 0);		-- stores ROM address
	BEGIN
		IF(Clock = '1' AND Clock'EVENT) THEN
			IF(Car_power_on = '1') THEN		-- using Car_power_on as synchr. reset signal
				State <= S0;
			ELSE
				CASE State IS
					WHEN S0 =>	-- do initializations
						Ok_status <= '0';
						Fault_status <= '0';
						Debug_port <= (OTHERS => '0');
						WEA <= "0";
						Addr_RAM <= (OTHERS => '0');
						Din_RAM <= (OTHERS => '0');
						A <= (OTHERS => '0');
						B <= (OTHERS => '0');
						Addr_ROM <= (OTHERS => '0');
						Addr_int := (OTHERS => '0');
						num_faults := 0;
						counter := 0;
						State <= S1;			-- start reading from ROM
					WHEN S1 =>	
						IF(Addr_int = "100000000000") THEN
							State <= S7;	-- done reading input patterns, go output log
						ELSE
							State <= S2;
						END IF;
						tmp_sig <= Dout_ROM;	-- sample input pattern (ROM content, first half)
					WHEN S2 =>		-- send input patterns to core
						A <= tmp_sig(15 DOWNTO 0);		
						B <= tmp_sig(31 DOWNTO 16);
						Addr_int := Addr_int + "100000000000";	-- accessing golden ROM	
						Addr_ROM <= Addr_int;
						State <= S3;	
					WHEN S3 =>		-- adds stability
						State <= S4;
					WHEN S4 =>
						tmp_sig <= P;		-- sample core output
						Addr_RAM <= STD_LOGIC_VECTOR(TO_UNSIGNED(num_faults, 11));
						State <= S5;
					WHEN S5 =>
						IF (tmp_sig /= Dout_ROM) THEN	-- fault found: write in RAM and increment fault counter
							WEA <= "1";
							Din_RAM <= Dout_ROM;		-- store erroneous result in RAM
							num_faults := num_faults + 1;		-- keep track of number of faults
						END IF;
						Addr_int := Addr_int - "100000000000" + 1;	-- go back to input patterns ROM
						Addr_ROM <= Addr_int;
						State <= S6;
					WHEN S6 =>
						WEA <= "0";		
						State <= S1;
					WHEN S7 =>		-- done doing comparisons, do output log
						IF (num_faults = 0) THEN	-- no errors from multiplier core
							Ok_status <= '1';
							State <= S8;
						ELSE
							State <= S9;		-- errors in mul core occured
						END IF;
					WHEN S8 =>
						IF(counter = 7496) THEN		-- 50 us: (Tclk = 6.67 ns) -> 7496
							Ok_status <= '0';
							State <= SEND;
						ELSE
							counter := counter + 1;
							State <= S8_1;		-- cycle for 50 us, then we are done
						END IF;
					WHEN S8_1 =>
						counter := counter + 1;
						State <= S8;
					WHEN S9 =>
						Fault_status <= '1';
						Debug_port <= STD_LOGIC_VECTOR(TO_UNSIGNED(num_faults, 32));
						counter := 0;
						State <= S10;
					WHEN S10 =>
						IF(counter = 150) THEN	-- 1 us: (Tclk = 6.67 ns) -> 150
							num_faults := num_faults - 1; -- bring num_faults to num-1 for correct ram addressing
							State <= S11;
						ELSE
							counter := counter + 1;
							State <= S10_1;
						END IF;
					WHEN S10_1 =>
						counter := counter + 1;
						State <= S10;
					WHEN S11 =>
						IF (num_faults >= 0) THEN
							Addr_RAM <= STD_LOGIC_VECTOR(TO_UNSIGNED(num_faults, 11));
							State <= S11_1;
						ELSE
							Fault_status <= '0';
							State <= SEND;
						END IF;
					WHEN S11_1 =>		-- adds stability
						State <= S12;
					WHEN S12 =>
						num_faults := num_faults - 1;
						Debug_port <= Dout_RAM;	
						State <= S11;
					WHEN SEND => 
						State <= SEND;	-- do nothing
					WHEN OTHERS =>	-- safe FSM
						State <= SEND;	-- do nothing
				END CASE;
			
				END IF;
		END IF;
	END PROCESS;

END OneProcessFSM;

