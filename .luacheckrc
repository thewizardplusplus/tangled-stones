exclude_files = {
  ".luarocks/", -- created by the `leafo/gh-actions-luarocks` GitHub action
  "vendor/",
}
globals = {
  table = { fields = { shuffle = {}, find = {} } },
  "love",
}
max_line_length = 80
