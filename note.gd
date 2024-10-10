extends Node2D

const SPEED = 500.0
const MIN_SCALE = 0.1

@onready var _sprite = $Sprite2D
@onready var _stream1 = $AudioStreamPlayer
@onready var _stream2 = $AudioStreamPlayer2

# Has the note been pressed and how well
enum State {
	UNPRESSED = 0,
	BAD_PRESS = 1,
	GOOD_PRESS = 2,
}

# Which cord does the note travel on, top to bottom.
enum Cord {
	NO_LINE = 0,
	LINE1 = 1,
	LINE2 = 2,
	LINE3 = 3,
	LINE4 = 4,
}

var note_state = State.UNPRESSED
var note_cord = Cord.NO_LINE
var distance = 2000

func _ready():
	if note_state == State.BAD_PRESS:
		press_poor()
	if note_state == State.GOOD_PRESS:
		press_well()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var new_scale = _sprite.get_scale().x - delta*0.9
	if new_scale <= MIN_SCALE:
		queue_free()
	match note_state:
		State.UNPRESSED:
			position.x -= SPEED * delta
		State.BAD_PRESS:
			_sprite.set_rotation( _sprite.get_rotation() + delta*2 )
			_sprite.set_scale( Vector2(new_scale, new_scale) )
		State.GOOD_PRESS:
			_sprite.set_scale( Vector2(new_scale, new_scale) )

# Called once when the note is pressed incorrectly.
func press_poor():
	note_state = State.BAD_PRESS
	_sprite.set_scale(Vector2(0.7, 0.7))
	_sprite.set_modulate(Color(1,0,0))
	_stream2.play()

# Called once when the note is pressed in close proximity to the target.
func press_well():
	note_state = State.GOOD_PRESS
	_sprite.set_scale(Vector2(0.9, 0.9))
	_sprite.set_modulate(Color(0,1,0))
	_stream1.play()

# This is used to set the pitch of the note's sound effects.
func set_pitch(pitch):
	_stream1.set_pitch_scale(pitch)
	_stream2.set_pitch_scale(pitch)
