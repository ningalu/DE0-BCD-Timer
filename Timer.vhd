library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

ENTITY Timer IS
    PORT (
        Data_In: IN STD_LOGIC_VECTOR(9 DOWNTO 0);
        Clk, Start: IN STD_LOGIC;
        Time_Out: OUT STD_LOGIC;
        --Count, Count1: OUT STD_LOGIC_VECTOR(9 DOWNTO 0); -- temporary
        mOut, suOut, slOut: OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
END ENTITY Timer;

ARCHITECTURE Counter OF Timer IS
    --Helper signal to get the prescaled Clk value
    SIGNAL pClk: STD_LOGIC;

    --Helper signal for BCDto7SEG all_off input
    SIGNAL iall_off: STD_LOGIC := '0';

    --Internal signals for the 3 BCDs
    SIGNAL mEnable, suEnable, slEnable: STD_LOGIC;
    SIGNAL mInit, suInit, slInit: STD_LOGIC;
    SIGNAL iDirection: STD_LOGIC := '1';
    SIGNAL mQ, suQ, slQ: STD_LOGIC_VECTOR(3 DOWNTO 0);

    --Final processed outputs of the BCDs
    SIGNAL fmQ, fsuQ, fslQ: STD_LOGIC_VECTOR(3 DOWNTO 0);

    --Declare Prescaler component
    COMPONENT Prescaler IS
        PORT (
            Clk_In: IN STD_LOGIC;
            Clk_Out: OUT STD_LOGIC
        );
    END COMPONENT;

    --Declare BCD Component
    COMPONENT BCD IS
        PORT (
            Clk, Direction, Init, Enable: IN std_logic;
            Q: OUT std_logic_VECTOR(3 DOWNTO 0)
        );
    END COMPONENT;

    --Declare BCD/7 Segment Display converter
    COMPONENT BCDto7SEG IS 
        PORT (
            BCD_in: IN STD_LOGIC_VECTOR(3 DOWNTO 0);
            all_off: IN STD_LOGIC;
            LED_out: OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
        );
    END COMPONENT;
    
BEGIN
    --Assign Clk as the input and pClk as the prescaled output
    ps: Prescaler PORT MAP(Clk_In => Clk, Clk_Out => pClk);

    --Assign iDirection as the universal direction, oClk as the universal Clock, and the individual internal signals for the rest
    mBCD: BCD PORT MAP (Clk => pClk, Direction => iDirection, Init => mInit, Enable => mEnable, Q => mQ);
    suBCD: BCD PORT MAP (Clk => pClk, Direction => iDirection, Init => suInit, Enable => suEnable, Q => suQ);
    slBCD: BCD PORT MAP (Clk => pClk, Direction => iDirection, Init => slInit, Enable => slEnable, Q => slQ);

    --Assign inputs as the final Q outputs after processing, all_off as the helper signal, and outputs as the respective Timer outputs
    mCon: BCDto7SEG PORT MAP(BCD_in => fmQ, all_off => iall_off, LED_out => mOut);
    suCon: BCDto7SEG PORT MAP(BCD_in => fsuQ, all_off => iall_off, LED_out => suOut);
    slCon: BCDto7SEG PORT MAP(BCD_in => fslQ, all_off => iall_off, LED_out => slOut);

    --The Timer should be sensitive to Clock signals and the Start signal
    PROCESS(Clk, Start)
    
    --Helper variable to read Time_Out
    VARIABLE iTime_Out: STD_LOGIC := '0';
    --Container for concatenation of all 3 BCD outputs
    VARIABLE fullQ: STD_LOGIC_VECTOR(9 DOWNTO 0); 

    VARIABLE diff: STD_LOGIC_VECTOR(9 DOWNTO 0);

    --Variables for different offset values
    VARIABLE mOffset, suOffset, slOffset: STD_LOGIC_VECTOR(3 DOWNTO 0);
    VARIABLE fullOffset: STD_LOGIC_VECTOR(9 DOWNTO 0);

    --Final output variable for convenience due to method of calculation
    VARIABLE fOut: STD_LOGIC_VECTOR(9 DOWNTO 0);

    BEGIN
        IF (iTime_Out = '1') THEN
            --Enable all 3 BCDs so they can be reinitialised
            mEnable <= '1';
            suEnable <= '1';
            slEnable <= '1';
            --Initialise all BCDs so they reset to 0
            mInit <= '1';
            suInit <= '1';
            slInit <= '1';
            --Turn off all 7segs when the time is up
            iall_off <= '1';
        END IF;

        IF (Start = '0') THEN
            --Enable all 3 BCDs so they can be reinitialised
            mEnable <= '1';
            suEnable <= '1';
            slEnable <= '1';
            --Initialise all BCDs so they reset to 0
            mInit <= '1';
            suInit <= '1';
            slInit <= '1';
            --Reset Time_Out and turn on all 7segs on reset
            iTime_Out := '0';
            iall_off <= '0';
        ELSE
            --Disable init to stop forcing the BCDs to 0
            mInit <= '0';
            suInit <= '0';
            slInit <= '0';
            --Disable all BCDs except the lower seconds
            mEnable <= '0';
            suEnable <= '0';
            slEnable <= '1';
            --Enable the BCD for the 10s of seconds every time the 1s of seconds hits 9
            --slQ cannot exceed 9 by definition
            IF (slQ = "1001") THEN

                --If the 10s of seconds is 5 at the same time the 1s of seconds is 9 reset the 10s of seconds and allow the minute to tick up
                IF (suQ = "0101") THEN
                    suInit <= '1';
                    mEnable <= '1';
                ELSE
                    suInit <= '0';
                    mEnable <= '0';
                END IF;

                suEnable <= '1';
            ELSE
                suEnable <= '0';
            END IF;

        END IF;

        --Concatenate BCD outputs to one full number
        fullQ(9 DOWNTO 8) := mQ(1 DOWNTO 0);
        fullQ(7 DOWNTO 4) := suQ;
        fullQ(3 DOWNTO 0) := slQ;

        --Calculate difference only if final count isn't reached
        IF (Data_In >= fullQ) THEN

            --iTime_Out := '0';
            diff := Data_In - fullQ;

            --Determine if offsets are necessary
            IF (diff(7 DOWNTO 4) > "0101") THEN
                suOffset := "1010";
            ELSE
                suOffset := "0000";
            END IF;

            IF (diff(3 DOWNTO 0) > "1001") THEN
                slOffset := "0110";
            ELSE
                slOffset := "0000";
            END IF;

            mOffset := "0000";

            --Concatenate offsets
            fullOffset(9 DOWNTO 8) := mOffset(1 DOWNTO 0);
            fullOffset(7 DOWNTO 4) := suOffset;
            fullOffset(3 DOWNTO 0) := slOffset;

            fOut := diff - fullOffset;
        ELSE
            iTime_Out := '1';

        END IF;

        --Set 7seg inputs
        fmQ(3 DOWNTO 2) <= "00";
        fmQ(1 DOWNTO 0) <= fOut(9 DOWNTO 8);
        fsuQ <= fOut(7 DOWNTO 4);
        fslQ <= fOut(3 DOWNTO 0);

        Time_Out <= iTime_Out;
        
    END PROCESS;
END ARCHITECTURE Counter;


    
    
--ARCHITECTURE Counters OF Timer IS
--
--    SIGNAL iDirection, iall_off: STD_LOGIC;
--
--    SIGNAL mInit, mEnable: STD_LOGIC;
--    SIGNAL suInit, suEnable: STD_LOGIC;
--    SIGNAL slInit, slEnable: STD_LOGIC;
--
--    SIGNAL oClk: STD_LOGIC;
--
--    SIGNAL mQ, suQ, slQ: STD_LOGIC_VECTOR(3 DOWNTO 0);
--    SIGNAL mLED_out, suLED_out, slLED_out: STD_LOGIC_VECTOR(7 DOWNTO 0);
--    SIGNAL fm, fsu, fsl: STD_LOGIC_VECTOR(3 DOWNTO 0);
--    COMPONENT BCD IS
--        PORT (
--            Clk, Direction, Init, Enable: IN std_logic;
--            Q: OUT std_logic_VECTOR(3 DOWNTO 0)
--        );
--    END COMPONENT;
--    COMPONENT BCDto7SEG IS 
--        PORT (
--            BCD_in: IN STD_LOGIC_VECTOR(3 DOWNTO 0);
--            all_off: IN STD_LOGIC;
--            LED_out: OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
--        );
--    END COMPONENT;
--    COMPONENT Prescaler IS
--        PORT (
--            Clk_In: IN STD_LOGIC;
--            Clk_Out: OUT STD_LOGIC
--        );
--    END COMPONENT;

    
--BEGIN
--
--    mBCD: BCD PORT MAP (Clk => oClk, Direction => iDirection, Init => mInit, Enable => mEnable, Q => mQ);
--    suBCD: BCD PORT MAP (Clk => oClk, Direction => iDirection, Init => suInit, Enable => suEnable, Q => suQ);
--    slBCD: BCD PORT MAP (Clk => oClk, Direction => iDirection, Init => slInit, Enable => slEnable, Q => slQ);
--    mCon: BCDto7SEG PORT MAP(BCD_in => fm, all_off => iall_off, LED_out => mOut);
--    suCon: BCDto7SEG PORT MAP(BCD_in => fsu, all_off => iall_off, LED_out => suOut);
--    slCon: BCDto7SEG PORT MAP(BCD_in => fsl, all_off => iall_off, LED_out => slOut);
--    ps: Prescaler PORT MAP(Clk_In => tClk, Clk_Out => oClk);
--
--    PROCESS(tStart, tClk)
--    VARIABLE iCount, iOffset, pCount, fCount: STD_LOGIC_VECTOR(9 DOWNTO 0); 
--
--    VARIABLE suOffset, slOffset: STD_LOGIC_VECTOR(3 DOWNTO 0);
--    VARIABLE mOffset: STD_LOGIC_VECTOR(1 DOWNTO 0);
--
--    BEGIN
--        --IF (rising_edge(tClk)) THEN
--            IF (tStart = '1') THEN
--                --Initialise the first digit and 7seg converters
--                iDirection <= '1';
--                slInit <= '0';
--                slEnable <= '1';
--                iall_off <= '0';
--                
--                --If the first digit is about to overflow enable the second seconds digit for one clock cycle
--                IF (slQ = "1001") THEN
--                
--                    
--                    --If the second digit is about to overflow (over 5) reset it and enable the minutes digit for one clock cycle
--                    IF (suQ = "0101") THEN
--                        mInit <= '0';
--                        mEnable <= '1';
--                        suInit <= '1';                    
--                    ELSE
--                        suInit <= '0';
--                        mEnable <= '0';
--                    END IF;
--                
--                    suEnable <= '1';
--                
--                ELSE
--                    mEnable <= '0';
--                    suEnable <= '0';
--                
--                END IF;
--            --If the timer is off reset all bits and set Time_Out
--            ELSE
--                mInit <= '1';
--                suInit <= '1';
--                slInit <= '1';
--                Time_Out <= '1';
--                iall_off <= '0';
--            END IF;
--        
--            --Concatenate internal Count variable
--            iCount(9 DOWNTO 8) := mQ(1 DOWNTO 0); 
--            iCount(7 DOWNTO 4) := suQ;
--            iCount(3 DOWNTO 0) := slQ;
--
--            --Calculate preliminary Count by subtracting the current count from Data_In
--            pCount := Data_In - iCount;
--
--            --Check if any offsets are needed
--            IF (pCount(7 DOWNTO 3) > "1010") THEN
--                suOffset := "1010";
--            ELSE
--                suOffset := "0000";
--            END IF;
--
--            IF (pCount(3 DOWNTO 0) > "0110") THEN
--                slOffset := "0110";
--            ELSE 
--                slOffset := "0000";
--            END IF;
--            mOffset := "00";
--
--            --Concatenate Offsets
--            iOffset(9 DOWNTO 8) := mOffset; 
--            iOffset(7 DOWNTO 4) := suOffset;
--            iOffset(3 DOWNTO 0) := slOffset;
--
--            --If timer hasnt reached the end update the final count
--            IF (iCount > Data_In) THEN
--                Time_Out <= '1';
--            ELSE
--                Time_Out <= '0';
--                fCount := pCount - iOffset;
--                --Count <= fCount;
--                --COUNT1 <= iCount;
--            END IF;
--
--            fsu <= fCount(7 DOWNTO 4);
--            fm(3 DOWNTO 2) <= "00";
--            fm(1 DOWNTO 0) <= fCount(9 DOWNTO 8);
--            
--            fsl <= fCount(3 DOWNTO 0);
--
--            --fsu <= "0001";
--            --fsl <= "0001";
--
--
--
--        --END IF;
--        
--    END PROCESS;
--END ARCHITECTURE Counters;