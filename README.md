# LunaGC for GI 7.0.0

Features and functionality of the ps is not guaranteed, try it yourself to see what works and what doesnt.
This is possibly the only public PS with updated mob and gadget spawns! (Up to Version 5.4)

Contribute if you want/can...

# Setup Guide

Requires [Docker & Docker Compose](https://docs.docker.com/get-docker/). No need to install Java, MongoDB, or Gradle manually on your host machine.

1. **Clone the repository with submodules**:
   ```bash
   git clone --recurse-submodules https://github.com/koboshchan/LunaGC.git
   cd LunaGC
   ```
   *If you already cloned without `--recurse-submodules`, run:*
   ```bash
   git submodule update --init --recursive
   ```

2. **Start the server and database**:
   ```bash
   docker compose up -d --build
   ```
   - Automatically builds the Fat JAR using a multi-stage builder (`eclipse-temurin:17-jdk`).
   - Starts an isolated MongoDB instance (no authentication, no exposed host ports, internal Docker DNS `mongodb:27017`).
   - Mounts resources, data, plugins, and logs automatically.

3. **Interact with the server console**:
   ```bash
   # View live logs
   docker compose logs -f lunagc

   # Attach to interactive command console (e.g. account create <username> <uid>)
   docker attach lunagc-server
   ```
   *(Tip: Press `Ctrl + P`, then `Ctrl + Q` to detach without stopping the container)*

4. **Stop the server**:
   ```bash
   docker compose down
   ```

## Connecting to Your Game

### Step 1: Create a Server Account

Before logging in, create an account using the server console:

- **If using Docker**:
  ```bash
  docker attach lunagc-server
  ```
- Type the command:
  ```text
  account create <username> <uid>
  ```
  *Example:* `account create player1 10001`
- **Detach safely**: Press `Ctrl + P`, then `Ctrl + Q`.

---

### Step 2: Patch the Game Client

1. Open your game directory: `<GameFolder>/GenshinImpact_Data/Plugins/`
2. Back up the original `Astrolabe.dll`.
3. Copy and replace it with `patch/Astrolabe.dll` from this repository.

---

### Step 3: Login & Play

1. At the in-game login screen:
   - **Username**: The `<username>` you created in Step 1 (e.g. `player1`).
   - **Password**: Any password.
2. Click **Login** and enter the world!

---

## Web GM Handbook & In-Game Commands

- **Web GM Panel**: Open **[http://localhost:8080/handbook](http://localhost:8080/handbook)** in your browser to give items, grant avatars, teleport, or spawn monsters with a single click.
- **In-Game Chat Commands**:
  - `/give 201 16000` — Add 16,000 Primogems
  - `/give 223 100` — Add 100 Intertwined Fates
  - `/heal` — Restore party HP & Energy
  - `/prop godmode on` — Invincibility
  - `/prop unlockmap 1` — Unlock all waypoints & map areas

## Troubleshooting

- Make a issue.

## Credit

original Project [LunaGC](https://github.com/girluh/LunaGC)

proto Repository [hk4e-protos](https://gitlab.com/kitkat-multiverse/genshin-protocol)

patch Repository [hk4e-patch-universal](https://github.com/kitkat033/hk4e-patch-universal) - `patch/Astrolabe.dll` is built from it
