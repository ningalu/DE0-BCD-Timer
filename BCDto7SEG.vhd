library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

ENTITY BCDto7SEG IS
    PORT (
        BCD_in: IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        all_off: IN STD_LOGIC;
        LED_out: OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE MUX OF BCDto7SEG IS
BEGIN
    PROCESS (BCD_in, all_off)
    BEGIN
        IF (all_off = '1') THEN 
            LED_out <= "00000000";
        else 
            case BCD_in is 
                WHEN "0000" => LED_out <= "00000011"; --0 
                WHEN "0001" => LED_out <= "10011111"; --1
                WHEN "0010" => LED_out <= "00100101"; --2
                WHEN "0011" => LED_out <= "00001101"; --3
                WHEN "0100" => LED_out <= "10011001"; --4
                WHEN "0101" => LED_out <= "01001001"; --5
                WHEN "0110" => LED_out <= "01000001"; --6
                WHEN "0111" => LED_out <= "00011111"; --7
                WHEN "1000" => LED_out <= "00000001"; --8
                WHEN "1001" => LED_out <= "00001001"; --9
                WHEN OTHERS => LED_out <= "11111111";   
            END CASE;
        END IF; 
    END PROCESS;
END ARCHITECTURE MUX;