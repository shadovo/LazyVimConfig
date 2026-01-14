-- Project-wide linting utilities
-- Runs eslint and svelte-check on the entire project and populates quickfix list

local M = {}

-- Parse ESLint JSON output into quickfix entries
local function parse_eslint_output(output)
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
end

-- Parse svelte-check machine output into quickfix entries
-- Format: TIMESTAMP SEVERITY "filepath" line:col "message"
local function parse_svelte_check_output(output)
  local entries = {}
  for line in output:gmatch("[^\r\n]+") do
    -- Match: timestamp ERROR/WARNING "filepath" line:col "message"
    local severity, filepath, lnum, col, message = line:match('^%d+%s+(%w+)%s+"([^"]+)"%s+(%d+):(%d+)%s+"(.+)"$')
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
end

-- Run a command and collect output
local function run_command(cmd, cwd, callback)
  local stdout_data = {}

  local job_id = vim.fn.jobstart(cmd, {
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
    on_exit = function()
      vim.schedule(function()
        callback(table.concat(stdout_data, "\n"))
      end)
    end,
  })

  if job_id <= 0 then
    vim.schedule(function()
      callback("")
    end)
  end
end

-- Run project-wide linting with eslint and svelte-check
function M.lint_project()
  local cwd = vim.fn.getcwd()
  local all_entries = {}
  local completed = 0

  -- Determine which linters to run
  local linters = { "eslint" }
  local has_svelte = vim.fn.filereadable(cwd .. "/svelte.config.js") == 1
    or vim.fn.filereadable(cwd .. "/svelte.config.ts") == 1
  if has_svelte then
    table.insert(linters, "svelte-check")
  end

  local total = #linters

  vim.notify("Running project linting...", vim.log.levels.INFO)

  local function on_complete()
    completed = completed + 1
    if completed == total then
      vim.schedule(function()
        if #all_entries > 0 then
          vim.fn.setqflist({}, "r", { title = "Project Lint", items = all_entries })
          -- Use Trouble for nicer quickfix display if available
          local ok, trouble = pcall(require, "trouble")
          if ok then
            trouble.open({ mode = "quickfix", focus = true })
          else
            vim.cmd("copen")
          end
          vim.notify(string.format("Linting found %d issues", #all_entries), vim.log.levels.WARN)
        else
          vim.fn.setqflist({}, "r", { title = "Project Lint", items = {} })
          vim.notify("No linting issues found!", vim.log.levels.INFO)
        end
      end)
    end
  end

  -- Run ESLint
  run_command({ "npx", "eslint", ".", "--format", "json" }, cwd, function(output)
    if output ~= "" then
      local entries, err = parse_eslint_output(output)
      if err then
        vim.notify("ESLint: " .. err, vim.log.levels.ERROR)
      elseif entries then
        for _, entry in ipairs(entries) do
          table.insert(all_entries, entry)
        end
      end
    end
    on_complete()
  end)

  -- Run svelte-check only if project has Svelte
  if has_svelte then
    run_command({ "npx", "svelte-check", "--tsconfig", "./tsconfig.json", "--output", "machine" }, cwd, function(output)
      if output ~= "" then
        local entries = parse_svelte_check_output(output)
        if entries then
          for _, entry in ipairs(entries) do
            -- svelte-check outputs relative paths, make them absolute
            if entry.filename and not entry.filename:match("^/") then
              entry.filename = cwd .. "/" .. entry.filename
            end
            table.insert(all_entries, entry)
          end
        end
      end
      on_complete()
    end)
  end
end

return M
