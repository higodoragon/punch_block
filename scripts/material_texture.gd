class_name MaterialTextureReference extends Resource

enum MATERIAL_KIND {
	CONCRETE,
	GRASS,
	GRAVEL,
	WATER,
}

@export var material_file: StandardMaterial3D
@export var material_kind: MATERIAL_KIND = MATERIAL_KIND.CONCRETE