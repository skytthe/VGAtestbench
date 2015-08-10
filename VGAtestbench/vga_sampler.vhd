library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;

entity vga_sampler is
	port (
		r_i		: in std_logic_vector(2 downto 0);
		g_i		: in std_logic_vector(2 downto 0);
		b_i		: in std_logic_vector(2 downto 0);
		hsync_i : in std_logic;
		vsync_i	: in std_logic
	);
end entity vga_sampler;

architecture Behavioral of vga_sampler is

	file output_file : text open write_mode is "data_output.txt";

	signal tk : std_logic;
	
	
begin


	
end architecture Behavioral;
