LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
--use IEEE.numeric_std.all;

ENTITY fifo_tb IS 
END ENTITY fifo_tb;

ARCHITECTURE behavior OF fifo_tb IS
-------------------------------------------------------------------------------
COMPONENT fifo IS
  port (
    -- 100 mhz port
    clk_100 : IN std_logic; -- 100Mhz clk
    rst_100n: IN std_logic; -- active in 0
    re      : IN std_logic;
    full_r  : OUT std_logic;
    empty   : OUT std_logic;
    data_r  : OUT std_logic_vector(63 downto 0);
    -- 25 mhz port
    clk_25  : IN  std_logic;
    rst_25n : IN  std_logic;
    data_w  : IN  std_logic_vector(63 downto 0);
    we      : IN  std_logic;
    full_w  : OUT std_logic
  ); 
END COMPONENT;
-------------------------------------------------------------------------------
   
   -- 100 mhz interface
   signal clk_100   : std_logic := '0';
   signal rst_100n  : std_logic := '0';
   signal re        : std_logic := '0';
   signal full_r    : std_logic;
   signal empty     : std_logic;
   signal data_r    : std_logic_vector(63 downto 0);
   
   -- 25 mhz interface
   signal clk_25    : std_logic := '0';
   signal rst_25n   : std_logic := '0';
   signal we        : std_logic := '0';
   signal data_w    : std_logic_vector(63 downto 0) := (others => '0');
   signal full_w    : std_logic;
   
   signal stop_sim: boolean := false;
   constant clk_period_100 : time := 10 ns;
   constant clk_period_25  : time := 40 ns;
    
   
   signal write_start : std_logic := '0';
begin

   i_fifo: fifo PORT MAP (
     -- clocks and resets
    -- 100 mhz port
    clk_100  => clk_100,
    rst_100n => rst_100n,
    re       => re,
    full_r   => full_r,
    empty    => empty,
    data_r   => data_r,
    -- 25 mhz port
    clk_25   => clk_25,
    rst_25n  => rst_25n,
    data_w   => data_w,
    we       => we,
    full_w   => full_w
   );
           
   sim: process
     begin
     rst_100n <= '0';
     rst_25n  <= '0';
     wait for 5 ns;
     rst_100n <= '1';
     rst_25n  <= '1';
     
     wait until clk_25 = '1' AND clk_25'EVENT;
     wait for 1 ns;
     data_w   <= (others => '1');
     we       <= '1';
     
     for I in 0 to 510 loop
     wait until clk_25 = '1' AND clk_25'EVENT;
     end loop;
     
     wait until clk_25 = '1' AND clk_25'EVENT;
     wait for 1 ns;
     we       <= '0';
     
     wait for 1 us;

     wait until clk_100 = '1' AND clk_100'EVENT;
     wait for 1 ns;     
     re       <= '1';
     for I in 0 to 510 loop
     wait until clk_100 = '1' AND clk_100'EVENT;
     end loop;
     
     wait until clk_100 = '1' AND clk_100'EVENT;
     wait for 1 ns;
     re       <= '0';     
     
     wait for 1 us;
     
     -- second round
     wait until clk_25 = '1' AND clk_25'EVENT;
     wait for 1 ns;
     data_w   <= (others => '1');
     we       <= '1';
     
     for I in 0 to 510 loop
     wait until clk_25 = '1' AND clk_25'EVENT;
     end loop;
     
     wait until clk_25 = '1' AND clk_25'EVENT;
     wait for 1 ns;
     we       <= '0';
     
     wait for 1 us;

     wait until clk_100 = '1' AND clk_100'EVENT;
     wait for 1 ns;     
     re       <= '1';
     for I in 0 to 510 loop
     wait until clk_100 = '1' AND clk_100'EVENT;
     end loop;
     
     wait until clk_100 = '1' AND clk_100'EVENT;
     wait for 1 ns;
     re       <= '0';     
     
     wait for 1 us;     
     
     stop_sim <= true;
     --report "simulation finished successfully" severity FAILURE;
     wait;    
   end process;
   
   clock_100: process
     begin
        clk_100 <= '0';
        wait for clk_period_100/2;  --
        clk_100 <= '1';
        wait for clk_period_100/2;  --
        if stop_sim = true then
          wait;
        end if;
   end process;
   
   clock_25: process
     begin
        clk_25 <= '0';
        wait for clk_period_25/2;  --
        clk_25 <= '1';
        wait for clk_period_25/2;  --
        if stop_sim = true then
          wait;
        end if;
   end process;   
   
--    read: process
--      begin 
--      
--    end process;

end ARCHITECTURE behavior; 
