library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

ENTITY Timer IS
    PORT (
        Data_In: IN STD_LOGIC_VECTOR(9 DOWNTO 0);
        tClk, tStart: IN STD_LOGIC;
        Time_Out: OUT STD_LOGIC;
        Count, Count1: OUT STD_LOGIC_VECTOR(9 DOWNTO 0) -- temporary
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
    VARIABLE iCount, iOffset: STD_LOGIC_VECTOR(9 DOWNTO 0); 

    VARIABLE suOffset, slOffset: STD_LOGIC_VECTOR(3 DOWNTO 0);
    VARIABLE mOffset: STD_LOGIC_VECTOR(1 DOWNTO 0);

    BEGIN
        --IF (rising_edge(tClk)) THEN
            IF (tStart = '1') THEN

                --iDirection <= '1';
                --slInit <= '0';
                --slEnable <= '1';
                --suEnable <= '1';
                --IF (slQ = "1001") THEN
                --    suEnable <= '1';
                --ELSE
                --    suEnable <= '0';
                --END IF;
                iDirection <= '1';
                slInit <= '0';
                slEnable <= '1';
                
                IF (slQ = "1001") THEN
                
                    
                
                    IF (suQ = "0101") THEN
                        mInit <= '0';
                        mEnable <= '1';
                        suInit <= '1';                    
                    ELSE
                        suInit <= '0';
                        mEnable <= '0';
                    END IF;
                
                    suEnable <= '1';
                
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
        
        
            IF (slQ = "0000") THEN
                slOffset := "0000";
            ELSE
                slOffset := "0110";
            END IF;

            IF ((suQ = "0000") AND (slQ = "0000"))THEN
                suOffset := "0000";
            ELSE 
                suOffset := "1010";
            END IF;

            mOffset := "00";

            iCount(9 DOWNTO 8) := mQ(1 DOWNTO 0); 
            iCount(7 DOWNTO 4) := suQ;
            iCount(3 DOWNTO 0) := slQ;

            iOffset(9 DOWNTO 8) := mOffset; 
            iOffset(7 DOWNTO 4) := suOffset;
            iOffset(3 DOWNTO 0) := slOffset;
            IF (iCount >= Data_In) THEN
                Time_Out <= '1';
            ELSE
                Time_Out <= '0';
                COUNT <= Data_In - iCount - iOffset;
                COUNT1 <= iCount;
            END IF;
        --END IF;
        
    END PROCESS;
END ARCHITECTURE Counters;