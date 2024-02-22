
-- import libraries
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity testbench is
-- empty
end testbench;

architecture tb of testbench is

-- DUT component
component FP_Adder is
    Port (A, B : in std_logic_vector (31 downto 0);
          S   : out std_logic_vector (31 downto 0);
          rule : in std_logic);
end component;

--input and output signals
signal A_in : std_logic_vector (31 downto 0);
signal B_in : std_logic_vector (31 downto 0);
signal S_out : std_logic_vector (31 downto 0);
signal rule_in : std_logic;
 
begin

  --Connect DUT
  DUT: FP_Adder port map (A_in, B_in, S_out, rule_in);
  process
  begin
  --test signals
  
    A_in <= "11000010111111101011000100100111";
    B_in <= "11001001111110100011111010000000";
    rule_in <= '1';
	wait for 1 ns;
    
 	A_in <= "01000010111111101011000100100111";
    B_in <= "01001001111110100011111010000000";
    rule_in <= '1';
    wait for 1 ns;
   
    A_in <= "01000110110000110101000000000000";
    B_in <= "11000001000001100110011001100110";
    rule_in <= '1';
    wait for 1 ns;
    
	--roundest to nearest 
    A_in <= "01000010011101000110011001100110";
    B_in <= "01000010100100100110011001100110";
    rule_in <= '1';
	wait for 1 ns;

    --positive positive
    A_in <= "01000010110010001011001100110011";
    B_in <= "01000001110011001010001111010111";
    rule_in <= '0';
    wait for 1 ns;
    
    --negative positive
    A_in <= "11000010110010001011001100110011";
    B_in <= "01000001110011001010001111010111";
    rule_in <= '0';
    wait for 1 ns;
    
    --overflow
    A_in <= "01000010110000000000000000000000";
    B_in <= "01000010110000000000000000000000";
    rule_in <= '0';
    wait for 1 ns;
    
    --0 output, mantissa of the sum is zero
    A_in <= "11000010110010001011001100110011";
    B_in <= "01000010110010001011001100110011";
    rule_in <= '0';
   wait for 1 ns;
    
    --sum is larger than positive representable range
    A_in <= "01111111010010001011001100110011";
    B_in <= "01111111010010001011001100110011";
    rule_in <= '0';
    wait for 1 ns;
    
    --sum is smaller than negative representable range
    A_in <= "11111111010010001011001100110011";
    B_in <= "11111111010010001011001100110011";
    rule_in <= '0';
    wait for 1 ns;
    
    --sum is NaN
   A_in <= "11111111110001011001100110011001";
   B_in <= "01111111111001011001100110011001";
   rule_in <= '0';
   wait for 1 ns;
    
    --sum is inifinity, inputs are infinity and real
    A_in <= "01111111110001011001100110011001";
    B_in <= "01111110011001011001000110011001";
    rule_in <= '0';
    wait for 1 ns;

    --sum is -inifinity, inputs are -infinity and real
    A_in <= "11111111110001011001100110011001";
    B_in <= "01111110011001011001000110011001";     	
	  rule_in <= '0';
    wait for 1 ns;

	-- case for normalization exponent and hidden bit inconsistency
    A_in <= "11000010110000000000000000000000";
    B_in <= "01000010110000000000000000000011";
    rule_in <= '0';
    wait for 1 ns;
    
    -- Clear inputs
    A_in <= "00000000000000000000000000000000";
    B_in <= "00000000000000000000000000000000";
    rule_in <= '0';
    wait for 1 ns;
    
    wait;
  end process;
end tb;
