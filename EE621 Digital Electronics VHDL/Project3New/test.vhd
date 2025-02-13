LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY Project3New IS
    PORT(
        KEY   : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
        LEDR  : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
        SW    : IN  STD_LOGIC_VECTOR(9 DOWNTO 0);
        HEX0  : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
        HEX1  : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
        HEX2  : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
        HEX3  : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
        HEX4  : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
        HEX5  : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
    );
END Project3New;

ARCHITECTURE Behavior OF Project3New IS

    -- COMPONENTS
    COMPONENT BCD6Bit
        PORT(
            I      : IN  STD_LOGIC_VECTOR(5 DOWNTO 0);    -- 6-bit input
            Out1, Out0 : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)  -- Two BCD digits
        );
    END COMPONENT;
    
    COMPONENT sevenSeg IS
        PORT(
            d0    : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
            HEX   : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
        );
    END COMPONENT;

    TYPE State_type IS (S0, S5, S10, S15, S20, S25, S30, S35, S40, S45, S50, S55);
    SIGNAL Y       : State_type;
    
    -- INPUTS: START, COIN, BUY, CLOCK
    SIGNAL START   : STD_LOGIC;                           -- START/RESET
    SIGNAL COIN    : STD_LOGIC_VECTOR(1 DOWNTO 0);         -- N/D/Q
    SIGNAL BUY     : STD_LOGIC;                             -- EVALUATE AT CURRENT BAL
    SIGNAL CLOCK   : STD_LOGIC;                             -- CYCLE STATE
    
    -- OUTPUTS: NR, DR, REF, REL, UNLATCH
    SIGNAL NR      : STD_LOGIC;                             -- NICKEL RETURN
    SIGNAL DR      : STD_LOGIC;                             -- DIME RETURN
    SIGNAL REF     : STD_LOGIC;                             -- TOTAL REFUND (INSUFFICIENT FUNDS AT BUY)
    SIGNAL REL     : STD_LOGIC;                             -- RELEASE COINS
    SIGNAL UNLATCH : STD_LOGIC;                             -- UNLATCH
    
    -- TRACKING
    SIGNAL BAL     : STD_LOGIC_VECTOR(5 DOWNTO 0);          -- AMOUNT OF CHANGE DEPOSITED
    SIGNAL Nx      : STD_LOGIC_VECTOR(2 DOWNTO 0);          -- # OF NICKELS DEPOSITED
    SIGNAL Dx      : STD_LOGIC_VECTOR(2 DOWNTO 0);          -- # OF DIMES DEPOSITED
    SIGNAL NRx     : STD_LOGIC_VECTOR(2 DOWNTO 0);          -- # OF NICKELS TO REFUND
    SIGNAL DRx     : STD_LOGIC_VECTOR(2 DOWNTO 0);          -- # OF DIMES TO REFUND
    SIGNAL CHECK   : STD_LOGIC;
    SIGNAL EXTRA   : STD_LOGIC_VECTOR(5 DOWNTO 0);          -- AMOUNT OF CHANGE OVER 35
    
    -- DISPLAY
    SIGNAL D5, D4, D3, D2, D1, D0 : STD_LOGIC_VECTOR(3 DOWNTO 0);

