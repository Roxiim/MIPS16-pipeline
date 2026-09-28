
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity execute_unit is
  Port (
    pc_plus_1: in std_logic_vector(15 downto 0);
    rd1: in std_logic_vector(15 downto 0);
    rd2: in std_logic_vector(15 downto 0);
    ext_imm: in std_logic_vector(15 downto 0);
    alu_src: in std_logic;
    sa: in std_logic;
    func: in std_logic_vector(2 downto 0);
    alu_op: in std_logic_vector( 2 downto 0);
    reg_dst: in std_logic;
    rt: in std_logic_vector(2 downto 0);
    rd: in std_logic_vector(2 downto 0);
    branch_address: out std_logic_vector(15 downto 0);
    zero: out std_logic;
    alu_res: out std_logic_vector(15 downto 0);
    wa: out std_logic_vector(2 downto 0)
   );
end execute_unit;

architecture Behavioral of execute_unit is

signal mux_out: std_logic_vector(15 downto 0);
signal alu_ctrl: std_logic_vector(2 downto 0);
signal alu_out: std_logic_vector(15 downto 0);

begin

mux_out<=rd2 when alu_src='0' else ext_imm;
branch_address<=pc_plus_1 + ext_imm;
wa <= rt when reg_dst='0' else rd;

process(alu_op, func)
begin
    case alu_op is
        when "000" => alu_ctrl<= "000"; --addi, lw, sw
        when "010" => alu_ctrl<= "001"; --beq
        when "100" => alu_ctrl<= "100"; --andi
        when "101" => alu_ctrl<= "101"; --ori
        when "001" => 
            case func is
                when "000" => alu_ctrl <= "000"; --add
                    when "001" => alu_ctrl <= "001"; --sub
                    when "010" => alu_ctrl <= "010"; --sll
                    when "011" => alu_ctrl <= "011"; --srl
                    when "100" => alu_ctrl <= "100"; --and
                    when "101" => alu_ctrl <= "101"; --or
                    when "110" => alu_ctrl <= "110"; --xor
                    when "111" => alu_ctrl <= "111"; --slt
                    when others => alu_ctrl <= "000";
                end case;
            when others => alu_ctrl <= "000";
     end case;  
end process;

process(alu_out, rd1, mux_out)
begin
    case alu_ctrl is
        when "000" => alu_out<= rd1+mux_out;
        when "001" => alu_out<= rd1-mux_out;
        when "010" => 
            if sa='1' then 
                alu_out<=mux_out(14 downto 0) & '0';
            else  
                alu_out<=mux_out;
            end if;
        when "011" => 
            if sa='1' then
                alu_out<='0' & mux_out(15 downto 1);
            else 
                alu_out<=mux_out; 
            end if;
        when "100" => alu_out<=rd1 and mux_out;
        when "101" => alu_out<=rd1 or mux_out;
        when "110" => alu_out<=rd1 xor mux_out;
        when "111" => 
            if rd1<mux_out then
                alu_out<=x"1111";
            else alu_out<=x"0000";  
            end if; 
       when others => alu_out <= "000";    
    end case;
end process;   

alu_res<=alu_out;

zero<='1' when alu_out=x"0000" else '0'; 

end Behavioral;
