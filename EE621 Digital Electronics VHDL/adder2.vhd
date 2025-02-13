LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY adder2 IS
   PORT (	Cin    			: IN    STD_LOGIC;
				X3, X2, X1, X0	: IN    STD_LOGIC_VECTOR(1 DOWNTO 0);
				Y1, Y0			: OUT   STD_LOGIC;
				Cout				: OUT   STD_LOGIC);
END adder2;

ARCHITECTURE Structure OF adder2 IS

	COMPONENT fulladd
		PORT(	Cin, x, y	: IN	STD_LOGIC;
				s, Cout		: OUT STD_LOGIC);
	END COMPONENT;

   SIGNAL Carry : STD_LOGIC;
	 
BEGIN

   stage0: fulladd PORT MAP ( Cin, X3, X1, Y0, Carry);
   stage1: fulladd PORT MAP ( Carry, X2, X0, Y1, Cout);
	 
END Structure;