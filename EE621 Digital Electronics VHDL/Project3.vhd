LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY Project3 IS
    PORT(	KEY	: IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
				LEDR	: OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
				SW		: IN  STD_LOGIC_VECTOR(9 DOWNTO 0);
				HEX0		: OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
				HEX1		: OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
				HEX2		: OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
				HEX3		: OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
				HEX4		: OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
				HEX5		: OUT STD_LOGIC_VECTOR(6 DOWNTO 0));
END Project3;

ARCHITECTURE Behavior OF Project3 IS

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
	SIGNAL NR			: STD_LOGIC;						-- NICKEL RETURN
	SIGNAL DR			: STD_LOGIC;						-- DIME RETURN
	SIGNAL REF			: STD_LOGIC;						-- TOTAL REFUND (INSUFFICIENT FUNDS AT BUY)
	SIGNAL REL			: STD_LOGIC;						-- RELEASE COINS
	SIGNAL UNLATCH		: STD_LOGIC;						-- UNLATCH
	 
	-- TRACKING
	SIGNAL BAL		: STD_LOGIC_VECTOR(5 DOWNTO 0);	-- AMOUNT OF CHANGE DEPOSITED
	SIGNAL Nx		: STD_LOGIC_VECTOR(2 DOWNTO 0);	-- # OF NICKELS DEPOSITED
	SIGNAL Dx		: STD_LOGIC_VECTOR(1 DOWNTO 0);	-- # OF DIMES DEPOSITED
	
	-- DISPLAY
	SIGNAL D5, D4, D3, D2, D1, D0		: STD_LOGIC_VECTOR(3 DOWNTO 0);

BEGIN

	PROCESS (START, Clock)
   BEGIN
		IF START = '1' THEN
			Y <= s0;			-- reset state/amount deposited
			Nx <= "000";	-- reset # of nickels
			Dx <= "00";		-- reset # of dimes
		ELSIF (Clock'EVENT AND Clock = '1') THEN
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
					ELSE							-- Q -> +25 cents
						Y <= s25;
						BAL <= "011001";
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
					ELSE							-- Q
						Y <= S30;
						BAL <= "011110";
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
					ELSE							-- Q
						Y <= s35;				-- CORRECT CHANGE
						BAL <= "100011";
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
					ELSE							-- Q
						Y <= s40;
						BAL <= "101000";
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
					ELSE							-- Q
						Y <= s45;
						BAL <= "101101";
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
					ELSE							-- Q
						Y <= s50;
						BAL <= "110010";
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
					ELSE							-- Q
						Y <= s55;
						BAL <= "110111";
					END IF;
				WHEN s35 =>

				WHEN s40 =>

				WHEN s45 =>

				WHEN s50 =>

				WHEN s55 =>
			END CASE;
		END IF;		
	END PROCESS;
	
	MICHAEL0		: BCD6Bit PORT MAP (BAL, D1, D0);
	
	MICHAEL1		: sevenSeg PORT MAP (D1, HEX1);
	MICHAEL2		: sevenSeg PORT MAP (D0, HEX0);
	
   START <= NOT KEY(0);
   COIN <= SW(2 DOWNTO 1);
   Clock <= NOT KEY(3);

END Behavior;