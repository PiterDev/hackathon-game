class_name KillParticle extends Node3D

@onready var debries: GPUParticles3D = $Debries
@onready var sparks: GPUParticles3D = $Sparks
@onready var smoke: GPUParticles3D = $Smoke

func fire():
	debries.emitting = true
	sparks.emitting = true
	smoke.emitting = true
	
