-- Project-wide linting utilities
-- Runs linters on the entire project and populates quickfix list

local M = {}

-- Linter configurations with their project-wide commands and output parsers
-- Each linter needs: cmd (command array), parser (function to parse output to qf entries)
local linter_configs = {
  eslint = {
    cmd = { "npx", "eslint", ".", "--format", "json" },
    parser = function(output)
      local ok, results = pcall(vim.json.decode, output)
      if not ok then
        return nil, "Failed to parse ESLint output"
      end

      local entries = {}
      for _, file_result in ipairs(results) do
        for _, msg in ipairs(file_result.messages or {}) do
          table.insert(entries, {
            filename = file_result.filePath,
            lnum = msg.line or 1,
            col = msg.column or 1,
            text = string.format("[%s] %s", msg.ruleId or "eslint", msg.message),
            type = msg.severity == 2 and "E" or "W",
          })
        end
      end
      return entries
    end,
  },
  svelte_check = {
    cmd = { "npx", "svelte-check", "--output", "machine-verbose" },
    parser = function(output)
      local entries = {}
      -- svelte-check machine-verbose format: filepath:line:col type message
      for line in output:gmatch("[^\r\n]+") do
        -- Format: /path/file.svelte:10:5 Error message here
        local filepath, lnum, col, severity, message = line:match("^(.+):(%d+):(%d+)%s+(%w+)%s+(.+)$")
        if filepath and lnum then
          local entry_type = "E"
          if severity and severity:lower() == "warning" then
            entry_type = "W"
          elseif severity and severity:lower() == "hint" then
            entry_type = "I"
          end
          table.insert(entries, {
            filename = filepath,
            lnum = tonumber(lnum),
            col = tonumber(col) or 1,
            text = message or line,
            type = entry_type,
          })
        end
      end
      return entries
    end,
  },
}

-- Get linters from nvim-lint configuration for all filetypes
local function get_configured_linters()
  local ok, lint = pcall(require, "lint")
  if not ok then
    return {}
  end

  local linters = {}
  for ft, ft_linters in pairs(lint.linters_by_ft or {}) do
    for _, linter in ipairs(ft_linters) do
      linters[linter] = true
    end
  end
  return linters
end

-- Run a single linter and return results via callback
local function run_linter(name, config, cwd, callback)
  local stdout_data = {}
  local stderr_data = {}

  local job_id = vim.fn.jobstart(config.cmd, {
    cwd = cwd,
    stdout_buffered = true,
    stderr_buffered = true,
    on_stdout = function(_, data)
      if data then
        for _, line in ipairs(data) do
          if line ~= "" then
            table.insert(stdout_data, line)
          end
        end
      end
    end,
    on_stderr = function(_, data)
      if data then
        for _, line in ipairs(data) do
          if line ~= "" then
            table.insert(stderr_data, line)
          end
        end
      end
    end,
    on_exit = function(_, exit_code)
      vim.schedule(function()
        local output = table.concat(stdout_data, "\n")
        if output == "" and #stderr_data > 0 then
          -- Some linters output to stderr
          output = table.concat(stderr_data, "\n")
        end

        if output == "" then
          callback(name, {})
          return
        end

        local entries, err = config.parser(output)
        if err then
          vim.notify(string.format("%s: %s", name, err), vim.log.levels.ERROR)
          callback(name, {})
          return
        end

        callback(name, entries or {})
      end)
    end,
  })

  -- Handle case where command fails to start
  if job_id <= 0 then
    vim.notify(string.format("%s: Failed to start linter", name), vim.log.levels.ERROR)
    callback(name, {})
  end
end

-- Run all configured linters on the project
function M.lint_project()
  local cwd = vim.fn.getcwd()
  local configured_linters = get_configured_linters()

  -- Determine which linters to run based on nvim-lint config
  local linters_to_run = {}

  -- Check for eslint
  if configured_linters["eslint"] or configured_linters["eslint_d"] then
    if linter_configs.eslint then
      linters_to_run.eslint = linter_configs.eslint
    end
  end

  -- Check for svelte (use svelte.config.js as indicator instead of expensive glob)
  local has_svelte = configured_linters["svelte_check"]
    or vim.fn.filereadable(cwd .. "/svelte.config.js") == 1
    or vim.fn.filereadable(cwd .. "/svelte.config.ts") == 1

  if has_svelte and linter_configs.svelte_check then
    linters_to_run.svelte_check = linter_configs.svelte_check
  end

  if vim.tbl_isempty(linters_to_run) then
    vim.notify("No project linters configured", vim.log.levels.WARN)
    return
  end

  local linter_names = vim.tbl_keys(linters_to_run)
  vim.notify(string.format("Running linters: %s", table.concat(linter_names, ", ")), vim.log.levels.INFO)

  local all_entries = {}
  local completed = 0
  local total = vim.tbl_count(linters_to_run)

  for name, config in pairs(linters_to_run) do
    run_linter(name, config, cwd, function(linter_name, entries)
      completed = completed + 1
      for _, entry in ipairs(entries) do
        table.insert(all_entries, entry)
      end

      if completed == total then
        -- All linters finished
        vim.schedule(function()
          if #all_entries > 0 then
            vim.fn.setqflist({}, "r", { title = "Project Lint", items = all_entries })
            vim.cmd("copen")
            vim.notify(string.format("Linting found %d issues", #all_entries), vim.log.levels.WARN)
          else
            vim.fn.setqflist({}, "r", { title = "Project Lint", items = {} })
            vim.notify("No linting issues found!", vim.log.levels.INFO)
          end
        end)
      end
    end)
  end
end

return M
