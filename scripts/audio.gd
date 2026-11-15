extends Node
## Short synthesized WAV streams are built once. No external audio or plugins.
var muted: bool = false
var streams: Dictionary = {}
var players: Array[AudioStreamPlayer] = []
var voice: int = 0
var music_clock: float = 0.0
var music_index: int = 0

func _ready() -> void:
	for i in range(10):
		var player = AudioStreamPlayer.new()
		player.volume_db = -12.0
		add_child(player)
		players.append(player)
	streams.jump = _synth(190,560,.15,0)
	streams.coin = _synth(990,1450,.1,0)
	streams.hit = _synth(170,30,.4,2)
	streams.smash = _synth(480,85,.17,2)
	streams.roar = _synth(110,35,.5,2)
	streams.fire = _synth(380,65,.22,2)
	for i in range(1,6):
		streams["stomp"+str(i)] = _synth(260+i*65,560+i*130,.13,1)
	var notes = [523.0,659.0,784.0,1046.0,784.0,659.0,698.0,880.0]
	for i in range(notes.size()):
		streams["note"+str(i)] = _synth(notes[i],notes[i],.09,0)

func _synth(first: float,last: float,duration: float,wave: int) -> AudioStreamWAV:
	var count = int(duration*22050)
	var bytes = PackedByteArray()
	bytes.resize(count*2)
	var phase = 0.0
	for i in range(count):
		var t = float(i)/count
		var frequency = first*pow(last/first,t)
		phase = fmod(phase+frequency/22050.0,1.0)
		var amplitude = 1.0 if phase<.5 else -1.0
		if wave == 1:
			amplitude = 1.0-4.0*absf(phase-.5)
		elif wave == 2:
			amplitude = phase*2.0-1.0
		var envelope = minf(1.0,float(i)/80.0)*pow(1.0-t,1.8)
		bytes.encode_s16(i*2,int(amplitude*envelope*8500.0))
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = 22050
	stream.stereo = false
	stream.data = bytes
	return stream

func play(effect: String, quiet: bool = false) -> void:
	if muted or not streams.has(effect):
		return
	var player = players[voice % players.size()]
	voice += 1
	player.stream = streams[effect]
	player.volume_db = -23.0 if quiet else -12.0
	player.play()

func star_music(delta: float, active: bool) -> void:
	if not active:
		music_clock = 0.0
		music_index = 0
		return
	music_clock -= delta
	if music_clock<=0:
		play("note"+str(music_index%8),true)
		music_index += 1
		music_clock = .12

func stop_sounds() -> void:
	for player in players:
		player.stop()
