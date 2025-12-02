---------------------------------------------------------------------------------
--                     Missile Command - Tang Nano 20K
--                          Code from Jim Gregory
--
--                        Modified for Tang Nano 20K 
--                            by pinballwiz.org 
--                               21/11/2025
---------------------------------------------------------------------------------
-- Keyboard inputs :
--   5 : Add coin
--   1 : Start 1 player
--   Z : Fire Left
--   X : Fire Center
--   C : Fire Right
--   RIGHT arrow : Move Crosshair Right
--   LEFT arrow  : Move Crosshair Left
--   UP arrow    : Move Crosshair Up
--   DOWN arrow  : Move Crosshair Down
---------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.ALL;
use ieee.numeric_std.all;
---------------------------------------------------------------------------------
entity missilecommand_tn20k is
port(
	Clock_48    : in std_logic;
   	I_RESET     : in std_logic;
	O_VIDEO_R	: out std_logic_vector(2 downto 0); 
	O_VIDEO_G	: out std_logic_vector(2 downto 0);
	O_VIDEO_B	: out std_logic_vector(1 downto 0);
	O_HSYNC		: out std_logic;
	O_VSYNC		: out std_logic;
	O_AUDIO_L 	: out std_logic;
	O_AUDIO_R 	: out std_logic;
   	ps2_clk     : in std_logic;
	ps2_dat     : inout std_logic;
 	led         : out std_logic_vector(5 downto 0)
 );
end missilecommand_tn20k;
------------------------------------------------------------------------------
architecture struct of missilecommand_tn20k is
 
 signal clock_20 : std_logic;
 signal clock_10 : std_logic;
 signal clock_5  : std_logic;
 signal pll_lock : std_logic;
 --
 signal video_r  : std_logic_vector(7 downto 0);
 signal video_g  : std_logic_vector(7 downto 0);
 signal video_b  : std_logic_vector(7 downto 0);
 --
 signal h_sync          : std_logic;
 signal v_sync	        : std_logic;
 --
 signal h_blank         : std_logic;
 signal v_blank	        : std_logic;
 --
 signal video_r_x2      : std_logic_vector(5 downto 0);
 signal video_g_x2      : std_logic_vector(5 downto 0);
 signal video_b_x2      : std_logic_vector(5 downto 0);
 signal hsync_x2        : std_logic;
 signal vsync_x2        : std_logic;
 --
 signal audio           : std_logic_vector(5 downto 0);
 signal AudioPWM        : std_logic;
 --
 signal vtb_dir1	    : std_logic;
 signal vtb_clk1	    : std_logic;
 signal htb_dir1	    : std_logic;
 signal htb_clk1	    : std_logic;
 --
 signal reset           : std_logic;
 --
 signal joystick_inputs : std_logic_vector(3 downto 0);
 signal joystick_analog : std_logic_vector(15 downto 0);
 signal ps2_mouse       : std_logic_vector(24 downto 0);
 --
 signal kbd_intr        : std_logic;
 signal kbd_scancode    : std_logic_vector(7 downto 0);
 signal joy_BBBBFRLDU   : std_logic_vector(8 downto 0);
 --
 constant CLOCK_FREQ    : integer := 27E6;
 signal counter_clk     : std_logic_vector(25 downto 0);
 signal clock_4hz       : std_logic;
 signal AD              : std_logic_vector(15 downto 0);
---------------------------------------------------------------------------
begin

 reset <= I_RESET;

---------------------------------------------------------------------------
Clock20: entity work.Gowin_rPLL20
    port map (
        clkout  => clock_20,
        clkoutd => clock_10,
        clkin   => clock_48
    );
---------------------------------------------------------------------------
process (clock_10)
begin
 if rising_edge(clock_10) then
  clock_5  <= not clock_5;
 end if;
end process;
---------------------------------------------------------------------------
-- Main

