# 📂 Global Scripts

**NPCGameState.gd**
- _ready
- _on_item_rigid_body_collected

**global.gd**
- deserialize
- serialize
- wait

**interaction_manager.gd**
- register_area
- unregister_area
- _input
- _physics_process
- _ready
- _sort_by_distance_to_player

**save_manager.gd**
- delete_save_file
- get_current_level
- get_current_level_name
- get_save_data_field
- get_save_file_path
- get_save_files
- load_audio_config
- load_existing_save_data
- load_game
- parse_json_safe
- read_existing_file
- read_file_as_text
- revert_and_reload_savable_nodes
- save_audio_config
- save_game
- save_savable_nodes
- _ready
- _verify_save_directory

**signal_bus.gd**
- _ready

# 📂 Other Scripts

**fixed_camera.gd**
- _ready
- _set_camera_current
- _on_body_entered
- _on_body_exited

**interact_component.gd**
- _on_body_entered
- _on_body_exited

**enemy_data.gd**

**player_data.gd**

**collectible.gd**

**collectible_rigid_body_3d.gd**

**enemy_attack_surface_area.gd**

**enemy_hit_box.gd**

**enemy_hurt_box.gd**

**player_attack_surface_area.gd**

**player_hit_box.gd**

**player_hurt_box.gd**

**aggro_area.gd**
- _on_body_entered

**deaggro_area.gd**
- _on_body_exited

**enemy_3d.gd**
- aggroed
- deaggroed
- _dead
- _ready
- _rotate_towards_target
- _on_aggro_area_body_entered
- _on_animation_finished
- _on_deaggro_area_body_exited
- _on_enemy_hurt_box_area_entered
- _on_idle_timeout
- _on_navigation_agent_3d_target_reached
- _on_player_detected
- _on_player_in_aggro_area_range
- _on_player_out_of_aggro_area_range
- _on_player_out_of_range

**note.gd**
- _play_and_free
- _ready
- _on_destroy_area_body_exited
- _on_interact_area_body_entered
- _on_sfx_finished

**player_3d.gd**
- move
- _apply_gravity
- _input
- _ready
- _on_animation_finished
- _on_player_died
- _on_player_hurt_box_area_entered
- _on_player_interacted

**wraith.gd**
- _ready
- _on_interact

**health_up.gd**
- _on_interaction_area_body_entered

**tooth.gd**
- _on_interaction_area_body_entered

**extract_methods.gd**
- format_output
- format_section
- get_scripts_and_methods
- save_to_file
- _ready

**game_controller.gd**
- change_3d_scene
- change_gui_scene
- _load_scene_async
- _play_transition
- _process
- _ready
- _on_final_dialogue_completed
- _on_level_changed
- _on_player_died
- _on_quest_completed

**transition_controller.gd**
- transition

**car_2.gd**
- _ready
- _on_interact

**tent.gd**
- _ready
- _on_interact

**open_space.gd**
- _ready
- _on_quest_completed

**aggroed.gd**
- _on_aggroed_state_physics_processing

**dead.gd**
- _on_dead_state_entered

**deaggroed.gd**
- _on_deaggroed_state_physics_processing

**enemy_state.gd**

**fighting.gd**
- _on_fighting_state_physics_processing

**hurt.gd**
- _on_hurt_state_physics_processing

**dead.gd**
- _on_dead_state_entered

**fighting.gd**
- _on_fighting_state_physics_processing

**hurt.gd**
- _on_hurt_state_physics_processing

**idle.gd**
- _on_idle_state_physics_processing

**interacting.gd**
- _on_interacting_state_physics_processing

**moving.gd**
- _on_moving_state_physics_processing

**player_state.gd**

**ending_scene.gd**
- _ready

**game_over_screen.gd**
- _ready
- _on_quit_button_pressed
- _on_restart_button_pressed

**hud_3d.gd**
- _ready
- _on_health_changed

**intro.gd**
- _ready

**pause_ui.gd**
- _input
- _ready
- _on_exit_button_pressed
- _on_main_menu_button_pressed

**config_screen.gd**
- _ready
- _on_back_button_pressed
- _on_bgm_slider_value_changed
- _on_master_slider_value_changed
- _on_sfx_slider_value_changed

**control_scheme.gd**
- _ready
- _on_back_button_pressed

**main_menu.gd**
- _ready
- _on_config_button_pressed
- _on_controls_button_pressed
- _on_new_game_button_pressed
- _on_quit_button_pressed

**loading_screen.gd**
- _ready
- _on_scene_load_update

**blood_spawner.gd**
- _get_random_blood_texture
- _ready
- _on_spawn_blood_decal

**collectible_spawner.gd**
- _ready
- _on_enemy_died

**enemy_model.gd**
- _physics_process

**news_crime_scene.gd**
- _ready
- _on_animation_finished
- _on_play_news

**player_model.gd**
- _input
- _physics_process

**fire_light.gd**
- _process
