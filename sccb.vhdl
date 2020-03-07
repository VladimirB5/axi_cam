LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.all;

ENTITY sccb IS
  port (
    clk       : IN std_logic; -- 100Mhz clk
    rst_n     : IN std_logic; -- active in 0
    start     : IN std_logic;
    sccb_data : IN std_logic_vector(15 downto 0); -- data to be send via sccb
    busy      : OUT std_logic;
    ack       : OUT std_logic;
    -- sccb interface
    siod_r    : in std_logic;
    siod_w    : out std_logic;
    sioc      : out std_logic
  ); 
END ENTITY sccb;

ARCHITECTURE rtl OF sccb IS

-- component declaration
COMPONENT sccb_sender IS
    Port ( clk   : in std_logic;
           rst_n : in std_logic;
           data  : in std_logic_vector(23 downto 0);
           start : in std_logic;
           busy  : out std_logic;
           ack   : out std_logic;
           siod_r: in std_logic;
           siod_w: out std_logic;
           sioc  : out std_logic
        );
end COMPONENT;

-- constants
constant write_id : std_logic_vector(7 downto 0) := x"42"; -- 42"; -- Device write ID - see top of page 11 of data sheet

signal data_send : std_logic_vector(23 downto 0);

begin
 data_send(23 downto 16) <= write_id; -- prepare data to be sedn via sccb
 data_send(15 downto 0)  <= sccb_data;

 i_sccb_sender: sccb_sender PORT MAP (
    clk   => clk,
    rst_n => rst_n,
    data  => data_send,
    start => start,
    busy  => busy,
    ack   => ack,
    siod_r=> siod_r,
    siod_w=> siod_w,
    sioc  => sioc
 ); 
 
END ARCHITECTURE RTL;
