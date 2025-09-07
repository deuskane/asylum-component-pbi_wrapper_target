library IEEE;
use     IEEE.STD_LOGIC_1164.ALL;
use     IEEE.NUMERIC_STD.ALL;
library asylum;
use     asylum.pbi_pkg.all;

package pbi_wrapper_target_pkg is
-- [COMPONENT_INSERT][BEGIN]
component pbi_wrapper_target_v1 is
  -- =====[ Parameters ]==========================
  generic (
    SIZE_DATA      : natural := 8;
    SIZE_ADDR_IP   : natural := 0;
    ID             : std_logic_vector (PBI_ADDR_WIDTH-1 downto 0) := (others => '0')
     );
  -- =====[ Interfaces ]==========================
  port (
    clk_i               : in    std_logic;
    cke_i               : in    std_logic;
    arstn_i             : in    std_logic; -- asynchronous reset

    -- To IP
    ip_cs_o             : out   std_logic;
    ip_re_o             : out   std_logic;
    ip_we_o             : out   std_logic;
    ip_addr_o           : out   std_logic_vector (SIZE_ADDR_IP-1 downto 0);
    ip_wdata_o          : out   std_logic_vector (SIZE_DATA-1    downto 0);
    ip_rdata_i          : in    std_logic_vector (SIZE_DATA-1    downto 0);
    ip_busy_i           : in    std_logic;
    
    -- From Bus
    pbi_ini_i           : in    pbi_ini_t;
    pbi_tgt_o           : out   pbi_tgt_t
    );
end component pbi_wrapper_target_v1;

component pbi_wrapper_target is
  -- =====[ Parameters ]==========================
  generic (
    SIZE_DATA      : natural := 8;
    SIZE_ADDR_IP   : natural := 0;
    ID             : std_logic_vector (PBI_ADDR_WIDTH-1 downto 0) := (others => '0');
    ADDR_ENCODING  : string  := "binary"; -- "binary" / "one_hot"
    TGT_ZEROING    : boolean := false
    
     );
  -- =====[ Interfaces ]==========================
  port (
    cs_o                : out   std_logic;

    -- To IP
    pbi_ini_o           : out   pbi_ini_t;
    pbi_tgt_i           : in    pbi_tgt_t;
    
    -- From Bus
    pbi_ini_i           : in    pbi_ini_t;
    pbi_tgt_o           : out   pbi_tgt_t
    );
end component pbi_wrapper_target;

-- [COMPONENT_INSERT][END]

end pbi_wrapper_target_pkg;
