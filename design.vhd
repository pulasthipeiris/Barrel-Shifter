
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity FP_Adder is
    Port (A, B : in std_logic_vector (31 downto 0);
          S   : out std_logic_vector (31 downto 0);
          rule : in std_logic);
          
end FP_Adder;

architecture myimplementation of FP_Adder is 
begin 

    process(A, B, S, rule)
    
        --input variables 
        variable A_mantissa     : std_logic_vector (32 downto 0);
        variable A_exponent     : std_logic_vector (7 downto 0);
        variable A_sign         : std_logic;

        variable B_mantissa     : std_logic_vector (32 downto 0);
        variable B_exponent     : std_logic_vector (7 downto 0);
        variable B_sign         : std_logic;
        
        --output variables
        variable S_mantissa     : std_logic_vector (22 downto 0);
        variable S_exponent     : std_logic_vector (7 downto 0);
        variable S_sign         : std_logic;
        
        --difference in exp
        variable exponent_diff  : std_logic_vector (7 downto 0); 
        
        --final mantissa
        variable output_mantissa: std_logic_vector (32 downto 0); 
        
        --counter 
        variable counter : std_logic_vector (7 downto 0);
        
        --hidden bit 
        variable hidden_bit : std_logic;
        
        --dummy variable
        variable dummy : std_logic_vector (32 downto 0);
        
        --idiot variable 
        variable pointer : integer;

    begin
    
    dummy := "000000000000000000000000000000000";
    
    --check if exponent is within the range, if it is then set it to 1
    if (A(30 downto 23) >= "00000001" and A(30 downto 23) <= "11111110") then 
        hidden_bit := '1';
    elsif (B(30 downto 23) >= "00000001" and B(30 downto 23) <= "11111110") then
        hidden_bit := '1';
    else
        hidden_bit := '0';
    end if;
    
    if(A(30 downto 23) > B(30 downto 23)) then --check which exponent is greater
        A_mantissa := '0' & hidden_bit & A(22 downto 0) & "00000000"; --add extra bits, big vector
        A_exponent := A(30 downto 23);
        A_sign := A(31);
        --so A_whatever are the components of the BIG vector 
        
        B_mantissa     := '0' & hidden_bit & B(22 downto 0) & "00000000";
        B_exponent     := B(30 downto 23);
        B_sign         := B(31);
        
        --B_whatever are the components of the small vector
        
    else --if A is smaller than B then assign other way around so that A is still larger, this way no need to check which is larger later!!!
        A_mantissa := '0' & hidden_bit & B(22 downto 0) & "00000000"; 
        A_exponent := B(30 downto 23);
        A_sign := B(31);
        
        B_mantissa     := '0' & hidden_bit & A(22 downto 0) & "00000000";
        B_exponent     := A(30 downto 23);
        B_sign         := A(31);
        
    end if;
    
    S_sign := A_sign; --get largest sign and assign to output sign
    
    --get difference between exponents
    exponent_diff := (A_exponent - B_exponent);
    
    --shift the mantissa
    counter := "00000000";
    while (counter < exponent_diff) loop 
    B_mantissa := '0' & B_mantissa (32 downto 1);
    counter := counter + '1';
    end loop;
  
    
    --summation of mantissas 
    if (A_sign = B_sign) then --if signs are equal then just add
        output_mantissa := (A_mantissa + B_mantissa);
    else -- if signs aren't equal then subtract
        output_mantissa := (A_mantissa + ((NOT B_mantissa) + '1')); 
    end if;
    
      --normalization
    if (output_mantissa(32) = '1') then
        A_exponent := A_exponent + "00000001";
        output_mantissa := '0' & output_mantissa (32 downto 1);
    end if;
    
    
    -- If the hidden bit is zero in the sum and 1 ≤ E ≤ 254, then the mantissa must be shifted to the left and the exponent decremented until the hidden bit becomes 1
    while(output_mantissa(31) = '0' and output_mantissa > "00000000000000000000000000000000") loop
        if(A_exponent >= "00000001" and A_exponent <= "11111110") then
            A_exponent := A_exponent - "00000001";
            output_mantissa := output_mantissa (31 downto 0) & '0';    
        elsif(A_exponent>"11111110" and B_exponent>"11111110" and A_sign = NOT(B_sign)) then 
            exit;
        end if;
    end loop;
    
    --representation for zero
    if(output_mantissa = "00000000000000000000000000000000") then 
        A_exponent := "00000000";
    end if;
    
    --check for infinity
    if(A_exponent = "11111111") then
        output_mantissa := "000000000000000000000000000000000";
    end if;
     
     --check for NaN
    if(A(30 downto 23) >= "11111111" and B(30 downto 23) >= "11111111" and A_sign = NOT(B_sign)) then 
        A_exponent := "11111111";
        output_mantissa := "000000010000000000000000000000000";
    end if;
    
    --rounding bonus points
    
    pointer := TO_INTEGER(unsigned(A_exponent)) - 127; --6
    
    if(rule = '1') then 
        if (output_mantissa(30 - pointer) = '1') then
            output_mantissa((30 - pointer) downto 0) := dummy((30 - pointer) downto 0);
            output_mantissa(30 downto (30-(pointer-1))) := output_mantissa(30 downto (30-(pointer-1)))+'1';
        else
            output_mantissa((30 - pointer) downto 0) := dummy((30 - pointer) downto 0);
        end if;
    end if;
            
    S_exponent := A_exponent; --get largest exponent and assign it to output exponent    
    S_mantissa := output_mantissa(30 downto 8);
    
    --final output 
    
    S(22 downto 0) <= S_mantissa; 
    S(30 downto 23) <= S_exponent;
    S(31) <= S_sign;
    
    end process; 
    
end myimplementation;
