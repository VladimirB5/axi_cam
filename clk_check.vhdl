LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.all;

ENTITY clk_check IS
  generic (
   G_CNTA    : natural := 8;  
   G_CNTB    : natural := 11;
   G_MIN_VAL : natural := 1014;
   G_MAX_VAL : natural := 1034
  );
  port (
   -- clock to be checked
   clk_a       : IN    std_logic;
   rstn_a      : IN    std_logic;
   -- performing clock
   clk_b       : IN    std_logic;
   rstn_b      : IN    std_logic;
   ena         : IN    std_logic;
   check_ok    : OUT   std_logic
  ); 
END ENTITY clk_check; 

ARCHITECTURE rtl OF clk_check IS
-- components -----------------------------------------------------------------
component synchronizer is
  Port ( clk       : in  STD_LOGIC;
         res_n     : in  STD_LOGIC;
         data_in   : in  STD_LOGIC;
         data_out  : out STD_LOGIC
  );
end component;

-- constants ------------------------------------------------------------------
  constant C_MAX_A : unsigned(G_CNTA-1 downto 0) := (others => '1');

-- signals --------------------------------------------------------------------
  signal ena_a : std_logic;
  signal max_b : std_logic; -- max_value_ rsynchronized to b domain

-- registers ------------------------------------------------------------------
 signal cnta_c, cnta_s     : unsigned(G_CNTA-1 downto 0);
 signal cntb_c, cntb_s     : unsigned(G_CNTB-1 downto 0);
 signal max_a_c, max_a_s   : std_logic;
 signal ok_c, ok_s         : std_logic;
 signal max_b_c, max_b_s   : std_logic; -- save max_b reg in b doman
BEGIN
-------------------------------------------------------------------------------
-- components
-------------------------------------------------------------------------------
  i_ena_sync : synchronizer
  port map( 
    clk       => clk_a,
    res_n     => rstn_a,
    data_in   => ena,
    data_out  => ena_a
  );

  i_max_sync : synchronizer
  port map( 
    clk       => clk_a,
    res_n     => rstn_a,
    data_in   => max_a_s,
    data_out  => max_b
  );  
  
-------------------------------------------------------------------------------
-- sequential 
-------------------------------------------------------------------------------
  reg_a : PROCESS (clk_a, rstn_a)
   BEGIN
    IF rstn_a = '0' THEN
      cnta_s  <= (others => '0');
      max_a_s <= '0';
    ELSIF clk_a = '1' AND clk_a'EVENT THEN
      cnta_s  <= cnta_c;
      max_a_s <= max_a_c;
    END IF;  
  END PROCESS reg_a;
  
  reg_b : PROCESS (clk_b, rstn_b)
   BEGIN
    IF rstn_b = '0' THEN
      cntb_s  <= (others => '0');
      ok_s    <= '0';
      max_b_s <= '0';
    ELSIF clk_b = '1' AND clk_b'EVENT THEN
      cntb_s  <= cntb_c;
      ok_s    <= ok_c;
      max_b_s <= max_b_c;
    END IF;  
  END PROCESS reg_b;  

-------------------------------------------------------------------------------
-- combinational parts 
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- cnt a and max
-------------------------------------------------------------------------------
  cnta_c <= cnta_s + 1 when ena_a = '1' else 
            (others => '0');
            
  max_a_c <= not max_a_s when cnta_s = C_MAX_A else 
             max_a_s;

-------------------------------------------------------------------------------
-- cnt b and ok
-------------------------------------------------------------------------------
  max_b_c <= max_b;
   
  ok_proc: process(ok_s, cntb_s, max_b_s, max_b, ena)
  begin
  ok_c   <= ok_s;
  cntb_c <= cntb_s + 1;
  if (cntb_s >= G_MIN_VAL AND cntb_s <= G_MAX_VAL) and max_b_s /= max_b then
    ok_c <= '1';
    cntb_c <= (others => '0');
  elsif cntb_s > G_MAX_VAL or max_b_s /= max_b or ena = '0' then
    ok_c <= '0';
    cntb_c <= (others => '0');
  end if;
  end process ok_proc;
 
-------------------------------------------------------------------------------
-- output assigment
-------------------------------------------------------------------------------
 check_ok <= ok_s;
 
END ARCHITECTURE rtl;
 
