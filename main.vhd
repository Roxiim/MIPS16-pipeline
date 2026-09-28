library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity main is
    Port ( 
        btn : in  std_logic_vector (4 downto 0);
        sw  : in  STD_LOGIC_VECTOR (15 downto 0);
        clk : in  STD_LOGIC;
        cat : out STD_LOGIC_VECTOR(6 downto 0);
        an  : out STD_LOGIC_VECTOR(3 downto 0);
        led : out STD_LOGIC_VECTOR(15 downto 0)
    );
end main;

architecture Behavioral of main is

    component mpg is
        Port(
            clk    : in  std_logic;
            btn    : in  std_logic_vector(4 downto 0);
            enable : out std_logic_vector(4 downto 0)
        );
    end component;

    component ssd is
        Port (            
            digit0 : in  STD_LOGIC_VECTOR(3 downto 0);
            digit1 : in  STD_LOGIC_VECTOR(3 downto 0);
            digit2 : in  STD_LOGIC_VECTOR(3 downto 0);
            digit3 : in  STD_LOGIC_VECTOR(3 downto 0);
            cat    : out STD_LOGIC_VECTOR(6 downto 0);
            an     : out STD_LOGIC_VECTOR(3 downto 0);
            clk    : in  STD_LOGIC
        );
    end component;

    component instruction_fetch is
        Port ( 
            Jump           : in  STD_LOGIC;
            PC_Src         : in  std_logic;
            Pc_en          : in  std_logic;
            Pc_reset       : in  std_logic;
            Instruction    : out STD_LOGIC_VECTOR(15 downto 0);
            PC_plus_1      : out STD_LOGIC_VECTOR(15 downto 0);
            clk            : in  STD_LOGIC;
            Jump_address   : in  STD_LOGIC_VECTOR(15 downto 0);
            Branch_address : in  STD_LOGIC_VECTOR(15 downto 0)
        );
    end component;

    component instruction_decode is
        Port ( 
            clk      : in std_logic;
            en       : in std_logic;
            Instr    : in std_logic_vector(15 downto 0);
            WD       : in std_logic_vector(15 downto 0);
            RegWrite : in std_logic;
            wa       : in std_logic_vector(2 downto 0);
            ExtOp    : in std_logic;
            RD1      : out std_logic_vector(15 downto 0);
            RD2      : out std_logic_vector(15 downto 0);
            Ext_Imm  : out std_logic_vector(15 downto 0);
            func     : out std_logic_vector(2 downto 0);
            sa       : out std_logic;
            rt       : out std_logic_vector(2 downto 0);
            rd       : out std_logic_vector(2 downto 0)
        );
    end component;

    component execute_unit is
        Port (
            pc_plus_1      : in std_logic_vector(15 downto 0);
            rd1            : in std_logic_vector(15 downto 0);
            rd2            : in std_logic_vector(15 downto 0);
            ext_imm        : in std_logic_vector(15 downto 0);
            alu_src        : in std_logic;
            sa             : in std_logic;
            func           : in std_logic_vector(2 downto 0);
            alu_op         : in std_logic_vector(2 downto 0);
            reg_dst        : in std_logic;
            rt             : in std_logic_vector(2 downto 0);
            rd             : in std_logic_vector(2 downto 0);
            branch_address : out std_logic_vector(15 downto 0);
            zero           : out std_logic;
            alu_res        : out std_logic_vector(15 downto 0);
            wa             : out std_logic_vector(2 downto 0)
        );
    end component;

    component data_memory is
        Port ( 
            mem_write   : in STD_LOGIC;
            en          : in STD_LOGIC;
            alu_res     : in STD_LOGIC_VECTOR (15 downto 0);
            rd2         : in STD_LOGIC_VECTOR (15 downto 0);
            clk         : in STD_LOGIC;
            mem_data    : out STD_LOGIC_VECTOR (15 downto 0);
            alu_res_out : out STD_LOGIC_VECTOR (15 downto 0) 
        );
    end component;

    component main_control_unit is
        Port (
            Opcode   : in std_logic_vector(2 downto 0);
            RegDst   : out std_logic;
            ExtOp    : out std_logic;
            ALUSrc   : out std_logic; 
            Branch   : out std_logic; 
            Jump     : out std_logic; 
            ALUOp    : out std_logic_vector(2 downto 0);
            MemWrite : out std_logic;
            MemtoReg : out std_logic;
            RegWrite : out std_logic
        );
    end component;

    signal en              : std_logic_vector(4 downto 0);
    signal instruction_sig : std_logic_vector(15 downto 0);
    signal pc_plus_1_sig   : std_logic_vector(15 downto 0);
    signal jump_addr_sig   : std_logic_vector(15 downto 0);
    signal pc_src_sig      : std_logic;
    
    signal rd1_sig, rd2_sig, ext_imm_sig : std_logic_vector(15 downto 0);
    signal func_sig        : std_logic_vector(2 downto 0);
    signal sa_sig          : std_logic;
    signal rt_sig, rd_sig  : std_logic_vector(2 downto 0);

    signal branch_addr_ex_sig : std_logic_vector(15 downto 0);
    signal alu_res_ex_sig     : std_logic_vector(15 downto 0);
    signal zero_ex_sig        : std_logic;
    signal wa_ex_sig          : std_logic_vector(2 downto 0);

    signal mem_data_sig    : std_logic_vector(15 downto 0);
    signal alu_res_out_sig : std_logic_vector(15 downto 0);
    signal wd_sig          : std_logic_vector(15 downto 0);

    signal RegDst_c, ExtOp_c, ALUSrc_c, Branch_c, Jump_c : std_logic;
    signal MemWrite_c, MemtoReg_c, RegWrite_c : std_logic;
    signal ALUOp_c : std_logic_vector(2 downto 0);

    signal ssd_data : std_logic_vector(15 downto 0);
    
    signal RegIF_ID  : std_logic_vector(31 downto 0);
    signal RegID_EX  : std_logic_vector(82 downto 0);
    signal RegEX_MEM : std_logic_vector(55 downto 0);
    signal RegMEM_WB : std_logic_vector(36 downto 0);

