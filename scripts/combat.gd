extends Node

func object_is_world( node : Node ):
	return ( node.collision_layer & 1 != 0 )

func object_is_hitbox( node : Node ):
	return ( node.collision_layer & 16 != 0 )

func hitscan( agressor : Node3D, position : Vector3, direction : Vector3, distance : float, do_penetrate_hitboxes : bool = false, do_penetrate_world : bool = false ):
	if global.check( agressor, "view_height" ):
			position.y += agressor.view_height
	
	var space_state = global.stage.get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.new()
	query.collide_with_areas = true
	query.collide_with_bodies = true
	query.hit_from_inside = true
	query.from = position
	query.to = direction * distance + position
	# colide only with hit hitboxes and the world geometry
	query.collision_mask = 17
	var exclude_array = []
	if "hitbox" in agressor:
		exclude_array = [ agressor.hitbox.get_rid() ]
	
	var hitscan_results : Array = []
	
	for i in range( 1000 ):
		query.set_exclude( exclude_array )
		var result = space_state.intersect_ray( query )

		if result.is_empty():
			break
		
		exclude_array.append( result.rid )
		query.from = result.position

		if object_is_hitbox( result.collider ):
			hitscan_results.append( result )
			if not do_penetrate_hitboxes:
				break
		elif object_is_world( result.collider ):
			hitscan_results.append( result )
			if not do_penetrate_world:
				break
		else:
			print( "hitscan: found something not reconised..." )
			break
			
	return hitscan_results

func hitscan_bullet( agressor : Node3D, position : Vector3, direction : Vector3, attack : Attack ):
	var hit_array = hitscan( agressor, position, direction, 1000, false, false )
	if not hit_array:
		return
	
	var hit_object : Node = hit_array[0].collider
	var enemy : Node = null
	var world : Node = null

	attack.agressor = agressor

	if object_is_hitbox( hit_object ):
		var hitbox = hit_object
		attack.knockback_position = position
		hitbox.parent.health.do_damage( attack )
		return
	else:
		return

const projectile_scene = preload( "res://entities/projectile.tscn" )

func fire_projectile( agressor : Node3D, position : Vector3, direction : Vector3, speed : float, attack : Attack ) -> Projectile:
	var projectile = projectile_scene.instantiate()
	
	if global.check( agressor, "view_height" ):
			position.y += agressor.view_height

	projectile.velocity = direction * speed
	projectile.attack = attack
	projectile.attack_owner = agressor
	
	attack.agressor = agressor
	attack.inflictor = projectile
	
	if global.check( agressor, "infight_group" ):
		attack.infight_group = agressor.infight_group
	
	global.stage.add_child( projectile )
	projectile.global_position = position
	return projectile
