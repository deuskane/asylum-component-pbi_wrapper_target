-------------------------------------------------------------------------------
-- Title      : pbi wrapper target
-- Project    : pbi (Pico Bus)
-------------------------------------------------------------------------------
-- File       : pbi_wrapper_target.vhd
-- Author     : Mathieu Rosière
-- Company    : 
-- Created    : 2014-06-03
-- Last update: 2025-03-15
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
-- 2025-08_03  1.1      mrosiere Use unconstrainted pbi
-------------------------------------------------------------------------------

library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
library work;
use     work.pbi_pkg.all;

entity pbi_wrapper_target is
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
                        
  alias    pbi_id          : std_logic_vector(SIZE_ADDR_ID-1 downto 0) is pbi_ini_i.addr(SIZE_ADDR-1 downto SIZE_ADDR_IP);
  alias    tgt_id          : std_logic_vector(SIZE_ADDR_ID-1 downto 0) is ID            (SIZE_ADDR-1 downto SIZE_ADDR_IP);
           
  signal    cs             : std_logic;
  
begin  -- rtl

  -----------------------------------------------------------------------------
  -- Check Parameters
  -----------------------------------------------------------------------------
--  assert SIZE_ADDR_IP>PBI_ADDR_WIDTH report "Invalid value at the parameter 'SIZE_ADDR_IP'" severity FAILURE;
  
  -----------------------------------------------------------------------------
  -- Chip Select
  -----------------------------------------------------------------------------
  cs             <= pbi_ini_i.cs when (pbi_id = tgt_id) else
                    '0';

  -----------------------------------------------------------------------------
  -- To Bus
  -----------------------------------------------------------------------------
  pbi_tgt_o.rdata<= pbi_tgt_i.rdata when cs='1' else
                    CST0;
  pbi_tgt_o.busy <= pbi_tgt_i.busy  when cs='1' else
                    '0';
  
  -----------------------------------------------------------------------------
  -- To IP
  -----------------------------------------------------------------------------
  pbi_ini_o.cs        <= cs;
  pbi_ini_o.re        <= pbi_ini_i.re;
  pbi_ini_o.we        <= pbi_ini_i.we;
  pbi_ini_o.addr      <= pbi_ini_i.addr (pbi_ini_o.addr'range);
  pbi_ini_o.wdata     <= pbi_ini_i.wdata;

-- pragma translate_off

--process is
--begin  -- process
--
--  report "Address : "&integer'image(pbi_ini_o.addr'length) severity note;  
--
--  wait;
--end process;

-- pragma translate_on  
  
  
end rtl;
