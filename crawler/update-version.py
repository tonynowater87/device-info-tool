import json

def load_updates_from_file(file_path):
    with open(file_path, 'r') as file:
        return json.load(file)

def update_os_versions(file_path, updates):
    # Load the current data from the file
    with open(file_path, 'r') as file:
        data = json.load(file)

    # Create a dictionary for quick access to versions by their major version number
    data_dict = {item['version']: item for item in data}

    for update in updates:
        major_version = update['version'].split('.')[0]
        # Check if this major version is already in the data
        if major_version in data_dict:
            # Update the existing entry
            data_dict[major_version]['latest_version'] = update['version']
            data_dict[major_version]['latest_date'] = update['release_date']
        else:
            # Add a new entry
            new_entry = {
                "version": major_version,
                "latest_version": update['version'],
                "release_date": update['release_date'],  # Assuming the initial release date is the same as the latest
                "latest_date": update['release_date']
            }
            data.append(new_entry)

    # Save the updated data back to the file
    with open(file_path, 'w') as file:
        json.dump(data, file, indent=2)

# Load updates from the specified file
updates_file_path = 'crawler/resources/apple_support_response_filtered.json'
updates = load_updates_from_file(updates_file_path)

# Example usage
update_os_versions('resources/ios-os-versions.json', updates)
update_os_versions('resources/ipad-os-versions.json', updates)