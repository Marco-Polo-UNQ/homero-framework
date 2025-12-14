# Homero Framework

Editor tools and runtime components for Godot 4.5+ focused on:
- Visual dialogue authoring and runtime dialogue resources
- Screen loading/management with typed screen constants
- Project initialization helpers (Events autoload, screen constants)

This repository also contains a comprehensive test suite under [tests](tests) using Gut with code coverage, covering editor tools and runtime components.


## Contents

- [Features](#features)
- [Installation](#installation)
- [Examples](#examples)
- [Tests](#tests)
- [License](#license)


## Features

- Screen loading and management
  - There are 3 main components of this system, the [ScreenManager](addons/homero_framework/src/core/components/screens/screen_manager.gd) that serves as a state machine handling the different [ScreenLoaders](addons/homero_framework/src/core/components/screens/screen_loader.gd), that in turn hold weak references that don't preload the dependencies to memory of scenes that implement the [Screen](addons/homero_framework/src/core/components/screens/screen.gd) class.
  - The plugin creates or validates a typed screen constants script at [screens_constants.gd](screens_constants.gd) (class name: HFScreenConstants with enum SCREENS) to be used by screen loaders/managers, editable by the user.

- Events management system
  - The plugin registers an autoload singleton [EventsManager](addons/homero_framework/src/core/components/events/events_manager.gd) that serves as mainly an event bus.
  - The main power here lies in the [EventListeners](addons/homero_framework/src/core/components/events/listeners/event_listener.gd) with extensible [EventConditionals](addons/homero_framework/src/core/components/events/listeners/conditionals/event_conditional.gd)  and [EventTriggerGroups](addons/homero_framework/src/core/components/events/triggers/event_trigger_group.gd) that can be used by elements like [TriggerArea2Ds](addons/homero_framework/src/core/components/events/triggers/trigger_area_2d.gd) or [TriggerArea3Ds](addons/homero_framework/src/core/components/events/triggers/trigger_area_3d.gd), all interfacing with the EventsManager to handle all different events.

- Dialogue system
  - It uses resources as basis for declaring different dialogue flows in a pure way via [`HFDialogueSequence`](addons/homero_framework/src/core/components/dialogues/dialogue_sequence.gd), exposing an API that can be harnessed with a dialogue UI of choice.
  - The Dialogue System can interact with the Events system, being able to toggle different dialogue paths, starting points and options depending of the events state, and also being able to activate or deactivate different events according to the current dialogue step or option selected.
  - All this can be set up using an integrated graph editor plugin that opens right in the Godot Editor IDE.

- Automatic version checking in the Editor, checking against the published Github repository (you can disable it from [the plugin file](addons/homero_framework/plugin.gd)).


## Installation

1. Copy the plugin to your project at:
   - [addons/homero_framework/](addons/homero_framework)
2. In Godot, open Project > Project Settings > Plugins and enable “Homero Framework”.
3. On first enable, the plugin:
   - Ensures a screens constants file exists at [screens_constants.gd](screens_constants.gd) with an `HFScreenConstants` class and a `SCREENS` enum.
   - Registers the EventsManager autoload from [addons/homero_framework/src/core/components/events/events_manager.gd](addons/homero_framework/src/core/components/events/events_manager.gd).


## Examples

You can see implementation examples [here](addons/homero_framework/examples).

## Tests

The project uses GUT for tests with an additional code coverage addon. You can run the [tests](tests) either using the GUT UI in the Editor or with the command line.

```bash
{Godot Executable Path} -d -s --path "path_to\homero-framework" "path_to\homero-framework\addons\gut\gut_cmdln.gd" -gblocking_mode="NonBlocking"
```

## License

MIT — see [LICENSE](LICENSE).
