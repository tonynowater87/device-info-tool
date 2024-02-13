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
        if '.' not in update['version']:
            continue
        split_versions = update['version'].split('.')
        if len(split_versions) < 2:
            continue
        major_version = split_versions[0]
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

def update_mac_os_versions(file_path, updates):
    # Load the current data from the file
    with open(file_path, 'r') as file:
        data = json.load(file)

    # Create a dictionary for quick access to versions by their major version number
    data_dict = {item['version']: item for item in data}

    for update in updates:
        if '.' not in update['version']:
            continue
        split_versions = update['version'].split('.')
        if len(split_versions) < 2:
            continue
        major_version = split_versions[0]
        if int(major_version) <= 10:
            continue
        # Check if this major version is already in the data
        if major_version in data_dict:
            # Update the existing entry
            data_dict[major_version]['latest_version'] = update['version']
            data_dict[major_version]['latest_release_date'] = update['release_date']
        else:
            # Add a new entry
            new_entry = {
                "version": major_version,
                "version_name": update['platform'][0].split(' ')[1],
                "latest_version": update['version'],
                "initial_release_date": update['release_date'],
                "latest_release_date": update['release_date']
            }
            data.append(new_entry)

    # Save the updated data back to the file
    with open(file_path, 'w') as file:
        json.dump(data, file, indent=2)

def update_watch_os_versions(file_path, updates):
    # Load the current data from the file
    with open(file_path, 'r') as file:
        data = json.load(file)

    # Create a dictionary for quick access to versions by their major version number
    data_dict = {item['version']: item for item in data}

    for update in updates:
        split_versions = update['version'].split('.')
        if len(split_versions) < 2:
            continue
        major_version = str(float(split_versions[0]))
        # Check if this major version is already in the data
        if major_version in data_dict:
            # Update the existing entry
            data_dict[major_version]['latest_version'] = update['version']
            data_dict[major_version]['latest_release_date'] = update['release_date']
        else:
            # Add a new entry
            new_entry = {
                "version": major_version,
                "latest_version": update['version'],
                "release_date": update['release_date'],
                "latest_release_date": update['release_date'],
                "based_on_ios_version": update['version'][0].split('.')[0] + '.0'
            }
            data.append(new_entry)

    # Save the updated data back to the file
    with open(file_path, 'w') as file:
        json.dump(data, file, indent=2)

def update_tv_os_versions(file_path, updates):
    # Load the current data from the file
    with open(file_path, 'r') as file:
        data = json.load(file)

    # Create a dictionary for quick access to versions by their major version number
    data_dict = {item['version']: item for item in data}

    for update in updates:
        if '.' not in update['version']:
            continue
        split_versions = update['version'].split('.')
        if len(split_versions) < 2:
            continue
        major_version = split_versions[0]
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
                "release_date": update['release_date'],
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
update_os_versions('resources/ios-os-versions.json', updates[0])
update_os_versions('resources/ipad-os-versions.json', updates[0])
update_mac_os_versions('resources/mac-os-versions.json', updates[1])
update_tv_os_versions('resources/tv-os-versions.json', updates[2])
update_watch_os_versions('resources/watch-os-versions.json', updates[3])