
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ssd is
    Port (           
           digit0 : in STD_LOGIC_VECTOR (3 downto 0);
           digit1 : in STD_LOGIC_VECTOR (3 downto 0);
           digit2 : in STD_LOGIC_VECTOR (3 downto 0);
           digit3 : in STD_LOGIC_VECTOR (3 downto 0);
           cat : out STD_LOGIC_VECTOR (6 downto 0);
           an : out STD_LOGIC_VECTOR (3 downto 0);
           clk : in STD_LOGIC);
end ssd;

architecture Behavioral of ssd is

signal cnt: std_logic_vector(15 downto 0) := (others=>'0');  
signal sel: std_logic_vector(1 downto 0) := (others=>'0');
signal y: std_logic_vector(3 downto 0) := (others=>'0');
signal y1: std_logic_vector(3 downto 0) := (others=>'0');
signal seg: std_logic_vector(6 downto 0) := (others=>'0');

begin
               
process(clk)
    begin
        if(rising_edge(clk)) then
              cnt <= cnt+1;
        end if;
 end process;

sel<=cnt(15 downto 14);

process(digit0, digit1, digit2, digit3, sel)
begin
    case sel is
        when "00" => y<=digit0;
        when "01" => y<=digit1;
        when "10" => y<=digit2;
        when "11" => y<=digit3;
        when others => y<=(others=>'0');
    end case;
end process;

process(sel)
begin 
     case sel is
        when "00" => y1<="1110";
        when "01" => y1<="1101";
        when "10" => y1<="1011";
        when "11" => y1<="0111";
        when others => y1<=(others=>'0');
     end  case;
end process;
 
an<=y1;
 
process(y)
begin
    case y is
        when "0000" => seg <= "1000000"; -- "0"     
        when "0001" => seg <= "1111001"; -- "1" 
        when "0010" => seg <= "0100100"; -- "2" 
        when "0011" => seg <= "0110000"; -- "3" 
        when "0100" => seg <= "0011001"; -- "4" 
        when "0101" => seg <= "0010010"; -- "5" 
        when "0110" => seg <= "0000010"; -- "6" 
        when "0111" => seg <= "1111000"; -- "7" 
        when "1000" => seg <= "0000000"; -- "8"     
        when "1001" => seg <= "0010000"; -- "9" 
        when "1010" => seg <= "0001000"; -- "A"
        when "1011" => seg <= "0000011"; -- "b"
        when "1100" => seg <= "1000110"; -- "C"
        when "1101" => seg <= "0100001"; -- "d"
        when "1110" => seg <= "0000110"; -- "E"
        when "1111" => seg <= "0001110"; 
    end case;
end process;
 
cat<=seg; 
 
end Behavioral;
