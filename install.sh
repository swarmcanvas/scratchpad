#!/bin/bash

install_docker_compose_setup() {
    if [ "$(id -u)" != "0" ]; then
        echo "This script must be run as root" >&2
        exit 1
    fi

    echo "Starting installation process..."

    ports_to_check=(80 443 3000 8080)
    echo "Checking if the following ports are available: ${ports_to_check[*]}"

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

    echo "Checking for Docker..."
    if command -v docker > /dev/null 2>&1; then
        echo "Docker is already installed."
    else
        echo "Docker not found. Installing Docker..."
        curl -fsSL https://get.docker.com | sh
        echo "Docker installed successfully."
    fi

    compose_file_url="https://raw.githubusercontent.com/swarmcanvas/scratchpad/refs/heads/main/docker-compose.yml"
    nginx_file_url="https://raw.githubusercontent.com/swarmcanvas/scratchpad/refs/heads/main/nginx.conf"
    target_folder="/opt/docker-setup"

    mkdir -p "$target_folder"

    echo "Downloading docker-compose.yml..."
    curl -o "$target_folder/docker-compose.yml" "$compose_file_url"
    chmod 644 "$target_folder/docker-compose.yml"
    echo "docker-compose.yml downloaded to $target_folder."

    echo "Downloading nginx.conf..."
    curl -o "$target_folder/nginx.conf" "$nginx_file_url"
    chmod 644 "$target_folder/nginx.conf"
    echo "nginx.conf downloaded to $target_folder."

    echo "Starting Docker Compose..."
    docker-compose -f "$target_folder/docker-compose.yml" up -d

    echo "Installation complete. Docker Compose services are up and running."
    echo "The following ports are now in use: ${ports_to_check[*]}"
    echo "Configuration files are located in: $target_folder"
}

install_docker_compose_setup
