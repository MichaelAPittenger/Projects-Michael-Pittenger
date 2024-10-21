library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;  -- Correct package for to_unsigned

ENTITY adder4_TB IS
END adder4_TB;

ARCHITECTURE behavior OF adder4_TB IS 

    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT adder4
    PORT(
        Cin  : IN  STD_LOGIC;
        X    : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
        Y    : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
        S    : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        Cout : OUT STD_LOGIC
    );
    END COMPONENT;

   -- Signals for simulation
   SIGNAL Cin  : STD_LOGIC := '0';
   SIGNAL X    : STD_LOGIC_VECTOR(3 DOWNTO 0) := (others => '0');
   SIGNAL Y    : STD_LOGIC_VECTOR(3 DOWNTO 0) := (others => '0');
   SIGNAL S    : STD_LOGIC_VECTOR(3 DOWNTO 0);
   SIGNAL Cout : STD_LOGIC;

BEGIN

    -- Instantiate the Unit Under Test (UUT)
    uut: adder4 PORT MAP (
          Cin => Cin,
          X => X,
          Y => Y,
          S => S,
          Cout => Cout
        );

    -- Stimulus process to generate all possible combinations
    stim_proc: PROCESS
    BEGIN	
        -- Loop through all possible values of X, Y, and Cin
        FOR Cin_val IN 0 TO 1 LOOP
            Cin <= std_logic'val(Cin_val);
            FOR X_val IN 0 TO 15 LOOP
                X <= std_logic_vector(to_unsigned(X_val, 4));  -- Convert integer to 4-bit vector
                FOR Y_val IN 0 TO 15 LOOP
                    Y <= std_logic_vector(to_unsigned(Y_val, 4));  -- Convert integer to 4-bit vector
                    WAIT FOR 10 ns;  -- Wait for 10 ns between each test case
                END LOOP;
            END LOOP;
        END LOOP;

        -- Stop the simulation after all test cases are covered
        WAIT;
    END PROCESS;

END behavior;
