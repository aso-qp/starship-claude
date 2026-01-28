#!/usr/bin/env bats
# Tests for raw environment variable outputs from Claude Code JSON data

bats_require_minimum_version 1.5.0
load test_helper

# =============================================================================
# Tests using active_session_with_context.json fixture
# This fixture has complete data for all fields
# =============================================================================

@test "raw: session_id is exported from active session" {
  output=$(run_with_fixture "active_session_with_context.json")
  assert_env_equals "CLAUDE_SESSION_ID" "00000000-0000-0000-0000-000000000000" "$output"
}

@test "raw: transcript_path is exported from active session" {
  output=$(run_with_fixture "active_session_with_context.json")
  value=$(get_env_var "CLAUDE_TRANSCRIPT_PATH" "$output")
  [[ "$value" == *"00000000-0000-0000-0000-000000000000.jsonl" ]]
}

@test "raw: cwd is exported from active session" {
  output=$(run_with_fixture "active_session_with_context.json")
  value=$(get_env_var "CLAUDE_CWD" "$output")
  [[ "$value" == *"starship-claude" ]]
}

@test "raw: workspace.current_dir is exported from active session" {
  output=$(run_with_fixture "active_session_with_context.json")
  value=$(get_env_var "CLAUDE_WORKSPACE_CURRENT_DIR" "$output")
  [[ "$value" == *"starship-claude" ]]
}

@test "raw: workspace.project_dir is exported from active session" {
  output=$(run_with_fixture "active_session_with_context.json")
  value=$(get_env_var "CLAUDE_WORKSPACE_PROJECT_DIR" "$output")
  [[ "$value" == *"starship-claude" ]]
}

@test "raw: version is exported from active session" {
  output=$(run_with_fixture "active_session_with_context.json")
  assert_env_equals "CLAUDE_VERSION" "2.0.76" "$output"
}

@test "raw: output_style.name is exported from active session" {
  output=$(run_with_fixture "active_session_with_context.json")
  assert_env_equals "CLAUDE_OUTPUT_STYLE" "default" "$output"
}

@test "raw: model.id is exported from active session" {
  output=$(run_with_fixture "active_session_with_context.json")
  assert_env_equals "CLAUDE_MODEL_ID" "claude-sonnet-4-5-20250929" "$output"
}

@test "raw: model.display_name is exported from active session" {
  output=$(run_with_fixture "active_session_with_context.json")
  assert_env_equals "CLAUDE_MODEL_DISPLAY_NAME" "Sonnet 4.5" "$output"
}

@test "raw: cost.total_cost_usd is exported from active session" {
  output=$(run_with_fixture "active_session_with_context.json")
  assert_env_equals "CLAUDE_COST_RAW" "0.70837435" "$output"
}

@test "raw: cost.total_duration_ms is exported from active session" {
  output=$(run_with_fixture "active_session_with_context.json")
  assert_env_equals "CLAUDE_TOTAL_DURATION_MS" "47648455" "$output"
}

@test "raw: cost.total_api_duration_ms is exported from active session" {
  output=$(run_with_fixture "active_session_with_context.json")
  assert_env_equals "CLAUDE_API_DURATION_MS" "198183" "$output"
}

@test "raw: cost.total_lines_added is exported from active session" {
  output=$(run_with_fixture "active_session_with_context.json")
  assert_env_equals "CLAUDE_LINES_ADDED" "141" "$output"
}

@test "raw: cost.total_lines_removed is exported from active session" {
  output=$(run_with_fixture "active_session_with_context.json")
  assert_env_equals "CLAUDE_LINES_REMOVED" "1" "$output"
}

@test "raw: context_window.total_input_tokens is exported from active session" {
  output=$(run_with_fixture "active_session_with_context.json")
  assert_env_equals "CLAUDE_TOTAL_INPUT_TOKENS" "8429" "$output"
}

@test "raw: context_window.total_output_tokens is exported from active session" {
  output=$(run_with_fixture "active_session_with_context.json")
  assert_env_equals "CLAUDE_TOTAL_OUTPUT_TOKENS" "9054" "$output"
}

@test "raw: context_window.context_window_size is exported from active session" {
  output=$(run_with_fixture "active_session_with_context.json")
  assert_env_equals "CLAUDE_CONTEXT_SIZE" "200000" "$output"
}

@test "raw: exceeds_200k_tokens is exported from active session" {
  output=$(run_with_fixture "active_session_with_context.json")
  assert_env_equals "CLAUDE_EXCEEDS_200K" "false" "$output"
}

@test "raw: current_usage.input_tokens is exported from active session" {
  output=$(run_with_fixture "active_session_with_context.json")
  assert_env_equals "CLAUDE_INPUT_TOKENS" "8" "$output"
}

