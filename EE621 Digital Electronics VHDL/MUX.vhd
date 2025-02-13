LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY MUX IS
	PORT(	Sel	: IN	STD_LOGIC_VECTOR(1 DOWNTO 0);
			X		: IN	STD_LOGIC_VECTOR(3 DOWNTO 0);
			Y		: OUT	STD_LOGIC);
END MUX;

ARCHITECTURE Structure OF MUX IS

	SIGNAL Y1, Y2, Y3, Y4	: STD_LOGIC;

BEGIN

	Y1 <= X(0) AND NOT Sel(1) AND NOT Sel(0);	-- Sel = 00
	Y2 <= X(1) AND NOT Sel(1) AND Sel(0);		-- Sel = 01
	Y3 <= X(2) AND Sel(1) AND NOT Sel(0);		-- Sel = 10
	Y4 <= X(3) AND Sel(1) AND Sel(0);			-- Sel = 11
	
	Y <= Y1 OR Y2 OR Y3 OR Y4;
	
END Structure;