begin

    mpg1 : mpg port map(clk => clk, btn => btn, enable => en);

    pc_src_sig <= RegEX_MEM(52) and RegEX_MEM(35);
    jump_addr_sig <= RegIF_ID(31 downto 29) & RegIF_ID(12 downto 0);

    instruction_fetch1: instruction_fetch port map(
        Jump           => Jump_c,        
        PC_Src         => pc_src_sig,      
        Pc_en          => en(0),      
        Pc_reset       => en(1),      
        clk            => clk,
        Jump_address   => jump_addr_sig,      
        Branch_address => RegEX_MEM(51 downto 36),      
        Instruction    => instruction_sig,
        PC_plus_1      => pc_plus_1_sig
    );
    
    process(clk)
    begin
        if rising_edge(clk) then
            if en(0)='1' then
                RegIF_ID <= pc_plus_1_sig & instruction_sig;
                
                RegID_EX(82 downto 74) <= RegWrite_c & MemtoReg_c & MemWrite_c & Branch_c & ALUOp_c & ALUSrc_c & RegDst_c;
                RegID_EX(73 downto 10) <= RegIF_ID(31 downto 16) & rd1_sig & rd2_sig & ext_imm_sig;
                RegID_EX(9 downto 0)   <= func_sig & sa_sig & rt_sig & rd_sig;
                
                RegEX_MEM(55 downto 52) <= RegID_EX(82 downto 79); 
                RegEX_MEM(51 downto 0)  <= branch_addr_ex_sig & zero_ex_sig & alu_res_ex_sig & RegID_EX(41 downto 26) & wa_ex_sig;
                
                RegMEM_WB(36 downto 35) <= RegEX_MEM(55 downto 54); 
                RegMEM_WB(34 downto 0)  <= mem_data_sig & RegEX_MEM(34 downto 19) & RegEX_MEM(2 downto 0);
            end if;
        end if;
    end process;


    instruction_decode1: instruction_decode port map(
        clk      => clk,
        en       => en(0),        
        Instr    => RegIF_ID(15 downto 0),
        WD       => wd_sig,
        RegWrite => RegMEM_WB(36),
        wa       => RegMEM_WB(2 downto 0),
        ExtOp    => ExtOp_c,
        RD1      => rd1_sig,
        RD2      => rd2_sig,
        Ext_Imm  => ext_imm_sig,
        func     => func_sig,
        sa       => sa_sig,
        rt       => rt_sig,
        rd       => rd_sig
    );

    control_unit1: main_control_unit port map(
        Opcode   => RegIF_ID(15 downto 13), 
        RegDst   => RegDst_c,
        ExtOp    => ExtOp_c,
        ALUSrc   => ALUSrc_c,
        Branch   => Branch_c,
        Jump     => Jump_c,
        ALUOp    => ALUOp_c,
        MemWrite => MemWrite_c,
        MemtoReg => MemtoReg_c,
        RegWrite => RegWrite_c
    );

    execute_unit1: execute_unit port map(
        pc_plus_1      => RegID_EX(73 downto 58),
        rd1            => RegID_EX(57 downto 42),
        rd2            => RegID_EX(41 downto 26),
        ext_imm        => RegID_EX(25 downto 10),
        alu_src        => RegID_EX(75),
        sa             => RegID_EX(6),
        func           => RegID_EX(9 downto 7),
        alu_op         => RegID_EX(78 downto 76),
        reg_dst        => RegID_EX(74),
        rt             => RegID_EX(5 downto 3),
        rd             => RegID_EX(2 downto 0),
        branch_address => branch_addr_ex_sig,
        zero           => zero_ex_sig,
        alu_res        => alu_res_ex_sig,
        wa             => wa_ex_sig
    );

    data_memory1: data_memory port map(
        clk         => clk,
        en          => en(0),       
        mem_write   => RegEX_MEM(53), 
        alu_res     => RegEX_MEM(34 downto 19),
        rd2         => RegEX_MEM(18 downto 3),
        mem_data    => mem_data_sig,
        alu_res_out => alu_res_out_sig
    );

    wd_sig <= RegMEM_WB(34 downto 19) when RegMEM_WB(35) = '1' else RegMEM_WB(18 downto 3);

    process(sw(7 downto 5), instruction_sig, pc_plus_1_sig, rd1_sig, rd2_sig, ext_imm_sig, alu_res_ex_sig, mem_data_sig, wd_sig)
    begin
        case sw(7 downto 5) is
            when "000"  => ssd_data <= instruction_sig;
            when "001"  => ssd_data <= pc_plus_1_sig;
            when "010"  => ssd_data <= rd1_sig;
            when "011"  => ssd_data <= rd2_sig;
            when "100"  => ssd_data <= ext_imm_sig;
            when "101"  => ssd_data <= alu_res_ex_sig;
            when "110"  => ssd_data <= mem_data_sig;
            when "111"  => ssd_data <= wd_sig;
            when others => ssd_data <= (others => '0');
        end case;
    end process;

    ssd_inst: ssd port map(
        digit0 => ssd_data(3 downto 0), digit1 => ssd_data(7 downto 4),
        digit2 => ssd_data(11 downto 8), digit3 => ssd_data(15 downto 12),
        cat    => cat, an     => an, clk    => clk
    );

    process(sw(0), RegDst_c, ExtOp_c, ALUSrc_c, Branch_c, Jump_c, MemWrite_c, MemtoReg_c, RegWrite_c, ALUOp_c)
    begin
        led <= (others => '0'); 
        if sw(0) = '0' then
            led(7) <= RegDst_c; led(6) <= ExtOp_c; led(5) <= ALUSrc_c;
            led(4) <= Branch_c; led(3) <= Jump_c; led(2) <= MemWrite_c;
            led(1) <= MemtoReg_c; led(0) <= RegWrite_c;
        else
            led(2 downto 0) <= ALUOp_c;
        end if;
    end process;

end Behavioral;