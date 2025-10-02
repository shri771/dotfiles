-- Function to get conflicted files from git status
local function get_git_conflicts()
  local handle = io.popen("git status --porcelain | grep '^UU' | awk '{print $2}'")
  local result = handle:read("*a")
  handle:close()
  local files = {}
  for file in result:gmatch("[^\n]+") do
    table.insert(files, { filename = file, lnum = 1, col = 1, text = "Git merge conflict" })
  end
  return files
end

-- Function to populate quickfix list with conflicted files
local function populate_git_conflicts_qf()
  local conflicts = get_git_conflicts()
  if #conflicts == 0 then
    print("No merge conflicts found")
    return
  end
  vim.fn.setqflist(conflicts, "r") -- Populate quickfix list
  vim.fn.setqflist({}, "a", { title = "Git Merge Conflicts" }) -- Set title
  vim.cmd("copen") -- Open quickfix window
end

-- Create a Neovim command to trigger the quickfix list
vim.api.nvim_create_user_command("GitConflictsQuickfix", populate_git_conflicts_qf, {})
