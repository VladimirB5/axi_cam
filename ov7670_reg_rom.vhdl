LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.all;

ENTITY ov7670_reg_rom IS
  port (
    addr: IN std_logic_vector(7 downto 0);
    dout: out std_logic_vector(15 downto 0)
  );
END ENTITY ov7670_reg_rom; 


ARCHITECTURE rtl OF ov7670_reg_rom IS
  TYPE rom_array is ARRAY (73 downto 0) OF std_logic_vector (15 downto 0);
  CONSTANT rom_block : rom_array := (
            x"1280", -- COM7   Reset
            x"1280", -- COM7   Reset

            x"8C03", -- RGB 444 SET 00=DISABLE
            x"1E07", -- MIRROR IMAGE
            x"1180", -- EXTERNAL CLK
            x"6B0A", -- BYPASS PPL
            x"3B0A",
            x"3A04",
            x"3D88", --
-- 
            x"1204", -- RGB
            x"8C03", -- RGB 444
            x"4010", -- RGB 565
            x"1180", -- EXTERNAL CLK
            x"703A", -- SCALING XSC
            x"7135", -- SCALING YSC
            x"A202", -- CLOCK DELAY
-- 
            x"1713", -- HSTART
            x"1801", -- HSTOP
            x"32B6", -- HREF
            x"1902", -- VSTRT
            x"1A7A", -- VSTOP
            x"030A", -- VREF
            x"7211", -- SAMPLING
            x"73F0", -- SAMPLING
--            -- AEC
            x"13E0",
            x"0000",
            x"1000",
            x"0D40",
            x"1418",
            x"A505",
            x"AB07",
            x"2495",
            x"2533",
            x"26E3",
            x"9F78",
            x"A068",
            x"A103",
            x"A6D8",
            x"A7D8",
            x"A8F0",
            x"A990",
            x"AA94",
            x"13E5",
-- 
--            -- MAGIC
            x"0E61",
            x"0F4B",
            x"1602",
            x"1E07",
            x"2102",
            x"2291",
            x"2907",
            x"330B",
            x"350B",
            x"371D",
            x"3871",
            x"392A",
            x"3C78",
            x"4D40",
            x"4E20",
            x"6900",
            x"6B0A",
            x"7410",
            x"8D4F",
            x"8E00",
            x"8F00",
            x"9000",
            x"9100",
            x"9600",
            x"9A00",
            x"B084",
            x"B10C",
            x"B20E",
            x"B382",
            x"B80A",
            x"0002"
           );
BEGIN
  
  dout <= rom_block(to_integer(unsigned(addr)));
END rtl;
