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
        --If time has run out, reset all bcds and turn off the 7segs
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

        --If start is pressed, restart all the BCDs, reset the Time_Out flag, and enable the 7segs
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

        --Calculate difference only if final count isn't reached and input is valid
        IF ((Data_In >= fullQ) AND (Data_In(7 DOWNTO 4) < "1010") AND (Data_In(3 DOWNTO 0) < "1010")) THEN

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

            --Calculate the inputs to the 7seg converters
            fOut := diff - fullOffset;
        ELSE
            iTime_Out := '1';

        END IF;

        --Set 7seg inputs
        fmQ(3 DOWNTO 2) <= "00";
        fmQ(1 DOWNTO 0) <= fOut(9 DOWNTO 8);
        fsuQ <= fOut(7 DOWNTO 4);
        fslQ <= fOut(3 DOWNTO 0);

        --Assign Time_Out to its helper
        Time_Out <= iTime_Out;
        
    END PROCESS;
END ARCHITECTURE Counter;