class_name BuildTool
extends Node

enum BuildingUnit { NONE, RAIL, PLATFORM }

@onready var building_unit: BuildingUnit = BuildingUnit.NONE

func _init():
	EventBus.set_build_platform_sig.connect(func x(): self._set_building_unit(BuildingUnit.PLATFORM))
	EventBus.set_build_rails_sig.connect(func x(): self._set_building_unit(BuildingUnit.RAIL))

func _set_building_unit(unit: BuildingUnit):
	self.building_unit = unit

func can_build(building: BuildingUnit, position: Vector2) -> bool:
	if (building == BuildingUnit.RAIL):
		if position.y >= 288 or position.y <= 112:
			return false
	return true
