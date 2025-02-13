LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY BCD6Bit IS
    PORT(
        I         : IN  STD_LOGIC_VECTOR(5 DOWNTO 0);  -- 6-bit input
        Out1, Out0 : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)  -- Two BCD digits
    );
END BCD6Bit;

ARCHITECTURE Behavior OF BCD6Bit IS
    SIGNAL temp : INTEGER RANGE 0 TO 63;  -- Temporary signal to hold the integer value of I
BEGIN
    PROCESS(I)
    BEGIN
        -- Convert 6-bit binary input to an integer
        temp <= CONV_INTEGER(I);

        -- Calculate the tens and units place in BCD
        Out1 <= CONV_STD_LOGIC_VECTOR(temp / 10, 4);  -- Tens digit
        Out0 <= CONV_STD_LOGIC_VECTOR(temp MOD 10, 4);  -- Units digit
    END PROCESS;
END Behavior;