@test "raw: current_usage.output_tokens is exported from active session" {
  output=$(run_with_fixture "active_session_with_context.json")
  assert_env_equals "CLAUDE_OUTPUT_TOKENS" "127" "$output"
}

@test "raw: current_usage.cache_creation_input_tokens is exported from active session" {
  output=$(run_with_fixture "active_session_with_context.json")
  assert_env_equals "CLAUDE_CACHE_CREATION" "31373" "$output"
}

@test "raw: current_usage.cache_read_input_tokens is exported from active session" {
  output=$(run_with_fixture "active_session_with_context.json")
  assert_env_equals "CLAUDE_CACHE_READ" "0" "$output"
}

# =============================================================================
# Tests using high_cost.json fixture
# Tests different token values and cache read behavior
# =============================================================================

@test "raw: high_cost fixture has different api_duration" {
  output=$(run_with_fixture "high_cost.json")
  assert_env_equals "CLAUDE_API_DURATION_MS" "205091" "$output"
}

@test "raw: high_cost fixture has cache read tokens" {
  output=$(run_with_fixture "high_cost.json")
  assert_env_equals "CLAUDE_CACHE_READ" "31373" "$output"
}

@test "raw: high_cost fixture has different total input tokens" {
  output=$(run_with_fixture "high_cost.json")
  assert_env_equals "CLAUDE_TOTAL_INPUT_TOKENS" "15524" "$output"
}

# =============================================================================
# Tests using zero_cost.json fixture
# Tests zero/null value handling
# =============================================================================

@test "raw: zero cost fixture has zero total_cost_usd" {
  output=$(run_with_fixture "zero_cost.json")
  assert_env_equals "CLAUDE_COST_RAW" "0" "$output"
}

@test "raw: zero cost fixture has zero total_input_tokens" {
  output=$(run_with_fixture "zero_cost.json")
  assert_env_equals "CLAUDE_TOTAL_INPUT_TOKENS" "0" "$output"
}

@test "raw: zero cost fixture has zero total_output_tokens" {
  output=$(run_with_fixture "zero_cost.json")
  assert_env_equals "CLAUDE_TOTAL_OUTPUT_TOKENS" "0" "$output"
}

@test "raw: zero cost fixture has zero lines_added" {
  output=$(run_with_fixture "zero_cost.json")
  assert_env_equals "CLAUDE_LINES_ADDED" "0" "$output"
}

@test "raw: zero cost fixture has zero lines_removed" {
  output=$(run_with_fixture "zero_cost.json")
  assert_env_equals "CLAUDE_LINES_REMOVED" "0" "$output"
}

# =============================================================================
# Tests using session_with_summary.json fixture
# Tests minimal data with different session_id
# =============================================================================

@test "raw: session_with_summary has different session_id" {
  output=$(run_with_fixture "session_with_summary.json")
  assert_env_equals "CLAUDE_SESSION_ID" "11111111-1111-1111-1111-111111111111" "$output"
}

@test "raw: session_with_summary has cost_raw" {
  output=$(run_with_fixture "session_with_summary.json")
  assert_env_equals "CLAUDE_COST_RAW" "0.05" "$output"
}

@test "raw: session_with_summary has context_size" {
  output=$(run_with_fixture "session_with_summary.json")
  assert_env_equals "CLAUDE_CONTEXT_SIZE" "200000" "$output"
}

# =============================================================================
# Tests using session_without_current_usage.json fixture
# Tests missing current_usage handling
# =============================================================================

@test "raw: missing current_usage leaves token vars empty" {
  output=$(run_with_fixture "session_without_current_usage.json")
  # When current_usage is null, these should be empty/unset
  assert_env_empty "CLAUDE_INPUT_TOKENS" "$output"
  assert_env_empty "CLAUDE_OUTPUT_TOKENS" "$output"
  assert_env_empty "CLAUDE_CACHE_CREATION" "$output"
  assert_env_empty "CLAUDE_CACHE_READ" "$output"
}

# =============================================================================
# Tests for computed values (not raw, but derived from raw)
# =============================================================================

@test "computed: CLAUDE_CURRENT_TOKENS sums input + cache tokens" {
  output=$(run_with_fixture "active_session_with_context.json")
  # 8 (input) + 31373 (cache_creation) + 0 (cache_read) = 31381
  assert_env_equals "CLAUDE_CURRENT_TOKENS" "31381" "$output"
}

@test "computed: CLAUDE_PERCENT_RAW calculates percentage correctly" {
  output=$(run_with_fixture "active_session_with_context.json")
  # 31381 * 100 / 200000 = 15 (integer division)
  assert_env_equals "CLAUDE_PERCENT_RAW" "15" "$output"
}
