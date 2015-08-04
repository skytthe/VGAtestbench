library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--library UNISIM;
--use UNISIM.VComponents.all;

entity tb_vga is
end entity tb_vga;

architecture Behavioral of tb_vga is
	constant clk_40M_period : time      := 25 ns;
	signal clk_40M          : std_logic := '0';

	signal mem_adr 		: std_logic_vector(18 downto 0) 	:= (others => '0');
	signal mem_data		: std_logic 							:= '0';

begin

	-- Clock process definitions
	clk_40M_process : process
	begin
		clk_40M <= '0';
		wait for clk_40M_period / 2;
		clk_40M <= '1';
		wait for clk_40M_period / 2;
	end process;

	-- Component declarations
	pong_image_rom : entity work.image_rom
		port map(
			clk_i  => clk_40M,
			adr_i  => mem_adr,
			data_o => mem_data
		);


	process(clk_40M)
		variable c : natural := 0;
	begin
		if rising_edge(clk_40M) then
			c := c +1;
			mem_adr <= std_logic_vector(to_unsigned(c, mem_adr'length));
		end if;
	end process;
	
	-- Stimulus process
	stim_proc : process
	begin
		wait for clk_40M_period*800*600;
	end process;

end architecture Behavioral;
