# NoahFrame: Functional Architecture Overview

## 1. Overall Architecture

NoahFrame is a C++ game server framework designed with a **plugin-based architecture** and a **distributed server model**. This modular design promotes separation of concerns, extensibility, and scalability for developing complex online games.

*   **Plugin-Based:** The core engine and game-specific functionalities are organized into plugins. Each plugin can contain multiple modules, where each module encapsulates a specific set of functionalities. This allows developers to easily add, remove, or modify features.
*   **Distributed Server Model:** The framework is built to support a distributed deployment, where different server types (Master, Login, World, Game, Proxy, DB) handle distinct responsibilities. These servers communicate with each other to manage the overall game state and player experience.

## 2. Plugin System

The plugin system is central to NoahFrame's design, managed primarily by the `NFPluginManager`.

*   **Structure:**
    *   **Plugins (`NFIPlugin`):** Represent a collection of related functionalities. Plugins are responsible for registering and managing their own modules. They have a lifecycle (`Install`, `Uninstall`) and propagate lifecycle events (`Awake`, `Init`, `Execute`, `Shut`) to their modules.
    *   **Modules (`NFIModule`):** The actual units of functionality. Each module implements specific logic (e.g., Kernel, Logging, Networking). Modules also follow the same lifecycle events initiated by their parent plugin and the `NFPluginManager`.
*   **Loading and Management (`NFPluginManager`):**
    *   Loads plugin configurations (determining which plugins to activate).
    *   Dynamically loads plugin libraries (DLLs/SOs) or integrates statically linked plugins.
    *   Manages a central registry of all loaded plugins and their modules.
    *   Orchestrates the lifecycle of all plugins and modules, ensuring they are initialized, executed, and shut down in the correct order.
*   **Lifecycle:** `Awake` -> `Init` -> `AfterInit` -> `CheckConfig` -> `ReadyExecute` -> `Execute` (called repeatedly) -> `BeforeShut` -> `Shut` -> `Finalize`. This ensures orderly startup, operation, and shutdown of all components.

## 3. Core Services

A set of fundamental modules provides essential services for game development.

*   **Kernel (`NFKernelModule`):** The heart of game object management.
    *   **Object Management:** Creates, destroys, and manages game objects (entities) identified by `NFGUID`.
    *   **Properties & Records:** Game objects have:
        *   **Properties (`NFIProperty`):** Named, typed, single data values (e.g., HP, Name, Position). Can have flags (Save, Public, Private, Cache, Upload).
        *   **Records (`NFIRecord`):** Table-like data structures attached to objects (e.g., inventory, quest list), with rows and typed columns. Also have flags.
    *   **Event System:** A robust event system for both class-level events (e.g., on object creation/destruction) and property/record change events. Callbacks can be registered to react to these events.
    *   **Scheduling:** Relies on a dedicated schedule module (`NFIScheduleModule`) for time-based events and callbacks.
*   **Configuration (`NFClassModule`, `NFElementModule`):** Manages game configuration data loaded from XML files.
    *   **`NFClassModule`:** Defines the "blueprints" or "classes" of game objects (e.g., "Player", "Monster", "Item"). A class definition specifies the names and types of properties and the structure of records that objects of this class will possess. Supports inheritance.
    *   **`NFElementModule`:** Loads the specific instances or "elements" of these classes (e.g., a "Goblin" monster with HP=50, Attack=5). This provides the concrete data for different types of game entities.
    *   **Runtime Access:** This configuration data is typically read-only at runtime and used to initialize objects and define their base characteristics.
*   **Logging (`NFLogModule`):** Provides a flexible logging system with different log levels (Debug, Info, Warning, Error, Fatal), ability to log to various outputs, and hooks for custom log processing.

## 4. Networking

NoahFrame includes a comprehensive networking layer to handle client-server and server-server communication.

*   **Supported Protocols:**
    *   **TCP:** The primary protocol for reliable, ordered communication, used for core game messages between clients and servers, and between different server instances.
    *   **HTTP:** Supported for both server (`NFIHttpServer`) and client (`NFIHttpClient`) roles, enabling web-based APIs, administrative interfaces, or communication with external web services. HTTPS is supported.
    *   **WebSockets (WS):** Support is indicated through dedicated modules (`NFWSModule`), allowing for persistent, low-latency, full-duplex communication, often initiated via an HTTP upgrade. This is suitable for browser-based clients or real-time web applications.
    *   **UDP:** Support is indicated through dedicated modules (`NFUDPModule`), available for scenarios requiring fast, unreliable packet transmission (e.g., certain types of real-time data synchronization).
*   **Message Handling (Core Gameplay - TCP/WS):**
    *   **Message Head (`NFMsgHead`):** A 6-byte header (2-byte MsgID, 4-byte total length) is prepended to TCP/WS messages, facilitating message framing and identification.
    *   **Protocol Buffers (Protobuf):** The body of game messages is typically serialized using Protocol Buffers. `.proto` files (e.g., `NFDefine.proto`) define message structures and enumerations (like `EGameMsgID`). This provides efficient, version-tolerant, and multi-language data serialization.
    *   **Receiving/Sending:** The `NFINet` interface (and its implementations) manages reading data into ring buffers, parsing messages based on the header, and dispatching message bodies to registered handlers. It also provides functions to send Protobuf-serialized data, automatically handling header prepending.
*   **Client/Server Communication Patterns:**
    *   **Game Client <-> Proxy Server:** Clients typically connect to a Proxy Server.
    *   **Proxy Server <-> Game Server / World Server:** The Proxy Server forwards messages between the client and the appropriate backend server.
    *   **Server-to-Server:** Various server types communicate directly with each other for registration, data synchronization, and service requests (e.g., Login Server queries Master Server, Game Server queries World Server).

