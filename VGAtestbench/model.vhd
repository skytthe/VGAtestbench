library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity model is
	port (
		clk_i 		: in  std_logic;
		data_i		: in  std_logic;
		data_o		: out std_logic_vector(8 downto 0)
	);
end entity model;

architecture Behavioral of model is
	
begin
	
	generate_label : for i in data_o'range generate
		data_o(i) <= data_i;
	end generate generate_label;
	
	
end architecture Behavioral;
