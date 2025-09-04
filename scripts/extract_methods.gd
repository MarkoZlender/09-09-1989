extends Node

# Folder to scan
const SCRIPTS_DIR := "res://scripts"
const GLOBALS_DIR := "res://scripts/globals"
const OUTPUT_FILE := "res://methods_report.txt"

func _ready():
    var data := get_scripts_and_methods(SCRIPTS_DIR)
    var formatted := format_output(data)
    save_to_file(formatted, OUTPUT_FILE)
    print(formatted)

    # Count scripts
    var global_count := 0
    var other_count := 0
    for script_name in data.keys():
        if script_name.begins_with(GLOBALS_DIR + "/"):
            global_count += 1
        else:
            other_count += 1
    print("📊 Total scripts: %d (Globals: %d, Others: %d)" % [global_count + other_count, global_count, other_count])
    print("\n✅ Method list saved to: " + OUTPUT_FILE)


# Recursively get scripts and their methods
func get_scripts_and_methods(path: String) -> Dictionary:
    var results := {}
    var dir := DirAccess.open(path)
    if dir:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        while file_name != "":
            if dir.current_is_dir() and file_name != "." and file_name != "..":
                results.merge(get_scripts_and_methods(path + "/" + file_name))
            elif file_name.ends_with(".gd"):
                var full_path = path + "/" + file_name
                var script := load(full_path)
                if script is GDScript:
                    var public_methods := []
                    var private_methods := []
                    var signal_callables := []

                    for method in script.get_script_method_list():
                        var name = method.name
                        var is_private = name.begins_with("_")
                        var is_signal_callable = name.begins_with("_on_") # Godot convention for signal handlers

                        if is_signal_callable:
                            signal_callables.append(name)
                        elif is_private:
                            private_methods.append(name)
                        else:
                            public_methods.append(name)

                    public_methods.sort()
                    private_methods.sort()
                    signal_callables.sort()

                    # Use only the file name, no path
                    results[file_name] = {
                        "public": public_methods,
                        "private": private_methods,
                        "signal": signal_callables
                    }
            file_name = dir.get_next()
        dir.list_dir_end()
    return results


# Format results for printing / saving
func format_output(data: Dictionary) -> String:
    var globals := {}
    var others := {}

    for script_name in data.keys():
        if script_name.find(GLOBALS_DIR.get_file()) != -1:
            globals[script_name] = data[script_name]
        else:
            others[script_name] = data[script_name]

    var text := "# 📂 Global Scripts\n"
    text += format_section(globals)
    text += "\n# 📂 Other Scripts\n"
    text += format_section(others)
    return text


func format_section(section: Dictionary) -> String:
    var text := ""
    var keys := section.keys()
    keys.sort()

    for script_name in keys:
        text += "\n**%s**\n\n" % script_name

        if section[script_name]["public"].size() > 0:
            text += "  Public:\n"
            for m in section[script_name]["public"]:
                text += "    - " + m + "\n"

        if section[script_name]["private"].size() > 0:
            text += "  Private:\n"
            for m in section[script_name]["private"]:
                text += "    - " + m + "\n"

        if section[script_name]["signal"].size() > 0:
            text += "  Signal Callables:\n"
            for m in section[script_name]["signal"]:
                text += "    - " + m + "\n"

        text += "\n"  # blank line after each script block

    return text


# Save string to file
func save_to_file(content: String, file_path: String) -> void:
    var file := FileAccess.open(file_path, FileAccess.WRITE)
    if file:
        file.store_string(content)
        file.close()
