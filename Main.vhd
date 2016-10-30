----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:28:33 11/05/2015 
-- Design Name: 
-- Module Name:    io - Behavioral 
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
    port(CLK,RST: in STD_LOGIC; --����ʱ���ź�CLK�͸�λ�ź�RST
		  SW: in STD_LOGIC_VECTOR(15 downto 0); --��ʼ��ַ����������
		  Ram1Addr: out STD_LOGIC_VECTOR(17 downto 0); --RAM1��ַ
		  L: out STD_LOGIC_VECTOR(15 downto 0); --�����������ʾ��ַ��8λ�����ݵ�8λ
		  Ram1Data: inout STD_LOGIC_VECTOR(15 downto 0); --RAM1����
		  Ram1OE,Ram1WE,Ram1EN: out STD_LOGIC; --RAM1���ʹ�ܡ�дʹ�ܡ�ʹ��
		  Ram2Addr: out STD_LOGIC_VECTOR(17 downto 0); --RAM2��ַ
		  Ram2Data: inout STD_LOGIC_VECTOR(15 downto 0); --RAM2����
		  Ram2OE,Ram2WE,Ram2EN: out STD_LOGIC; --RAM2���ʹ�ܡ�дʹ�ܡ�ʹ��
		  DYP0: out STD_LOGIC_VECTOR(6 downto 0); --�߶�����ܲ������
		  DYP1: out STD_LOGIC_VECTOR(6 downto 0); --�߶�����ܲ������
		  RDN: out STD_LOGIC; --��ס����
		  WRN: out STD_LOGIC --��ס����
        );
end Main;

architecture Behavioral of Main is

component DigitLights is
	Port ( L : out  STD_LOGIC_VECTOR (6 downto 0);
           NUMBER : in  INTEGER);
end component;

    signal state: INTEGER := 0; --��̬
	 shared variable tempAddr: STD_LOGIC_VECTOR(17 downto 0) := "000000000000000000"; --�ݴ��ַ����ʱ����
	 shared variable tempData: STD_LOGIC_VECTOR(15 downto 0) := "0000000000000000"; --�ݴ����ݵ���ʱ����
	 shared variable offset: INTEGER RANGE 0 TO 10 := 0; --��¼��д�Ĵ��� 10��Ϊ����
	 signal real_offset: INTEGER RANGE 0 TO 10 := 0; --��¼��д�Ĵ��� 10��Ϊ����
	 shared variable temp_1_oe,temp_1_we,temp_2_oe,temp_2_we: STD_LOGIC := '1'; --�ݴ�ʹ���ź�
	 shared variable temp_1_en,temp_2_en: STD_LOGIC := '0'; --�ݴ�ʹ���ź�
begin
    process(CLK , RST)
	 begin
	    if(RST = '0') then --RST������ ��ʼ��
		      tempAddr := "000000000000000000";
				tempData := "0000000000000000";
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
		  elsif(CLK'event and CLK = '1') then --�����ص��� ��ʼ����
		      case state is
				    when 0 => --�׸�״̬ �����ַ��Ԫ�ĵ�ַ
					     tempAddr(15 downto 0) := SW;
					     state <= 1;
				    when 1 => --��2��״̬ �����ʼ���� ��һ��д��RAM1
					     tempData := SW;
						  temp_1_we := '0';
						  Ram1Addr <= tempAddr;
						  Ram1Data <= tempData;
						  offset := offset + 1;
						  state <= 2;		  

					 when 2 => --��3��״̬ ����д�ź�
        				  temp_1_we := '1';
                    state <= 3;
						  
				    when 3 => --��4��״̬ ����д�ź� ��ַ�����ݸ���1��Ȼ��д�� ����Ҫ9��
					     temp_1_we := '0';
					     tempData := tempData + '1';
						  tempAddr := tempAddr + '1';
						  Ram1Data <= tempData;
						  Ram1Addr <= tempAddr;
						  offset := offset + 1;
						  if(offset < 10) then
								state <= 2;
						  elsif(offset = 10) then
						      offset := 0;
								state <= 4;
						  end if;
						  
				    when 4 => --��5��״̬ ׼����RAM1 ��Ҫ����д�ź� ���Ͷ��ź� ͬʱ�����������óɸ���
						  Ram1Data <= "ZZZZZZZZZZZZZZZZ";
					     temp_1_we := '1';
						  temp_1_oe := '0';
						  state <= 5;
						  Ram1Addr <= tempAddr;
						  
				    when 5 => --��6��״̬ ��RAM1 ��Ҫ10��
					     tempData := Ram1Data;
						  offset := offset + 1;
						  tempAddr := tempAddr - '1';
						  Ram1Addr <= tempAddr;
						  if(offset = 10) then
						      offset := 0;
								Ram1Addr <= tempAddr + '1';
						      state <= 6;
						  end if;
						  
					 when 6 => --��7��״̬ �л���RAM2 ��Ҫ��RAM1�Ķ���д�ź����� ׼��д���һ������
                    temp_1_oe := '1';
						  temp_1_we := '1';
						  tempData := tempData - '1';
						  tempAddr := tempAddr + '1';
						  state <= 7;
						  	  
				    when 7 => --��8��״̬ д��ʣ�µ�10������
					     temp_2_we := '0';
						  Ram2Data <= tempData;
						  Ram2Addr <= tempAddr;
						  offset := offset + 1;
						  state <= 8;
						  
				    when 8 => --��9��״̬ ����д�ź�
					     temp_2_we := '1';
						  state <= 9;
						  
				    when 9 => --��10��״̬ ����д�ź� ����д
					     temp_2_we := '0';
					     tempData := tempData + '1';
						  tempAddr := tempAddr + '1';
						  Ram2Data <= tempData;
						  Ram2Addr <= tempAddr;
						  offset := offset + 1;
						  if(offset < 10) then
								state <= 8;
						  elsif(offset = 10) then
						      state <= 10;
								offset := 0;
						  end if;
						  
					 when 10 => --��11��״̬ ׼����RAM2 ��Ҫ����д�ź� ���Ͷ��ź� ͬʱ�����������óɸ���
						  Ram2Data <= "ZZZZZZZZZZZZZZZZ";
					     temp_2_we := '1';
						  temp_2_oe := '0';
						  state <= 11;
					 
					 when 11 => --��12��״̬ ������
					     tempData := Ram2Data;
						  offset := offset + 1;
						  tempAddr := tempAddr - '1'; 
						  Ram2Addr <= tempAddr;
						  if(offset = 10) then
						      offset := 0;
								Ram2Addr <= tempAddr + '1';
						      state <= 12;
						  end if;
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
	 
	 L(15 downto 8) <= tempAddr(7 downto 0); --�����ַ��8λ
	 L(7 downto 0) <= tempData(7 downto 0); --������ݵ�8λ
		  
	 rdn <= '1';
	 wrn <= '1';
			  			
    L1: DigitLights port map (DYP0,state);
	 L2: DigitLights port map (DYP1,real_offset);

end Behavioral;

