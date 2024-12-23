#!/bin/bash

install_docker_compose_setup() {
    # Check if the script is run as root
    if [ "$(id -u)" != "0" ]; then
        echo "This script must be run as root" >&2
        exit 1
    fi

    echo "Starting installation process..."

    # Step 1: Define specific ports to check
    ports_to_check=(80 443 3000 8080) # Add your ports here
    echo "Checking if the following ports are available: ${ports_to_check[*]}"

    # Check each port
    unavailable_ports=()
    for port in "${ports_to_check[@]}"; do
        if ss -tuln | grep -q ":$port "; then
            unavailable_ports+=("$port")
        fi
    done

    if [ "${#unavailable_ports[@]}" -gt 0 ]; then
        echo "Error: The following ports are already in use: ${unavailable_ports[*]}" >&2
        exit 1
    else
        echo "All specified ports are available."
    fi

    # Step 2: Check if Docker is installed, install if not
    echo "Checking for Docker..."
    if command -v docker > /dev/null 2>&1; then
        echo "Docker is already installed."
    else
        echo "Docker not found. Installing Docker..."
        curl -fsSL https://get.docker.com | sh
        echo "Docker installed successfully."
    fi

    # Step 3: Download docker-compose.yml
    compose_file_url="https://example.com/path/to/docker-compose.yml" # Replace with your URL
    compose_file_path="/opt/docker-compose.yml"
    echo "Downloading docker-compose.yml from $compose_file_url..."
    curl -o "$compose_file_path" "$compose_file_url"
    chmod 644 "$compose_file_path"
    echo "docker-compose.yml downloaded to $compose_file_path."

    # Step 4: Start `docker-compose up`
    echo "Starting Docker Compose..."
    docker-compose -f "$compose_file_path" up -d

    # Step 5: Print progress
    echo "Installation complete. Docker Compose services are up and running."
    echo "The following ports are now in use: ${ports_to_check[*]}"
}

# Main script execution
install_docker_compose_setup
