----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:28:33 11/05/2015 
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
use IEEE.STD_LOGIC_ARITH.ALL; 
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Main is
    port(CLK,RST: in STD_LOGIC;
		  SW: in STD_LOGIC_VECTOR(15 downto 0);
		  Ram1Addr: out STD_LOGIC_VECTOR(17 downto 0);
		  L: out STD_LOGIC_VECTOR(15 downto 0);
		  Ram1Data: inout STD_LOGIC_VECTOR(15 downto 0);
		  Ram1OE,Ram1WE,Ram1EN: out STD_LOGIC;
		  Ram2Addr: out STD_LOGIC_VECTOR(17 downto 0);
		  Ram2Data: inout STD_LOGIC_VECTOR(15 downto 0);
		  Ram2OE,Ram2WE,Ram2EN: out STD_LOGIC;
		  DYP0: out STD_LOGIC_VECTOR(6 downto 0);
		  DYP1: out STD_LOGIC_VECTOR(6 downto 0);
		  RDN: out STD_LOGIC;
		  WRN: out STD_LOGIC
        );
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
      EN : out  STD_LOGIC;
      OE : out  STD_LOGIC;
      WE : out  STD_LOGIC;
		InputData : in  STD_LOGIC_VECTOR(15 downto 0);
      InputAddr : in  STD_LOGIC_VECTOR(15 downto 0);
		OutputData : out STD_LOGIC_VECTOR(15 downto 0);
      OutputAddr : out  STD_LOGIC_VECTOR(15 downto 0);
		Flag : in  INTEGER);
end component;

    signal state: INTEGER := 0;
	 shared variable baseAddr: STD_LOGIC_VECTOR(15 downto 0) := "0000000000000000";
	 shared variable baseData: STD_LOGIC_VECTOR(15 downto 0) := "0000000000000000";
	 shared variable offset: INTEGER range 0 to 10 := 0;
	 signal real_offset: INTEGER range 0 to 10 := 0;
	 shared variable temp_1_oe,temp_1_we,temp_2_oe,temp_2_we: STD_LOGIC := '1';
	 shared variable temp_1_en,temp_2_en: STD_LOGIC := '0';
	 
	 shared variable displayAddr: STD_LOGIC_VECTOR(17 downto 0) := "000000000000000000";
	 shared variable displayData: STD_LOGIC_VECTOR(15 downto 0) := "0000000000000000";
	 
begin
    process(CLK , RST)
	 begin
	    if(RST = '0') then
		      baseAddr := "0000000000000000";
				baseData := "0000000000000000";
				offset := 0;
				state <= 0;
				temp_1_oe := '1';
				temp_2_oe := '1';
				temp_1_we := '1';
				temp_2_we := '1';
				temp_1_en := '0';
				temp_2_en := '0';
				Ram1Data <= "0000000000000000";
				Ram2Data <= "0000000000100000";
				Ram1Addr <= "000000000000000000";
				Ram2Addr <= "000000000000000000";
		  elsif(CLK'event and CLK = '1') then
		      case state is
				    when 0 => --Read BaseAddr
					     baseAddr := SW;
					     state <= 1;
				    when 1 => --Read BaseData
					     baseData := SW;
						  state <= 2;
					 when 2 => --Calculate current Addr&Data and WRITE DATA INTO RAM1
						  temp_1_we := '0';
						  Ram1Data <= baseData + conv_std_logic_vector(offset,16);
						  Ram1Addr <= baseAddr + conv_std_logic_vector(offset,16);
						  displayData := baseData + conv_std_logic_vector(offset,16);
						  displayAddr := baseAddr + conv_std_logic_vector(offset,16);
						  state <= 3;
				    when 3 => --Stop writting and update offset
						  temp_1_we := '1';
						  offset := offset+1;
						  if(offset < 10) then
						      state <= 2;
                    else
						      offset := 0;
								state <= 4;
						  end if;
				    when 4 => --Calculate Addr and READ DATA FROM RAM1
						  Ram1Data <= "ZZZZZZZZZZZZZZZZ";
						  Ram1Addr <= baseAddr + conv_std_logic_vector(offset,16);
						  temp_1_oe := '0';
						  state <= 5;
						  displayAddr := baseAddr + conv_std_logic_vector(offset,16);
				    when 5 => --Update offset
						  displayData := Ram1Data;
						  offset := offset+1;
						  if(offset < 10) then
						      state <= 4;
                    else
						      offset := 0;
								state <= 6;
						  end if;
					 when 6 => --Stop Reading and Update the baseData
						  temp_1_oe := '1';
						  baseData :=  baseData - '1';
						  state <= 7;
				    when 7 => --Calculate the Addr&Data and WRITE DATA INTO RAM2
					     Ram2Addr <= baseAddr + conv_std_logic_vector(offset,16);
						  Ram2Data <= baseData + conv_std_logic_vector(offset,16);
						  displayAddr := baseAddr + conv_std_logic_vector(offset,16);
						  displayData := baseData + conv_std_logic_vector(offset,16);
						  temp_2_we := '0';
						  state <= 8;
				    when 8 => --Stop Writting and Update offset
						  temp_2_we := '1';
						  offset := offset+1;
						  if(offset < 10) then
						      state <= 7;
                    else
						      offset := 0;
								state <= 9;
						  end if;
				    when 9 => --Calculate Addr and READ DATA FROM RAM2
						  Ram2Data <= "ZZZZZZZZZZZZZZZZ";
					     Ram2Addr <= baseAddr + conv_std_logic_vector(offset,16);
						  displayAddr := baseAddr + conv_std_logic_vector(offset,16);
						  temp_2_oe := '0';
						  state <= 10;
					 when 10 => --Update offset
					     displayData := Ram2Data;
						  offset := offset+1;
						  if(offset < 10) then
						      state <= 9;
                    else
						      offset := 0;
								state <= 11;
						  end if;
					 when 11 => --Final
				    when others=>
			   end case;
		  end if;
		  

	 end process;

	 real_offset <= offset;
	 Ram1OE <= temp_1_oe;
	 Ram2OE <= temp_2_oe;
	 Ram1WE <= temp_1_we;
	 Ram2WE <= temp_2_we;
	 Ram1EN <= temp_1_en;
	 Ram2EN <= temp_2_en;
	 
	 L(15 downto 8) <= displayAddr(7 downto 0);
	 L(7 downto 0) <= displayData(7 downto 0);
		  
	 RDN <= '1';
	 WRN <= '1';
			  			
    L1: DigitLights port map (DYP0,state);
	 L2: DigitLights port map (DYP1,real_offset);

end Behavioral;