missile_inst :  entity work.missile
  port map (
 clk_10M    => clock_10,
 ce_5M      => clock_5,
 reset      => reset,
 r      	=> video_r,
 g      	=> video_g,
 b     		=> video_b,
 h_sync     => h_sync,
 v_sync 	=> v_sync,
 h_blank    => h_blank,
 v_blank 	=> v_blank,
 audio_o    => audio,
 AD        	=> AD,
 coin    	=> joy_BBBBFRLDU(7), 	-- 5 : Add coin
 p1_start  	=> joy_BBBBFRLDU(5), 	-- 1 : Start 1 Player
 p2_start  	=> joy_BBBBFRLDU(6),    -- 2 : Start 2 Players
 p1_fire_l 	=> joy_BBBBFRLDU(4), 	-- Z : P1 left fire
 p1_fire_c 	=> joy_BBBBFRLDU(8), 	-- X : P1 center fire
 p1_fire_r 	=> joy_BBBBFRLDU(6), 	-- C : P1 right fire
 p2_fire_l 	=> joy_BBBBFRLDU(4), 	-- Z : P2 left fire
 p2_fire_c 	=> joy_BBBBFRLDU(8), 	-- X : P2 center fire
 p2_fire_r 	=> joy_BBBBFRLDU(6), 	-- C : P2 right fire
 vtb_dir1 	=>	vtb_dir1,
 vtb_clk1 	=>	vtb_clk1,
 htb_dir1 	=>	htb_dir1,
 htb_clk1 	=>	htb_clk1,
 vtb_dir2 	=>	'0',
 vtb_clk2 	=>	'0',
 htb_dir2 	=>	'0',
 htb_clk2 	=>	'0'
   );
---------------------------------------------------------------------------  

joystick_inputs <= joy_BBBBFRLDU(0) & joy_BBBBFRLDU(1) & joy_BBBBFRLDU(2) & joy_BBBBFRLDU(3);

  trackball_inst : entity work.trackball
    port map (
		clk  					=>	clock_10,
		flip 					=>	'0',
		joystick				=>	joystick_inputs,
		joystick_mode			=>	'0',
		joystick_analog		    =>	joystick_analog,
		joystick_sensitivity	=>	'0',
		mouse_speed				=>	"00",
		ps2_mouse				=>	ps2_mouse,
		v_dir					=>	vtb_dir1,
		v_clk					=>	vtb_clk1,
		h_dir					=>	htb_dir1,
		h_clk					=>	htb_clk1
	);	
---------------------------------------------------------------------------  
  u_dblscan : entity work.scandoubler
    port map (
		clk_sys => clock_20,
		r_in => video_r(7 downto 2),
		g_in => video_g(7 downto 2),
		b_in => video_b(7 downto 2),
		hs_in => h_sync,
		vs_in => v_sync,
		r_out => video_r_x2,
		g_out => video_g_x2,
		b_out => video_b_x2,
		hs_out => hsync_x2,
		vs_out => vsync_x2,
		scanlines => "00"
	);
-------------------------------------------------------------------------
-- to output

	O_VIDEO_R 	<= video_r_x2(5 downto 3);
	O_VIDEO_G 	<= video_g_x2(5 downto 3);
	O_VIDEO_B 	<= video_b_x2(5 downto 4);
	O_HSYNC		<= hsync_x2;
	O_VSYNC		<= vsync_x2;
-------------------------------------------------------------------------
--dac

  u_dac : entity work.dac
	generic map(
	  msbi_g => 5
	)
	port  map(
	  clk_i   => Clock_10,
	  res_n_i => '1',
	  dac_i   => audio,
	  dac_o   => AudioPWM
	);

 O_AUDIO_L  <= AudioPWM;
 O_AUDIO_R  <= AudioPWM;
------------------------------------------------------------------------------
-- get scancode from keyboard

keyboard : entity work.io_ps2_keyboard
port map (
  clk       => clock_10,
  kbd_clk   => ps2_clk,
  kbd_dat   => ps2_dat,
  interrupt => kbd_intr,
  scancode  => kbd_scancode
);
------------------------------------------------------------------------------
-- translate scancode to joystick

joystick : entity work.kbd_joystick
port map (
  clk         => clock_10,
  kbdint      => kbd_intr,
  kbdscancode => std_logic_vector(kbd_scancode), 
  joy_BBBBFRLDU  => joy_BBBBFRLDU 
);
------------------------------------------------------------------------------
-- debug

process(reset, clock_20)
begin
  if reset = '1' then
    clock_4hz <= '0';
    counter_clk <= (others => '0');
  else
    if rising_edge(clock_20) then
      if counter_clk = CLOCK_FREQ/8 then
        counter_clk <= (others => '0');
        clock_4hz <= not clock_4hz;
        led(5 downto 0) <= not AD(9 downto 4);
      else
        counter_clk <= counter_clk + 1;
      end if;
    end if;
  end if;
end process;
------------------------------------------------------------------------
end struct;