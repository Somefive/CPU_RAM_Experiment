----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:25:36 10/29/2016 
-- Design Name: 
-- Module Name:    RAM - Behavioral 
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

entity RAM is
    Port (
		Data : inout  STD_LOGIC_VECTOR(15 downto 0);
		Addr : out  STD_LOGIC_VECTOR(17 downto 0);
      CE : out  STD_LOGIC;
      OE : out  STD_LOGIC;
      WE : out  STD_LOGIC;
		InputData : in  STD_LOGIC_VECTOR(15 downto 0);
      InputAddr : in  STD_LOGIC_VECTOR(15 downto 0);
		OutputData : out STD_LOGIC_VECTOR(15 downto 0);
      OutputAddr : out  STD_LOGIC_VECTOR(15 downto 0);
		Flag : in  INTEGER);
end RAM;

architecture Behavioral of RAM is

begin
	process(Flag, Data)
	begin
		case Flag is
			when 0 =>
				CE <= '1';
				OE <= '1';
				WE <= '1';
			when 1 =>
				CE <= '0';
				OE <= '0';
				OutputAddr <= InputAddr;
				OutputData <= Data;
			when 2 =>
				CE <= '0';
				WE <= '0';
				OutputAddr <= InputAddr;
				OutputData <= InputData;
			when others =>
		end case;
	end process;
	
	process(InputData)
	begin
		Data <= InputData;
	end process;
	
	process(InputAddr)
	begin
		Addr <= "00"&InputAddr;
	end process;
	
end Behavioral;

