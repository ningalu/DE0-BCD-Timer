LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.numeric_std.ALL;

ENTITY TimerBench IS
END ENTITY TimerBench;

Architecture Test OF TimerBench IS
    SIGNAL t_Data_In: STD_LOGIC_VECTOR(9 DOWNTO 0);
    SIGNAL t_tClk, t_tStart: STD_LOGIC;
    SIGNAL t_Time_Out: STD_LOGIC;
    COMPONENT Timer IS
        PORT (
            Data_In: IN STD_LOGIC_VECTOR(9 DOWNTO 0);
            tClk, tStart: IN STD_LOGIC;
            Time_Out: OUT STD_LOGIC
        );
    END COMPONENT;
BEGIN
    DUT: Timer Port Map (Data_In => t_Data_In, tClk => t_tClk, tStart => t_tStart, Time_Out => t_Time_Out);

    clk_gen: PROCESS
    BEGIN
        t_tClk <= '1';
        WAIT FOR 5 ns;
        t_tClk <= '0';
        WAIT FOR 5 ns;
    END PROCESS clk_gen;

    start_gen: PROCESS
    BEGIN
        t_tStart <= '1';
    END PROCESS start_gen;
END ARCHITECTURE Test;