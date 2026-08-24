# LunaGC-7.0.0 WIP

## Note from the maintainer
Might update to latest occasionally, depends on how I'm feeling and my situation. Of course, I post the protocol buffer definitions on [GitLab](https://gitlab.com/kitkat-multiverse/genshin-protocol) and translations. Contact me at my [Discord](https://discord.gg/5Rfyjrt5aB)

## Updated version of Grasscutters, with some new features implemented.
Old Discord for LunaGC https://discord.gg/7D5gkyJR5Y (don't ask for support there as it's been taken over by other people (...), instead create an issue in this repository)

Features and functionality of the ps is not guaranteed, try it yourself to see what works and what doesnt.
This is possibly the only public PS with updated mob and gadget spawns! (Up to Version 5.4)

Contribute if you want/can...

# Read the [handbook](handbook.md)!

# Setup Guide

### Method 1: One-Click Docker Startup (Recommended)

Requires [Docker & Docker Compose](https://docs.docker.com/get-docker/). No need to install Java, MongoDB, or Gradle manually on your host machine.

1. **Clone the repository with submodules**:
   ```bash
   git clone --recurse-submodules https://github.com/girluh/LunaGC.git
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

---

### Method 2: Manual Setup

#### Main Requirements
- Get [Java 17](https://www.oracle.com/java/technologies/javase/jdk17-archive-downloads.html)
- Get [MongoDB Community Server](https://www.mongodb.com/try/download/community)
- Get [NodeJS](https://nodejs.org/dist/v20.15.0/node-v20.15.0-x64.msi) (Optional, for handbook generation)
- Get game version REL7.0.0
- Resources (included as submodule in `./resources` or downloaded from [LunaGC-Resources](https://github.com/girluh/LunaGC-Resources))
- Set `useEncryption`, `questing`, and `useInRouting` to `false` (default)
- [Patch the game](#patching-the-game)
- Start the server and the game, make sure to also create an account in the LunaGC console!

#### Compile the actual Server

**Requirements**:

[Java Development Kit 17 | JDK](https://oracle.com/java/technologies/javase/jdk17-archive-downloads.html) or higher

- **Sidenote**: Handbook generation may fail on some systems. To disable handbook generation, append `-PskipHandbook=1` to the `gradlew jar` command.

- **For Windows**:

  ```shell
  .\gradlew.bat
  .\gradlew.bat jar
  ```

- **For Linux / macOS**:

  ```bash
  chmod +x gradlew
  ./gradlew
  ./gradlew jar
  ```

Output JAR can be found in the project root folder.

#### Manually compile the handbook

```shell
./gradlew generateHandbook
```

---

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

- Make sure to set useEncryption and useInRouting both to false otherwise you might encounter errors.
- To use windy make sure that you put your luac files in C:\Windy (make the folder if it doesnt exist)
- If you get an error related to MongoDB connection timeout, check if the mongodb service is running. On windows: Press windows key and r then type `services.msc`, look for mongodb server and if it's not started then start it by right clicking on it and start. On linux, you can do `systemctl status mongod` to see if it's running, if it isn't then type `systemctl start mongod`. However, if you get error 14 on linux change the owner of the mongodb folder and the .sock file (`sudo chown -R mongodb:mongodb /var/lib/mongodb` and `sudo chown mongodb:mongodb /tmp/mongodb-27017.sock` then try to start the service again.)

## Credit

proto Repository [hk4e-protos](https://gitlab.com/kitkat-multiverse/genshin-protocol)

patch Repository [hk4e-patch-universal](https://github.com/kitkat033/hk4e-patch-universal) - `patch/Astrolabe.dll` is built from it
