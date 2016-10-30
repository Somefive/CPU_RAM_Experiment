----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:05:52 10/29/2016 
-- Design Name: 
-- Module Name:    LEDLights - Behavioral 
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

entity LEDLights is
    Port ( data1 : in  STD_LOGIC_VECTOR(15 downto 0);
           addr1 : in  STD_LOGIC_VECTOR(15 downto 0);
			  data2 : in  STD_LOGIC_VECTOR(15 downto 0);
           addr2 : in  STD_LOGIC_VECTOR(15 downto 0); 
           display : in  STD_LOGIC_VECTOR(15 downto 0);
           L : out  STD_LOGIC_VECTOR(15 downto 0);
			  DisplayState : in  INTEGER
			  );
end LEDLights;

architecture Behavioral of LEDLights is

begin

	process(DisplayState,data1,addr1,data2,addr2,display)
	begin
		case DisplayState is
			when 0 =>
				L <= display;
			when 1 =>
				L <= addr1(7 downto 0) & data1(7 downto 0);
			when 2 =>
				L <= addr2(7 downto 0) & data2(7 downto 0);
			when 3 =>
				L <= data1;
			when 4 =>
				L <= data2;
			when 5 =>
				L <= addr1;
			when 6 =>
				L <= addr2;
			when others =>
				L <= "0000000000000000";
		end case;
	end process;


end Behavioral;

