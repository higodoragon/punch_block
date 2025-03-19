class_name MaterialTextureReference extends Resource

enum MATERIAL_KIND {
	CONCRETE,
	GRASS,
	GRAVEL,
	WATER,
}

@export var material_file : StandardMaterial3D
@export var meterial_kind : MATERIAL_KIND = MATERIAL_KIND.CONCRETE
