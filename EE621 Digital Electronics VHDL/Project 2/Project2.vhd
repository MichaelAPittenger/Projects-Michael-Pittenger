-- Michael Pittenger
-- EE 621, November 26, 2024

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY Project2 IS
    PORT(
        KEY  : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
        LEDR : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
    );
END Project2;

ARCHITECTURE Behavior OF Project2 IS

    TYPE State_type IS (RESET, A, B, C, D, E, F, G, H, I, J, K);
    SIGNAL y       : State_type;
    SIGNAL Resetn  : STD_LOGIC;
    SIGNAL z       : STD_LOGIC;
    SIGNAL w       : STD_LOGIC;
    SIGNAL Clock   : STD_LOGIC;
    
    SIGNAL d0, d1, d2, d3 : STD_LOGIC; -- to carry the w signal across 4 bits

BEGIN
    PROCESS (Resetn, Clock)
    BEGIN
        IF Resetn = '1' THEN
            y <= RESET;
            d0 <= '0';
            d1 <= '0';
            d2 <= '0';
            d3 <= '0';
        ELSIF (Clock'EVENT AND Clock = '1') THEN
            CASE y IS
                WHEN RESET =>
                    IF w = '0' THEN
                        y <= H;
                    ELSE
                        y <= A;
                    END IF;
                WHEN A =>
                    IF w = '0' THEN
                        y <= B;
                    ELSE
                        y <= E;
                    END IF;
                WHEN B =>
                    IF w = '0' THEN
                        y <= C;
                    ELSE
                        y <= A;
                    END IF;
                WHEN C =>
                    IF w = '0' THEN
                        y <= I;
                    ELSE
                        y <= D;
                    END IF;
                WHEN D =>
                    IF w = '0' THEN
                        y <= B;
                    ELSE
                        y <= K;
                    END IF;
                WHEN E =>
                    IF w = '0' THEN
                        y <= B;
                    ELSE
                        y <= F;
                    END IF;
                WHEN F =>
                    IF w = '0' THEN
                        y <= B;
                    ELSE
                        y <= G;
                    END IF;
                WHEN G =>
                    IF w = '0' THEN
                        y <= B;
                    ELSE
                        y <= G;
                    END IF;
                WHEN H =>
                    IF w = '0' THEN
                        y <= I;
                    ELSE
                        y <= A;
                    END IF;
                WHEN I =>
                    IF w = '0' THEN
                        y <= I;
                    ELSE
                        y <= J;
                    END IF;
                WHEN J =>
                    IF w = '0' THEN
                        y <= B;
                    ELSE
                        y <= K;
                    END IF;
                WHEN K =>
                    IF w = '0' THEN
                        y <= B;
                    ELSE
                        y <= F;
                    END IF;
            END CASE;
            
            -- Shift signals
            d3 <= d2;
            d2 <= d1;
            d1 <= d0;
            d0 <= w;
            
        END IF;
    END PROCESS;

    Resetn <= NOT KEY(0);
    w <= NOT KEY(1);
    Clock <= NOT KEY(3);
    
    -- LED output assignments for shifted signals
    LEDR(0) <= d0;
    LEDR(1) <= d1;
    LEDR(2) <= d2;
    LEDR(3) <= d3;

    -- Output z based on certain states
    z <= '1' WHEN (y = D OR y = G OR y = K) ELSE '0';
	 LEDR(5) <= z;

END Behavior;
