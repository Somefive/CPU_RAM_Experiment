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
			next_state <= 0;
		elsif(CLK'EVENT and CLK='1')then
			state	<= next_state;
		end if;
	end process;
	
	process(state)
	begin
		case state is
			when 0		=>
				Rem1State	<= 0;
				Rem2State	<= 0;
				DisplayState<= 0;
				state_next	<= 1;
			when 1		=>
				addr			<=	SW;
				state_next	<= 2;
				Display		<=	addr;
			when 2		=>
				data			<=	SW;
				state_next	<= 3;
				Display		<= data;
			when 3		=>
				InputData1	<= data + to_stdlogicvector(offset);
				InputAddr1	<= addr + to_stdlogicvector(offset);
				Rem1State	<= 2;
				DisplayState<= 1;
				state_next	<= 4;
			when 4		=>
				Rem1State	<= 0;
				state_next	<= 5;
			when 5		=>
				if(offset=9) then
					offset <= 0;
					state_next <= 6;
				else
					offset <= offset+1;
					state_next <= 3;
				end if;
			when 6		=>
				InputAddr1	<= addr + to_stdlogicvector(offset);
				Rem1State	<= 1;
				state_next	<= 7;
			when 7		=>
				if(offset=9) then
					offset <= 0;
					state_next <= 8;
				else
					offset <= offset+1;
					state_next <= 6;
				end if;
			when 8		=>
				InputAddr1	<= addr + to_stdlogicvector(offset);
				InputAddr2	<=	InputAddr1;
				Ram1State	<=	1;
				DisplayState<= 1;
				state_next	<= 9;
			when 9		=>
				InputData2	<= OutputData1-to_stdlogicvector(1);
				Ram2State	<= 2;
				DisplayState<= 2;
				state_next	<= 10;
			when 10		=>
				Ram2State	<= 0;
				if(offset=9) then
					offset <= 0;
					state_next <= 11;
				else
					offset <= offset+1;
					state_next <= 8;
				end if;
			when 11		=>
				InputData2	<= addr + to_stdlogicvector(offset);
				Ram2State	<= 2;
				DisplayState<= 4;
				state_next	<= 12;
			when 12		=>
				Ram2State	<= 0;
				if(offset=9) then
					offset <= 0;
					state_next <= 0;
				else
					offset <= offset+1;
					state_next <= 11;
				end if;
			when others	=>
				state_next	<= 0;
		end case;
	end process;
	
	U1: DigitLights port map (DYP0,offset);
	U2: DigitLights port map (DYP1,state);
	
	RAM1: RAM port map (Ram1Data,Ram1Addr,Ram1OE,Ram1WE,Ram1EN,InputData1,InputAddr1,OutputData1,OutputAddr1,Ram1State);
	RAM2: RAM port map (Ram2Data,Ram2Addr,Ram2OE,Ram2WE,Ram2EN,InputData2,InputAddr2,OutputData2,OutputAddr2,Ram2State);
	
	LEDLights1: LEDLights port map (OutputData1, OutputAddr1, OutputData2, OutputAddr2, Display, L, DisplayState);
	
end Behavioral;

