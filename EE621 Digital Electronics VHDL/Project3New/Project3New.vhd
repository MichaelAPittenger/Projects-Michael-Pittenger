LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY Project3New IS
    PORT(	KEY	: IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
				LEDR	: OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
				SW		: IN  STD_LOGIC_VECTOR(9 DOWNTO 0);
				HEX0		: OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
				HEX1		: OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
				HEX2		: OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
				HEX3		: OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
				HEX4		: OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
				HEX5		: OUT STD_LOGIC_VECTOR(6 DOWNTO 0));
END Project3New;

ARCHITECTURE Behavior OF Project3New IS

	-- COMPONENTS
	COMPONENT BCD6Bit
		 PORT(	I         	: IN  STD_LOGIC_VECTOR(5 DOWNTO 0);	-- 6-bit input
					Out1, Out0	: OUT STD_LOGIC_VECTOR(3 DOWNTO 0));	-- Two BCD digits
	END COMPONENT;
	
	COMPONENT sevenSeg IS
		PORT(	d0		: IN 	STD_LOGIC_VECTOR(3 DOWNTO 0);
				HEX	: OUT	STD_LOGIC_VECTOR(6 DOWNTO 0));
	END COMPONENT;

   TYPE State_type IS (S0, S5, S10, S15, S20, S25, S30, S35, S40, S45, S50, S55);
	SIGNAL Y     	: State_type;
	 
	-- INPUTS:		START, COIN, BUY, CLOCK
	SIGNAL START	: STD_LOGIC;							-- START/RESET
	SIGNAL COIN		: STD_LOGIC_VECTOR(1 DOWNTO 0);	-- N/D/Q
	SIGNAL BUY		: STD_LOGIC;							-- EVALUATE AT CURRENT BAL
	SIGNAL CLOCK	: STD_LOGIC;							-- CYCLE STATE
	 
	-- OUTPUTS:	NR, DR, REF, REL, UNLATCH
	SIGNAL NR				: STD_LOGIC;							-- NICKEL RETURN
	SIGNAL DR				: STD_LOGIC;							-- DIME RETURN
	SIGNAL REF				: STD_LOGIC;							-- TOTAL REFUND (INSUFFICIENT FUNDS AT BUY)
	SIGNAL REL				: STD_LOGIC;							-- RELEASE COINS
	SIGNAL UNLATCH			: STD_LOGIC;							-- UNLATCH
	SIGNAL LEDR_internal	: STD_LOGIC_VECTOR(9 DOWNTO 0);	-- INTERNAL LED SIGNAL
	 
	-- TRACKING
	SIGNAL BAL		: STD_LOGIC_VECTOR(5 DOWNTO 0);	-- AMOUNT OF CHANGE DEPOSITED
	SIGNAL Nx		: STD_LOGIC_VECTOR(2 DOWNTO 0);	-- # OF NICKELS DEPOSITED
	SIGNAL Dx		: STD_LOGIC_VECTOR(2 DOWNTO 0);	-- # OF DIMES DEPOSITED
	SIGNAL NRx		: STD_LOGIC_VECTOR(2 DOWNTO 0);	-- # OF NICKELS TO REFUND
	SIGNAL DRx		: STD_LOGIC_VECTOR(2 DOWNTO 0);	-- # OF DIMES TO REFUND
	SIGNAL NRx_counter   : INTEGER := 0;  				-- Counter for NRx pulses
	SIGNAL DRx_counter   : INTEGER := 0;  				-- Counter for DRx pulses
	SIGNAL pulse_timer   : INTEGER := 0;  				-- Timer for pulse duration
	SIGNAL pulse_period  : INTEGER := 100000;  		-- Period for LED pulse (adjust for timing)
	SIGNAL EXTRA	: STD_LOGIC_VECTOR(5 DOWNTO 0);	-- AMOUNT OF CHANGE OVER 35
	SIGNAL CHECK	: STD_LOGIC;
	
	SIGNAL A			: STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL B			: STD_LOGIC_VECTOR(2 DOWNTO 0);
	
	-- DISPLAY
	SIGNAL D5, D4, D3, D2, D1, D0		: STD_LOGIC_VECTOR(3 DOWNTO 0);

