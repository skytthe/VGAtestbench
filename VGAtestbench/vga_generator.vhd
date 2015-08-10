library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.log_pkg.all;

entity vga_generator is
	generic(
--		G_CLK_FREQ_HZ	: integer := 40000000;
		G_PXL_CLK_PRD	: time    := 25 ns;
		G_COLOR_WIDTH	: integer := 10;
	
		----------------
		-- 640x480@60 --
		----------------
--		C_H_Pulse 	: integer := 96;
--		C_H_FP 		: integer := 16;
--		C_H_BP 		: integer := 48;
--		C_H_PX 		: integer := 640;
--		
--		C_HS_OFFSET 	: integer := C_H_Pulse+C_H_BP;	
--		C_PIXEL_PR_LINE : integer := C_H_FP+C_H_Pulse+C_H_BP+C_H_PX;		
--			
--		C_V_Pulse 	: integer := 2;
--		C_V_FP 		: integer := 10;
--		C_V_BP 		: integer := 33;
--		C_V_LN 		: integer := 480;
--		
--		C_VS_OFFSET 		: integer := C_V_Pulse+C_V_BP;	
--		C_LINES_PR_FRAME 	: integer := C_V_FP+C_V_Pulse+C_V_BP+C_V_LN	

		----------------
		-- 800x600@60 --
		----------------
		C_H_Pulse 	: integer := 128;
		C_H_FP 		: integer := 40;
		C_H_BP 		: integer := 88;
		C_H_PX 		: integer := 800;
		
		C_HS_OFFSET 	: integer := C_H_Pulse+C_H_BP;	
		C_HS_OFFSET2 	: integer := C_H_Pulse+C_H_BP+C_H_PX;	
		C_PIXEL_PR_LINE : integer := C_H_FP+C_H_Pulse+C_H_BP+C_H_PX;		
			
		C_V_Pulse 	: integer := 4;
		C_V_FP 		: integer := 1;
		C_V_BP 		: integer := 23;
		C_V_LN 		: integer := 600;
		
		C_VS_OFFSET 		: integer := C_V_Pulse+C_V_BP;
		C_VS_OFFSET2		: integer := C_V_Pulse+C_V_BP+C_V_LN;
		C_LINES_PR_FRAME 	: integer := C_V_FP+C_V_Pulse+C_V_BP+C_V_LN		
	);
	port (
		r_o		: out std_logic_vector(G_COLOR_WIDTH-1 downto 0);
		g_o		: out std_logic_vector(G_COLOR_WIDTH-1 downto 0);
		b_o		: out std_logic_vector(G_COLOR_WIDTH-1 downto 0);
		hsync_o : out std_logic;
		vsync_o	: out std_logic		
	);
end entity vga_generator;

architecture Behavioral of vga_generator is
	
	signal pxl_clk			: std_logic;
	
	signal pixel_cnt_reg : unsigned(log2r(C_PIXEL_PR_LINE) downto 0) := (others=>'0');
	signal pixel_cnt_nxt : unsigned(log2r(C_PIXEL_PR_LINE) downto 0);
	
	signal line_cnt_reg : unsigned(log2r(C_LINES_PR_FRAME) downto 0) := (others=>'0');
	signal line_cnt_nxt : unsigned(log2r(C_LINES_PR_FRAME) downto 0);	
	
	signal mem_adr  : std_logic_vector(18 downto 0);
	signal mem_data	: std_logic;
begin


	-- pixel clock generator
	process
	begin
		pxl_clk <= '0';
		wait for G_PXL_CLK_PRD/2;
		pxl_clk <= '1';
		wait for G_PXL_CLK_PRD/2;
	end process;
	
	-- HS and VS generator
	process(pxl_clk)
	begin
		if rising_edge(pxl_clk) then		
			pixel_cnt_reg <= pixel_cnt_nxt;
			line_cnt_reg <= line_cnt_nxt;
		end if;
	end process;
	
	pixel_cnt_nxt <=	pixel_cnt_reg+1 when pixel_cnt_reg<C_PIXEL_PR_LINE-1 
										else 
						(others=>'0');
	line_cnt_nxt  <=	line_cnt_reg+1 	when pixel_cnt_reg=C_PIXEL_PR_LINE-1 and 
											 line_cnt_reg<C_LINES_PR_FRAME-1 
										else 
						(others=>'0')  	when pixel_cnt_reg=C_PIXEL_PR_LINE-1 
						 				else
						line_cnt_reg;
	
	hsync_o <= '0' when pixel_cnt_reg < C_H_pulse else '1';
	vsync_o <= '0' when line_cnt_reg  < C_V_Pulse else '1';


	r_o <=	(others=>'1')	 when	(pixel_cnt_reg >= (C_HS_OFFSET)   and 
									 pixel_cnt_reg <= (C_HS_OFFSET2)  and 
									 line_cnt_reg  >= (C_VS_OFFSET)   and 
									 line_cnt_reg  <= (C_VS_OFFSET2))
							else
			(others=>'0');
	g_o <=	(others=>'1')	 when	(pixel_cnt_reg >= (C_HS_OFFSET)   and 
									 pixel_cnt_reg <= (C_HS_OFFSET2)  and 
									 line_cnt_reg  >= (C_VS_OFFSET)   and 
									 line_cnt_reg  <= (C_VS_OFFSET2))
							else
			(others=>'0');
	b_o <=	(others=>'1')	 when	(pixel_cnt_reg >= (C_HS_OFFSET)   and 
									 pixel_cnt_reg <= (C_HS_OFFSET2)  and 
									 line_cnt_reg  >= (C_VS_OFFSET)   and 
									 line_cnt_reg  <= (C_VS_OFFSET2)) --and 
--									 mem_data = '1'
							else
			(others=>'0');
	
		pong_image_rom : entity work.image_rom
		port map(
			clk_i  => pxl_clk,
			adr_i  => mem_adr,
			data_o => mem_data
		);
	
end architecture Behavioral;

