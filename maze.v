`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:58:53 12/06/2021 
// Design Name: 
// Module Name:    maze 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module maze(
	input 		          clk,
	input [5:0]  starting_col, starting_row, 	// indicii punctului de start
	input  			  maze_in, 			// oferã informa?ii despre punctul de coordonate [row, col]
	output reg[5:0] row, col,	 		// selecteazã un rând si o coloanã din labirint
	output reg		 maze_oe,			// output enable (activeazã citirea din labirint la rândul ?i coloana date) - semnal sincron	
	output reg 		 maze_we, 			// write enable (activeazã scrierea în labirint la rândul ?i coloana date) - semnal sincron
	output reg	  	 done = 0);		 	// ie?irea din labirint a fost gasitã; semnalul rãmane activ 

	
	`define direction 5
	`define direction_change 6
	`define direction_right 7
	`define right_check 8
	`define direction_forward 9
	`define forward_check 10
	`define final_state 11 //starile automatului
	
	`define right 0
	`define left 1
	`define up 2
	`define down 3
	`define init 4 //directiile de deplasare

	reg[5:0] copy_row, copy_col; //variabile in care este retinuta pozitia precedenta
	reg[5:0] state = `init; //stare
	reg[5:0] next_state; //urmatoarea stare
	reg[1:0] direc; //directia de deplasare
	
	always @(posedge clk) begin
		if (done == 0) begin
			state <= next_state;
		end
	end

	always @(*) begin
		maze_we = 0;
		maze_oe = 0;
	
		case(state)
			`init: begin //starea initiala
				maze_we = 1;
				row = starting_row;
				col = starting_col;
				direc = `right; //prima directie de deplasare
				next_state = `direction;
			end
		
			`direction: begin //starea in care se testeaza sensul deplasarii
			//retinem linia si coloana in variabile
				copy_row = row;
				copy_col = col;
				maze_oe = 1;
				case(direc)
					`right: begin
						col = col + 1;
					 end
					`left: begin
						col = col - 1;
					 end
					`up: begin 
						row = row - 1;
					 end
					`down: begin
						row = row + 1;
					 end
				endcase
				
				next_state = `direction_change;
			end
			
			`direction_right: begin //starea in care se incearca deplasarea in dreapta
				copy_row = row;
				copy_col = col;
				maze_oe = 1;
				case(direc)
					`right: begin
						col = col + 1;
					 end
					`left: begin
						col = col - 1;
					 end
					`up: begin 
						row = row - 1;
					 end
					`down: begin
						row = row + 1;
					 end
				endcase
				
				next_state = `right_check;
			end
			
			`direction_forward: begin //starea in care se incearca deplasarea in fata
				copy_row = row;
				copy_col = col;
				maze_oe = 1;
				case(direc)
					`right: begin
						col = col + 1;
					 end
					`left: begin
						col = col - 1;
					 end
					`up: begin 
						row = row - 1;
					 end
					`down: begin
						row = row + 1;
					 end
				endcase
				
				next_state = `forward_check;
			end
			
			`direction_change: begin
				if(maze_in == 1) begin //verificam daca intalnim sau nu perete
					row = copy_row;	
					col = copy_col;
					//se revine la pozitia anterioara
					direc = direc + 1; //testam urmatarea directie
					next_state = `direction;
				end
				else if (maze_in == 0) begin
					maze_we = 1; //marcam punctul prin care se trece
					next_state = `direction_right; //se incearca deplasarea la dreapta
				end
			end
				
			`right_check: begin
				if(maze_in == 1) begin //daca intalnim perete, trecem in alta stare
					row = copy_row;
					col = copy_col;
					next_state = `direction_forward;
				end
				else if (maze_in == 0) begin //daca nu avem perete, schimbam directia in sens orar
					case(direc)
						`right: begin 
							direc = `down; 
						end
						`left: begin 
							direc = `up; 
						end
						`up: begin 
							direc = `right; 
						end
						`down: begin 
							direc = `left; 
						end
					endcase
					maze_we = 1;
					next_state = `final_state;
				end
			end
			
			`forward_check: begin
				if(maze_in == 1) begin
					row = copy_row;
					col = copy_col;
					next_state = `final_state;
					case(direc) //schimbam directia in sens opus orar
						`right: begin 
							direc = `up; 
						end
						`left: begin 
							direc = `down; 
						end
						`up: begin 
							direc = `left; 
						end
						`down: begin 
							direc = `right; 
						end
					endcase
					
				end
				else if (maze_in == 0) begin
					maze_we = 1;
					next_state = `final_state;
				end
			end
			
			`final_state: begin
				if (maze_in == 1) begin //in cazul existentei unui perete, continuam deplasarea
					next_state = `direction_right;
				end
				else if(maze_in == 0) begin
					if(row == 0 || row == 63 || col == 0 || col == 63) begin //verificam daca am ajuns la finalul labirintului
						maze_we = 1;
						done = 1;
					end
					else begin //daca nu exista perete, dar nu este finalul labirintului, continuam deplasarea
						next_state = `direction_right;
					end
				end
			
			end
		endcase
	end
	endmodule
