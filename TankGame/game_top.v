/*=======================================================
Author				:				ctlvie
Email Address		:				ctlvie@gmail.com
Filename			:				game_top.v
Date				:				2018-05-06
Description			:				the top module

Modification History:
Date		By			Version		Description
----------------------------------------------------------
180506		ctlvie		0.5			Module interface definition and modules links
180507		ctlvie		0.6			Update some modules' interfaces
180510		ctlvie		0.8			Bugs fixed:
									1. change enemy tanks' speed to clk_2Hz
									2. cancel the VGA enable signal
180510		ctlvie		1.5			Full Version!
180515		ctlvie		1.8			Updated Version!
180525		ctlvie		2.0			Final Version
========================================================*/

`timescale 1ns/1ns

module game_top
(	
	input 					clk,
	
	input 					bt_w,
	input 					bt_a,
	input 					bt_s,
	input 					bt_d,
	input 					bt_st,
	input		[15:0]		sw,	
	input					fpga_rxd,
	output					Hsync,
	output					Vsync,
	output		[3:0]		vgaRed,
	output		[3:0]		vgaBlue,
	output		[3:0]		vgaGreen,
	output		[3:0]		an,
	output		[6:0]		seg,
	output					dp,
	output		[15:0]		led,
	output					fpga_txd,
	output					audio
);

//----------------------------------------
//wires definition
//clocks
wire			clk_2Hz;
wire			clk_4Hz;
wire			clk_8Hz;
wire			clk_100M;
wire			clk_VGA;


wire	[4:0]	bul1_x;
wire	[4:0]	bul1_y;
wire	[4:0]	bul2_x;
wire	[4:0]	bul2_y;
wire	[4:0]	bul3_x;
wire	[4:0]	bul3_y;
wire	[4:0]	bul4_x;
wire	[4:0]	bul4_y;

//wires about my tank
wire			mytank_en;
wire	[4:0]	mytank_xpos;
wire	[4:0]	mytank_ypos;
wire 	[4:0]	mytank_xpos_feedback;// = mytank_xpos;
wire 	[4:0]	mytank_ypos_feedback;// = mytank_ypos;
wire	[1:0]	mytank_dir;
wire			mytank_sht;
wire			mytank_state;
wire			mybul_state_fb;

//wires about enemy tank 1
wire			enytank1_en;
wire			enytank1_state;
wire	[4:0]	enytank1_xpos;
wire	[4:0]	enytank1_ypos;
wire	[1:0]	enytank1_dir;
wire			enybul1_state_fb;

//wires about enemy tank 2
wire			enytank2_en;
wire			enytank2_state;
wire	[4:0]	enytank2_xpos;
wire	[4:0]	enytank2_ypos;
wire	[1:0]	enytank2_dir;
wire			enybul2_state_fb;

//wires about enemy tank 3
wire			enytank3_en;
wire			enytank3_state;
wire	[4:0]	enytank3_xpos;
wire	[4:0]	enytank3_ypos;
wire	[1:0]	enytank3_dir;
wire			enybul3_state_fb;

//wires about enemy tank 4
wire			enytank4_en;
wire			enytank4_state;
wire	[4:0]	enytank4_xpos;
wire	[4:0]	enytank4_ypos;
wire	[1:0]	enytank4_dir;
wire			enybul4_state_fb;

//wires about bullets
wire	[4:0]	mybul_xpos;
wire	[4:0]	mybul_ypos;
wire	[4:0]	mybul_xpos_feedback;
wire	[4:0]	mybul_ypos_feedback;
wire	[11:0]	VGA_data_mybul;	
wire	[4:0]	bul1_x_feedback;
wire	[4:0]	bul1_y_feedback;
wire			bul1_state;
wire	[11:0]	VGA_data_bul1;
wire	[4:0]	bul2_x_feedback;
wire	[4:0]	bul2_y_feedback;
wire			bul2_state;
wire	[11:0]	VGA_data_bul2;
wire	[4:0]	bul3_x_feedback;
wire	[4:0]	bul3_y_feedback;
wire			bul3_state;
wire	[11:0]	VGA_data_bul3;
wire	[4:0]	bul4_x_feedback;
wire	[4:0]	bul4_y_feedback;
wire			bul4_state;
wire	[11:0]	VGA_data_bul4;
wire	[11:0]	VGA_data_mytank;
wire	[11:0]	VGA_data_enytank1;
wire	[11:0]	VGA_data_enytank2;
wire	[11:0]	VGA_data_enytank3;
wire	[11:0]	VGA_data_enytank4;
wire	[11:0]	VGA_data_info;
wire	[11:0]	VGA_data_reward;
wire	[11:0]	VGA_data_reward_laser;
wire 	[10:0]	VGA_xpos;
wire 	[10:0]	VGA_ypos;
wire 	[11:0]	VGA_data;

wire		enable_bul1;
wire		enable_bul2;
wire		enable_bul3;
wire		enable_bul4;
wire		enable_mybul;
wire		enable_mytank_app;
wire		enable_mytank_phy;
wire		enable_enytank1_app;
wire		enable_enytank1_phy;
wire		enable_enytank2_app;
wire		enable_enytank2_phy;
wire		enable_enytank3_app;
wire		enable_enytank3_phy;
wire		enable_enytank4_app;
wire		enable_enytank4_phy;
wire		enable_gamelogic;
wire		enable_reward;
wire		enable_startmusic;	
wire        enable_gamemusic;	
wire		enable_shootmusic;

wire		[4:0]		HP_value;
wire		[5:0]		timer;
wire		[6:0]		score;
wire		[11:0]		VGA_data_interface;
wire		[2:0]		mode;
wire				kill1;
wire				kill2;
wire				kill3;
wire				kill4;
wire				kill;
assign				kill = kill1 | kill2 | kill3 | kill4;

wire	[6:0]		score1;
wire	[6:0]		score2;
wire	[6:0]		score3;
wire	[6:0]		score4;
wire				gameover;


wire				gameover_classic;
wire				gameover_infinity;
wire				enable_game_classic;
wire				enable_game_infinity;
wire	[3:0]		an_classic;
wire	[15:0]		seg_classic;
wire	[15:0]		led_classic;
wire	[3:0]		an_infinity;
wire	[15:0]		seg_infinity;
wire	[15:0]		led_infinity;
wire	[6:0]		score_classic;
wire	[6:0]		score_infinity;

wire				btn_wireless_w;
wire				btn_wireless_s;
wire				btn_wireless_a;
wire				btn_wireless_d;
wire				btn_wireless_st;
wire				btn_wireless_tri;
wire				btn_wireless_sqr;
wire				btn_wireless_cir;
wire				btn_wireless_cro;
wire				btn_w ;
wire				btn_s ;
wire				btn_a ;
wire				btn_d ;
wire				btn_st;
wire				btn_mode_sel;
wire				btn_return;
wire				btn_stop;

wire				reward_addtime;
wire				reward_faster;
wire				reward_frozen;
wire				reward_invincible;
wire				reward_laser;
wire				start_protect;


assign 			bul1_x 			= 		bul1_x_feedback;
assign 			bul2_x 			= 		bul2_x_feedback;
assign 			bul3_x 			= 		bul3_x_feedback;
assign 			bul4_x 			= 		bul4_x_feedback;
assign 			bul1_y 			= 		bul1_y_feedback;
assign 			bul2_y 			= 		bul2_y_feedback;
assign 			bul3_y 			= 		bul3_y_feedback;
assign 			bul4_y 			= 		bul4_y_feedback;
assign			mybul_xpos 		= 		mybul_xpos_feedback;
assign			mybul_ypos 		= 		mybul_ypos_feedback;
assign			mytank_xpos 	= 		mytank_xpos_feedback;
assign			mytank_ypos 	= 		mytank_ypos_feedback;




clk_wiz_0 u_VGA_clock
   (
    // Clock out ports
    .clk_out1	(clk_100M),     // output clk_out1
    .clk_out2	(clk_VGA),     // output clk_out2
   // Clock in ports
    .clk_in1	(clk)
	);		


	
clock u_clock
(
	.clk			(clk_100M),
	.reward_faster	(reward_faster),
	.clk_4Hz		(clk_4Hz),
	.clk_8Hz		(clk_8Hz),
	.clk_2Hz		(clk_2Hz)
);


game_mode_v2  u_game_mode_v2
(
	.clk				(clk_100M),	
	.bt_st				(btn_st),
	.btn_mode_sel		(btn_mode_sel),
	.btn_return			(btn_return),
	.gameover_classic	(gameover_classic),
	.gameover_infinity	(gameover_infinity),
	.enable_bul1		(enable_bul1),
	.enable_bul2		(enable_bul2),
	.enable_bul3		(enable_bul3),
	.enable_bul4		(enable_bul4),
	.enable_mybul		(enable_mybul),
	.enable_mytank_app	(enable_mytank_app),
	.enable_mytank_phy	(enable_mytank_phy),
	.enable_enytank1_app(enable_enytank1_app),
	.enable_enytank1_phy(enable_enytank1_phy),
	.enable_enytank2_app(enable_enytank2_app),
	.enable_enytank2_phy(enable_enytank2_phy),
	.enable_enytank3_app(enable_enytank3_app),
	.enable_enytank3_phy(enable_enytank3_phy),
	.enable_enytank4_app(enable_enytank4_app),
	.enable_enytank4_phy(enable_enytank4_phy),
	.enable_game_classic(enable_game_classic),
	.enable_game_infinity(enable_game_infinity),
	.enable_reward		(enable_reward),
	.enable_startmusic	(enable_startmusic),
	.enable_gamemusic	(enable_gamemusic),
	.start_protect		(start_protect),
//	.enable_shootmusic	(enable_shootmusic),
	.mode				(mode)
);   

game_logic_classic u_game_logic_classic
(	
	.clk				(clk_100M),
	.btn_return			(btn_return),
	.btn_stop			(btn_stop),
	.enable_game_classic(enable_game_classic),
	.mytank_state		(mytank_state),
	.scorea				(score1),
	.scoreb				(score2),
	.scorec				(score3),
	.scored				(score4),
	.reward_invincible	(reward_invincible),
	.HP_value			(HP_value),
	.seg_classic		(seg_classic),
	.led_classic		(led_classic),
	.gameover_classic	(gameover_classic),
	.score_classic		(score_classic)
);

game_logic_infinity u_game_logic_infinity
(
	.clk				(clk_100M),
	.btn_return			(btn_return),
	.btn_stop			(btn_stop),
	.enable_game_infinity(enable_game_infinity),
	.scorea				(score1),
	.scoreb				(score2),
	.scorec				(score3),
	.scored				(score4),
	.reward_addtime		(reward_addtime),
	.reward_test		(sw[4]),
	.timer				(timer),
	.seg_infinity		(seg_infinity),
	.led_infinity		(led_infinity),
	.gameover_infinity	(gameover_infinity),
	.score_infinity		(score_infinity)
);

game_information	u_game_information
(
	.clk					(clk_100M),
	.enable_game_classic	(enable_game_classic),
	.enable_game_infinity	(enable_game_infinity),
	.mode					(mode),
	.HP_print				(HP_value),
	.time_print				(timer),
	.VGA_xpos				(VGA_xpos),
	.VGA_ypos				(VGA_ypos),
	.VGA_data				(VGA_data_info)
);

game_SegAndLed 	u_game_SegAndLed
(
	.clk					(clk_100M),
	.mode					(mode),
	.sw						(sw),
	.led_classic			(led_classic),
	.led_infinity			(led_infinity),
	.seg_classic			(seg_classic),
	.seg_infinity			(seg_infinity),
	.score_classic			(score_classic),
	.score_infinity			(score_infinity),
	.enable_game_classic	(enable_game_classic),
	.enable_game_infinity	(enable_game_infinity),
	.an						(an),
	.seg					(seg),
	.led					(led)
);


game_interface  u_game_interface
(
	.clk			(clk_100M),
	.clk_4Hz		(clk_4Hz),
	.clk_8Hz		(clk_8Hz),
	.btn_mode_sel	(btn_mode_sel),
	.mode			(mode),
	.VGA_xpos		(VGA_xpos),
	.VGA_ypos		(VGA_ypos),
	.VGA_data		(VGA_data_interface)
);


uart_controller  u_uart_controller
( 
	.clk			(clk_100M),		
	.fpga_rxd		(fpga_rxd),		//pc 2 fpga uart receiver
	.fpga_txd		(fpga_txd),		//fpga 2 pc uart transfer
	.bt_w			(btn_wireless_w),
	.bt_s			(btn_wireless_s),
	.bt_a			(btn_wireless_a),
	.bt_d			(btn_wireless_d),
	.bt_st			(btn_wireless_st),
	.bt_tri			(btn_wireless_tri),
	.bt_sqr			(btn_wireless_sqr),
	.bt_cir			(btn_wireless_cir),
	.bt_cro			(btn_wireless_cro)
);

music_controller	u_music_controller
(
	.clk				(clk_100M),
	.sw1				(enable_startmusic),
	.sw2				(enable_gamemusic),
	.btnC				(btn_st),
	.kill				(kill),
	.audio				(audio)
);

reward_logic	u_reward_logic
(
	.clk					(clk_100M),
	.clk_4Hz				(clk_4Hz),
	.enable_reward			(enable_reward),
	.enable_game_classic	(enable_game_classic),
	.enable_game_infinity	(enable_game_infinity),
	.mytank_xpos			(mytank_xpos), 
	.mytank_ypos			(mytank_ypos),
	.VGA_xpos				(VGA_xpos),
	.VGA_ypos				(VGA_ypos),
	.sw						(sw),
	.start_protect			(start_protect),
	.reward_invincible		(reward_invincible),
	.reward_addtime			(reward_addtime),
	.reward_faster			(reward_faster),
	.reward_frozen			(reward_frozen),
	.reward_laser			(reward_laser),
	.VGA_data_reward		(VGA_data_reward)
);


reward_laser	u_reward_laser
(
	.clk			(clk_100M),
	.enable_reward	(enable_reward),
	.reward_laser	(reward_laser),
	.mytank_xpos	(mytank_xpos),
	.mytank_ypos	(mytank_ypos),
	.mytank_dir		(mytank_dir),
	.VGA_xpos		(VGA_xpos),
	.VGA_ypos		(VGA_ypos),
	.VGA_data		(VGA_data_reward_laser)
);


button_logic	u_button_logic
(
	.clk				(clk_100M),
	.sw					(sw),
	.bt_w				(bt_w),
	.bt_s				(bt_s),
	.bt_a				(bt_a),
	.bt_d				(bt_d),
	.bt_st				(bt_st),
	.btn_wireless_w		(btn_wireless_w),
	.btn_wireless_s		(btn_wireless_s),
	.btn_wireless_a		(btn_wireless_a),
	.btn_wireless_d		(btn_wireless_d),
	.btn_wireless_st	(btn_wireless_st),
	.btn_wireless_tri	(btn_wireless_tri),
	.btn_wireless_sqr	(btn_wireless_sqr),
	.btn_wireless_cir	(btn_wireless_cir),
	.btn_wireless_cro	(btn_wireless_cro),
	.btn_w				(btn_w),
	.btn_s  			(btn_s),
	.btn_a  			(btn_a),
	.btn_d  			(btn_d),
	.btn_st 			(btn_st),
	.btn_mode_sel		(btn_mode_sel),
	.btn_stop			(btn_stop),
	.btn_return			(btn_return)
);





mytank_app u_mytank_app
(
	.clk			(clk_100M),
	.clk_4Hz		(clk_4Hz),
	.enable			(enable_mytank_app),
	.tank_en		(1'b1),	//enable  
	
	// input button direction (w,a,s,d)
	.bt_w			(btn_w),
	.bt_a			(btn_a),
	.bt_s			(btn_s),
	.bt_d			(btn_d),
	.bt_st			(btn_st), // shoot button
	
	//input the position of each bullet
	.bul1_x			(bul1_x),
	.bul1_y			(bul1_y),
	.bul2_x			(bul2_x),
	.bul2_y			(bul2_y),
	.bul3_x			(bul3_x),
	.bul3_y			(bul3_y),
	.bul4_x			(bul4_x),
	.bul4_y			(bul4_y),
	
	.mybul_state_feedback	(mybul_state_fb),
	//relative position input and output
	.x_rel_pos_in		(mytank_xpos),
	.y_rel_pos_in		(mytank_ypos),
	.x_rel_pos_out		(mytank_xpos_feedback),
	.y_rel_pos_out		(mytank_ypos_feedback),
	
	.tank_state		(mytank_state),
	
	.tank_dir_out	(mytank_dir),
	.bul_sht		(mytank_sht)
);


enytank_app u_enytank1_app
(	
	.clk			(clk_100M),
	.clk_4Hz		(clk_2Hz),
	.clk_8Hz		(clk_8Hz),
	.enable			(enable_enytank1_app),
	.tank_en		(enytank1_en),
	
	.tank_num		(2'b00),
	.mybul_x		(mybul_xpos),
	.mybul_y		(mybul_ypos),
	
	.mytank_xpos	(mytank_xpos),
	.mytank_ypos	(mytank_ypos),
	.reward_frozen	(reward_frozen),
	.reward_laser	(reward_laser),
	.mytank_dir			(mytank_dir),
	
	.kill				(kill1),
	.score				(score1),
	
	.enybul_state_feedback	(enybul1_state_fb),
	.enybul_state	(bul1_state),
	.tank_state		(enytank1_state),
	.enytank_xpos	(enytank1_xpos),
	.enytank_ypos	(enytank1_ypos),
	.tank_dir_out	(enytank1_dir)
);


enytank_app u_enytank2_app
(	
	.clk			(clk_100M),
	.clk_4Hz		(clk_2Hz),
	.clk_8Hz		(clk_8Hz),
	.enable			(enable_enytank2_app),
	.tank_en		(enytank2_en),
	
	.tank_num		(2'b01),
	.mybul_x		(mybul_xpos),
	.mybul_y		(mybul_ypos),
	
	.mytank_xpos	(mytank_xpos),
	.mytank_ypos	(mytank_ypos),
	.reward_frozen	(reward_frozen),
	.reward_laser	(reward_laser),
	.mytank_dir			(mytank_dir),
	.kill				(kill2),
	.score				(score2),
	
	.enybul_state_feedback	(enybul2_state_fb),
	.enybul_state	(bul2_state),
	.tank_state		(enytank2_state),
	.enytank_xpos	(enytank2_xpos),
	.enytank_ypos	(enytank2_ypos),
	.tank_dir_out	(enytank2_dir)
);



enytank_app u_enytank3_app
(	
	.clk			(clk_100M),
	.clk_4Hz		(clk_2Hz),
	.clk_8Hz		(clk_8Hz),
	.enable			(enable_enytank3_app),
	.tank_en		(enytank3_en),
	
	.tank_num		(2'b10),
	.mybul_x		(mybul_xpos),
	.mybul_y		(mybul_ypos),
	.reward_frozen	(reward_frozen),
	.reward_laser	(reward_laser),
	.mytank_dir			(mytank_dir),
	
	.mytank_xpos	(mytank_xpos),
	.mytank_ypos	(mytank_ypos),
	.kill				(kill3),
	.score				(score3),
	
	.enybul_state_feedback	(enybul3_state_fb),
	.enybul_state	(bul3_state),
	.tank_state		(enytank3_state),
	.enytank_xpos	(enytank3_xpos),
	.enytank_ypos	(enytank3_ypos),
	.tank_dir_out	(enytank3_dir)
);



enytank_app u_enytank4_app
(	
	.clk			(clk_100M),
	.clk_4Hz		(clk_2Hz),
	.clk_8Hz		(clk_8Hz),
	.enable			(enable_enytank4_app),
	.tank_en		(enytank4_en),
	
	.tank_num		(2'b11),
	.mybul_x		(mybul_xpos),
	.mybul_y		(mybul_ypos),
	.reward_frozen	(reward_frozen),
	.reward_laser	(reward_laser),
	.mytank_dir			(mytank_dir),
	
	.mytank_xpos	(mytank_xpos),
	.mytank_ypos	(mytank_ypos),
	.kill				(kill4),
	.score			(score4),
	
	.enybul_state_feedback	(enybul4_state_fb),
	.enybul_state	(bul4_state),
	.tank_state		(enytank4_state),
	.enytank_xpos	(enytank4_xpos),
	.enytank_ypos	(enytank4_ypos),
	.tank_dir_out	(enytank4_dir)
);


bullet u_mybullet
(
	.clk		(clk_100M),
	.clk_8Hz	(clk_8Hz),
	.enable		(enable_mybul),
	.bul_ide	(1'b0),

	
	.bul_dir	(mytank_dir),	//the direction of bullet
	.bul_state	(mytank_sht),	//the state of my bullet
	
	.tank_xpos	(mytank_xpos),
	.tank_ypos	(mytank_ypos),
	//input and output the position of my bullet
	.x_bul_pos_out	(mybul_xpos_feedback),
	.y_bul_pos_out	(mybul_ypos_feedback),
	
	//input VGA scan coordinate
	.VGA_xpos	(VGA_xpos),
	.VGA_ypos	(VGA_ypos),
	
	//input the VGA data
	.VGA_data	(VGA_data_mybul),
	
	.bul_state_feedback	(mybul_state_fb)
);
	

bullet u_bul1
(
	.clk		(clk_100M),
	.clk_8Hz	(clk_8Hz),
	.enable		(enable_bul1),
	.bul_ide	(1'b1),

	
	.bul_dir	(enytank1_dir),	//the direction of bullet
	.bul_state	(bul1_state),	//the state of my bullet
	
	.tank_xpos	(enytank1_xpos),
	.tank_ypos	(enytank1_ypos),
	//input and output the position of my bullet
	.x_bul_pos_out	(bul1_x_feedback),
	.y_bul_pos_out	(bul1_y_feedback),
	
	//input VGA scan coordinate
	.VGA_xpos	(VGA_xpos),
	.VGA_ypos	(VGA_ypos),
	
	//input the VGA data
	.VGA_data	(VGA_data_bul1),
	
	.bul_state_feedback	(enybul1_state_fb)
);



bullet u_bul2
(
	.clk		(clk_100M),
	.clk_8Hz	(clk_8Hz),
	.enable		(enable_bul2),
	.bul_ide	(1'b1),

	
	.bul_dir	(enytank2_dir),	//the direction of bullet
	.bul_state	(bul2_state),	//the state of my bullet
	
	.tank_xpos	(enytank2_xpos),
	.tank_ypos	(enytank2_ypos),
	//input and output the position of my bullet
	.x_bul_pos_out	(bul2_x_feedback),
	.y_bul_pos_out	(bul2_y_feedback),
	
	//input VGA scan coordinate
	.VGA_xpos	(VGA_xpos),
	.VGA_ypos	(VGA_ypos),
	
	//input the VGA data
	.VGA_data	(VGA_data_bul2),
	
	.bul_state_feedback	(enybul2_state_fb)
);



bullet u_bul3
(
	.clk		(clk_100M),
	.clk_8Hz	(clk_8Hz),
	.enable		(enable_bul3),
	.bul_ide	(1'b1),

	
	.bul_dir	(enytank3_dir),	//the direction of bullet
	.bul_state	(bul3_state),	//the state of my bullet
	
	.tank_xpos	(enytank3_xpos),
	.tank_ypos	(enytank3_ypos),
	//input and output the position of my bullet
	.x_bul_pos_out	(bul3_x_feedback),
	.y_bul_pos_out	(bul3_y_feedback),
	
	//input VGA scan coordinate
	.VGA_xpos	(VGA_xpos),
	.VGA_ypos	(VGA_ypos),
	
	//input the VGA data
	.VGA_data	(VGA_data_bul3),
	
	.bul_state_feedback	(enybul3_state_fb)
);



bullet u_bul4
(
	.clk		(clk_100M),
	.clk_8Hz	(clk_8Hz),
	.enable		(enable_bul4),
	.bul_ide	(1'b1),

	
	.bul_dir	(enytank4_dir),	//the direction of bullet
	.bul_state	(bul4_state),	//the state of my bullet
	
	.tank_xpos	(enytank4_xpos),
	.tank_ypos	(enytank4_ypos),
	//input and output the position of my bullet
	.x_bul_pos_out	(bul4_x_feedback),
	.y_bul_pos_out	(bul4_y_feedback),
	
	//input VGA scan coordinate
	.VGA_xpos	(VGA_xpos),
	.VGA_ypos	(VGA_ypos),
	
	//input the VGA data
	.VGA_data	(VGA_data_bul4),
	
	.bul_state_feedback	(enybul4_state_fb)
);



tank_phy	mytank_phy
(
	.clk		(clk_100M),
	.enable		(enable_mytank_phy),

	//input the relative position of tank
	.x_rel_pos	(mytank_xpos),
	.y_rel_pos	(mytank_ypos),
	.VGA_xpos	(VGA_xpos),
	.VGA_ypos	(VGA_ypos),
	
	.tank_state	(mytank_state),	//the state of tank
	.tank_ide	(1'b1),	//the identify of tank (my tank(1'b1) or enemy tank(1'b0))
	.tank_dir	(mytank_dir),	//the direction of tank
	
	//output the VGA data
	.VGA_data	(VGA_data_mytank)
);



tank_phy	enytank1_phy
(
	.clk		(clk_100M),
	.enable		(enable_enytank1_phy),
	//input the relative position of tank
	.x_rel_pos	(enytank1_xpos),
	.y_rel_pos	(enytank1_ypos),
	.VGA_xpos	(VGA_xpos),
	.VGA_ypos	(VGA_ypos),
	
	.tank_state	(enytank1_state),	//the state of tank
	.tank_ide	(1'b0),	//the identify of tank (my tank(1'b1) or enemy tank(1'b0))
	.tank_dir	(enytank1_dir),	//the direction of tank
	
	//output the VGA data
	.VGA_data	(VGA_data_enytank1)
);



tank_phy	enytank2_phy
(
	.clk		(clk_100M),
	.enable		(enable_enytank2_phy),
	//input the relative position of tank
	.x_rel_pos	(enytank2_xpos),
	.y_rel_pos	(enytank2_ypos),
	.VGA_xpos	(VGA_xpos),
	.VGA_ypos	(VGA_ypos),
	
	.tank_state	(enytank2_state),	//the state of tank
	.tank_ide	(1'b0),	//the identify of tank (my tank(1'b1) or enemy tank(1'b0))
	.tank_dir	(enytank2_dir),	//the direction of tank
	
	//output the VGA data
	.VGA_data	(VGA_data_enytank2)
);



tank_phy	enytank3_phy
(
	.clk		(clk_100M),
	.enable		(enable_enytank3_phy),
	//input the relative position of tank
	.x_rel_pos	(enytank3_xpos),
	.y_rel_pos	(enytank3_ypos),
	.VGA_xpos	(VGA_xpos),
	.VGA_ypos	(VGA_ypos),
	
	.tank_state	(enytank3_state),	//the state of tank
	.tank_ide	(1'b0),	//the identify of tank (my tank(1'b1) or enemy tank(1'b0))
	.tank_dir	(enytank3_dir),	//the direction of tank
	
	//output the VGA data
	.VGA_data	(VGA_data_enytank3)
);



tank_phy	enytank4_phy
(
	.clk		(clk_100M),
	.enable		(enable_enytank4_phy),
	//input the relative position of tank
	.x_rel_pos	(enytank4_xpos),
	.y_rel_pos	(enytank4_ypos),
	.VGA_xpos	(VGA_xpos),
	.VGA_ypos	(VGA_ypos),
	
	.tank_state	(enytank4_state),	//the state of tank
	.tank_ide	(1'b0),	//the identify of tank (my tank(1'b1) or enemy tank(1'b0))
	.tank_dir	(enytank4_dir),	//the direction of tank
	
	//output the VGA data
	.VGA_data	(VGA_data_enytank4)
);


VGA_data_selector u_VGA_data_selector
(
	.clk	(clk_100M),
//input interfaces
	.in1	(VGA_data_bul1),
	.in2	(VGA_data_bul2),
	.in3	(VGA_data_bul3),
	.in4	(VGA_data_bul4),
	.in5	(VGA_data_enytank1),
	.in6	(VGA_data_enytank2),
	.in7	(VGA_data_enytank3),
	.in8	(VGA_data_enytank4),
	.in9	(VGA_data_mybul),
	.in10	(VGA_data_mytank),
	.in11	(VGA_data_interface),
	.in12	(VGA_data_info),
	.in13	(VGA_data_reward),
	.in14	(VGA_data_reward_laser),
	.in15	(0),
	.in16	(0),
	.in17	(0),
	.in18	(0),
	.in19	(0),
	.in20	(0),
//output interfaces	
	.out	(VGA_data)
);

		
				
VGA_driver		u_VGA_driver
(
//global clock
	.clk		(clk_VGA),
	.rst_n		(1'b1),

//vga interface
	.Hsync		(Hsync),
	.Vsync		(Vsync),
	.VGA_en		(),
	.vgaRed		(vgaRed),
	.vgaBlue	(vgaBlue),
	.vgaGreen	(vgaGreen),

//user interface
	.VGA_request(),
	.VGA_xpos	(VGA_xpos),
	.VGA_ypos	(VGA_ypos),
	.VGA_data	(VGA_data)
);

tank_generate	u_tank_generate
(	
	.clk_4Hz	(clk_4Hz),
	
	.tank1_state(enytank1_state),
	.tank2_state(enytank2_state),
	.tank3_state(enytank3_state),
	.tank4_state(enytank4_state),
	
	.tank1_en	(enytank1_en),
	.tank2_en	(enytank2_en),
	.tank3_en	(enytank3_en),
	.tank4_en	(enytank4_en)
);

endmodule