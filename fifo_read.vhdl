LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.all;

ENTITY fifo_read IS
  port (
    -- 100 mhz port
    clk       : IN  std_logic; -- clk
    rstn      : IN  std_logic; -- active in 0
    re        : IN  std_logic;
    sw_rstn   : IN std_logic; -- sw reset
    write_ptr : IN  std_logic_vector(5 downto 0);
    read_ptr  : OUT std_logic_vector(5 downto 0);    
    addr      : OUT std_logic_vector(8 downto 0);
    full      : OUT std_logic;
    empty     : OUT std_logic
  ); 
END ENTITY fifo_read; 

ARCHITECTURE rtl OF fifo_read IS
  signal address_c   : unsigned(9 downto 0); -- bcd code
  signal address_s   : unsigned(9 downto 0); -- bcd code
  signal read_ptr_c : std_logic_vector(5 downto 0); -- gray code
  signal read_ptr_s : std_logic_vector(5 downto 0); -- gray code
  signal full_c      : std_logic;
  signal full_s      : std_logic;
  signal empty_c     : std_logic;
  signal empty_s     : std_logic;
BEGIN

-------------------------------------------------------------------------------
-- sequential 
-------------------------------------------------------------------------------    
  state_reg : PROCESS (clk, rstn)
   BEGIN
    IF rstn = '0' THEN
      address_s   <= (others => '0');
      read_ptr_s  <= (others => '0');
      full_s      <= '0';
      empty_s     <= '1';
    ELSIF clk = '1' AND clk'EVENT THEN
      address_s   <= address_c;
      read_ptr_s  <= read_ptr_c;
      full_s      <= full_c;
      empty_s     <= empty_c;
    END IF;       
  END PROCESS state_reg;

-------------------------------------------------------------------------------
-- combinational parts 
-------------------------------------------------------------------------------
  full_gen : PROCESS (read_ptr_c, write_ptr)
   variable write_ptr_upd : std_logic_vector(4 downto 0);
   variable read_ptr_upd  : std_logic_vector(4 downto 0); 
   BEGIN
     write_ptr_upd(3 downto 0) := write_ptr(3 downto 0);
     write_ptr_upd(4)          := write_ptr(5) xor write_ptr(4);
     read_ptr_upd(3 downto 0)  := read_ptr_c(3 downto 0);
     read_ptr_upd(4)           := read_ptr_c(5) xor read_ptr_c(4);    
     if read_ptr_c(5) /= write_ptr(5) and write_ptr_upd = read_ptr_upd then 
       full_c <= '1';
     else
       full_c <= '0';
     end if;
  END PROCESS full_gen;
  
  empty_gen : PROCESS (read_ptr_c, write_ptr)
   BEGIN
     if read_ptr_c = write_ptr then
       empty_c <= '1';
     else
       empty_c <= '0';
     end if;
  END PROCESS empty_gen;  

  addr_gen : PROCESS (sw_rstn, empty_s, re, address_s, read_ptr_s)
   variable bin : unsigned(9 downto 0);
   BEGIN
     bin := address_s + 1; 
     if sw_rstn = '0' then
       address_c  <= (others => '0');
       read_ptr_c <= (others => '0');
     elsif empty_s = '0' and re = '1' then
       address_c  <= bin;
       read_ptr_c <= std_logic_vector(bin(9 downto 4)) xor std_logic_vector('0'&bin((9) DOWNTO 5)); -- transfer to gray code
     else 
       address_c   <= address_s;
       read_ptr_c  <= read_ptr_s;
     end if;
  END PROCESS addr_gen;   
  
-------------------------------------------------------------------------------
-- output assigment
-------------------------------------------------------------------------------  
addr     <= std_logic_vector(address_s(8 downto 0));
empty    <= empty_s;
read_ptr <= read_ptr_s;
full     <= full_s;

END ARCHITECTURE rtl;
