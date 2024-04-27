-- Rerun tests only if their modification time changed.
cache = true
codes = true

exclude_files = {
  "tests/indent/lua/"
}

-- Global objects defined by the C code
read_globals = {
  "vim",
}
