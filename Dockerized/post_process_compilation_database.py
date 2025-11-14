#!/usr/bin/env python3
import json
import subprocess
import re

def extract_compiler_stl_paths(file_path):
    """
    Reads compile_commands.json, identifies unique compilers, queries them 
    for their implicit STL include paths, and returns a set of paths.
    """
    compilers = set()
    try:
        with open(file_path, 'r') as f:
            data = json.load(f)
            for entry in data:
                # Assuming the compiler is the first argument in the list or the start of the 'command' string
                if 'arguments' in entry and entry['arguments']:
                    compilers.add(entry['arguments'][0])
                elif 'command' in entry:
                    # Extract the first word of the command string
                    cmd_match = re.match(r"^\s*(\S+)", entry['command'])
                    if cmd_match:
                        compilers.add(cmd_match.group(1))
    except (FileNotFoundError, json.JSONDecodeError) as e:
        print(f"Error reading {file_path}: {e}")
        return set()

    stl_paths = set()
    for compiler in compilers:
        # print(f"Querying compiler: {compiler} for built-in paths...")
        try:
            process = subprocess.Popen(
                [compiler, "-Wp,-v", "-x", "c++", "-E", "-"],
                stdin=subprocess.PIPE,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True
            )
            _, stderr = process.communicate(input="")
            
            # Parse stderr output to find paths between 'starts here:' and 'End of search list.'
            inside = False
            for line in stderr.splitlines():
                if re.search(r"search starts here:", line):
                    inside = True
                elif re.search(r"End of search list.", line):
                    inside = False
                elif inside:
                    # Clean up whitespace and add to set
                    path = line.strip()
                    if path:
                        stl_paths.add(path)
        except FileNotFoundError:
            print(f"Warning: Compiler '{compiler}' not found/executable. Skipping path extraction.")
        except Exception as e:
            print(f"Warning: Error querying compiler '{compiler}': {e}")
            
    return stl_paths

def insert_include_paths_idempotent(file_path, include_paths):
    """
    Inserts a list of include paths into the arguments list of a 
    compile_commands.json file before every instance of '-c', only if they 
    aren't already present in the arguments list for that entry.
    """
    if not include_paths:
        print("No paths to insert.")
        return

    try:
        with open(file_path, 'r') as f:
            data = json.load(f)
    except Exception as e:
        print(f"Error loading JSON: {e}")
        return

    formatted_paths = set([f"-I{p}" for p in include_paths])
    
    updates_made = False
    for entry in data:
        if 'arguments' in entry:
            existing_args_set = set(entry['arguments'])
            paths_to_add_for_entry = [p for p in formatted_paths if p not in existing_args_set]

            if paths_to_add_for_entry:
                new_arguments = []
                for arg in entry['arguments']:
                    if arg == '-c':
                        # Insert new paths before -c
                        new_arguments.extend(paths_to_add_for_entry)
                        new_arguments.append(arg)
                    else:
                        new_arguments.append(arg)
                entry['arguments'] = new_arguments
                updates_made = True
        
        # 'command' string field handling is complex to make idempotent and is omitted for robustness

    if updates_made:
        with open(file_path, 'w') as f:
            json.dump(data, f, indent=4)
        print(f"Successfully updated {file_path} with new paths.")
    else:
        print(f"No new paths needed to be added to {file_path}. File is already up to date.")

if __name__ == "__main__":
    json_file = 'compile_commands.json'
    
    # 1. Extract the built-in paths
    paths_to_add = extract_compiler_stl_paths(json_file)
    
    # 2. Insert these paths into the JSON file idempotently
    insert_include_paths_idempotent(json_file, paths_to_add)
