package input

import "shared:odin-glfw"

game_input :: struct {
	keys: [348]bool,

	up, down, left, right: bool
}

update :: proc(input: ^game_input, keys: [348]bool) {
	if keys[glfw.KEY_W] {
		input.up = true;
	} else {
		input.up = false;
	}
	if keys[glfw.KEY_S] {
		input.down = true;
	} else {
		input.down = false;
	}
	if keys[glfw.KEY_A] {
		input.left = true;
	} else {
		input.left = false;
	}
	if keys[glfw.KEY_D] {
		input.right = true;
	} else {
		input.right = false;
	}
}