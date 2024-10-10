extends Node2D

@onready var spawns = [
	$Spawn1,
	$Spawn2,
	$Spawn3,
	$Spawn4,
]
@onready var targets = [
	$Target1,
	$Target2,
	$Target3,
	$Target4,
]

@export var note_scene: PackedScene

# Read this to know when to write new notes and where.
var track1 = [
	# [note_time, note_line]
	[1, 1],
	[2, 2],
	[3, 3],
	[4, 1],
	[4, 4],
	[4.5, 1],
	[4.5, 2],
	[5, 3],
	[5, 4],
	[5.5, 1],
]
var track2 = [
	[1, 3],
	[1.5, 2],
	[1.5, 4],
	
	[2.5, 1],
	[3, 2],
	[3.5, 2],
	[3.5, 4],
	
	[4.5, 2],
	[5, 1],
	[5.7, 3],
	[6, 2],
	[6.5, 4],
	[7, 3],
	[7.5, 2],
	[7.5, 4],
]
var track3 = [
	# [note_time, note_line]
	[1, 3],
	[1.5, 4],
	[2, 1],
	[2.5, 4],
	[3, 2],
	[3.5, 4],
	[4.4, 3],
	[4.6, 3],
	[5.5, 1],
	[6, 2],
	[7, 1],
	[7.3, 2],
	[7.6, 3],
]
# green mage final battle
var track4 = [
	# [note_time, note_line]
	[1, 3],
	[1.5, 4],
	[2, 3],
	[2.5, 4],
	[3, 3],
	[3.5, 4],
	[4, 3],
	[4.5, 4],
	[5, 3],
	[5.1, 3],
	[5.5, 4],
	[6, 3],
	[6.5, 4],
	[7, 3],
	[7.5, 4],
	[8, 1],
	[8.1, 1],
	[8.3, 2],
	[8.4, 2],
	[8.6, 3],
	[8.7, 3],
]
var track5 = [
	# [note_time, note_line]
	[0, 1],
	[0.5, 3],
	[0.5, 4],
	
	[1.5, 2],
	[2, 4],
	[2.5, 3],
	[3, 2],
	[3.5, 4],
	[4, 1],
	[4.5, 3],
	[4.5, 4],
	
	[5.5, 3],
	[6, 1],
	[6, 2],
	[6.5, 2],
	[7, 3],
	[7, 4],
	
	#2
	[8, 1],
	[8.5, 3],
	[8.5, 4],
	
	[9.5, 2],
	[10, 4],
	[10.5, 3],
	[11, 2],
	[11.5, 4],
	[12, 1],
	[12.5, 3],
	[12.5, 4],
	
	[13.5, 1],
	[13.7, 1],
	[14, 2],
	[14.5, 4],
	[15, 3],
]
var track0 = [
	# [note_time, note_line]
	[0, 1],
	[0.5, 3],
	[0.5, 4],
]
@onready var sheet_music = track0
	#change this to change which track is played
@onready var time_offset = Time.get_ticks_msec() - (sheet_music[0][0] * 1000.0)

var next_note = 0
#var tempo = 1
var tempo = 0.85
#var tempo = 1.5

# A dictionary of all current notes, organized by line. Starts empty, is populated during runtime.
var active_notes = {
	# Line_number: [array of active notes on that line in order of closest to furthest]
	1: [],
	2: [],
	3: [],
	4: [],
}

# Called when the node enters the scene tree for the first time.
func _ready():
	print("start with time_offset of ", time_offset/1000.0, " seconds")

func _process(_delta):
	for key in active_notes:
		if active_notes[key].size() > 0 and active_notes[key][0].global_position.x < 0:
			var note_removed = active_notes[key].pop_front()
			note_removed.press_poor()

func _physics_process(_delta):
	# Spawn in all the upcoming notes when their time is reached.
	while next_note < sheet_music.size() and \
	(Time.get_ticks_msec() - time_offset)/1000.0 >= sheet_music[next_note][0]*tempo:
		print("make note number ", next_note, " at time ", Time.get_ticks_msec())
		make_note(sheet_music[next_note][1])
		next_note += 1

func _input(event):
	if event.is_action_pressed("move_up"):
		print("UP")
		play_note(1)
	if event.is_action_pressed("move_down"):
		print("DO")
		play_note(2)
	if event.is_action_pressed("move_left"):
		print("LE")
		play_note(3)
	if event.is_action_pressed("move_right"):
		print("RI")
		play_note(4)
	if event.is_action_pressed("reload"):
		print("SPACE, reloading scene")
		get_tree().reload_current_scene()

# Create a new note on the line indicated.
# Line must be an int, 1 through 4, or 0.
# The new note is appended to the corresponding active_notes array.
# Can call with line "0" to make nothing. Used for offset in front.
func make_note(line):
	if line == 0:
		print("no note made at ", Time.get_ticks_msec())
		return
	var note = note_scene.instantiate()
	note.position = spawns[line-1].position
	active_notes[line].push_back(note)
	add_child(note)
	note.set_pitch(1.5 - (line * 0.25))

# Called when the button for the passed line is pressed.
# Check the closest note's proximity to the target
#	and evaluate whether it is a good or bad press.
func play_note(line):
	if active_notes[line].size() <= 0:
		print("PRESS ", line, " EMPTY, time: ", Time.get_ticks_msec())
		return
	
	var distance_to_target = abs(active_notes[line][0].global_position.x - targets[line-1].global_position.x)
	
	if distance_to_target > 300:
		print("PRESS ", line, " FAR, time: ", Time.get_ticks_msec())
	elif distance_to_target > 64:
		print("PRESS ", line, " BAD, time: ", Time.get_ticks_msec())
		var note_removed = active_notes[line].pop_front()
		note_removed.press_poor()
	elif distance_to_target > 30:
		print("PRESS ", line, " GOOD, time: ", Time.get_ticks_msec())
		var note_removed = active_notes[line].pop_front()
		note_removed.press_well()
	else:
		print("PRESS ", line, " GREAT, time: ", Time.get_ticks_msec())
		var note_removed = active_notes[line].pop_front()
		note_removed.press_well()
	
	
