
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity main_control_unit is
  Port (
    Opcode: in std_logic_vector(2 downto 0);
    RegDst: out std_logic;
    ExtOp: out std_logic;
    ALUSrc: out std_logic; 
    Branch: out std_logic; 
    Jump: out std_logic; 
    ALUOp: out std_logic_vector(2 downto 0);
    MemWrite: out std_logic;
    MemtoReg: out std_logic;
    RegWrite: out std_logic
   );
end main_control_unit;

architecture Behavioral of main_control_unit is

begin

process(Opcode)
begin   

RegDst <= '0'; 
ExtOp <= '0'; 
ALUSrc <= '0'; 
Branch <= '0'; 
Jump <= '0'; 
MemWrite <= '0'; 
MemtoReg <= '0'; 
RegWrite <= '0';
ALUOp <= "000";

    case Opcode is
        when "000" => 
            RegDst<='1';
            --ExtOp<='0';
            ALUSrc<='0';
            Branch<='0';
            Jump<='0';
            MemWrite<='0';
            MemtoReg<='0';
            RegWrite<='1';
            ALUOp<="001";
        when "001" =>
            RegDst<='0';
            ExtOp<='1';
            ALUSrc<='1';
            Branch<='0';
            Jump<='0';
            MemWrite<='0';
            MemtoReg<='0';
            RegWrite<='1';
            ALUOp<="000";
        when "010" =>
            RegDst<='0';
            ExtOp<='1';
            ALUSrc<='1';
            Branch<='0';
            Jump<='0';
            MemWrite<='0';
            MemtoReg<='1';
            RegWrite<='1';
            ALUOp<="000";
         when "011" =>
            --RegDst<='0';
            ExtOp<='1';
            ALUSrc<='1';
            Branch<='0';
            Jump<='0';
            MemWrite<='1';
            --MemtoReg<='1';
            RegWrite<='0';
            ALUOp<="000";
         when "100" =>
            --RegDst<='0';
            ExtOp<='1';
            ALUSrc<='0';
            Branch<='1';
            Jump<='0';
            MemWrite<='0';
            --MemtoReg<='1';
            RegWrite<='0';
            ALUOp<="010";
          when "101" =>
            RegDst<='0';
            ExtOp<='0';
            ALUSrc<='1';
            Branch<='0';
            Jump<='0';
            MemWrite<='0';
            MemtoReg<='0';
            RegWrite<='1';
            ALUOp<="100";
          when "110" =>
            RegDst<='0';
            ExtOp<='0';
            ALUSrc<='1';
            Branch<='0';
            Jump<='0';
            MemWrite<='0';
            MemtoReg<='0';
            RegWrite<='1';
            ALUOp<="101";
          when "111" =>
            --RegDst<='0';
            --ExtOp<='0';
            --ALUSrc<='1';
            Branch<='0';
            Jump<='1';
            MemWrite<='0';
            --MemtoReg<='0';
            RegWrite<='0';
            --ALUOp<="101"; 
       end case; 
end process;
end Behavioral;
