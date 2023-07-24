local pickers = require("telescope.pickers")
local actions = require "telescope.actions"
local make_entry = require "telescope.make_entry"
local finders = require("telescope.finders")
local conf = require("telescope.config").values

local M = {}
local flatten = vim.tbl_flatten

local function M.fuzzy_grep(opts)
	local opts = opts or {}
  local vimgrep_arguments = opts.vimgrep_arguments or conf.vimgrep_arguments

  local args = vimgrep_arguments

  local live_grepper = finders.new_job(function(prompt)
    if not prompt or prompt == "" then
      return nil
    end

    local search_list = {}

    return flatten { args, "--", prompt }
  end, make_entry.gen_from_vimgrep(opts), opts.max_results, opts.cwd)

	pickers
		.new(opts, {
			prompt_title = "Fuzzy Grep",
			finder = live_grepper,
			previewer = conf.grep_previewer(opts),
			sorter = sorters.highlighter_only(opts),
			attach_mappings = function(_, map)
				map("i", "<c-space>", actions.to_fuzzy_refine)
				return true
			end,
		})
		:find()
end

return M
