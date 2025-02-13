LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY sevenSeg IS
	PORT(	d0		: IN 	STD_LOGIC_VECTOR(3 DOWNTO 0);
			HEX	: OUT	STD_LOGIC_VECTOR(6 DOWNTO 0));
END sevenSeg;

ARCHITECTURE Structure OF sevenSeg IS
BEGIN
	HEX(0) <= (NOT d0(3) AND NOT d0(2) AND NOT d0(1) AND d0(0)) OR (d0(2) AND NOT d0(1) AND NOT d0(0));
	HEX(1) <= (d0(2) AND NOT d0(1) AND d0(0)) OR (d0(2) AND d0(1) AND NOT d0(0));
	HEX(2) <= (NOT d0(2) AND d0(1) AND NOT d0(0));
	HEX(3) <= (NOT d0(3) AND NOT d0(2) AND NOT d0(1) AND d0(0)) OR (d0(2) AND NOT d0(1) AND NOT d0(0)) OR (d0(2) AND d0(1) AND d0(0));
	HEX(4) <= d0(0) OR (d0(2) AND NOT d0(1));
	HEX(5) <= (NOT d0(3) AND NOT d0(2) AND d0(0)) OR (NOT d0(2) AND d0(1)) OR (d0(1) AND d0(0));
	HEX(6) <= (NOT d0(3) AND NOT d0(2) AND NOT d0(1)) OR (d0(2) AND d0(1) AND d0(0));
END Structure;