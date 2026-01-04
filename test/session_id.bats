#!/usr/bin/env bats
# Test session ID extraction

load test_helper

@test "extracts and sets CLAUDE_SESSION_ID" {
  output=$(run_with_fixture "active_session_with_context.json")

  session_id=$(get_env_var "CLAUDE_SESSION_ID" "$output")

  # Should be a UUID format
  [[ "$session_id" =~ ^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$ ]]
}

@test "handles missing session_id gracefully" {
  # Create a minimal fixture without session_id
  echo '{"model":{"display_name":"Sonnet 4.5"}}' >"${TEST_TEMP_DIR}/no_session.json"

  output=$(STARSHIP_CMD="${TEST_TEMP_DIR}/print-env" "${BIN_DIR}/starship-claude" <"${TEST_TEMP_DIR}/no_session.json")

  # CLAUDE_SESSION_ID should be empty
  session_id=$(get_env_var "CLAUDE_SESSION_ID" "$output")
  [ -z "$session_id" ]
}
