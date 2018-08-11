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
    velocity: math.v2,
    health: i32,
    invincible: bool,
    timer: f32,
    score: i32,
}
//Player stuff
create_player :: proc(pos, dim: math.v2) -> player_set {
    result: player_set;
    result.sprite.sprite = renderer.init_sprite(pos, dim, "art/player.png");
    
    result.aabb.transform = result.sprite.transform;
    
    result.velocity = math.v2{0, 0};
    result.health = 3;
    
    result.invincible = false;
    result.timer = 0;
    
    return result;
}

update_player :: proc(player: ^player_set, input: input.game_input, bounce: ^[]bounce_set, max: i32, delta: f32) {
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
    
    //Check against bounces
    if !player.invincible{
        for i in 0..max {
            if aabb_against_aabb(player.aabb, bounce[i].aabb) {
                player.health -= 1;
                player.invincible = true;
                player.timer = 100.0;
            }
        }
    }else {
        player.timer -= delta;
        if player.timer <= 0 {
            player.invincible = false;
        }
    }
    if player.health <= 0 {
        //TODO: Loose condition
    }
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

create_bounce :: proc(random: ^rand.Rand) -> bounce_set {
    result: bounce_set;
    pos := math.v2{rand.float32(random) * 16, rand.float32(random) * 9};
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
    //fmt.println(bounce.sprite.sprite);
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

aabb_against_aabb ::proc(a, b: AABB) -> bool {
    if a.pos.x - a.scale.x/2 < b.pos.x + b.scale.x/2 &&
        a.pos.x + a.scale.x/2 > b.pos.x - b.scale.x/2 &&
        a.pos.y - a.scale.y/2 < b.pos.y + b.scale.y/2 &&
        a.pos.y + a.scale.y/2 > b.pos.y - b.scale.y/2 {
        return true;
    }else{
        return false;
    }
}

//Heart/Health bar

heart_set :: struct {
    sprite: sprite_component,
    count: i32,
    spacing: f32,
}

create_heart :: proc(pos: math.v2) -> heart_set {
    result: heart_set;
    //TODO: Different size bounceies?
    result.sprite.sprite = renderer.init_sprite(pos, math.v2{0.5, 0.5}, "art/heart.png");
    
    result.count = 3;
    //Magic number for spacing
    result.spacing = 0.2;
    
    return result;
}

draw_hearts :: proc(hearts: ^heart_set, player: player_set, program: u32, pr_matrix: math.mat4) {
    hearts.count = player.health;
    
    renderer.use_program(program);
    for i in 0..hearts.count {
        temp := hearts.sprite.transform;
        temp.pos.x += cast(f32)i * hearts.spacing;
        renderer.set_uniforms(temp, pr_matrix, program);
        renderer.draw_sprite(&hearts.sprite);
    }
}

//Coin
//This is the point system
//Grab em get points

coin_set :: struct {
    sprite: sprite_component,
    aabb: AABB,
}

create_coin :: proc(random: ^rand.Rand) -> coin_set {
    result: coin_set;
    rand_vec := math.v2{rand.float32(random) * 16, rand.float32(random) * 9};
    
    result.sprite.sprite = renderer.init_sprite(rand_vec, math.v2{0.65, 0.65}, "art/pickup.png");
    result.aabb.transform = result.sprite.transform;
    
    return result;
}

update_coin :: proc(coin: ^coin_set, player: ^player_set, random: ^rand.Rand) {
    if aabb_against_aabb(player.aabb, coin.aabb) {
        rand_vec := math.v2{rand.float32(random) * 16, rand.float32(random) * 9};
        coin.sprite.transform = renderer.transform{rand_vec, coin.sprite.transform.scale};
        coin.aabb.transform = coin.sprite.transform;
        
        player.score += 1;
    }
}

draw_coin :: proc(coin: ^coin_set, program: u32, pr_matrix: math.mat4) {
    renderer.use_program(program);
    renderer.set_uniforms(coin.sprite.transform, pr_matrix, program);
    renderer.draw_sprite(&coin.sprite);
}

//This is the coin UI
coin_ui_set :: struct {
    sprite: sprite_component,
    count: i32,
    spacing: f32,
}

create_coin_ui :: proc(pos: math.v2) -> coin_ui_set {
    result: coin_ui_set;
    result.sprite.sprite = renderer.init_sprite(pos, math.v2{0.45, 0.45}, "art/pickup.png");
    
    result.count = 0;
    //Magic number for spacing
    result.spacing = 0.2;
    
    return result;
}

draw_coin_ui :: proc(coins: ^coin_ui_set, player: player_set, program: u32, pr_matrix: math.mat4) {
    coins.count = player.score;
    
    renderer.use_program(program);
    for i in 0..coins.count {
        temp := coins.sprite.transform;
        temp.pos.x += cast(f32)i * coins.spacing;
        renderer.set_uniforms(temp, pr_matrix, program);
        renderer.draw_sprite(&coins.sprite);
    }
}

//This is for power ups
power_up_type :: enum {
	HEALTH,
	SPEED,
	REMOVE,
}

power_up_set :: struct {
	aabb: AABB,
	sprite: sprite_component,
	p_type: power_up_type,
}

create_power_up :: proc(random: ^rand.Rand) -> power_up_set {
	result: power_up_set;
    rand_vec := math.v2{rand.float32(random) * 16, rand.float32(random) * 9};
    
    rand := rand.uint32(random) % 2;
    result.sprite.sprite = renderer.init_sprite(rand_vec, math.v2{0.65, 0.65}, "art/pickup.png");
    result.aabb.transform = result.sprite.transform;
    
    return result;
}