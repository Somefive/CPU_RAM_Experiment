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
    port(CLK,RST: in STD_LOGIC; --单步时钟信号CLK和复位信号RST
		  SW: in STD_LOGIC_VECTOR(15 downto 0); --初始地址和数据输入
		  Ram1Addr: out STD_LOGIC_VECTOR(17 downto 0); --RAM1地址
		  L: out STD_LOGIC_VECTOR(15 downto 0); --发光二极管显示地址低8位及数据低8位
		  Ram1Data: inout STD_LOGIC_VECTOR(15 downto 0); --RAM1数据
		  Ram1OE,Ram1WE,Ram1EN: out STD_LOGIC; --RAM1输出使能、写使能、使能
		  Ram2Addr: out STD_LOGIC_VECTOR(17 downto 0); --RAM2地址
		  Ram2Data: inout STD_LOGIC_VECTOR(15 downto 0); --RAM2数据
		  Ram2OE,Ram2WE,Ram2EN: out STD_LOGIC; --RAM2输出使能、写使能、使能
		  DYP0: out STD_LOGIC_VECTOR(6 downto 0); --七段数码管测试输出
		  DYP1: out STD_LOGIC_VECTOR(6 downto 0); --七段数码管测试输出
		  RDN: out STD_LOGIC; --锁住串口
		  WRN: out STD_LOGIC --锁住串口
        );
end Main;

architecture Behavioral of Main is

component DigitLights is
	Port ( L : out  STD_LOGIC_VECTOR (6 downto 0);
           NUMBER : in  INTEGER);
end component;

    signal state: INTEGER := 0; --初态
	 shared variable tempAddr: STD_LOGIC_VECTOR(17 downto 0) := "000000000000000000"; --暂存地址的临时变量
	 shared variable tempData: STD_LOGIC_VECTOR(15 downto 0) := "0000000000000000"; --暂存数据的临时变量
	 shared variable offset: INTEGER RANGE 0 TO 10 := 0; --记录读写的次数 10次为上限
	 signal real_offset: INTEGER RANGE 0 TO 10 := 0; --记录读写的次数 10次为上限
	 shared variable temp_1_oe,temp_1_we,temp_2_oe,temp_2_we: STD_LOGIC := '1'; --暂存使能信号
	 shared variable temp_1_en,temp_2_en: STD_LOGIC := '0'; --暂存使能信号
begin
    process(CLK , RST)
	 begin
	    if(RST = '0') then --RST被按下 初始化
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
		  elsif(CLK'event and CLK = '1') then --上升沿到来 开始操作
		      case state is
				    when 0 => --首个状态 读入地址单元的地址
					     tempAddr(15 downto 0) := SW;
					     state <= 1;
				    when 1 => --第2个状态 读入初始数据 第一次写入RAM1
					     tempData := SW;
						  temp_1_we := '0';
						  Ram1Addr <= tempAddr;
						  Ram1Data <= tempData;
						  offset := offset + 1;
						  state <= 2;		  

					 when 2 => --第3个状态 拉高写信号
        				  temp_1_we := '1';
                    state <= 3;
						  
				    when 3 => --第4个状态 拉低写信号 地址、数据各加1，然后写入 还需要9次
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
						  
				    when 4 => --第5个状态 准备读RAM1 需要拉高写信号 拉低读信号 同时将数据线设置成高阻
						  Ram1Data <= "ZZZZZZZZZZZZZZZZ";
					     temp_1_we := '1';
						  temp_1_oe := '0';
						  state <= 5;
						  Ram1Addr <= tempAddr;
						  
				    when 5 => --第6个状态 读RAM1 需要10次
					     tempData := Ram1Data;
						  offset := offset + 1;
						  tempAddr := tempAddr - '1';
						  Ram1Addr <= tempAddr;
						  if(offset = 10) then
						      offset := 0;
								Ram1Addr <= tempAddr + '1';
						      state <= 6;
						  end if;
						  
					 when 6 => --第7个状态 切换到RAM2 需要将RAM1的读和写信号拉高 准备写入第一个数据
                    temp_1_oe := '1';
						  temp_1_we := '1';
						  tempData := tempData - '1';
						  tempAddr := tempAddr + '1';
						  state <= 7;
						  	  
				    when 7 => --第8个状态 写入剩下的10个数据
					     temp_2_we := '0';
						  Ram2Data <= tempData;
						  Ram2Addr <= tempAddr;
						  offset := offset + 1;
						  state <= 8;
						  
				    when 8 => --第9个状态 拉高写信号
					     temp_2_we := '1';
						  state <= 9;
						  
				    when 9 => --第10个状态 拉低写信号 继续写
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
						  
					 when 10 => --第11个状态 准备读RAM2 需要拉高写信号 拉低读信号 同时将数据线设置成高阻
						  Ram2Data <= "ZZZZZZZZZZZZZZZZ";
					     temp_2_we := '1';
						  temp_2_oe := '0';
						  state <= 11;
					 
					 when 11 => --第12个状态 继续读
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
	 
	 L(15 downto 8) <= tempAddr(7 downto 0); --输出地址低8位
	 L(7 downto 0) <= tempData(7 downto 0); --输出数据低8位
		  
	 rdn <= '1';
	 wrn <= '1';
			  			
    L1: DigitLights port map (DYP0,state);
	 L2: DigitLights port map (DYP1,real_offset);

end Behavioral;

