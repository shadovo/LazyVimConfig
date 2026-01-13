-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Run ESLint on the entire project and populate quickfix list
vim.keymap.set("n", "<leader>cE", function()
  local cwd = vim.fn.getcwd()
  -- Use npx to run eslint with JSON format (built-in, no extra packages needed)
  local cmd = "npx eslint . --format json"

  vim.notify("Running ESLint on project...", vim.log.levels.INFO)

  local stdout_data = {}
  local stderr_data = {}

  vim.fn.jobstart(cmd, {
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
        -- Check for stderr output (config errors, etc.)
        if #stderr_data > 0 and #stdout_data == 0 then
          vim.notify("ESLint error: " .. table.concat(stderr_data, "\n"), vim.log.levels.ERROR)
          return
        end

        local json_str = table.concat(stdout_data, "\n")
        if json_str == "" then
          vim.notify("ESLint: No output received", vim.log.levels.WARN)
          return
        end

        local ok, results = pcall(vim.json.decode, json_str)
        if not ok then
          vim.notify(string.format("ESLint: Failed to parse output: %s", tostring(results)), vim.log.levels.ERROR)
          return
        end

        local qf_entries = {}
        for _, file_result in ipairs(results) do
          for _, msg in ipairs(file_result.messages or {}) do
            table.insert(qf_entries, {
              filename = file_result.filePath,
              lnum = msg.line or 1,
              col = msg.column or 1,
              text = string.format("[%s] %s", msg.ruleId or "eslint", msg.message),
              type = msg.severity == 2 and "E" or "W", -- 2 = error, 1 = warning
            })
          end
        end

        if #qf_entries > 0 then
          vim.fn.setqflist({}, "r", { title = "ESLint", items = qf_entries })
          vim.cmd("copen")
          vim.notify(string.format("ESLint found %d issues", #qf_entries), vim.log.levels.WARN)
        else
          vim.fn.setqflist({}, "r", { title = "ESLint", items = {} })
          vim.notify("ESLint: No issues found!", vim.log.levels.INFO)
        end
      end)
    end,
  })
end, { desc = "ESLint Project" })
