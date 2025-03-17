extends Area3D
class_name PickupComponent

@onready var parent : Node3D = get_parent()

func _ready():
	self.body_entered.connect( _body_entered )

func _body_entered( toucher: Node3D ) -> void:
	if "do_pickup" in parent: parent.do_pickup( toucher )
