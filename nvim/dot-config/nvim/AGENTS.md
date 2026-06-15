# AGENTS.md - Neovim Configuration Agent Guidelines

## Overview

This repository contains Neovim configuration files using the Lazy plugin manager. The codebase is primarily Lua-based with some Vimscript compiler configurations for Swift development. Agents should focus on maintaining consistency with existing patterns while following Neovim and Lua best practices.

## Build/Lint/Test Commands

### Lua/Neovim Testing
Since this is a Neovim configuration repository, there are no traditional build/test commands. However, you can validate the configuration by:

- **Validate Lua syntax**: `lua -e "require('lua/config/options')"` - Test if core config files load without errors
- **Check Neovim startup**: `nvim --headless -c 'quitall'` - Verify configuration loads without issues
- **Plugin validation**: Run `:Lazy check` within Neovim to verify plugin installations

### Swift Development Support
The repository includes compiler configurations for Swift development:

- **Swift single file**: `:compiler swift` - Compile standalone Swift files with optimizations
- **SwiftPM release**: `:compiler swiftpm` - Build Swift Package Manager projects in release mode
- **SwiftPM debug**: `:compiler swiftpm_debug` - Build Swift Package Manager projects in debug mode

### Running Individual Tests
- No formal test framework exists for this configuration
- Test plugin configurations by running `:Lazy sync` and checking for errors
- Validate LSP configurations by testing language server connections

## Code Style Guidelines

### Response Format & Communication
- **Be concise and direct**: Answer user questions in 1-3 sentences or short paragraphs
- **Minimize output tokens**: Keep responses under 4 lines unless detailed information is requested
- **One word answers when possible**: For simple questions like "2+2" → "4"
- **No unnecessary preamble**: Don't explain actions with "I will now..." or "Based on the information..."
- **Direct answers**: Don't say "The answer is X", just respond with "X"

### Tool Usage Policy
- **Batch tool calls**: Use multiple tools in a single response when independent information is needed
- **Prioritize specialized tools**: Use dedicated tools (Read, Edit, Glob) over Bash for file operations
- **Concurrent execution**: Run independent bash commands in parallel when possible
- **Proper quoting**: Always quote file paths with spaces using double quotes
- **Working directory**: Use `workdir` parameter instead of `cd <directory> && <command>` patterns

### Lua Code Style

#### File Structure
- **Plugin configurations**: Place in `lua/plugins/` directory with descriptive names (e.g., `blink-cmp.lua`)
- **Core configurations**: Place in `lua/core/` directory (e.g., `lazy.lua`, `lsp.lua`)
- **Options and settings**: Place in `lua/config/` directory (e.g., `options.lua`, `autocmds.lua`)
- **LSP configurations**: Place in `lsp/` directory with language-specific names (e.g., `lua_ls.lua`)

#### Imports and Dependencies
- Use `require()` for importing modules: `local lazy = require("lazy")`
- Import plugins using Lazy's import system: `{ import = "plugins" }`
- Avoid global variables; use local scope where possible
- Prefix local variables with descriptive names

#### Naming Conventions
- **Functions**: camelCase for regular functions, PascalCase for constructors
- **Variables**: camelCase with descriptive names (e.g., `mapleader`, `have_nerd_font`)
- **Constants**: UPPER_SNAKE_CASE for global constants
- **Files**: kebab-case for files, descriptive names (e.g., `blink-cmp.lua`, `neo-tree.lua`)
- **Directories**: lowercase with underscores if needed (e.g., `core`, `config`)

#### Formatting
- **Indentation**: 4 spaces (configured in options.lua)
- **Line length**: 120 characters maximum (configured in options.lua)
- **String quotes**: Use double quotes `"` for consistency
- **Table formatting**: Use consistent formatting with proper alignment
- **Function parameters**: Space after commas, no space before parentheses

#### Plugin Configuration Patterns
```lua
return {
    "plugin/name",
    version = "1.*",
    dependencies = {
        "dependency1",
        "dependency2",
    },
    opts = {
        -- Configuration options here
        setting = value,
    },
    config = function()
        -- Custom configuration logic
    end,
}
```

#### Keymaps
- Use descriptive names in keymap definitions
- Follow existing patterns: `vim.keymap.set({mode}, {keys}, {action}, {opts})`
- Include `desc` field for documentation
- Use `noremap = true` and `silent = true` consistently

#### Options Setting
- Use `vim.o` for simple options: `vim.o.number = true`
- Use `vim.opt` for complex options: `vim.opt.listchars = { tab = "» ", trail = "·" }`
- Group related options together with comments
- Set critical options early (before Lazy loads)

### Vimscript Code Style (for compiler files)
- Keep compiler files minimal and focused
- Use proper errorformat patterns
- Comment the purpose of each compiler configuration

### Error Handling
- Use `pcall()` for potentially failing operations during startup
- Provide meaningful error messages when operations fail
- Log errors appropriately without exposing sensitive information
- Handle async operations with proper error propagation

### Security Best Practices
- Never introduce code that exposes or logs secrets and keys
- Avoid storing sensitive configuration in version control
- Use environment variables for API keys and sensitive data
- Validate URLs and external dependencies

## Task Management
- **Proactive todo creation**: Use TodoWrite for multi-step tasks (3+ steps)
- **Status tracking**: Mark tasks as pending/in_progress/completed/cancelled
- **Single task focus**: Only one task in_progress at any time
- **Complete before starting**: Finish current tasks before beginning new ones

## External Rules Integration

No Cursor rules (.cursor/rules/ or .cursorrules) or Copilot rules (.github/copilot-instructions.md) found in this repository.

## Project-Specific Notes

### Neovim Configuration Structure
- **Entry point**: `init.lua` bootstraps the configuration
- **Plugin management**: Lazy.nvim handles plugin installation and configuration
- **Language support**: LSP configurations for multiple languages (Swift, Lua, etc.)
- **Development workflow**: Includes debugging, git integration, and testing tools

### Plugin Categories
- **Completion**: blink.cmp, snippets
- **LSP**: mason, fidget, lsp configurations
- **Navigation**: neo-tree, harpoon2, fzf
- **Git**: gitsigns, neogit, diffview
- **UI**: lualine, noice, snacks
- **Development**: nvim-dap, compiler configurations

### Key Bindings Philosophy
- **Leader key**: Space (` `) for most operations
- **Local leader**: Backslash (`\`) for buffer-local operations
- **Descriptive mappings**: All keymaps include `desc` fields for discoverability
- **Consistent patterns**: Follow existing conventions for similar operations

### Performance Considerations
- Lazy loading enabled by default
- Disabled unused built-in plugins (netrw, etc.)
- Optimized startup time with strategic plugin loading
- Tree-sitter for syntax highlighting and folding

When working with this Neovim configuration, maintain the established patterns while ensuring compatibility with Neovim's latest features and best practices.</content>
<parameter name="filePath">/Users/craig/dotfiles/nvim/dot-config/nvim/AGENTS.md