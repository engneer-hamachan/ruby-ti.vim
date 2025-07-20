# Ruby-TI Vim Plugin

A modern, modular Vim/Neovim plugin that integrates with the Ruby-TI type checker to provide real-time visual feedback with animated error messages.

## Features

- **Real-time Type Checking**: Automatically runs Ruby-TI on file save and buffer events
- **Animated Feedback**: Progressive typing animation for error messages
- **Visual Error Highlighting**: Highlights error lines in the source code
- **Smart Popup System**: Context-aware popup that appears when cursor is on error line
- **Configurable Interface**: Customizable colors, symbols, and animation settings
- **Modular Architecture**: Clean, maintainable code structure

## Installation

### Using vim-plug

Add this line to your vimrc/init.vim:

```vim
Plug 'username/ruby-ti.vim'
```

Then run `:PlugInstall`

### Manual Installation

1. Clone this repository to your Vim plugin directory:
   ```bash
   git clone https://github.com/username/ruby-ti.vim ~/.vim/pack/plugins/start/ruby-ti.vim
   ```

2. For Neovim:
   ```bash
   git clone https://github.com/username/ruby-ti.vim ~/.local/share/nvim/site/pack/plugins/start/ruby-ti.vim
   ```

## Configuration

You can customize the plugin by setting `g:ruby_ti_config` in your vimrc:

```vim
let g:ruby_ti_config = {
  \ 'animation_speed': 10,
  \ 'min_popup_width': 50,
  \ 'checker_command': 'ruby-ti',
  \ 'enable_animation': 1,
  \ 'enable_line_highlighting': 1,
  \ 'colors': {
  \   'warning_fg': 'Red',
  \   'error_bg': '#001122',
  \   'error_fg': '#00ff99'
  \ }
\ }
```

### Configuration Options

| Option | Default | Description |
|--------|---------|-------------|
| `animation_speed` | `7` | Timer delay in milliseconds for typing animation |
| `min_popup_width` | `40` | Minimum width for popup window |
| `popup_offset_col` | `-2` | Column offset for popup positioning |
| `popup_offset_row` | `1` | Row offset for popup positioning |
| `checker_command` | `'ti'` | Command to run Ruby-TI type checker |
| `enable_animation` | `1` | Enable/disable typing animation |
| `enable_line_highlighting` | `1` | Enable/disable error line highlighting |

## Architecture

The plugin is organized into modular components:

### Core Modules

- **`ruby_ti.vim`**: Main plugin entry point and autocommand setup
- **`autoload/ruby_ti/config.vim`**: Configuration management
- **`autoload/ruby_ti/state.vim`**: State management (replaces global variables)
- **`autoload/ruby_ti/ui.vim`**: User interface and popup management
- **`autoload/ruby_ti/animation.vim`**: Typing animation system
- **`autoload/ruby_ti/checker.vim`**: Type checker integration

### Key Improvements Over Original

1. **Modular Design**: Separated concerns into focused modules
2. **State Management**: Replaced global variables with proper state container
3. **Error Handling**: Added comprehensive error checking and validation
4. **Configuration System**: Externalized all configuration options
5. **Documentation**: Added inline documentation and usage examples
6. **Code Quality**: Improved naming, structure, and maintainability

## Usage

The plugin automatically activates for Ruby files (*.rb) and provides:

1. **Automatic Checking**: Runs on file save, read, and window enter events
2. **Visual Feedback**: Highlights error lines and shows warning messages
3. **Interactive Popup**: Displays animated error details when cursor is on error line
4. **Smart Cleanup**: Automatically manages timers, windows, and state

## API Reference

### Public Functions

- `ruby_ti#config#get(key, default)`: Get configuration value
- `ruby_ti#config#set(key, value)`: Set configuration value
- `ruby_ti#state#reset()`: Reset plugin state
- `ruby_ti#ui#show_popup()`: Manually show error popup
- `ruby_ti#ui#hide_popup()`: Manually hide error popup
- `ruby_ti#checker#run()`: Manually run type checker

## Troubleshooting

### Common Issues

1. **Type checker not found**: Ensure `ti` command is in your PATH
2. **No popup appearing**: Check that error line matches cursor position
3. **Animation not working**: Verify Neovim version supports timer functions

### Debug Mode

Enable debug output by setting:
```vim
let g:ruby_ti_debug = 1
```


## Requirements

- Vim 8.0+ or Neovim 0.3+
- Ruby-TI type checker installed and accessible as `ti` command
- Timer support (for animations)

## License

This plugin follows the same license as the Ruby-TI project.