require("full-border"):setup()
-- git icons
th.git = th.git or {}
th.git.modified       = ui.Style():fg("#e0af68")
th.git.added          = ui.Style():fg("#9ece6a")
th.git.untracked      = ui.Style():fg("#9ece6a")
th.git.ignored        = ui.Style():fg("#565f89")
th.git.deleted        = ui.Style():fg("#f7768e")
th.git.updated        = ui.Style():fg("#7aa2f7")

th.git.modified_sign  = " "
th.git.added_sign     = " "
th.git.untracked_sign = " "
th.git.ignored_sign   = " "
th.git.deleted_sign   = " "
th.git.updated_sign   = " "

require("git"):setup {
	-- Order of status signs showing in the linemode
	order = 1500,
}
local pref_by_location = require("pref-by-location")
pref_by_location:setup({
  prefs = {
    { location = ".*/Downloads", sort = { "btime", reverse = true, dir_first = true }, linemode = "btime" },
  },
})

require("recycle-bin"):setup()
require("restore"):setup()
require("starship"):setup()