BEGIN

    PROCESS (START, Clock)
    BEGIN
        IF START = '1' THEN
            Y <= S0;            -- reset state/amount deposited
            Nx <= "000";        -- reset # of nickels
            Dx <= "000";        -- reset # of dimes
            REF <= '0';
            REL <= '0';
            UNLATCH <= '0';
            BAL <= "000000";
        ELSIF (Clock'EVENT AND Clock = '1') THEN
            CASE Y IS
                WHEN S0 =>
                    IF COIN = "00" THEN        -- N -> +5 cents
                        Nx <= std_logic_vector(unsigned(Nx) + 1);  -- Use unsigned() for addition
                        Y <= S5;
                        BAL <= "000101";
                    ELSIF COIN = "01" THEN    -- D -> +10 cents
                        Dx <= std_logic_vector(unsigned(Dx) + 1);
                        Y <= S10;
                        BAL <= "001010";
                    ELSE                        -- Q -> +25 cents
                        Y <= S25;
                        BAL <= "011001";
                    END IF;
                WHEN S5 =>
                    IF COIN = "00" THEN        -- N
                        Nx <= std_logic_vector(unsigned(Nx) + 1);
                        Y <= S10;
                        BAL <= "001010";
                    ELSIF COIN = "01" THEN    -- D
                        Dx <= std_logic_vector(unsigned(Dx) + 1);
                        Y <= S15;
                        BAL <= "001111";
                    ELSE                        -- Q
                        Y <= S30;
                        BAL <= "011110";
                    END IF;
                WHEN S10 =>
                    IF COIN = "00" THEN        -- N
                        Nx <= std_logic_vector(unsigned(Nx) + 1);
                        Y <= S15;
                        BAL <= "001111";
                    ELSIF COIN = "01" THEN    -- D
                        Dx <= std_logic_vector(unsigned(Dx) + 1);
                        Y <= S20;
                        BAL <= "010100";
                    ELSE                        -- Q
                        Y <= S35;                -- CORRECT CHANGE
                        BAL <= "100011";
                        REL <= '1';
                        UNLATCH <= '1';
                    END IF;
                WHEN S15 =>
                    IF COIN = "00" THEN        -- N
                        Nx <= std_logic_vector(unsigned(Nx) + 1);
                        Y <= S20;
                        BAL <= "010100";
                    ELSIF COIN = "01" THEN    -- D
                        Dx <= std_logic_vector(unsigned(Dx) + 1);
                        Y <= S25;
                        BAL <= "011001";
                    ELSE                        -- Q
                        Y <= S40;
                        BAL <= "101000";
                    END IF;
                WHEN S20 =>
                    IF COIN = "00" THEN        -- N
                        Nx <= std_logic_vector(unsigned(Nx) + 1);
                        Y <= S25;
                        BAL <= "011001";
                    ELSIF COIN = "01" THEN    -- D
                        Dx <= std_logic_vector(unsigned(Dx) + 1);
                        Y <= S30;
                        BAL <= "011110";
                    ELSE                        -- Q
                        Y <= S45;
                        BAL <= "101101";
                    END IF;
                WHEN S25 =>
                    IF COIN = "00" THEN        -- N
                        Nx <= std_logic_vector(unsigned(Nx) + 1);
                        Y <= S30;
                        BAL <= "011110";
                    ELSIF COIN = "01" THEN    -- D
                        Dx <= std_logic_vector(unsigned(Dx) + 1);
                        Y <= S35;                -- CORRECT CHANGE
                        BAL <= "100011";
                        REL <= '1';
                        UNLATCH <= '1';
                    ELSE                        -- Q
                        Y <= S50;
                        BAL <= "110010";
                    END IF;
                WHEN S30 =>
                    IF COIN = "00" THEN        -- N
                        Nx <= std_logic_vector(unsigned(Nx) + 1);
                        Y <= S35;                -- CORRECT CHANGE
                        BAL <= "100011";
                        REL <= '1';
                        UNLATCH <= '1';
                    ELSIF COIN = "01" THEN    -- D
                        Dx <= std_logic_vector(unsigned(Dx) + 1);
                        Y <= S40;
                        BAL <= "101000";
                    ELSE                        -- Q
                        Y <= S55;
                        BAL <= "110111";
                    END IF;
                WHEN S35 =>
                    -- 5 OVER BAL, CHECK IF NICKEL CAN BE REFUNDED
                WHEN S40 =>
                    IF to_integer(unsigned(Nx)) > 0 THEN
                        NRx <= std_logic_vector(unsigned(NRx) + 1);
                        REL <= '1';
                        UNLATCH <= '1';
                    ELSE
                        REF <= '1';
                    END IF;

                -- 10 OVER BAL, CHECK IF DIME OR 2 NICKELS CAN BE REFUNDED
                WHEN S45 =>
                    EXTRA <= "001010";
                    IF to_integer(unsigned(Dx)) > 0 THEN
                        DRx <= std_logic_vector(unsigned(DRx) + 1);
                        REL <= '1';
                        UNLATCH <= '1';
                    ELSIF to_integer(unsigned(Nx)) > 1 THEN
                        NRx <= std_logic_vector(unsigned(NRx) + 2);
                        REL <= '1';
                        UNLATCH <= '1';
                    ELSE
                        REF <= '1';
                    END IF;

                -- 
