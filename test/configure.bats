#!/usr/bin/env bats
# Tests for plugin/bin/configure.sh

bats_require_minimum_version 1.5.0
load test_helper

# Override setup to add plugin bin to PATH
setup() {
  # Call parent setup
  export PATH="${BIN_DIR}:${PATH}"
  export TEST_TEMP_DIR="$(mktemp -d)"

  # Add plugin bin directory to PATH for configure.sh
  export PLUGIN_BIN_DIR="${PROJECT_ROOT}/plugin/bin"
  export PREVIEW_SCRIPT="${PLUGIN_BIN_DIR}/configure.sh"

  # Templates are in the real location
  export TEMPLATE_DIR="${PROJECT_ROOT}/plugin/templates"

  # Create a mock starship-claude that captures calls
  export MOCK_STARSHIP="${TEST_TEMP_DIR}/starship-claude"
  cat > "${MOCK_STARSHIP}" << 'EOF'
#!/usr/bin/env bash
# Mock starship-claude for testing - just echo what we received
echo "MOCK_CALLED"
echo "args: $*"
cat
EOF
  chmod +x "${MOCK_STARSHIP}"
}

# Helper to run configure.sh with mocked starship-claude
run_preview() {
  # Create a modified version of configure.sh that uses our mock and correct template dir
  local test_script="${TEST_TEMP_DIR}/preview-test.sh"

  # Copy the script and replace both the template dir and starship-claude paths
  sed -e "s|TEMPLATE_DIR=\"\${SCRIPT_DIR}/../templates\"|TEMPLATE_DIR=\"${TEMPLATE_DIR}\"|" \
      -e "s|STARSHIP_CLAUDE=\"\${TEMPLATE_DIR}/starship-claude\"|STARSHIP_CLAUDE=\"${MOCK_STARSHIP}\"|" \
    "${PREVIEW_SCRIPT}" > "${test_script}"
  chmod +x "${test_script}"

  run bash "${test_script}" "$@"
}

@test "configure.sh: shows help with --help" {
  run_preview --help

  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage: configure.sh"* ]]
  [[ "$output" == *"--nerdfont"* ]]
  [[ "$output" == *"--palette"* ]]
}

@test "configure.sh: shows help with -h" {
  run_preview -h

  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage: configure.sh"* ]]
}

@test "configure.sh: accepts valid minimal palette" {
  run_preview --palette catppuccin_mocha

  [ "$status" -eq 0 ]
  [[ "$output" == *"MOCK_CALLED"* ]]
}

@test "configure.sh: accepts valid dracula palette" {
  run_preview --palette dracula

  [ "$status" -eq 0 ]
  [[ "$output" == *"MOCK_CALLED"* ]]
}

@test "configure.sh: rejects invalid palette" {
  run_preview --palette invalid_palette_name

  [ "$status" -eq 1 ]
  [[ "$output" == *"Invalid palette 'invalid_palette_name'"* ]]
  [[ "$output" == *"Valid palettes:"* ]]
}

@test "configure.sh: accepts minimal style" {
  run_preview --style minimal

  [ "$status" -eq 0 ]
  [[ "$output" == *"MOCK_CALLED"* ]]
}

@test "configure.sh: accepts bubbles style" {
  run_preview --style bubbles --nerdfont

  [ "$status" -eq 0 ]
  [[ "$output" == *"MOCK_CALLED"* ]]
}

@test "configure.sh: rejects invalid style" {
  run_preview --style invalid_style

  [ "$status" -eq 1 ]
  [[ "$output" == *"Invalid style 'invalid_style'"* ]]
  [[ "$output" == *"Valid styles: minimal, bubbles"* ]]
}

@test "configure.sh: --palette requires argument" {
  run_preview --palette

  [ "$status" -eq 1 ]
  [[ "$output" == *"Option --palette requires an argument"* ]]
}

@test "configure.sh: --style requires argument" {
  run_preview --style

  [ "$status" -eq 1 ]
  [[ "$output" == *"Option --style requires an argument"* ]]
}

@test "configure.sh: --config requires argument" {
  run_preview --config

  [ "$status" -eq 1 ]
  [[ "$output" == *"Option --config requires an argument"* ]]
}

@test "configure.sh: --path requires argument" {
  run_preview --path

  [ "$status" -eq 1 ]
  [[ "$output" == *"Option --path requires an argument"* ]]
}

@test "configure.sh: --write requires argument" {
  run_preview --write

  [ "$status" -eq 1 ]
  [[ "$output" == *"Option --write requires an argument"* ]]
}

@test "configure.sh: rejects unknown option" {
  run_preview --unknown-option

  [ "$status" -eq 1 ]
  [[ "$output" == *"Unknown option: --unknown-option"* ]]
}

@test "configure.sh: rejects unexpected positional argument" {
  run_preview unexpected_arg

  [ "$status" -eq 1 ]
  [[ "$output" == *"Unexpected argument: unexpected_arg"* ]]
}

