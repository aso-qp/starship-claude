---
name: starship
description: Starship-claude statusline setup wizard
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - AskUserQuestion
  - Glob
---

# Starship-Claude Setup Wizard

You are running an interactive setup wizard to configure the starship-claude statusline for Claude Code. Follow these steps in order, using AskUserQuestion for each decision point.

## Step 1: Check for Starship

Run this command to check if starship is installed:

```bash
command -v starship >/dev/null 2>&1 && echo "installed" || echo "not_installed"
```

### If starship is NOT installed:

Tell the user: "This prompt uses **Starship**, a fast configurable prompt for any shell. You can read more about it at https://starship.rs. We need to install starship to use this prompt."

Then ask:

- **Question**: "Install starship to continue?"
- **Header**: "Starship"
- **Options**:
  - "Install starship" → Run: `curl -sS https://starship.rs/install.sh | sh`
  - "Exit wizard" → Tell them to visit <https://starship.rs> when they're ready and exit the wizard

### If starship IS installed

Tell the user: "Looks like you already have starship installed, great!"

Then ask:

- **Question**: "Ready to configure your Claude statusline?"
- **Header**: "Ready"
- **Options**:
  - "Launch it! 🚀" → Continue to the next step

## Step 2: Check Existing Configuration

Check if configuration already exists:

```bash
test -f ~/.claude/starship.toml && echo "exists" || echo "not_found"
```

If it exists, ask:

- **Question**: "Found existing ~/.claude/starship.toml. What should I do?"
- **Header**: "Existing"
- **Options**:
  - "Replace it" → Continue to the next step
  - "Back it up and replace it" → Run: `cp ~/.claude/starship.toml ~/.claude/starship.toml.bak` and continue to the next step
  - "Keep it and exit" → Exit the wizard without changes

## Step 3: Nerd Font Detection

Ask the user if they can see Nerd Font icons.

> [!IMPORTANT]
> You can't display nerd fonts properly.
> You MUST run the cat command below.

```bash
cat ${CLAUDE_PLUGIN_ROOT}/templates/nerd-fonts-sample.txt
```

Then ask:

- **Question**: "Can you see the icons above clearly?"
- **Header**: "Nerd Font"
- **Options**:
  - "Yes, I can see the icons clearly" → Continue to Step 4
  - "No, I see boxes or question marks" → Set `has_nerd_fonts=false` and skip to Step 5

## Step 4: Format Style Selection

> [!NOTE]
> Only run this step if the user has Nerd Fonts.
> If they don't have Nerd Fonts, skip to Step 5 and use `minimal-text` template.

Show both style options side by side:

> [!Important]
> You MUST run this command.
> You are unable to properly output nerd fonts. Trust that it will work.

```bash
${CLAUDE_PLUGIN_ROOT}/bin/configure.sh --nerdfont --compare-styles
```

Then ask:

- **Question**: "Which prompt style do you prefer?"
- **Header**: "Style"
- **Options**:
  - "Minimal" → Set `chosen_style=minimal`
  - "Bubbles" → Set `chosen_style=bubbles`

## Step 5: Color Palette Selection

Show all available palettes in the chosen style.

**If user has Nerd Fonts**, run:

```bash
${CLAUDE_PLUGIN_ROOT}/bin/configure.sh --nerdfont --style ${chosen_style} --all-palettes
```

**If user does NOT have Nerd Fonts**, run:

```bash
${CLAUDE_PLUGIN_ROOT}/bin/configure.sh --all-palettes
```

Then ask:

- **Question**: "Which color palette do you like? (press ctrl+o to see)"
- **Header**: "Palette"
- **Options**:
  - "Catppuccin Mocha" → `chosen_palette=catppuccin_mocha`
  - "Catppuccin Frappe" → `chosen_palette=catppuccin_frappe`
  - "Dracula" → `chosen_palette=dracula`
  - "Gruvbox Dark" → `chosen_palette=gruvbox_dark`
  - "Nord" → `chosen_palette=nord`
  - "Solarized Dark" → `chosen_palette=solarized_dark`

## Step 6: Install Files

### 6a. Create directories

```bash
mkdir -p ~/.local/bin ~/.claude
```

### 6b. Copy the starship-claude script

```bash
cp ${CLAUDE_PLUGIN_ROOT}/bin/starship-claude \
~/.local/bin/starship-claude && chmod +x ~/.local/bin/starship-claude
```

### 6c. Generate starship.toml

Generate the configuration file using configure.sh based on the user's choices:

**If user has Nerd Fonts**, run:

```bash
${CLAUDE_PLUGIN_ROOT}/bin/configure.sh --nerdfont --style ${chosen_style} --palette ${chosen_palette} --write
```

**If user does NOT have Nerd Fonts**, run:

```bash
${CLAUDE_PLUGIN_ROOT}/bin/configure.sh --palette ${chosen_palette} --write
```

This will create `~/.claude/starship.toml` with the appropriate template and palette.

### 6d. Update settings.json

Read `~/.claude/settings.json` if it exists. Add or update the statusLine configuration:

```json
{
  "statusLine": {
    "type": "command",
    "padding": 0,
    "command": "~/.local/bin/starship-claude"
  }
}
```

If the file doesn't exist, create it with just the statusLine configuration.
If it exists, preserve all other settings and only add/update the statusLine key.

## Step 7: Verify Installation

Run a test to verify everything works:

```bash
echo '{"model":{"display_name":"Sonnet 4"},"cost":{"total_cost_usd":0.05},"context_window":{"context_window_size":200000,"current_usage":{"input_tokens":10000,"cache_creation_input_tokens":0,"cache_read_input_tokens":0}}}' | ~/.local/bin/starship-claude --no-progress
```

Show the output to the user.

## Step 8: Success Message

Display this completion message:

```
Setup complete!

Your starship-claude statusline is now configured with:
- Palette: {chosen_palette}
- Style: {chosen_style or "minimal-text"}
- Nerd Fonts: {yes/no based on has_nerd_fonts}

Files created/updated:
- ~/.local/bin/starship-claude (statusline script)
- ~/.claude/starship.toml (starship config)
- ~/.claude/settings.json (claude settings)

To reconfigure later, run /starship again.

You may need to restart Claude Code to see the changes.
```

## Template File Locations

The template files are located at `${CLAUDE_PLUGIN_ROOT}/templates/`:

```
templates/
├── minimal-text.toml    # Minimal style without nerd fonts (includes all palettes)
├── minimal-nerd.toml    # Minimal style with nerd fonts (includes all palettes)
├── bubbles-nerd.toml  # Bubbles style with nerd fonts (palettes appended by configure.sh)
└── starship-claude      # Binary for generating statusline
```

All palettes are embedded in the template files. The setup wizard replaces the `palette = "catppuccin_mocha"` line with the user's choice.
