LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
--use IEEE.numeric_std.all;

use work.tb_top_pkg.all;
use work.axi_lite_pkg.all;

ENTITY stimuli_tb IS 
  port (
    axi_m_in  : IN   t_AXI_M_IN; 
    axi_m_out : OUT  t_AXI_M_OUT;
    ctrl      : OUT  t_CTRL
  );
END ENTITY stimuli_tb;

ARCHITECTURE sccb_stimuli OF stimuli_tb IS
-------------------------------------------------------------------------------
  signal address : std_logic_vector(31 downto 0);
  signal data    : std_logic_vector(31 downto 0);
 
begin

   sim: process
     begin
     axi_m_out.ARPROT  <= (others => '0');
     --AXI_L_ARVALID <= '0';     
     ctrl.rst_n <= '0';
     wait for 100 ns;
     wait for 100 ns;
     ctrl.AXI_HP_AWREADY <= '1';
     ctrl.AXI_HP_WREADY  <= '1';
     ctrl.AXI_HP_BVALID  <= '1';
     ctrl.rst_n <= '1';
     
     wait for 50 us;
     address <= x"00000004";
     data    <= x"00001280";
     axi_write(axi_m_in, axi_m_out, address, data);
     
     wait for 50 us;
     address <= x"00000014";
     data    <= x"00000001";
     axi_write(axi_m_in, axi_m_out, address, data);
     
     wait for 300 us;
     address <= x"00000014";
     data    <= x"00000001";
     axi_write(axi_m_in, axi_m_out, address, data);
     
     wait for 300 us;
     address <= x"00000014";
     data    <= x"00000001";
     axi_write(axi_m_in, axi_m_out, address, data);
     
     wait for 300 us;
     
     wait for 10 us;
     
     ctrl.stop_sim <= true;
     --report "simulation finished successfully" severity FAILURE;
     wait;    
   end process;
           
end ARCHITECTURE sccb_stimuli; 
 
