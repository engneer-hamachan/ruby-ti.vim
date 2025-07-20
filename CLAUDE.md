# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Vim/Neovim plugin that integrates with the Ruby-TI type checker to provide real-time visual feedback with animated error messages for Ruby files. The plugin is written entirely in Vimscript and follows a modular architecture.

## Development Commands

Since this is a Vim plugin written in Vimscript, there are no build/test/lint commands. Development workflow involves:

- Testing the plugin by sourcing `ruby_ti.vim` in a Vim/Neovim instance
- Requires the external `ti` command (Ruby-TI type checker) to be available in PATH
- Plugin automatically activates for `*.rb` files

## Architecture

The plugin uses a modular autoload structure organized into focused components:

### Core Components

- **`ruby_ti.vim`**: Main entry point, sets up autocommands and loads modules
- **`autoload/ruby_ti/config.vim`**: Configuration management with user overrides via `g:ruby_ti_config`
- **`autoload/ruby_ti/state.vim`**: Centralized state management replacing global variables
- **`autoload/ruby_ti/checker.vim`**: Ruby-TI integration using Neovim's job system (`jobstart`)
- **`autoload/ruby_ti/ui.vim`**: Popup windows and visual feedback management
- **`autoload/ruby_ti/animation.vim`**: Typing animation system using timers

### Key Design Patterns

- **Autoload Functions**: All functions follow `ruby_ti#module#function()` naming
- **State Container**: Single state object managed through `ruby_ti#state` module
- **Async Job System**: Uses Neovim's `jobstart` for non-blocking type checking
- **Timer-based Animation**: Progressive typing animation using `timer_start`
- **Event-driven UI**: Autocommands trigger checking on file events and cursor movement

### Configuration System

Users configure the plugin via `g:ruby_ti_config` dictionary with options for:
- Animation speed and styling
- Popup appearance and positioning  
- Type checker command customization
- Color and visual customization

### Error Flow

1. File save/read triggers `ruby_ti#checker#run()`
2. Async job parses output format: `file_path::line_number::error_message`
3. Error info stored in state and visual feedback applied
4. Cursor movement on error lines triggers animated popup display

## File Structure

```
ruby_ti.vim              # Main plugin file
autoload/ruby_ti/        # Modular components
├── config.vim           # Configuration management
├── state.vim            # State container
├── checker.vim          # Type checker integration
├── ui.vim               # User interface
└── animation.vim        # Animation system
```

## Testing Workflow

Manual testing involves:
1. Installing plugin in Vim/Neovim
2. Opening Ruby files with type errors
3. Verifying popup animations and error highlighting
4. Testing configuration customization