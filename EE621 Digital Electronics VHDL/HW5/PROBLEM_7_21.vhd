LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY PROBLEM_7_21 IS
	PORT(	clk		: IN	STD_LOGIC;
			reset		: IN	STD_LOGIC;
			up_down	: IN 	STD_LOGIC;
			load		: IN	STD_LOGIC;
			data_in	: IN	STD_LOGIC_VECTOR(23 DOWNTO 0);
			Q			: OUT	STD_LOGIC_VECTOR(23 DOWNTO 0));
END PROBLEM_7_21;

ARCHITECTURE BEHAVIORAL OF PROBLEM_7_21 IS

	SIGNAL count : STD_LOGIC_VECTOR(23 DOWNTO 0);

BEGIN

	PROCESS(clk, reset)
	BEGIN
		IF reset = '1' THEN
			count <= (other => '0');
		ELSIF RISING_EDGE(clk) THEN
			IF load = '1' THEN
				count <= data_in;
			ELSIF up_down = '0' THEN
				count <= count + 1;
			ELSE
				count <= count - 1;
			END IF;
		END IF;
	END PROCESS;
	
	Q <= count;

END BEHAVIORAL;