package set

import "core:fmt"
import "core:math/rand"
using import "../components"
import "../renderer"
import "../input"

import "../math"

//Player
player_set :: struct {
	aabb: AABB,
	sprite: sprite_component,
	velocity: math.v2
}
//Player stuff
create_player :: proc(pos, dim: math.v2) -> player_set {
	result: player_set;
	result.sprite.sprite = renderer.init_sprite(pos, dim, "art/player.png");

	result.aabb.transform = result.sprite.transform;

	result.velocity = math.v2{0, 0};

	return result;
}

update_player :: proc(player: ^player_set, input: input.game_input, delta: f32) {
	if input.up {
		player.velocity.y += .05 * delta;
	}
	if input.down {
		player.velocity.y -= .05 * delta;
	}
	if input.left {
		player.velocity.x -= .05 * delta;
	}
	if input.right {
		player.velocity.x += .05 * delta;
	}
	player.sprite.transform.pos.x += player.velocity.x;
	player.sprite.transform.pos.y += player.velocity.y;

	//AABB
	//Update AABB
	player.aabb.transform = player.sprite.transform;
	if aabb_check_against_edge(player.aabb) {
		player.velocity.x *= -1;
		player.velocity.y *= -1;
	}

	player.sprite.transform.pos.x += player.velocity.x;
	player.sprite.transform.pos.y += player.velocity.y;

	//TODO: Slide
	player.velocity.x = 0;
	player.velocity.y = 0;
}

draw_player :: proc(player: ^player_set, program: u32, pr_matrix: math.mat4) {
	renderer.use_program(program);
	renderer.set_uniforms(player.sprite.transform, pr_matrix, program);
	renderer.draw_sprite(&player.sprite);
}

//Bouncey 

bounce_set :: struct {
	aabb: AABB,
	sprite: sprite_component,
	velocity: math.v2,
}

create_bounce :: proc(pos: math.v2, random: ^rand.Rand) -> bounce_set {
	result: bounce_set;
	//TODO: Different size bounceies?
	result.sprite.sprite = renderer.init_sprite(pos, math.v2{0.5, 0.5}, "art/bounce.png");
	result.aabb.transform = result.sprite.transform;

	rand_vec := math.v2{rand.float32(random), rand.float32(random)};
	//TODO: Variable speed even more
	rand_vec.x *= .0005;
	rand_vec.y *= .0005;

	result.velocity = rand_vec;

	return result;
}

update_bounce :: proc(bounce: ^bounce_set, delta: f32) {
	bounce.sprite.transform.pos.x += bounce.velocity.x;
	bounce.sprite.transform.pos.y += bounce.velocity.y;

	//AABB
	//Update AABB
	bounce.aabb.transform = bounce.sprite.transform;
	if aabb_check_against_edge(bounce.aabb) {
		bounce.velocity.x *= -1;
		bounce.velocity.y *= -1;
	}	
}

draw_bounce :: proc(bounce: ^bounce_set, program: u32, pr_matrix: math.mat4) {
	renderer.use_program(program);
	renderer.set_uniforms(bounce.sprite.transform, pr_matrix, program);
	renderer.draw_sprite(&bounce.sprite);
}

//Non player stuff
//TODO: Move this to a better place
aabb_check_against_edge :: proc(aabb: AABB) -> bool{
	if 	aabb.pos.x - aabb.scale.x/2 < 0		||
		aabb.pos.x + aabb.scale.x/2 > 16 	||
		aabb.pos.y - aabb.scale.y/2 < 0		||
		aabb.pos.y + aabb.scale.y/2 > 9 {
		return true;
	}else {
		return false;
	}
}