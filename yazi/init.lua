-- Yazi init.lua
-- Keep the zoxide database updated as you navigate inside Yazi, so `z`/`cd`
-- jumps learn the dirs you visit here too (mirrors ranger's zoxide plugin).
require("zoxide"):setup({
	update_db = true,
})
