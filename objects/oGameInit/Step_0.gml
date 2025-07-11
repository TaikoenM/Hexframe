/// @description Insert description here
// You can write your code in this editor


if(load_phase == 0) {
	load_phase++
	load_sprites_from_folder("base/sprites")
}

if(load_phase == 1) {
	load_phase++
	load_game_data()
}

