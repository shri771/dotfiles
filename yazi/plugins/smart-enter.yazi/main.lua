--- @sync entry
-- smart-enter: enter a directory, or open a file.
-- Replicates ranger's `l`/Enter behaviour and, crucially, makes Yazi ENTER
-- directories internally instead of running the opener (which on this system
-- would xdg-open the dir and launch the inode/directory default app).
return {
	entry = function()
		local h = cx.active.current.hovered
		if not h then
			return
		end
		-- Emit API history: ya.manager_emit -> ya.mgr_emit (deprecated v25.5.28)
		-- -> ya.emit (current). Prefer the newest available.
		local emit = ya.emit or ya.mgr_emit or ya.manager_emit
		emit(h.cha.is_dir and "enter" or "open", { hovered = true })
	end,
}
