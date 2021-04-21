library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

ENTITY BCD IS 
    PORT (
        Clk, Direction, Init, Enable: IN STD_LOGIC;
        Q: OUT STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000"
    );
END ENTITY BCD;

ARCHITECTURE COUNTER OF BCD IS
BEGIN
    increment: PROCESS(Clk)
    VARIABLE iQ: STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000";
    BEGIN
        IF (rising_edge(Clk)) THEN
            IF (Enable = '1') THEN
                IF (Direction = '1') THEN
                    IF (Init = '1') THEN
                        iQ := "0000";
                    ELSE
                        iQ := iQ + "1";
                        IF (iQ > "1001") THEN
                            iQ := "0000";
                        END IF;
                    END IF;
                ELSIF (Direction = '0') THEN
                    IF (Init = '1') THEN
                        iQ := "1001";
                    ELSE
                        iQ := iQ - "0001";
                        IF (iQ > "1001") THEN
                            iQ := "1001";
                        END IF;
                    END IF;
                END IF;
            END IF;
            Q <= iQ;
        END IF;
        
    END PROCESS increment;
END ARCHITECTURE COUNTER;