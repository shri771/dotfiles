-- zquery: ranger-style `cd` — prompt for a query, jump to zoxide's top match.
-- No fzf picker; you just type, like ranger's `console z%space`.
-- entry is ASYNC: ya.input() and Command:output() are async-only (per Yazi docs).
-- A "  z >  " input box appears at the TOP-CENTER; type a query and press <Enter>.
return {
	entry = function()
		local value, event = ya.input({
			title = "  z >  (type a path fragment, Enter to jump)",
			position = { "top-center", y = 3, w = 60 },
		})
		-- 1 = confirmed, 2 = canceled, 3 = changed
		if event ~= 1 then
			return
		end

		local output = Command("zoxide")
			:args({ "query", "--", value or "" })
			:stdout(Command.PIPED)
			:stderr(Command.PIPED)
			:output()
		if not output then
			ya.notify({ title = "zoxide", content = "failed to run zoxide", level = "error", timeout = 3 })
			return
		end

		local target = (output.stdout or ""):gsub("%s+$", "")
		if target == "" then
			ya.notify({ title = "zoxide", content = "no match for: " .. (value or ""), level = "warn", timeout = 3 })
			return
		end

		ya.emit("cd", { target })
	end,
}
