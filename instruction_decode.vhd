library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity instruction_decode is
 Port ( 
    clk: in std_logic;
    en: in std_logic;
    Instr: in std_logic_vector(15 downto 0);
    WD: in std_logic_vector(15 downto 0);
    RegWrite: in std_logic;
    wa: in std_logic_vector(2 downto 0);
    ExtOp: in std_logic;
    RD1: out std_logic_vector(15 downto 0);
    RD2: out std_logic_vector(15 downto 0);
    Ext_Imm: out std_logic_vector(15 downto 0);
    func: out std_logic_vector(2 downto 0);
    sa: out std_logic;
    rt: out std_logic_vector(2 downto 0);
    rd: out std_logic_vector(2 downto 0)
    );
end instruction_decode;

architecture Behavioral of instruction_decode is

component reg_file is
    port (
    clk : in std_logic;
    ra1 : in std_logic_vector (2 downto 0); 
    ra2 : in std_logic_vector (2 downto 0); 
    wa  : in std_logic_vector (2 downto 0); 
    wd  : in std_logic_vector (15 downto 0);
    wen : in std_logic;
    rd1 : out std_logic_vector (15 downto 0);
    rd2 : out std_logic_vector (15 downto 0)
    );
end component;

begin

reg_file1: reg_file Port map(
    clk => clk,
    ra1 => Instr(12 downto 10), 
    ra2 => Instr(9 downto 7),   
    wa  => wa,       
    wd  => WD,
    wen => RegWrite,
    rd1 => RD1,
    rd2 => RD2   
    );

Ext_Imm(6 downto 0) <= Instr(6 downto 0);
Ext_Imm(15 downto 7) <= (others=>Instr(6)) when ExtOp='1' else (others=>'0');

func <= Instr(2 downto 0);
sa <= Instr(3);
rt <= Instr(9 downto 7);
rd <= Instr(6 downto 4);

end Behavioral;