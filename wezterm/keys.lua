local wezterm = require("wezterm")
local resurrect = wezterm.plugin.require("https://github.com/MLFlexer/resurrect.wezterm")

local Keys = {}

local function is_vi_process(pane)
	return pane:get_foreground_process_name():find("n?vim") ~= nil
end

local direction_keys = {
	Left = "h",
	Down = "j",
	Up = "k",
	Right = "l",
	h = "Left",
	j = "Down",
	k = "Up",
	l = "Right",
}

local function split_nav(resize_or_move, key)
	return {
		key = key,
		mods = resize_or_move == "resize" and "SHIFT|ALT" or "ALT",
		action = wezterm.action_callback(function(win, pane)
			if is_vi_process(pane) then
				win:perform_action({
					SendKey = { key = key, mods = resize_or_move == "resize" and "SHIFT|ALT" or "ALT" },
				}, pane)
			else
				if resize_or_move == "resize" then
					win:perform_action({ AdjustPaneSize = { direction_keys[key], 3 } }, pane)
				else
					win:perform_action({ ActivatePaneDirection = direction_keys[key] }, pane)
				end
			end
		end),
	}
end

function Keys.setup(config)
	config.disable_default_key_bindings = true
	config.keys = {
		split_nav("move", "h"),
		split_nav("move", "j"),
		split_nav("move", "k"),
		split_nav("move", "l"),
		split_nav("resize", "h"),
		split_nav("resize", "j"),
		split_nav("resize", "k"),
		split_nav("resize", "l"),

		-- Resize/Pane swiching keybinds
		-- ALT + \ -> SplitHorizontal
		-- ALT + - -> SplitVertical
		-- ALT|SHIFT + h/j/k/l -> Resize Pane
		-- ALT + h/j/k/l -> Move between panes
		-- NOTE: You cannot move between wezterm and neovim panes unless within tmux. Wezterm and neovim pane swiching can also be done seamlessly with
		-- the help of a plugin, smart-splits.nvim.
		{
			mods = "ALT",
			key = [[\]],
			action = wezterm.action({
				SplitHorizontal = { domain = "CurrentPaneDomain" },
			}),
		},
		{
			mods = "ALT|SHIFT",
			key = [[|]],
			action = wezterm.action.SplitPane({
				top_level = true,
				direction = "Right",
				size = { Percent = 50 },
			}),
		},
		{
			mods = "ALT",
			key = [[-]],
			action = wezterm.action({
				SplitVertical = { domain = "CurrentPaneDomain" },
			}),
		},
		{
			mods = "ALT|SHIFT",
			key = [[_]],
			action = wezterm.action.SplitPane({
				top_level = true,
				direction = "Down",
				size = { Percent = 50 },
			}),
		},
		{
			key = "n",
			mods = "ALT",
			action = wezterm.action({ SpawnTab = "CurrentPaneDomain" }),
		},
		{
			key = "Q",
			mods = "ALT",
			action = wezterm.action({ CloseCurrentTab = { confirm = false } }),
		},
		-- {
		-- 	key = ",",
		-- 	mods = "ALT",
		-- 	action = wezterm.action.PromptInputLine({
		-- 		description = "Enter new name for tab",
		-- 		action = wezterm.action_callback(function(window, pane, line)
		-- 			if line then
		-- 				window:active_tab():set_title(line)
		-- 			end
		-- 		end),
		-- 	}),
		-- },
		-- Attach to muxer
		{
			key = "a",
			mods = "ALT",
			action = wezterm.action.AttachDomain("unix"),
		},

		-- Detach from muxer
		{
			key = "d",
			mods = "ALT|SHIFT",
			action = wezterm.action.DetachDomain({ DomainName = "unix" }),
		},
		-- Rename current session; analagous to command in tmux
		{
			key = "$",
			mods = "ALT|SHIFT",
			action = wezterm.action.PromptInputLine({
				description = "Enter new name for session",
				action = wezterm.action_callback(function(window, pane, line)
					if line then
						wezterm.mux.rename_workspace(window:mux_window():get_workspace(), line)
					end
				end),
			}),
		},
		-- Show list of workspaces
		{
			key = "x",
			mods = "ALT",
			action = wezterm.action.ShowLauncherArgs({ flags = "WORKSPACES" }),
		},

		-- resurrect.wezterm keybinds (github.com/MLFlexer/resurrect.wezterm)
		-- ---------------------------------------------------------------
		{
			key = "w",
			mods = "ALT",
			action = wezterm.action_callback(function(win, pane)
				resurrect.save_state(resurrect.workspace_state.get_workspace_state())
			end),
		},
		{
			key = "W",
			mods = "ALT",
			action = resurrect.window_state.save_window_action(),
		},
		{
			key = "T",
			mods = "ALT",
			action = resurrect.tab_state.save_tab_action(),
		},
		{
			key = "s",
			mods = "ALT",
			action = wezterm.action_callback(function(win, pane)
				resurrect.save_state(resurrect.workspace_state.get_workspace_state())
				resurrect.window_state.save_window_action()
			end),
		},
		-- Restore a session
		{
			key = "r",
			mods = "ALT",
			action = wezterm.action_callback(function(win, pane)
				resurrect.fuzzy_load(win, pane, function(id, label)
					local type = string.match(id, "^([^/]+)") -- match before '/'
					id = string.match(id, "([^/]+)$") -- match after '/'
					id = string.match(id, "(.+)%..+$") -- remove file extention
					local opts = {
						relative = true,
						restore_text = true,
						on_pane_restore = resurrect.tab_state.default_on_pane_restore,
					}
					if type == "workspace" then
						local state = resurrect.load_state(id, "workspace")
						resurrect.workspace_state.restore_workspace(state, opts)
					elseif type == "window" then
						local state = resurrect.load_state(id, "window")
						resurrect.window_state.restore_window(pane:window(), state, opts)
					elseif type == "tab" then
						local state = resurrect.load_state(id, "tab")
						resurrect.tab_state.restore_tab(pane:tab(), state, opts)
					end
				end)
			end),
		},
		{
			-- Delete a saved session using a fuzzy finder
			key = "d",
			mods = "ALT",
			action = wezterm.action_callback(function(win, pane)
				resurrect.fuzzy_load(win, pane, function(id)
					resurrect.delete_state(id)
				end, {
					title = "Delete State",
					description = "Select session to delete and press Enter = accept, Esc = cancel, / = filter",
					fuzzy_description = "Search session to delete: ",
					is_fuzzy = true,
				})
			end),
		},

		-- ----------------------------------------------------------------
		{ key = "q", mods = "ALT", action = wezterm.action.CloseCurrentPane({ confirm = false }) },
		{ key = "z", mods = "ALT", action = wezterm.action.TogglePaneZoomState },
		{ key = "F11", mods = "", action = wezterm.action.ToggleFullScreen },
		{ key = "[", mods = "ALT", action = wezterm.action({ ActivateTabRelative = -1 }) },
		{ key = "]", mods = "ALT", action = wezterm.action({ ActivateTabRelative = 1 }) },
		{ key = "{", mods = "SHIFT|ALT", action = wezterm.action.MoveTabRelative(-1) },
		{ key = "}", mods = "SHIFT|ALT", action = wezterm.action.MoveTabRelative(1) },
		{ key = "y", mods = "ALT", action = wezterm.action.ActivateCopyMode },
		{ key = "c", mods = "CTRL|SHIFT", action = wezterm.action({ CopyTo = "Clipboard" }) },
		{ key = "v", mods = "CTRL|SHIFT", action = wezterm.action({ PasteFrom = "Clipboard" }) },
		{ key = "=", mods = "CTRL", action = wezterm.action.IncreaseFontSize },
		{ key = "-", mods = "CTRL", action = wezterm.action.DecreaseFontSize },
		{ key = "1", mods = "ALT", action = wezterm.action({ ActivateTab = 0 }) },
		{ key = "2", mods = "ALT", action = wezterm.action({ ActivateTab = 1 }) },
		{ key = "3", mods = "ALT", action = wezterm.action({ ActivateTab = 2 }) },
		{ key = "4", mods = "ALT", action = wezterm.action({ ActivateTab = 3 }) },
		{ key = "5", mods = "ALT", action = wezterm.action({ ActivateTab = 4 }) },
		{ key = "6", mods = "ALT", action = wezterm.action({ ActivateTab = 5 }) },
		{ key = "7", mods = "ALT", action = wezterm.action({ ActivateTab = 6 }) },
		{ key = "8", mods = "ALT", action = wezterm.action({ ActivateTab = 7 }) },
		{ key = "9", mods = "ALT", action = wezterm.action({ ActivateTab = 8 }) },
	}
end

return Keys
