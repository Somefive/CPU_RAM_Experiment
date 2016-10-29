----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:23:10 10/29/2016 
-- Design Name: 
-- Module Name:    DigitLights - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity DigitLights is
    Port ( L : out  STD_LOGIC_VECTOR (6 downto 0);
           NUMBER : in  INTEGER);
end DigitLights;

architecture Behavioral of DigitLights is
begin
	process(NUMBER)
	begin
		case number is
			when 0		=>	L<="1111110"; --0
			when 1		=>	L<="0110000"; --1
			when 2		=>	L<="1101101"; --2
			when 3		=>	L<="1111001"; --3
			when 4		=>	L<="0110011"; --4
			when 5		=>	L<="1011011"; --5
			when 6		=>	L<="1011111"; --6
			when 7		=>	L<="1110000"; --7
			when 8		=>	L<="1111111"; --8
			when 9		=>	L<="1111011"; --9
			when others	=>	L<="0000000"; 
		end case;
	end process;
end Behavioral;

