library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

ENTITY Prescaler IS
    PORT (
        Clk_In: IN STD_LOGIC;
        Clk_Out: OUT STD_LOGIC
    );
END ENTITY Prescaler;

ARCHITECTURE divider OF Prescaler IS
BEGIN
    PROCESS(Clk_In)
        VARIABLE Count: integer;
        VARIABLE iClk_Out: STD_LOGIC := '0';
    BEGIN
        IF (rising_edge(Clk_In)) THEN
            Count := Count + 1;
            IF (Count > 25000000) THEN
                iClk_Out := NOT iClk_Out;
                Count := 0;
            END IF;
            Clk_Out <= iClk_Out;
        END IF;
    END PROCESS;

END ARCHITECTURE divider;
