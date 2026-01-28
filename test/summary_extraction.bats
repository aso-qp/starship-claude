#!/usr/bin/env bats
# Test summary extraction from transcript JSONL

load test_helper

@test "extracts CLAUDE_SUMMARY from transcript JSONL" {
  output=$(run_with_fixture "session_with_summary.json")

  summary=$(get_env_var "CLAUDE_SUMMARY" "$output")

  [ "$summary" = "Working on starship-claude integration for Claude Code status line display" ]
}

@test "handles missing transcript_path gracefully" {
  # Create a fixture without transcript_path
  echo '{"model":{"display_name":"Sonnet 4.5"},"session_id":"test-123"}' >"${TEST_TEMP_DIR}/no_transcript.json"

  output=$(STARSHIP_CMD="${TEST_TEMP_DIR}/print-env" "${BIN_DIR}/starship-claude" <"${TEST_TEMP_DIR}/no_transcript.json")

  summary=$(get_env_var "CLAUDE_SUMMARY" "$output")
  [ -z "$summary" ]
}

@test "handles non-existent transcript file gracefully" {
  # Create a fixture with a transcript_path that doesn't exist
  echo '{"model":{"display_name":"Sonnet 4.5"},"transcript_path":"/nonexistent/path.jsonl"}' >"${TEST_TEMP_DIR}/bad_transcript.json"

  output=$(STARSHIP_CMD="${TEST_TEMP_DIR}/print-env" "${BIN_DIR}/starship-claude" <"${TEST_TEMP_DIR}/bad_transcript.json")

  summary=$(get_env_var "CLAUDE_SUMMARY" "$output")
  [ -z "$summary" ]
}

@test "handles transcript without summary gracefully" {
  # Create a JSONL without any summary entries
  echo '{"type":"user","message":"hello"}' >"${TEST_TEMP_DIR}/no_summary.jsonl"
  echo '{"type":"assistant","message":"hi"}' >>"${TEST_TEMP_DIR}/no_summary.jsonl"

  # Create fixture pointing to that JSONL
  echo "{\"model\":{\"display_name\":\"Sonnet 4.5\"},\"transcript_path\":\"${TEST_TEMP_DIR}/no_summary.jsonl\"}" >"${TEST_TEMP_DIR}/no_summary.json"

  output=$(STARSHIP_CMD="${TEST_TEMP_DIR}/print-env" "${BIN_DIR}/starship-claude" <"${TEST_TEMP_DIR}/no_summary.json")

  summary=$(get_env_var "CLAUDE_SUMMARY" "$output")
  [ -z "$summary" ]
}

@test "gets most recent summary when multiple exist" {
  # Create a JSONL with multiple summary entries
  echo '{"type":"summary","summary":"First summary"}' >"${TEST_TEMP_DIR}/multi_summary.jsonl"
  echo '{"type":"user","message":"more work"}' >>"${TEST_TEMP_DIR}/multi_summary.jsonl"
  echo '{"type":"summary","summary":"Latest summary after more work"}' >>"${TEST_TEMP_DIR}/multi_summary.jsonl"

  # Create fixture pointing to that JSONL
  echo "{\"model\":{\"display_name\":\"Sonnet 4.5\"},\"transcript_path\":\"${TEST_TEMP_DIR}/multi_summary.jsonl\"}" >"${TEST_TEMP_DIR}/multi_summary.json"

  output=$(STARSHIP_CMD="${TEST_TEMP_DIR}/print-env" "${BIN_DIR}/starship-claude" <"${TEST_TEMP_DIR}/multi_summary.json")

  summary=$(get_env_var "CLAUDE_SUMMARY" "$output")
  [ "$summary" = "Latest summary after more work" ]
}
