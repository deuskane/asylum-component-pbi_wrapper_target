-------------------------------------------------------------------------------
-- Title      : pbi wrapper target
-- Project    : pbi (Pico Bus)
-------------------------------------------------------------------------------
-- File       : pbi_wrapper_target.vhd
-- Author     : Mathieu Rosière
-- Company    : 
-- Created    : 2014-06-03
-- Last update: 2025-04-05
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2014 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author   Description
-- 2014-06-03  1.0      mrosiere Created
-- 2025-08-03  1.1      mrosiere Use unconstrainted pbi
-- 2025-04-05  1.2      mrosiere Add Algo (binary/one-hot)
-------------------------------------------------------------------------------

library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
library work;
use     work.pbi_pkg.all;
use     work.logic_pkg.all;
use     work.convert_pkg.all;

entity pbi_wrapper_target is
  -- =====[ Parameters ]==========================
  generic (
    SIZE_DATA      : natural := 8;
    SIZE_ADDR_IP   : natural := 0;
    ID             : std_logic_vector (PBI_ADDR_WIDTH-1 downto 0) := (others => '0');
    ALGO           : string  := "binary" -- "binary" / "one_hot"
     );
  -- =====[ Interfaces ]==========================
  port (
    clk_i               : in    std_logic;
    cke_i               : in    std_logic;
    arstn_i             : in    std_logic; -- asynchronous reset

    -- To IP
    pbi_ini_o           : out   pbi_ini_t;
    pbi_tgt_i           : in    pbi_tgt_t;
    
    -- From Bus
    pbi_ini_i           : in    pbi_ini_t;
    pbi_tgt_o           : out   pbi_tgt_t
    );
end pbi_wrapper_target;

architecture rtl of pbi_wrapper_target is
  constant SIZE_ADDR       : natural := pbi_ini_i.addr'length;
  constant SIZE_ADDR_ID    : natural := SIZE_ADDR-SIZE_ADDR_IP;
  constant CST0            : std_logic_vector(pbi_tgt_o.rdata'range) := (others => '0');
  constant IDX             : integer := onehot_to_integer(ID);
    
  signal   pbi_id          : std_logic_vector(SIZE_ADDR_ID-1 downto 0);
  signal   tgt_id          : std_logic_vector(SIZE_ADDR_ID-1 downto 0);
           
  signal   cs              : std_logic;
  signal   tgt_addr        : std_logic_vector(SIZE_ADDR_IP-1 downto 0);
  signal   tgt_rdata       : std_logic_vector(pbi_tgt_o.rdata'range);
  signal   tgt_busy        : std_logic;

  signal   ini_cs          : std_logic;
  signal   ini_re          : std_logic;
  signal   ini_we          : std_logic;
  signal   ini_addr        : std_logic_vector(pbi_ini_i.addr'range);
  signal   ini_wdata       : std_logic_vector(pbi_ini_i.wdata'range);

    
begin  -- rtl

  -----------------------------------------------------------------------------
  -- Check Parameters
  -----------------------------------------------------------------------------
--  assert SIZE_ADDR_IP>PBI_ADDR_WIDTH report "Invalid value at the parameter 'SIZE_ADDR_IP'" severity FAILURE;
  
  -----------------------------------------------------------------------------
  -- Chip Select
  -----------------------------------------------------------------------------
  -- Don't use Alias to see this signal in gtkwave
  
  gen_binary: if ALGO="binary"
  generate
    pbi_id             <= ini_addr(SIZE_ADDR   -1 downto SIZE_ADDR_IP);
    tgt_id             <= ID      (SIZE_ADDR   -1 downto SIZE_ADDR_IP);
    
    cs                 <= ini_cs when (pbi_id = tgt_id) else
                          '0';
  end generate gen_binary;
    
  gen_one_hot: if ALGO="one_hot"
  generate
    cs                 <= ini_cs and ini_addr(IDX);
  end generate gen_one_hot;

  
  -----------------------------------------------------------------------------
  -- From Bus
  -----------------------------------------------------------------------------
  -- USe tmp signal to see this signal in gtkwave
  ini_cs             <= pbi_ini_i.cs   ;
  ini_re             <= pbi_ini_i.re   ;
  ini_we             <= pbi_ini_i.we   ;
  ini_addr           <= pbi_ini_i.addr ;
  ini_wdata          <= pbi_ini_i.wdata;

  tgt_addr           <= ini_addr(SIZE_ADDR_IP-1 downto 0);
  
  -----------------------------------------------------------------------------
  -- To Bus
  -----------------------------------------------------------------------------
  tgt_rdata          <= pbi_tgt_i.rdata when cs='1' else
                        CST0(tgt_rdata'range);
  tgt_busy           <= pbi_tgt_i.busy  when cs='1' else
                        '0';

  pbi_tgt_o.rdata    <= tgt_rdata;
  pbi_tgt_o.busy     <= tgt_busy ;
  
  -----------------------------------------------------------------------------
  -- To IP
  -----------------------------------------------------------------------------
  pbi_ini_o.cs        <= cs;
  pbi_ini_o.re        <= ini_re;
  pbi_ini_o.we        <= ini_we;
  pbi_ini_o.addr      <= std_logic_vector(resize(unsigned(tgt_addr),pbi_ini_o.addr'length));
  pbi_ini_o.wdata     <= ini_wdata;

-- pragma translate_off

  process is
  begin  -- process

    report "Target["&to_hstring(ID)&"] Address : "&integer'image(SIZE_ADDR_IP) severity note;

    if (ALGO = "one_hot")
    then
      report "  * Index : " &integer'image(IDX) severity note;
      
    end if;
    

    wait;
  end process;

-- pragma translate_on  
  
  
end rtl;
