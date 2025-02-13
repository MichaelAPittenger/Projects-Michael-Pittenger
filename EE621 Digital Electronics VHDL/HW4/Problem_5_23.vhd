LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY Problem_5_23 IS
   PORT (	X		: IN    STD_LOGIC_VECTOR(7 DOWNTO 0);
				Y		: OUT   STD_LOGIC_VECTOR(3 DOWNTO 0));
END Problem_5_23;

ARCHITECTURE Structure OF Problem_5_23 IS

	COMPONENT fulladd IS
		PORT(	Cin, x, y	: IN	STD_LOGIC;
				s, Cout		: OUT	STD_LOGIC);
	END COMPONENT;
	
	COMPONENT adder2 IS
		PORT (	Cin    			: IN    STD_LOGIC;
					X3, X2, X1, X0	: IN    STD_LOGIC_VECTOR(1 DOWNTO 0);
					Y1, Y0			: OUT   STD_LOGIC;
					Cout				: OUT   STD_LOGIC);
	END COMPONENT;
	
	--STAGE0
	SIGNAL C0_12, C0_345, C0_67 : STD_LOGIC;
	SIGNAL S0_12, S0_345, S0_67 : STD_LOGIC;
	--STAGE1
	SIGNAL C1						: STD_LOGIC;
	SIGNAL S1_1, S1_0				: STD_LOGIC;
	--STAGE2
	SIGNAL C2						: STD_LOGIC;
	SIGNAL S2_1, S2_0				: STD_LOGIC;
	 
BEGIN

	--STAGE0
	HW4_0: fulladd PORT MAP (X(0), X(1), X(2), S0_12, C0_12);
	HW4_1: fulladd PORT MAP (X(3), X(4), X(5), S0_345, C0_345);
	S0_76 <= X(6) XOR X(7); --HALF ADDER
	C0_76 <= X(6) AND X(7);
	
	--STAGE1
	HW4_2: adder2 PORT MAP (S0_12, C0_345, S0_67, C0_12, S0_345, S1_1, S1_0, C1);
	
	--STAGE2
	HW4_3: adder2 PORT MAP ('0', '0', C0_67, C1, S1_1, S2_1, S2_0, C2);
	
	Y(0) <= S1_0;
	Y(1) <= S2_0;
	Y(2) <= S2_1;
	Y(3) <= C2;
	 
END Structure;
