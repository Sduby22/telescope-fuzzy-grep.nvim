local pickers = require("telescope.pickers")
local sorters = require("telescope.sorters")
local actions = require("telescope.actions")
local make_entry = require("telescope.make_entry")
local finders = require("telescope.finders")
local conf = require("telescope.config").values

local M = {}
local flatten = vim.tbl_flatten

-- split the pattern into words and generate a regex pattern
-- ^(?=.*asdsadsad)(?=.*d)(?=.*asdasd)(?=.*asd)(?=.*as)
local function gen_regex_pattern(pattern)
	local words = vim.split(pattern, " ")
	local words = vim.tbl_filter(function(word)
		return word ~= ""
	end, words)
	local regex_pattern = "^"
	for _, word in ipairs(words) do
		regex_pattern = regex_pattern .. "(?=.*" .. word .. ")"
	end
	return regex_pattern
end

function M.fuzzy_grep(opts)
	local opts = opts or {}
	opts.cwd = opts.cwd and vim.fn.expand(opts.cwd) or vim.loop.cwd()

	local vimgrep_arguments = opts.vimgrep_arguments or conf.vimgrep_arguments

	local additional_args = {}
	if opts.additional_args ~= nil then
		if type(opts.additional_args) == "function" then
			additional_args = opts.additional_args(opts)
		elseif type(opts.additional_args) == "table" then
			additional_args = opts.additional_args
		end
	end

	-- "rg",
	-- "--color=never",
	-- "--no-heading",
	-- "--with-filename",
	-- "--line-number",
	-- "--column",
	-- "--smart-case"
	-- rg --null --line-buffered --color=never --max-columns=1000 --path-separator / --smart-case --no-heading --with-filename --line-number --search-zip --hidden -g !.git -g !.svn -g !.hg -P -e ^(?=.*asdsadsad)(?=.*d)(?=.*asdasd)(?=.*asd)(?=.*as) .
	additional_args = additional_args
		or {
			"--path-separator",
			"/",
			"--hidden",
			"-g",
			"!{.git,.svn,.hg}",
			"--max-columns",
			"1000",
		}

	local args = flatten({ vimgrep_arguments, additional_args })

	local live_grepper = finders.new_job(function(prompt)
		if not prompt or prompt == "" then
			return nil
		end

		local search_list = {}

		return flatten({ args, "-P", "-e", gen_regex_pattern(prompt) })
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
