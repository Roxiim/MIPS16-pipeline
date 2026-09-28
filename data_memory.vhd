
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity data_memory is
    Port ( mem_write : in STD_LOGIC;
           en: in STD_LOGIC;
           alu_res : in STD_LOGIC_VECTOR (15 downto 0);
           rd2 : in STD_LOGIC_VECTOR (15 downto 0);
           clk : in STD_LOGIC;
           mem_data : out STD_LOGIC_VECTOR (15 downto 0);
           alu_res_out : out STD_LOGIC_VECTOR (15 downto 0));
end data_memory;

architecture Behavioral of data_memory is

type ram_array is array (0 to 63) of std_logic_vector(15 downto 0);
signal RAM: ram_array := (others=>x"0000");

begin

mem_data<=RAM(conv_integer(alu_res(5 downto 0)));

alu_res_out<=alu_res;

process(clk)
begin
    if rising_edge(clk) then
        if en='1' and mem_write='1' then   
            RAM(conv_integer(alu_res(5 downto 0)))<=rd2;
        end if;
    end if;
end process;


end Behavioral;
