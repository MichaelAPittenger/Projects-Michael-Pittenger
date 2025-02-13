LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY BCD IS
	PORT(	I				: IN	STD_LOGIC_VECTOR(3 DOWNTO 0);
			Out1, Out0	: OUT	STD_LOGIC_VECTOR(3 DOWNTO 0));
END BCD;

ARCHITECTURE Structure OF BCD IS

	SIGNAL C : STD_LOGIC;

BEGIN

	C <= (I(3) AND I(1)) OR (I(3) AND I(2));
	
	Out1(0) <= C;
	
	Out0(3) <= (NOT C AND I(3)) OR (C AND (NOT C));
	Out0(2) <= (NOT C AND I(2)) OR (C AND (I(2) AND I(1)));
	Out0(1) <= (NOT C AND I(1)) OR (C AND (NOT I(1)));
	Out0(0) <= (NOT C AND I(0)) OR (C AND (I(0)));
END Structure;