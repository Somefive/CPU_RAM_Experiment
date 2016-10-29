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
USE IEEE.STD_LOGIC_SIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

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

component RAM is
    Port (
		Data : inout  STD_LOGIC_VECTOR(15 downto 0);
		Addr : out  STD_LOGIC_VECTOR(17 downto 0);
      CE : out  STD_LOGIC;
      OE : out  STD_LOGIC;
      WE : out  STD_LOGIC;
      InputAddr : in  STD_LOGIC_VECTOR(15 downto 0);
		InputData : in  STD_LOGIC_VECTOR(15 downto 0);
      OutputAddr : out  STD_LOGIC_VECTOR(15 downto 0);
		OutputData : out STD_LOGIC_VECTOR(15 downto 0);
		Flag : in  INTEGER);
end component;

component LEDLights is
    Port ( data1 : in  STD_LOGIC_VECTOR(15 downto 0);
           addr1 : in  STD_LOGIC_VECTOR(15 downto 0);
			  data2 : in  STD_LOGIC_VECTOR(15 downto 0);
           addr2 : in  STD_LOGIC_VECTOR(15 downto 0); 
           display : in  STD_LOGIC_VECTOR(15 downto 0);
           L : out  STD_LOGIC_VECTOR(15 downto 0);
			  DisplayState : in  INTEGER
			  );
end component;
	
	signal state: INTEGER := 0;
	signal state_next: INTEGER := 0;
	
	signal data: STD_LOGIC_VECTOR (15 downto 0):="0000000000000000";
	signal addr: STD_LOGIC_VECTOR (15 downto 0):="0000000000000000";

	
	signal offset: INTEGER := 0;
	
	signal InputAddr1: STD_LOGIC_VECTOR (15 downto 0);
	signal InputData1: STD_LOGIC_VECTOR (15 downto 0);
	signal InputAddr2: STD_LOGIC_VECTOR (15 downto 0);
	signal InputData2: STD_LOGIC_VECTOR (15 downto 0);
	
	signal OutputAddr1: STD_LOGIC_VECTOR (15 downto 0);
	signal OutputData1: STD_LOGIC_VECTOR (15 downto 0);
	signal OutputAddr2: STD_LOGIC_VECTOR (15 downto 0);
	signal OutputData2: STD_LOGIC_VECTOR (15 downto 0);
	
	-- 0 Reset; 1 Read; 2 Write;
	signal Ram1State: INTEGER := 0;
	signal Ram2State: INTEGER := 0;
	
	-- 0 Display normally; 1 Ram1 Combine; 2 Ram2 Combine; 3 Ram1 Data; 4 Ram2 Data; 5 Ram1 Addr; 6 Ram2 Addr;
	signal DisplayState: INTEGER := 0;
	signal Display: STD_LOGIC_VECTOR (15 downto 0):="0000000000000000";
	
begin
	
	process(CLK, RST)
	begin
		if(RST='0')then
			state <= 0;
			offset <= 0;
			Display <= "0000000000000000";
			Ram1State <= 0;
			DisplayState <= 0;
		elsif(CLK'EVENT and CLK='1')then
			case state is
				when 0 =>
					addr <= SW;
					Display <= addr;
					state <= 1;
				when 1 =>
					data <= SW;
					Display <= data;
					state <= 2;
				when 2 =>
					InputAddr1 <= addr + conv_std_logic_vector(offset,16);
					InputData1 <= data + conv_std_logic_vector(offset,16);
					DisplayState <= 1;
					state <= 3;
				when 3 =>
					Ram1State <= 2;
					state <= 4;
				when 4 =>
					Ram1State <= 0;
					state <= 5;
				when 5 =>
					if(offset=9)then
						offset <= 0;
						InputData1	<= "ZZZZZZZZZZZZZZZZ";
						state <= 6;
					else
						offset <= offset+1;
						state <= 2;
					end if;
				when 6 =>
					InputAddr1	<= addr + conv_std_logic_vector(offset,16);
					Display <= addr;
					DisplayState <= 0;
					state <= 7;
				when 7 =>
					Ram1State <= 1;
					DisplayState <= 3;
					state <= 8;
				when 8 =>
					if(offset=9)then
						offset <= 0;
						state <= 9;
					else
						offset <= offset+1;
						state <= 6;
					end if;
				when others =>
					offset <= 0;
					DisplayState <= 0;
					Ram1State <= 0;
					state <= 0;
			end case;
		end if;
	end process;
	
	U1: DigitLights port map (DYP0,offset);
	U2: DigitLights port map (DYP1,state);
	
	RAM1: RAM port map (Ram1Data,Ram1Addr,Ram1EN,Ram1OE,Ram1WE,InputData1,InputAddr1,OutputData1,OutputAddr1,Ram1State);
	RAM2: RAM port map (Ram2Data,Ram2Addr,Ram2EN,Ram2OE,Ram2WE,InputData2,InputAddr2,OutputData2,OutputAddr2,Ram2State);
	
	LEDLights1: LEDLights port map (OutputData1, OutputAddr1, OutputData2, OutputAddr2, Display, L, DisplayState);
	
end Behavioral;

