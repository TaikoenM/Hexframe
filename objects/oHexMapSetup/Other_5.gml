/// @description export setup data

if (variable_global_exists("mapSetupData")) {
    delete global.mapSetupData
}
global.mapSetupData = mapSetupData

struct_to_log(global.mapSetupData, "Map Setup Data", LogComponent.MAP)
setup_room_for_hex_map(global.mapSetupData.width, global.mapSetupData.height)