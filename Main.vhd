----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:56:12 10/29/2016 
-- Design Name: 
-- Module Name:    Main - Behavioral 
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

entity Main is
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           SW : in  STD_LOGIC_VECTOR (15 downto 0);
           L : out  STD_LOGIC_VECTOR (15 downto 0);
           Ram1Addr : out  STD_LOGIC_VECTOR (17 downto 0);
           Ram1Data : inout  STD_LOGIC_VECTOR (15 downto 0);
           Ram1OE : out  STD_LOGIC;
           Ram1WE : out  STD_LOGIC;
           Ram1EN : out  STD_LOGIC;
           Ram2Addr : out  STD_LOGIC_VECTOR (17 downto 0);
           Ram2Data : inout  STD_LOGIC_VECTOR (15 downto 0);
           Ram2OE : out  STD_LOGIC;
           Ram2WE : out  STD_LOGIC;
           Ram2EN : out  STD_LOGIC;
           DYP0 : out  STD_LOGIC_VECTOR (6 downto 0);
           DYP1 : out  STD_LOGIC_VECTOR (6 downto 0));
end Main;

architecture Behavioral of Main is

component DigitLights is
	Port ( L : out  STD_LOGIC_VECTOR (6 downto 0);
           NUMBER : in  INTEGER);
end component;

	signal digitLights1: INTEGER := 0;
	signal digitLights2: INTEGER := 9;

begin
	
	process(CLK, RST)
	begin
		L 			<= "0000000000000000";
		Ram1Addr <= "000000000000000000";
		Ram1Data <= "0000000000000000";
		Ram1OE 	<= '0';
		Ram1WE	<= '0';
		Ram1EN	<= '0';
		Ram2Addr <= "000000000000000000";
		Ram2Data <= "0000000000000000";
		Ram2OE 	<= '0';
		Ram2WE	<= '0';
		Ram2EN	<= '0';
	end process;
	U1: DigitLights port map (DYP0,digitLights1);
	U2: DigitLights port map (DYP1,digitLights2);
end Behavioral;

