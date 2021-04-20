LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.numeric_std.ALL;

ENTITY BCDBench IS
END ENTITY BCDBench;

ARCHITECTURE Test OF BCDBench IS
    SIGNAL t_Clk, t_Direction, t_Init, t_Enable : std_logic;
    SIGNAL t_Q: std_logic_vector(0 to 3);
    COMPONENT BCD IS
        PORT (
        Clk, Direction, Init, Enable: IN std_logic;
        Q: OUT std_logic_VECTOR(0 TO 3)
        );
    end component;
begin
    DUT: BCD port map (Clk => t_Clk, Direction => t_Direction, Init => t_Init, Enable => t_Enable, Q => t_Q);
    init: process
    begin
    -- reset pulse
        wait;
    end process init;
    -- clock generation
    clk_gen: process
    begin
        t_clk <= '1';
        wait for 5 ns;
        t_clk <= '0';
        wait for 5 ns;
    end process clk_gen;
    
    direction_gen: process
    begin
        t_direction <= '0';
        wait for 200 ns;
        t_direction <= '1';
        wait for 200 ns;
 
    end process direction_gen; 

    init_gen: process
    begin
        t_init <= '0';
        wait for 400 ns;
        t_init <= '1';
        wait for 400 ns;
    end process init_gen;

    enable_gen: process
    begin
        t_enable <= '1';
        wait for 800 ns;
        t_enable <= '0';
        wait for 800 ns;
    end process enable_gen;

end architecture Test;

