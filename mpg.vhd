

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity mpg is
Port(
    clk: in std_logic;
    btn: in std_logic_vector(4 downto 0);
    enable: out std_logic_vector(4 downto 0)
    );
end mpg;

architecture Behavioral of mpg is
signal cnt: unsigned(15 downto 0):= (others =>'0');
signal q0, q1, q2 :std_logic_vector(4 downto 0) := (others=>'0');
signal sample: std_logic;
begin

process(clk)
    begin
        if(rising_edge(clk)) then 
            cnt<= cnt+1;
        end if;
end process;

sample <= '1' when cnt = 0 else '0';

process(clk)
    begin
        if(rising_edge(clk)) then
            if(sample='1') then
                q0<=btn;
            end if;
        end if;
end process;

process(clk)
    begin
        if(rising_edge(clk)) then
            q1<=q0;
            q2<=q1;
        end if;
end process;

enable <= (q1) and (not (q2));

end Behavioral;
