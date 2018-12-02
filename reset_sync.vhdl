-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity reset_sync is
    Port ( async_res_n : in  STD_LOGIC;
           clk         : in  STD_LOGIC;
           sync_res_n  : out  STD_LOGIC);
end reset_sync;

architecture RTL of reset_sync is
SIGNAL A_d     : std_logic;
SIGNAL A_q_B_d : std_logic;
SIGNAL B_q     : std_logic;
begin
   A_d <= '1';
    regA_B : PROCESS (clk, async_res_n)
    BEGIN
        IF async_res_n = '0' THEN
            A_q_B_d <= '0';
            B_q <= '0';
        ELSIF clk'EVENT AND clk='1' THEN
            A_q_B_d <= A_d;
            B_q <= A_q_B_d;
        END IF;
    END PROCESS regA_B;
---------------------------------------------------------- output    
   sync_res_n <= B_q;

end RTL;