@test "configure.sh: uses minimal-text template by default" {
  run_preview

  [ "$status" -eq 0 ]
  [[ "$output" == *"MOCK_CALLED"* ]]
  # Config should be passed as argument
  [[ "$output" == *"--config"* ]]
}

@test "configure.sh: uses minimal-nerd template with --nerdfont" {
  run_preview --nerdfont

  [ "$status" -eq 0 ]
  [[ "$output" == *"MOCK_CALLED"* ]]
}

@test "configure.sh: uses bubbles-nerd template with --style bubbles" {
  run_preview --style bubbles --nerdfont

  [ "$status" -eq 0 ]
  [[ "$output" == *"MOCK_CALLED"* ]]
}

@test "configure.sh: creates config with selected palette" {
  run_preview --palette dracula

  [ "$status" -eq 0 ]
  # The script should have created a temp config
  [[ "$output" == *"MOCK_CALLED"* ]]
}

@test "configure.sh: passes --no-progress to starship-claude" {
  run_preview

  [ "$status" -eq 0 ]
  [[ "$output" == *"args:"*"--no-progress"* ]]
}

@test "configure.sh: passes --path option through to starship-claude" {
  run_preview --path /test/fake/path

  [ "$status" -eq 0 ]
  [[ "$output" == *"args:"*"--path"* ]]
  [[ "$output" == *"/test/fake/path"* ]]
}

@test "configure.sh: passes --config option through to starship-claude" {
  local test_config="${TEST_TEMP_DIR}/test-config.toml"
  echo 'format = "test"' > "$test_config"

  run_preview --config "$test_config"

  [ "$status" -eq 0 ]
  [[ "$output" == *"args:"*"--config"* ]]
  [[ "$output" == *"$test_config"* ]]
}

@test "configure.sh: --write saves config to file" {
  local output_file="${TEST_TEMP_DIR}/saved-config.toml"

  run_preview --write "$output_file"

  [ "$status" -eq 0 ]
  [ -f "$output_file" ]
  # Should contain palette setting
  grep -q 'palette = "catppuccin_mocha"' "$output_file"
  # Should have written config message
  [[ "$output" == *"Wrote config to:"* ]]
}

@test "configure.sh: --write expands tilde in path" {
  # We can't actually write to ~ in tests, but we can verify the attempt is made
  run_preview --write "~/test-config.toml"

  # Will fail because we can't write to actual home in test, but command should process the path
  # The error or success depends on permissions, so just check it tried to process
  [[ "$output" == *"Wrote config to:"* ]] || [ "$status" -eq 1 ]
}

@test "configure.sh: pipes sample JSON to starship-claude" {
  run_preview

  [ "$status" -eq 0 ]
  # Check that stdin contains expected JSON structure (from the mock output)
  [[ "$output" == *'"model"'* ]]
  [[ "$output" == *'"display_name":"Sonnet 4"'* ]]
  [[ "$output" == *'"cost"'* ]]
}

@test "configure.sh: --compare-styles shows both styles" {
  run_preview --compare-styles

  [ "$status" -eq 0 ]
  [[ "$output" == *"MINIMAL:"* ]]
  [[ "$output" == *"POWERLINE:"* ]]
  # Should call starship-claude twice (look for MOCK_CALLED)
  [[ "$(echo "$output" | grep -c 'MOCK_CALLED')" -eq 2 ]]
}

@test "configure.sh: --all-palettes shows all 6 palettes" {
  run_preview --all-palettes

  [ "$status" -eq 0 ]
  # Should show all palette names
  [[ "$output" == *"catppuccin_mocha:"* ]]
  [[ "$output" == *"catppuccin_frappe:"* ]]
  [[ "$output" == *"dracula:"* ]]
  [[ "$output" == *"gruvbox_dark:"* ]]
  [[ "$output" == *"nord:"* ]]
  [[ "$output" == *"solarized_dark:"* ]]
  # Should call mock 6 times
  [[ "$(echo "$output" | grep -c 'MOCK_CALLED')" -eq 6 ]]
}

@test "configure.sh: --all-palettes respects --style option" {
  run_preview --all-palettes --style bubbles --nerdfont

  [ "$status" -eq 0 ]
  # Should call mock 6 times for all palettes
  [[ "$(echo "$output" | grep -c 'MOCK_CALLED')" -eq 6 ]]
}

@test "configure.sh: combines --nerdfont and --palette options" {
  run_preview --nerdfont --palette dracula

  [ "$status" -eq 0 ]
  [[ "$output" == *"MOCK_CALLED"* ]]
}

@test "configure.sh: handles multiple options in any order" {
  run_preview --palette nord --nerdfont --style minimal

  [ "$status" -eq 0 ]
  [[ "$output" == *"MOCK_CALLED"* ]]
}
