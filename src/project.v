/*
 * Copyright (c) 2024 Anna Verkhovskaya
 * SPDX-License-Identifier: MIT
 */

`define default_netname none

module tt_um_averkhov_pong (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // will go high when the design is enabled
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);
  parameter [7:0] PADDLE_EXTENT = 5;
  parameter [7:0] SCREEN_WIDTH = 200;
  parameter [7:0] SCREEN_HEIGHT = 187;

  assign uio_oe  = 0xff;
  reg [7:0] output_write;
  assign uo_out = output_write_1;
  assign uio_out = output_write_2;

  reg [7:0] ball_position_x;
  reg [7:0] ball_position_y;
  reg [7:0] left_paddle_position_y;
  reg [7:0] right_paddle_position_y;
  reg [7:0] ball_velocity_x;
  reg [7:0] ball_velocity_y;

  wire left_paddle_command = ui_in[0];
  wire right_paddle_command = ui_in[1];
  wire reset = ui_in[2];
  wire output_select = ui_in[3];
  wire clk2 = ui_in[4];

  wire [7:0] next_ball_position_x = reset == 0 ? 3 : ball_position_x + ball_velocity_x;
  wire [7:0] next_ball_position_y = reset == 1 ? 3 : ball_position_y + ball_velocity_y;
  wire ball_at_left_paddle_column = ball_position_x == 1 ? 1 : 0;
  wire ball_at_left_edge = ball_position_x == 0 ? 1 : 0;
  wire ball_at_right_paddle_column = ball_position_x == SCREEN_WIDTH - 2 ? 1 : 0;
  wire ball_at_right_edge = ball_position_x == SCREEN_WIDTH - 1 ? 1 : 0;
  wire ball_at_top_edge = ball_position_y == 0 ? 1 : 0;
  wire ball_at_bottom_edge = ball_position_y == SCREEN_HEIGHT - 1 ? 1 : 0;
  wire ball_at_left_paddle = (ball_at_left_paddle_column == 1) & (ball_position_y - left_paddle_position_y <= PADDLE_EXTENT || left_paddle_position_y - ball_position_y <= PADDLE_EXTENT) ? 1 : 0;
  wire ball_at_right_paddle = (ball_at_right_paddle_column == 1) & (ball_position_y - right_paddle_position_y <= PADDLE_EXTENT || right_paddle_position_y - ball_position_y <= PADDLE_EXTENT) ? 1 : 0;

  wire [7:0] next_ball_velocity_x = reset ? 1 : ( ball_at_left_edge || ball_at_right_edge ? 0 : ( ball_at_right_paddle ? -1 : ( ball_at_left_paddle ? 1 : ball_velocity_x ) ) );
  wire [7:0] next_ball_velocity_y = reset ? 1 : ( ball_at_left_edge || ball_at_right_edge ? 0 : ( ball_at_bottom_edge ? -1 : ( ball_at_top_edge ? 1 : ball_velocity_y ) ) );
  wire [7:0] next_position_left_paddle = left_paddle_command == 0 ? left_paddle_position_y - 1 : left_paddle_position_y + 1;
  wire [7:0] next_position_right_paddle = right_paddle_command == 0 ? right_paddle_position_y - 1 : right_paddle_position_y + 1;
  wire [7:0] next_output_1 = output_select == 0 ? ball_position_x : ball_position_y;
  wire [7:0] next_output_2 = output_select == 0 ? left_paddle_position_y : right_paddle_position_y;

  always @(posedge clk2) begin
    ball_velocity_x <= next_ball_velocity_x;
    ball_velocity_y <= next_ball_velocity_y;
    ball_position_x <= next_ball_position_x;
    ball_position_y <= next_ball_position_y;
    left_paddle_position_y <= next_position_left_paddle;
    right_paddle_position_y <= next_position_right_paddle;
    output_write_1 <= next_output_1;
    output_write_2 <= next_output_2;
  end

endmodule