## 5. Data Management

NoahFrame manages both static configuration data and dynamic runtime data.

*   **Static Configuration Data (XML):**
    *   As described in "Core Services," `NFClassModule` and `NFElementModule` load object blueprints and specific element data from XML files. This data defines the static characteristics of game entities and items.
*   **Dynamic Runtime Data Persistence (Redis):**
    *   **`NFINoSqlModule`:** Provides an abstraction layer for NoSQL database interactions, with a primary implementation for Redis (`NFRedisClient`). It manages connections and provides an interface for Redis commands.
    *   **Player Data Management (`NFPlayerRedisModule` example):**
        *   Player character data (properties and records marked with a "Save" flag) is persisted to Redis.
        *   The `NFPlayerRedisModule` handles loading player data from Redis when a player logs in (deserializing it into a `NFMsg::RoleDataPack` Protobuf message) and saving it back when they log out or periodically.
    *   **Data Mapping:** While not a full ORM, properties and records of persistent objects (like players) are often grouped (e.g., into a Protobuf message like `RoleDataPack`) and then stored, commonly in Redis Hashes where the object's `NFGUID` serves as part of the key. Individual properties might be fields in the hash, and records might be serialized as a single field.
    *   Other modules like `NFAccountRedisModule` handle specific data sets (e.g., account credentials) using Redis.

## 6. Distributed Server Architecture

The framework is designed for a distributed environment with specialized server types:

*   **Master Server (`NFMasterModule`):**
    *   **Purpose:** Central coordinator. Manages a list of all active server instances.
    *   **Interactions:** All other servers register with it. Login/World servers query it for available server lists.
*   **Login Server (`NFLoginLogicModule`):**
    *   **Purpose:** Handles player authentication and World Server selection.
    *   **Interactions:** Clients (for login), Master Server (for world list), DB Server (for account verification via `NFAccountRedisModule`).
*   **World Server (`NFWorldNet_ServerModule` as core):**
    *   **Purpose:** Manages the overall game world state, high-level player tracking (which Game Server a player is on), and facilitates inter-server communication.
    *   **Interactions:** Registers with Master. Game, Proxy, and DB servers connect to it. Routes messages between these servers and to players on specific Game Servers.
*   **Game Server (`NFGameServerModule`):**
    *   **Purpose:** Hosts the actual gameplay logic, scene management, NPC AI, and real-time interactions for a subset of the game world.
    *   **Interactions:** Clients (via Proxy), World Server (registration, status updates, message routing), DB Server (for persistent player/game state, often via World).
*   **Proxy Server (`NFProxyLogicModule`):**
    *   **Purpose:** Gateway for client connections. Routes messages between clients and the appropriate Game Servers.
    *   **Interactions:** Clients (accepts connections), World Server (for routing information), Game Servers (forwards messages).
*   **DB Server (e.g., `NFDBLogicPlugin` containing `NFAccountRedisModule`, `NFPlayerRedisModule`):**
    *   **Purpose:** Manages persistent data storage, primarily using Redis.
    *   **Interactions:** Login Server (account data), Game/World Servers (player data, other game state). Registers with Master and World servers.

## 7. Specialized Game Development Modules

NoahFrame provides several advanced modules to aid in game development:

*   **Actor Model (`NFActorModule`):**
    *   **Purpose:** Implements an actor-based concurrency model (similar to Akka or Orleans) for managing state and behavior of game entities or tasks concurrently without explicit lock management.
    *   **Functionality:** Actors communicate via asynchronous messages. The module manages actor lifecycle and message dispatching, utilizing a thread pool.
    *   **Integration:** Enhances the core by allowing complex, stateful game logic to be processed in parallel, improving server responsiveness and scalability.
*   **Blueprint System (`NFBluePrintModule`, `NFBPVirtualMachineModule`):**
    *   **Purpose:** Provides a visual scripting environment, enabling developers and designers to create and manage game logic graphically.
    *   **Functionality:** `NFBluePrintModule` defines the structure of "Logic Blocks" with various node types (events, variables, branches, executors, etc.) and links between them. `NFBPVirtualMachineModule` executes these logic blocks at runtime.
    *   **Integration:** Allows for rapid prototyping and iteration of game mechanics, AI behaviors, and event handling, which can be triggered by and interact with the C++ core (e.g., KernelModule).
*   **Navigation (`NFNavigationModule`):**
    *   **Purpose:** Provides 3D pathfinding and navigation capabilities using the Recast & Detour library.
    *   **Functionality:** Loads navigation mesh data for game scenes, allows finding paths between points, locating random reachable points, and performing raycasts against the navmesh.
    *   **Integration:** Used by Game Server logic to enable NPC and player character movement, AI-driven navigation, and spatial queries within game scenes.
*   **Lua Scripting (`NFLuaScriptModule`):**
    *   **Purpose:** Allows embedding Lua scripts for game logic, event handling, and extending C++ functionalities.
    *   **Functionality:** Provides extensive Lua bindings to core framework modules (Kernel, Networking, Config, Logging, Protobuf handling). Supports registering Lua functions as callbacks for various game events and network messages. Enables hot reloading of scripts.
    *   **Integration:** Offers a flexible and dynamic way to write and modify game logic without recompiling the core C++ server, facilitating rapid development and customization.

This document provides a high-level overview of NoahFrame's functional architecture, highlighting its key components and their interactions. The modular, distributed, and extensible nature of the framework makes it suitable for a variety of online game projects.
