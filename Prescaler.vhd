library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

ENTITY Prescaler IS
    PORT (
        Clk_In: IN STD_LOGIC;
        Clk_Out: OUT STD_LOGIC := 1;
    );
END ENTITY Timer;

ARCHITECTURE divider OF Prescaler IS
BEGIN
    VARIABLE Count: INTEGER := 0;
    BEGIN
        IF (rising_edge(Clk_In)) THEN
            Count := Count + 1;
            IF (Count > 25000000) THEN
                Clk_Out = NOT Clk_Out;
                Count = 0;
            END IF;
        END IF;
    END PROCESS;

END ARCHITECTURE divider;
