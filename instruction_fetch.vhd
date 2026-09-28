library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
 
entity instruction_fetch is
    Port (
        Jump           : in  STD_LOGIC;
        PC_Src         : in  std_logic;
        Pc_en          : in  std_logic;
        Pc_reset       : in  std_logic;
        Instruction    : out STD_LOGIC_VECTOR (15 downto 0);
        PC_plus_1      : out STD_LOGIC_VECTOR (15 downto 0);
        clk            : in  STD_LOGIC;
        Jump_address   : in  STD_LOGIC_VECTOR (15 downto 0);
        Branch_address : in  STD_LOGIC_VECTOR (15 downto 0)
    );
end instruction_fetch;
 
architecture Behavioral of instruction_fetch is
 
signal pc_out    : std_logic_vector(15 downto 0) := (others=>'0');
signal adder_out : std_logic_vector(15 downto 0);
signal mux1_out  : std_logic_vector(15 downto 0);
signal mux2_out  : std_logic_vector(15 downto 0);

type rom_type is array (0 to 255) of std_logic_vector(15 downto 0);
signal ROM : rom_type := (
    0 => b"000_001_010_011_0_000", --add $3, $1, $2   x"0530"
    1 => b"001_000_010_0001010",   --addi $2, $0, 10  x"210A"
    2 => x"2000",
    3 => x"2000",
    4 => b"000_001_010_011_0_000", --add $3, $1, $2   x"0530"
    5 => x"2000",
    6 => x"2000",
    7 => b"011_000_011_0000000",   --sw $3 0($0)      x"6180"
    8 => b"010_000_100_0000000",   --lw $4, 0($0)     x"4200"
    9 => x"2000",
    10 => x"2000",
    11 => b"100_011_100_0000010",   --bew $3, $4, 2    x"8E02"
    12 => x"2000",
    13 => x"2000",
    14 => x"2000",
    15 => b"001_000_101_0000001",   --addi $5, $0, 1   x"2281"
    others => x"AAAA"
);
 
begin
 
process(clk)
begin
    if rising_edge(clk) then
        if Pc_reset='1' then
            pc_out<=x"0000";
        end if;
        if Pc_en='1' then
            pc_out<=mux2_out;
        end if;
     end if;
end process;
 
adder_out <= pc_out + 1;
 
mux1_out <= adder_out when PC_Src='0' else Branch_address;
mux2_out <= mux1_out when Jump='0' else Jump_address;
 
Instruction <= ROM(conv_integer(Pc_out(7 downto 0)));
 
PC_plus_1 <= adder_out;
 
end Behavioral;