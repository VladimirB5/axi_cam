LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.all;

ENTITY sccb IS
  port (
    clk   : IN std_logic; -- 100Mhz clk
    rst_n : IN std_logic; -- active in 0
    start : IN std_logic;
    busy  : OUT std_logic;
    -- sccb interface
    siod  : out  STD_LOGIC;
    sioc  : out  STD_LOGIC
  ); 
END ENTITY sccb;

ARCHITECTURE rtl OF sccb IS

-- component declaration
COMPONENT i2c_sender IS
    Port ( clk   : in  STD_LOGIC; 
           siod  : out  STD_LOGIC;
           sioc  : out  STD_LOGIC;
           taken : out  STD_LOGIC;
           send  : in  STD_LOGIC;
           id    : in  STD_LOGIC_VECTOR (7 downto 0);
           reg   : in  STD_LOGIC_VECTOR (7 downto 0);
           value : in  STD_LOGIC_VECTOR (7 downto 0));
end COMPONENT;

COMPONENT ov7670_reg_rom IS
  port (
    addr: IN std_logic_vector(1 downto 0);
    dout: out std_logic_vector(15 downto 0)
  );
END COMPONENT;

signal dout  : std_logic_vector (15 downto 0);
signal taken : std_logic;
constant camera_address : std_logic_vector(7 downto 0) := x"42"; -- 42"; -- Device write ID - see top of page 11 of data sheet

-- registers
TYPE tstate IS (idle, read_rom, send_start, send_stop);
SIGNAL fsm_c :tstate;
SIGNAL fsm_s :tstate;

signal busy_c  : std_logic;
signal busy_s  : std_logic;
signal send_c  : std_logic;
signal send_s  : std_logic;
signal addr_c  : unsigned (1 downto 0);
signal addr_s  : unsigned (1 downto 0);
begin

 i_reg_rom: ov7670_reg_rom PORT MAP (
   addr => std_logic_vector(addr_s),
   dout => dout
 ); 

 i_i2c_sender: i2c_sender PORT MAP (
   clk   => clk,
   siod  => siod,
   sioc  => sioc,
   taken => taken,
   send  => send_s,
   id    => camera_address,
   reg   => dout(15 downto 8),
   value => dout(7 downto 0)
 ); 
 
 state_reg : PROCESS (clk,rst_n)
   begin
    IF rst_n = '0' THEN
         addr_s <= (others => '0');         
         busy_s <= '0';
         send_s <= '0';
         fsm_s  <= idle;
    ELSIF clk = '1' AND clk'EVENT THEN
         busy_s <= busy_c;
         addr_s <= addr_c;
         send_s <= send_c;
         fsm_s  <= fsm_c;
    END IF;       
 END PROCESS state_reg;
 
next_state_logic : PROCESS (fsm_s, taken, start, addr_s)
  begin
    fsm_c <= fsm_s;
    case fsm_s is
      when idle => 
        if start = '1' then
          fsm_c <= send_start; -- address 0 is read by default
        end if;
      when read_rom =>
        fsm_c <= send_start;
      when send_start => 
        fsm_c <= send_stop;
      when send_stop  => 
        if taken = '1' then
          if (addr_s < 2) then
            fsm_c <= read_rom;
          else  
            fsm_c <= idle;
          end if;
        end if;
 END case;        
END PROCESS next_state_logic;

output_logic : PROCESS (fsm_c, send_s, addr_s)
begin
 send_c <= send_s;
 addr_c <= addr_s;
 CASE fsm_c is
   when idle => 
     send_c <= '0';
     busy_c <= '0';
     addr_c <= (others => '0');
   when read_rom =>
     addr_c <= addr_s + 1;
     busy_c <= '1';
     send_c <= '0';
   when send_start  =>
     busy_c <= '1';
     send_c <= '1';
   when send_stop =>
     busy_c <= '1'; 
     send_c <= '1';
 END case;         
END PROCESS output_logic; 

-- output assigments
busy <= busy_s;

END ARCHITECTURE RTL;
