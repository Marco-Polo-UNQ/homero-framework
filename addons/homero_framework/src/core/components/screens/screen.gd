@abstract
class_name HFScreen
extends Node
## Base class for all screens in the Homero Framework.
##
## Extend this class to implement custom screen logic. Used by [HFScreenLoader] and [HFScreenManager].
## Handles screen entry and exit, and provides signals for screen changes and exit completion.

## Emitted when the screen requests a change to another screen.
## [param target_screen] The id of the target screen.
## [param value] Optional value to pass to the target screen.
signal change_screen(target_screen: int, value: Variant)

## Emitted when the screen has finished its exit logic and can be safely removed.
signal finished_exit()

## Called when the screen is entered. Override to implement custom logic.
## [param value] Optional value passed to the screen on entry.
@abstract
func enter(value: Variant = null) -> void

## Called when the screen is exited. Override to implement custom logic.
func exit() -> void:
	finished_exit.emit()
