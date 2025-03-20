class_name MaterialReferences
extends RefCounted

static var refs: Array[MaterialTextureReference] = []

static func compile_material_references():
	const path := 'res://audio/material_references'
	var dir = DirAccess.open(path)

	for file in dir.get_files():
		var res = load(path + '/' + file) as MaterialTextureReference
		refs.append(res)
	
	for ref in refs:
		print_rich('LOADED MAT REF - loaded [color=CYAN]%s[/color]' % ref)