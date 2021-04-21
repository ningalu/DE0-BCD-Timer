library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

ENTITY Timer IS
    PORT (
        Data_In: IN STD_LOGIC_VECTOR(9 DOWNTO 0);
        tClk, tStart: IN STD_LOGIC;
        Time_Out: OUT STD_LOGIC;
        Count, Count1: OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
    );
END ENTITY Timer;

ARCHITECTURE Counters OF Timer IS

    SIGNAL iDirection, iall_off: STD_LOGIC;

    SIGNAL mInit, mEnable: STD_LOGIC;
    SIGNAL suInit, suEnable: STD_LOGIC;
    SIGNAL slInit, slEnable: STD_LOGIC;

    SIGNAL mQ, suQ, slQ: STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL mLED_out, suLED_out, slLED_out: STD_LOGIC_VECTOR(7 DOWNTO 0);

    COMPONENT BCD IS
        PORT (
            Clk, Direction, Init, Enable: IN std_logic;
            Q: OUT std_logic_VECTOR(3 DOWNTO 0)
        );
    END COMPONENT;
    COMPONENT BCDto7SEG IS 
        PORT (
            BCD_in: IN STD_LOGIC_VECTOR(3 DOWNTO 0);
            all_off: IN STD_LOGIC;
            LED_out: OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
        );
    END COMPONENT;
BEGIN

    mBCD: BCD PORT MAP (Clk => tClk, Direction => iDirection, Init => mInit, Enable => mEnable, Q => mQ);
    suBCD: BCD PORT MAP (Clk => tClk, Direction => iDirection, Init => suInit, Enable => suEnable, Q => suQ);
    slBCD: BCD PORT MAP (Clk => tClk, Direction => iDirection, Init => slInit, Enable => slEnable, Q => slQ);
    mCon: BCDto7SEG PORT MAP(BCD_in => mQ, all_off => iall_off, LED_out => mLED_out);
    suCon: BCDto7SEG PORT MAP(BCD_in => suQ, all_off => iall_off, LED_out => suLED_out);
    slCon: BCDto7SEG PORT MAP(BCD_in => slQ, all_off => iall_off, LED_out => slLED_out);

    PROCESS(tStart, tClk)
    VARIABLE mCount: STD_LOGIC_VECTOR(9 DOWNTO 0);
    VARIABLE suData, slData: STD_LOGIC_VECTOR(3 DOWNTO 0);
    VARIABLE mData: STD_LOGIC_VECTOR(1 DOWNTO 0);
    BEGIN
        IF (tStart = '1') THEN
            iDirection <= '1';
            slInit <= '0';
            slEnable <= '1';
            IF (slQ = "1001") THEN

                suEnable <= '1';

                IF (suQ = "0101") THEN
                    suInit <= '1';
                    mEnable <= '1';
                ELSE
                    suInit <= '0';
                    mEnable <= '0';
                END IF;

            ELSE
                mEnable <= '0';
                suEnable <= '0';
            
            END IF;
        ELSE
            mInit <= '1';
            suInit <= '1';
            slInit <= '1';
            Time_Out <= '1';
        END IF;
        
        mCount(9 DOWNTO 8) := mQ(1 DOWNTO 0); 
        mCount(7 DOWNTO 4) := suQ;
        mCOUNT (3 DOWNTO 0) := slQ;
        mData := Data_In(9 DOWNTO 8);
        suData := Data_In(7 DOWNTO 4);
        slData := Data_In(3 DOWNTO 0);
        
        --IF (slQ = "0000") THEN

        COUNT <= Data_In - mCount - "0010100110";
        --COUNT <= (mData(1 DOWNTO 0) - mQ(1 DOWNTO 0)) & (suData - suQ - "0010") & (slData - slQ - "0110");
        COUNT1 <= mCount;


    END PROCESS;
END ARCHITECTURE Counters;