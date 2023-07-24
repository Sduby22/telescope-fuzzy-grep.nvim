return require("telescope").register_extension({
	setup = function(ext_config, config)
		-- access extension config and user config
	end,
	exports = {
		fuzzy_grep = require("telescope-fuzzy-grep").fuzzy_grep,
	},
})