BEGIN

	PROCESS (START, Clock)
   BEGIN
		IF START = '1' THEN
			Y <= s0;			-- reset state/amount deposited
			Nx <= "000";	-- reset # of nickels
			Dx <= "000";	-- reset # of dimes
			NRx <= "000";
			DRx <= "000";
			REF <= '0';
			REL <= '0';
			UNLATCH <= '0';
			BAL <= "000000";
		ELSIF (Clock'EVENT AND Clock = '1') AND CHECK <= '1' THEN
			CASE Y IS
				WHEN s0 =>
					IF COIN = "00" THEN		-- N -> +5 cents
						Nx <= Nx + 1;
						Y <= s5;
						BAL <= "000101";
					ELSIF COIN = "01" THEN	-- D -> +10 cents
						Dx <= Dx + 1;
						Y <= s10;
						BAL <= "001010";
					ELSIF COIN = "10" THEN	-- Q -> +25 cents
						Y <= s25;
						BAL <= "011001";
					ELSE							-- COIN == '11' -> BUY
						REF <= '1';
					END IF;
				WHEN s5 =>
					IF COIN = "00" THEN		-- N
						Nx <= Nx + 1;
						Y <= s10;
						BAL <= "001010";
					ELSIF COIN = "01" THEN	-- D
						Dx <= Dx + 1;
						Y <= S15;
						BAL <= "001111";
					ELSIF COIN = "10" THEN	-- Q
						Y <= S30;
						BAL <= "011110";
					ELSE							-- BUY
						REF <= '1';
					END IF;
				WHEN s10 =>
					IF COIN = "00" THEN		-- N
						Nx <= Nx + 1;
						Y <= s15;
						BAL <= "001111";
					ELSIF COIN = "01" THEN	-- D
						Dx <= Dx + 1;
						Y <= s20;
						BAL <= "010100";
					ELSIF COIN = "10" THEN	-- Q
						Y <= s35;				-- CORRECT CHANGE
						BAL <= "100011";
					ELSE							-- BUY
						REF <= '1';
						REL <= '1';
						UNLATCH <= '1';
					END IF;
				WHEN s15 =>
					IF COIN = "00" THEN		-- N
						Nx <= Nx + 1;
						Y <= s20;
						BAL <= "010100";
					ELSIF COIN = "01" THEN	-- D
						Dx <= Dx + 1;
						Y <= s25;
						BAL <= "011001";
					ELSIF COIN = "10" THEN	-- Q
						Y <= s40;
						BAL <= "101000";
					ELSE							-- BUY
						REF <= '1';
					END IF;
				WHEN s20 =>
					IF COIN = "00" THEN		-- N
						Nx <= Nx + 1;
						Y <= s25;
						BAL <= "011001";
					ELSIF COIN = "01" THEN	-- D
						Dx <= Dx + 1;
						Y <= s30;
						BAL <= "011110";
					ELSIF COIN = "10" THEN	-- Q
						Y <= s45;
						BAL <= "101101";
					ELSE							-- BUY
						REF <= '1';
					END IF;
				WHEN s25 =>
					IF COIN = "00" THEN		-- N
						Nx <= Nx + 1;
						Y <= s30;
						BAL <= "011110";
					ELSIF COIN = "01" THEN	-- D
						Dx <= Dx + 1;
						Y <= s35;				-- CORRECT CHANGE
						BAL <= "100011";
						REL <= '1';
						UNLATCH <= '1';
					ELSIF COIN = "10" THEN	-- Q
						Y <= s50;
						BAL <= "110010";
					ELSE							-- BUY
						REF <= '1';
					END IF;
				WHEN s30 =>
					IF COIN = "00" THEN		-- N
						Nx <= Nx + 1;
						Y <= s35;				-- CORRECT CHANGE
						BAL <= "100011";
						REL <= '1';
						UNLATCH <= '1';
					ELSIF COIN = "01" THEN	-- D
						Dx <= Dx + 1;
						Y <= s40;
						BAL <= "101000";
					ELSIF COIN = "10" THEN	-- Q
						Y <= s55;
						BAL <= "110111";
					ELSE							-- BUY
						REF <= '1';
					END IF;
				WHEN s35 =>
					CHECK <= '1';
					
				-- 5 OVER BAL, DCHECK IF NICKEL CAN BE REFUNDED
				WHEN s40 =>
					IF (Nx(2) = '1' OR Nx(1) = '1' OR Nx(0) = '1') THEN	-- Nx > 0
						NRx <= NRx + 1;
						NRx_counter <= NRx_counter + 1;
						REL <= '1';
						UNLATCH <= '1';
					ELSE
						REF <= '1';
					END IF;
					CHECK <= '1';
					
				-- 10 OVER BAL, DCHECK IF DIME OR 2 NICKELS CAN BE REFUNDED
				WHEN s45 =>
					EXTRA <= "001010";
					IF (Dx(2) = '1' OR Dx(1) = '1' OR Dx(0) = '1') THEN	-- Dx > 0
						DRx <= DRx + 1;
						DRx_counter <= DRx_counter + 1;
						REL <= '1';
						UNLATCH <= '1';
					ELSIF (Nx(2) = '1' OR Nx(1) = '1') THEN	-- Nx > 1
						NRx <= NRx + 2;
						NRx_counter <= NRx_counter + 2;
						REL <= '1';
						UNLATCH <= '1';
					ELSE
						REF <= '1';
					END IF;
					CHECK <= '1';
					
				-- 15 OVER BAL, DCHECK IF 1 DIME AND 1 NICKEL OR 3 NICKELS CAN BE REFUNDED
				WHEN s50 =>
					EXTRA <= "001111";
					IF (Dx(2) = '1' OR Dx(1) = '1' OR Dx(0) = '1') AND (Nx(2) = '1' OR Nx(1) = '1' OR Nx(0) = '1') THEN	-- Dx > 0 AND Nx > 0
						DRx <= DRx + 1;
						DRx_counter <= DRx_counter + 1;
						NRx <= NRx + 1;
						NRx_counter <= NRx_counter + 1;
						REL <= '1';
						UNLATCH <= '1';
					ELSIF (Nx(2) = '1' OR (Nx(1) = '1' AND Nx(0) = '1')) THEN	-- Nx > 2
						NRx <= NRx + 3;
						NRx_counter <= NRx_counter + 3;
						REL <= '1';
						UNLATCH <= '1';
					ELSE
						REF <= '1';
					END IF;
					CHECK <= '1';
				
				-- 20 OVER BAL, DCHECK IF 2 DIMES OR 1 DIME AND 2 NICKELS OR 4 NICKELS CAN BE REFUNDED
				WHEN s55 =>
					EXTRA <= "010100";
					IF (Dx(2) = '1' OR Dx(1) = '1') THEN	-- Dx > 1
						DRx <= DRx + 2;
						DRx_counter <= DRx_counter + 2;
						REL <= '1';
						UNLATCH <= '1';
					ELSIF (Dx(2) = '1' OR Dx(1) = '1' OR Dx(0) = '1') AND (Nx(2) = '1' OR Nx(1) = '1') THEN	-- Dx > 0 AND Nx > 1
						DRx <= DRx + 1;
						DRx_counter <= DRx_counter + 1;
						NRx <= NRx + 2;
						NRx_counter <= NRx_counter + 2;
						REL <= '1';
						UNLATCH <= '1';
					ELSIF Nx(2) = '1' THEN	-- Nx > 3
						NRx <= NRx + 4;
						NRx_counter <= NRx_counter + 4;
						REL <= '1';
						UNLATCH <= '1';
					ELSE
						REF <= '1';
					END IF;
					CHECK <= '1';
			END CASE;
			
		END IF;

	IF SW(9) = '1' THEN
		A <= Nx;
		B <= Dx;
	ELSE
		A <= NRx;
		B <= DRx;
	END IF;		
	END PROCESS;
	
--	-- Process to pulse LEDs
--	PROCESS (CLOCK)
--	BEGIN
--		 IF CLOCK'EVENT AND CLOCK = '1' AND CHECK <= '1' THEN
--			  -- Pulse logic for LEDR(9) (DRx)
--			  IF DRx_counter > 0 THEN
--					IF pulse_timer = 0 THEN
--						 LEDR_internal(9) <= '1';  -- Turn on LED
--						 pulse_timer <= pulse_period - 1;  -- Set pulse duration
--					ELSE
--						 pulse_timer <= pulse_timer - 1;
--						 IF pulse_timer = 0 THEN
--							  LEDR_internal(9) <= '0';  -- Turn off LED
--							  DRx_counter <= DRx_counter - 1;  -- Decrement counter
--						 END IF;
--					END IF;
--			  END IF;
--
--			  -- Pulse logic for LEDR(8) (NRx)
--			  IF NRx_counter > 0 THEN
--					IF pulse_timer = 0 THEN
--						 LEDR_internal(8) <= '1';  -- Turn on LED
--						 pulse_timer <= pulse_period - 1;  -- Set pulse duration
--					ELSE
--						 pulse_timer <= pulse_timer - 1;
--						 IF pulse_timer = 0 THEN
--							  LEDR_internal(8) <= '0';  -- Turn off LED
--							  NRx_counter <= NRx_counter - 1;  -- Decrement counter
--						 END IF;
--					END IF;
--			  END IF;
--		 END IF;
--	END PROCESS;

	
   START <= NOT KEY(0);
   COIN <= SW(1 DOWNTO 0);
   Clock <= NOT KEY(3);
	 
	LEDR(9 DOWNTO 8) <= LEDR_internal(9 DOWNTO 8);
	LEDR(7) <= REF;
	LEDR(6) <= REL;
	LEDR(5) <= UNLATCH;
	
	--SEVEN SEGMENT DISPLAY
	
	MICHAEL0	: BCD6Bit PORT MAP ("000" & A, D5, D4);
	MICHAEL1	: BCD6Bit PORT MAP ("000" & B, D3, D2);
	MICHAEL2	: BCD6Bit PORT MAP (BAL, D1, D0);
	
	MICHAEL3		: sevenSeg PORT MAP (D5, HEX5);
	MICHAEL4		: sevenSeg PORT MAP (D4, HEX4);
	MICHAEL5		: sevenSeg PORT MAP (D3, HEX3);
	MICHAEL6		: sevenSeg PORT MAP (D2, HEX2);
	MICHAEL7		: sevenSeg PORT MAP (D1, HEX1);
	MICHAEL8		: sevenSeg PORT MAP (D0, HEX0);


END Behavior;