-- Ingame Options Main Menu

-- ffi setup
local ffi = require("ffi")
local C = ffi.C
ffi.cdef[[
	typedef struct {
		int x;
		int y;
	} ResolutionInfo;
	bool AllowPersonalizedData(void);
	bool CanOpenWebBrowser(void);
	const char* GetBuildVersionSuffix(void);
	uint32_t GetFXAAOption(void);
	bool GetLargeHUDMenusOption(void);
	bool GetMouseOverTextOption(void);
	ResolutionInfo GetRenderResolutionOption(void);
	bool GetSavesCompressedOption(void);
	bool GetScreenDisplayOption(void);
	const char* GetTrackerNameOption(void);
	const char* GetTrackerSDKOption(void);
	float GetUIScale();
	bool HasSavegame(void);
	bool IsAppStoreVersion(void);
	bool IsDemoVersion(void);
	bool IsVRVersion(void);
	bool IsSaveListLoadingComplete(void);
	void OpenWebBrowser(const char* url);
	void ReloadSaveList(void);
	void SetFXAAOption(uint32_t fxaa);
	void SetLargeHUDMenusOption(bool value);
	void SetMouseOverTextOption(bool value);
	void SetSavesCompressedOption(bool value);
	void SetUIScale(const float scale);
	void ToggleScreenDisplayOption(void);
]]

local menu = {
	name = "OptionsMenu",
}

local config = {
	offsetx = 55,
	headerOffsety = 105,
	tableOffsety = 105,
	sliderOffsety = 158,
	frameOffsetx = C.IsVRVersion() and 100 or 0,
	frameOffsety = 0,
	frameWidth = 960,
	frameHeight = 720,
	headerWidth = 870,
	tableHeight = 430,
	tableFirstColumnWidth = 20,
	tableSecondColumn1Width = 845,
	tableSecondColumn2Width = 465,
	tableSecondColumn3Width = 335,
	tableSecondColumn4Width = 560,
	tableThirdColumnWidth = 375,
	tableThirdColumn2Width = 250,
	tableThirdColumn3Width = 280,
	tableFourthColumnWidth = 250,
	headerEntryFont = "Zekton_unfiltered bold",
	headerEntrySize = 24,
	headerEntryOffsetx = 5,
	headerEntryOffsety = 0,
	headerEntryBGColor = C.IsVRVersion() and {r = 81, g = 106, b = 126, a = 30} or {r = 81, g = 106, b = 126, a = 60},
	headerEntryHeight = 48,
	tableEntryFont = "Zekton_unfiltered",
	tableEntrySize = 16,
	tableEntryOffsetx = 5,
	tableEntryOffsety = 0,
	maxTableRowWithoutScrollbar = 10,
	tableScrollbarWidth = -20,
	arrowicon = 0,
	arrowiconHeight = 31,
	arrowiconWidth = 20,
	greyTextColor = {r = 110, g = 110, b = 110, a = 100},
	white = {r = 255, g = 255, b = 255, a = 100},
	bgTexture = "optionsMenu_bg",
	fgTexture = C.IsVRVersion() and "" or "optionsMenu_fg",
	borderEnabled = (not C.IsVRVersion()) or (GetCurrentModuleName() ~= "startmenu")
}

local function init()
	__CORE_GAMEOPTIONS_RESTORE = __CORE_GAMEOPTIONS_RESTORE or nil
	__CORE_GAMEOPTIONS_RESTOREINFO = __CORE_GAMEOPTIONS_RESTOREINFO or {}
	Menus = Menus or { }
	table.insert(Menus, menu)
	if Helper then
		Helper.registerMenu(menu)
	end
	config.arrowicon = CreateIcon("table_arrow", 255, 255, 255, 100, 0, 0, config.arrowiconHeight, config.arrowiconWidth)
	menu.restored = HasToRestoreOptionsMenu()
	if __CORE_GAMEOPTIONS_RESTORE or (menu.restored ~= 0) or (GetCurrentModuleName() == "startmenu") then
		RestoreOptionsMenu()
	end

	RegisterEvent("openOptionsMenuParam", menu.openOptionsMenuParamCallback)
end

function menu.openOptionsMenuParamCallback(_, param)
	menu.openParam = param
end

function menu.cleanup()
	if GetCurrentModuleName() ~= "startmenu" then
		Unpause()
	end

	menu.title = ""
	menu.textdbtitle = ""
	menu.selectedrow = 1
	menu.preselectrow = nil
	menu.preselectcol = nil
	menu.pretoprow = nil
	menu.restored = 0
	menu.volumetype = ""
	menu.defaultmenutype = ""
	menu.data = nil
	menu.savegames = nil
	menu.controls = {}
	menu.controlsorder = {}
	menu.controltextpage = {}
	menu.controlcontext = nil
	menu.inputfunctions = {}
	menu.forbiddenKeys = {}
	menu.forbiddenMouseButtons = {}
	menu.cheatControls = {}
	menu.openParam = nil
	menu.gamemodules = {}

	menu.headertable = nil
	menu.infotable = nil

	if C.IsVRVersion() then
		Helper.defaultHeaderBackgroundColor = { r = 0, b = 0, g = 0, a = 60 }
		Helper.defaultSimpleBackgroundColor = { r = 55, b = 55, g = 55, a = 60 }
		Helper.defaultSelectBackgroundColor = { r = 83, g = 116, b = 139, a = 60 }
	end
end

-- Menu member functions

function menu.getVRVersionGraphicOptionOffset()
	return C.IsVRVersion() and 6 or 0
end

function menu.onShowMenu()
	if C.IsVRVersion() then
		Helper.defaultHeaderBackgroundColor = { r = 0, b = 0, g = 0, a = 10 }
		Helper.defaultSimpleBackgroundColor = { r = 110, b = 110, g = 110, a = 10 }
		Helper.defaultSelectBackgroundColor = { r = 143, g = 176, b = 199, a = 10 }
	end

	if GetCurrentModuleName() ~= "startmenu" then
		Pause()
	end
	if menu.restored == 1 then
		menu.time = GetCurRealTime() + 15.0
		openChangedParameterMenu()
	elseif menu.restored == 2 then
		menu.preselectrow = 2
		openGraphicsMenu()
		StopRestoringOptionsMenu()
	elseif menu.restored == 3 then
		menu.preselectrow = 3
		openGraphicsMenu()
		StopRestoringOptionsMenu()
	elseif menu.restored == 4 then
		menu.pretoprow = 4 + menu.getVRVersionGraphicOptionOffset()
		menu.preselectrow = 13 + menu.getVRVersionGraphicOptionOffset()
		openGraphicsMenu()
		StopRestoringOptionsMenu()
	elseif menu.restored == 5 then
		menu.time = GetCurRealTime() + 15.0
		openChangedParameterMenu()
	elseif menu.restored == 6 then
		local offset = menu.getVRVersionGraphicOptionOffset()
		menu.pretoprow = (offset > 0) and offset or nil
		menu.preselectrow = 6 + offset
		openGraphicsMenu()
		StopRestoringOptionsMenu()
	elseif menu.restored == 7 then
		menu.preselectrow = 5 + menu.getVRVersionGraphicOptionOffset()
		openGraphicsMenu()
		StopRestoringOptionsMenu()
	elseif menu.restored == 8 then
		menu.pretoprow = 12 + menu.getVRVersionGraphicOptionOffset()
		menu.preselectrow = 18 + menu.getVRVersionGraphicOptionOffset()
		openGraphicsMenu()
		StopRestoringOptionsMenu()
	elseif menu.restored == 9 then
		menu.preselectrow = 5 + menu.getVRVersionGraphicOptionOffset()
		openGraphicsMenu()
		StopRestoringOptionsMenu()
	elseif menu.restored == 10 then
		menu.preselectrow = 11
		openGameMenu()
		StopRestoringOptionsMenu()
	elseif menu.restored == 11 then
		menu.pretoprow = 10
		menu.preselectrow = 17
		openGameMenu()
		StopRestoringOptionsMenu()
	elseif __CORE_GAMEOPTIONS_RESTORE == 11 then
		menu.preselectrow = __CORE_GAMEOPTIONS_RESTOREINFO.oldrow
		openTutorialsMenu()
		__CORE_GAMEOPTIONS_RESTORE = nil
	else
		C.ReloadSaveList()
		if menu.openParam then
			if menu.openParam == "save" then
				openSaveMenu()
			elseif menu.openParam == "load" then
				openLoadMenu()
			elseif menu.openParam == "quit" then
				openExitMenu()
			end
		else
			if GetCurrentModuleName() ~= "startmenu" then
				menu.preselectrow = 10
			end
			openOptionsMenu()
		end
	end
end

menu.updateInterval = 0.1

function menu.onUpdate()
	if menu.lock then
		if getElapsedTime() > menu.lock then
			menu.lock = nil
		end
	end
	if menu.time ~= nil then
		if GetCurRealTime() < menu.time then
			Helper.updateCellText(menu.infotable, 1, 1, menu.textdbtitle .. " (" .. math.floor(menu.time - GetCurRealTime()) .. ReadText(1001, 100) .. ")")
		else 
			if menu.restored == 1 then
				local oldresolution = GetResolutionOption(true)
				SetResolutionOption(oldresolution.width, oldresolution.height, false)
				openResolutionMenu()
			elseif menu.restored == 5 then
				local setting
				if __CORE_GAMEOPTIONS_RESTOREINFO.oldfullscreen then
					setting = 1
				else
					if __CORE_GAMEOPTIONS_RESTOREINFO.oldborderless then
						setting = 3
					else
						setting = 2
					end
				end
				SetFullscreenOption(setting, false)
				menu.preselectrow = 4 + menu.getVRVersionGraphicOptionOffset()
				openGraphicsMenu()
			end
			menu.time = nil
		end
	end
	if menu.title == "Volume Menu" then
		value1, value2, value3, value4 = GetSliderValue(menu.infotable)
		if menu.data ~= value1 then
			menu.data = value1
			SetVolumeOption(menu.volumetype, math.floor(value1) / 100)
		end
	elseif menu.title == "Gamma Menu" then
		value1, value2, value3, value4 = GetSliderValue(menu.infotable)
		if menu.data ~= value1 then
			menu.data = value1
			SetGammaOption(math.floor(value1 + 50) / 100)
		end
	elseif menu.title == "Joystick Deadzone Menu" then
		value1, value2, value3, value4 = GetSliderValue(menu.infotable)
		if menu.data ~= value1 then
			menu.data = value1
			SetDeadzoneOption(value1)
		end
	elseif menu.title == "Rumble Menu" then
		value1, value2, value3, value4 = GetSliderValue(menu.infotable)
		if menu.data ~= value1 then
			menu.data = value1
			SetRumbleOption(value1 / 100)
		end
	elseif menu.title == "LOD Menu" then
		value1, value2, value3, value4 = GetSliderValue(menu.infotable)
		if menu.data ~= value1 then
			menu.data = value1
			SetLODOption(Helper.round(value1 / 100, 2))
		end
	elseif menu.title == "View Distance Menu" then
		value1, value2, value3, value4 = GetSliderValue(menu.infotable)
		if menu.data ~= value1 then
			menu.data = value1
			SetViewDistanceOption(Helper.round(value1 / 100, 2))
		end
	elseif menu.title == "Effect Distance Menu" then
		value1, value2, value3, value4 = GetSliderValue(menu.infotable)
		if menu.data ~= value1 then
			menu.data = value1
			SetEffectDistanceOption(Helper.round(value1 / 100, 2))
		end
	elseif menu.title == "Sensitivity Slider Menu" then
		value1, value2, value3, value4 = GetSliderValue(menu.infotable)
		if menu.data ~= value1 then
			menu.data = value1
			SetSensitivitySetting(menu.controlcontext[1], menu.controlcontext[2], Helper.round(value1 / 100, 2))
		end
	elseif menu.title == "Rename Input Profile Menu" then
		if menu.activateEditBox then
			Helper.activateEditBox(menu.infotable, menu.activateEditBox + 1, 2)
			menu.activateEditBox = nil
		end
	elseif menu.title == "New Game" then
		if menu.selectedmodule ~= Helper.currentTableRowData then
			menu.selectedmodule = Helper.currentTableRowData
			menu.preselectrow = Helper.currentTableRow
			menu.pretoprow = GetTopRow(menu.infotable)
			openNewMenu()
		end
	elseif menu.title == "Options Menu" then
		if menu.savegames == nil then
			if not menu.lock then
				menu.updateSavegameRelatedEntries()
			end
		end
	end
	if menu.remapControl then
		if menu.remapControl.shown then
			menu.remapControl.shown = false
			Helper.updateButtonText(menu.infotable, menu.remapControl.row, menu.remapControl.col, "")
		else
			menu.remapControl.shown = true
			Helper.updateButtonText(menu.infotable, menu.remapControl.row, menu.remapControl.col, "_")
		end
	end
end

function menu.onRowChanged(row, rowdata)
	if row then
		SetCellContent(menu.infotable, Helper.emptyCellDescriptor, menu.selectedrow, 1)
		local height = GetTableRowHeight(menu.infotable, row)
		if height ~= config.arrowiconHeight then
			SetCellContent(menu.infotable, CreateIcon("table_arrow", 255, 255, 255, 100, 0, 0, height, config.arrowiconWidth), row, 1)
		else
			SetCellContent(menu.infotable, config.arrowicon, row, 1)
		end
		menu.selectedrow = row
		if menu.title == "Save Game" or menu.title == "Load Game" then
			if rowdata then
				if rowdata.playername then
					Helper.updateCellText(menu.infotable, 2, 1, rowdata.playername .. " - " .. ConvertMoneyString(rowdata.money, false, true, 0, true, false) .. " " .. ReadText(1001, 101) .. " - " .. ConvertTimeString(rowdata.playtime, "%d" .. ReadText(1001, 104) .. " %H" .. ReadText(1001, 102) .. " %M" .. ReadText(1001, 103)) .. " - " .. ReadText(1001, 2655) .. ReadText(1001, 120) .. " " .. rowdata.version)
				else
					Helper.updateCellText(menu.infotable, 2, 1, "")
				end
			else
				Helper.updateCellText(menu.infotable, 2, 1, "")
			end
		end
		if menu.title == "Tutorials Menu" then
			if rowdata then
				SetCellContent(menu.overviewtable, Helper.createIcon(rowdata[2], 100, 100, 100, 100, 0, 0, 350 * 9 / 16, 350), 1, 1)
				Helper.updateCellText(menu.overviewtable, 2, 1, ReadText(1027, rowdata[1] + 2))
			end
		end
		if menu.title == "Extension Menu" then
			if rowdata == "defaults" then
				Helper.updateCellText(menu.overviewtable, 1, 1, "")
			elseif rowdata == "globalsync" then
				Helper.updateCellText(menu.overviewtable, 1, 1, "")
			elseif rowdata == "workshop" then
				Helper.updateCellText(menu.overviewtable, 1, 1, "")
			elseif rowdata then
				local info = ""
				if rowdata.warning then
					info = info .. rowdata.warningtext .. "\n \n"
				end
				if rowdata.error then
					info = info .. rowdata.errortext .. "\n \n"
				end
				info = info .. ReadText(1001, 2404) .. ReadText(1001, 120) .. " " .. AdjustMultilineString(rowdata.desc)
				info = info .. "\n" .. ReadText(1001, 2690) .. ReadText(1001, 120) .. " " .. rowdata.author
				info = info .. "\n" .. ReadText(1001, 2691) .. ReadText(1001, 120) .. " " .. rowdata.date
				if rowdata.isworkshop then
					info = info .. "\n" .. ReadText(1001, 4824) .. ReadText(1001, 120) .. " " .. (rowdata.sync and ReadText(1001, 2617) or ReadText(1001, 2618))
				end
				info = info .. "\n" .. ReadText(1001, 2943) .. ReadText(1001, 120) .. " " .. rowdata.location
				info = info .. "\n" .. ReadText(1001, 4823) .. ReadText(1001, 120) .. " " .. rowdata.id
				info = info .. "\n" .. ReadText(1001, 2655) .. ReadText(1001, 120) .. " " .. rowdata.version
				if #rowdata.dependencies > 0 then
					info = info .. "\n" .. ReadText(1001, 2692) .. ReadText(1001, 120)
					for i, dependency in ipairs(rowdata.dependencies) do
						info = info .. "\n- " .. dependency.name .. " (" .. dependency.id .. " - " .. dependency.version .. ")"
					end
				end
				Helper.updateCellText(menu.overviewtable, 1, 1, info)
			end
		end
		if menu.title == "Bonus Menu" then
			if rowdata then
				local info = rowdata.description
				if rowdata.installed then
					if rowdata.path ~= "" then
						info = info .. "\n \n" .. ReadText(1001, 4801) .. ReadText(1001, 120) .. "\n" .. rowdata.path
					end
				elseif rowdata.owned and rowdata.optional and not rowdata.changed then
					info = info .. "\n \n" .. ReadText(1001, 4807)
				end
				Helper.updateCellText(menu.overviewtable, 1, 1, info)
			end
		end
		if menu.title == "Privacy Menu" then
			local infotext = ""
			if rowdata then
				if rowdata == "crashreport" then
					infotext = ReadText(1001, 4874)
				elseif rowdata== "senduserid" then
					infotext = ReadText(1001, 4875)
				end
			end
			Helper.updateCellText(menu.overviewtable, 1, 1, infotext)
		end
	end
end

function menu.onRowChangedSound()
	if menu.title ~= "New Game" then
		PlaySound("ui_menu_start_change")
	end
end

function menu.removeInput()
	if menu.remapControl then
		if menu.remapControl.controltype == "functions" then
			for _, functionaction in ipairs(menu.controls[menu.remapControl.controltype][menu.remapControl.controlcode].actions) do
				local inputs = menu.controls.actions[functionaction]
				if type(inputs) == "table" then
					for i, input in ipairs(inputs) do
						if input[1] == menu.remapControl.oldinputtype and input[2] == menu.remapControl.oldinputcode then
							table.remove(inputs, i)
						end
					end
				end
			end
			for _, functionstate in ipairs(menu.controls[menu.remapControl.controltype][menu.remapControl.controlcode].states) do
				local inputs = menu.controls.states[functionstate]
				if type(inputs) == "table" then
					for i, input in ipairs(inputs) do
						if input[1] == menu.remapControl.oldinputtype and input[2] == menu.remapControl.oldinputcode then
							table.remove(inputs, i)
						end
					end
				end
			end
			for _, functionrange in ipairs(menu.controls[menu.remapControl.controltype][menu.remapControl.controlcode].ranges) do
				local inputs = menu.controls.ranges[functionrange]
				if type(inputs) == "table" then
					for i, input in ipairs(inputs) do
						if input[1] == menu.remapControl.oldinputtype and input[2] == menu.remapControl.oldinputcode then
							table.remove(inputs, i)
						end
					end
				end
			end
		else
			if type(menu.controls[menu.remapControl.controltype][menu.remapControl.controlcode]) == "table" then
				for i, input in ipairs(menu.controls[menu.remapControl.controltype][menu.remapControl.controlcode]) do
					if input[1] == menu.remapControl.oldinputtype and input[2] == menu.remapControl.oldinputcode then
						table.remove(menu.controls[menu.remapControl.controltype][menu.remapControl.controlcode], i)
					end
				end
			end
		end
		SaveInputSettings(menu.controls.actions, menu.controls.states, menu.controls.ranges)
	end
end

function menu.remapInput(newinputtype, newinputcode, newinputsgn)
	UnregisterEvent("keyboardInput", menu.keyboardInput)
	for i = 1, 8 do
		UnregisterEvent("joyaxesInputPosSgn" .. i, menu.joyaxesInputPosSgn[i])
		UnregisterEvent("joyaxesInputNegSgn" .. i, menu.joyaxesInputNegSgn[i])
		UnregisterEvent("joybuttonsInput" .. i, menu.joybuttonsInput[i])
	end
	UnregisterEvent("mousebuttonsInput", menu.mousebuttonsInput)

	-- Delete -> Remove mapping
	if (newinputtype == 1 and newinputcode == 211) and menu.remapControl.oldinputcode ~= -1 then
		menu.removeInput()

		menu.pretoprow = GetTopRow(menu.infotable)
		menu.preselectrow = menu.remapControl.row
		menu.preselectcol = menu.remapControl.col
		openControlsSetupMenu(menu.controlcontext)
		menu.remapControl = nil
		return
	end

	-- Forbidden input or same mapping -> Do nothing
	if (newinputtype == 1 and (menu.forbiddenKeys[newinputcode] or menu.remapControl.nokeyboard)) or (newinputtype == menu.remapControl.oldinputtype and newinputcode == menu.remapControl.oldinputcode) then
		menu.pretoprow = GetTopRow(menu.infotable)
		menu.preselectrow = menu.remapControl.row
		menu.preselectcol = menu.remapControl.col
		openControlsSetupMenu(menu.controlcontext)
		menu.remapControl = nil
		return
	end

	-- We want to map a range but didn't get an axis - OR - got forbidden mouseinput -> Keep listening
	if ((menu.remapControl.controltype == "ranges") and not ((newinputtype >= 2 and newinputtype <= 9) or (newinputtype == 18))) or (newinputtype == 19 and menu.forbiddenMouseButtons[newinputcode]) then
		RegisterEvent("keyboardInput", menu.keyboardInput)
		for i = 1, 8 do
			RegisterEvent("joyaxesInputPosSgn" .. i, menu.joyaxesInputPosSgn[i])
			RegisterEvent("joyaxesInputNegSgn" .. i, menu.joyaxesInputNegSgn[i])
			RegisterEvent("joybuttonsInput" .. i, menu.joybuttonsInput[i])
		end
		RegisterEvent("mousebuttonsInput", menu.mousebuttonsInput)

		ListenForInput()
		return
	end

	local function checkInput(inputtable, entry, input)
		if input[1] == newinputtype and input[2] == newinputcode and (input[3] == 0 or input[3] == newinputsgn) then
			table.remove(inputtable, entry)
		elseif input[1] == menu.remapControl.oldinputtype and input[2] == menu.remapControl.oldinputcode and (input[3] == 0 or input[3] == menu.remapControl.oldinputsgn) then
			input[1] = 0
			input[2] = 0
		end
	end

	local function resolveInput(input)
		if input[1] == 0 and input[2] == 0 then
			input[1] = newinputtype
			input[2] = newinputcode
			input[3] = (menu.remapControl.controltype == "ranges") and 0 or newinputsgn
		end
	end

	local function hasContextSimple(context)
		if type(menu.remapControl.controlcontext) == "table" then
			for _, remapcontext in ipairs(menu.remapControl.controlcontext) do
				if context == remapcontext then
					return true
				end
			end
		else
			return context == menu.remapControl.controlcontext
		end
	end

	local function hasContext(contexts)
		if type(contexts) == "table" then
			for _, context in ipairs(contexts) do
				if hasContextSimple(context) then
					return true
				end
			end
		else
			return hasContextSimple(contexts)
		end
	end

	-- check for resulting conflicts and change control map appropriatly
	for _, controlgroup in ipairs(menu.controlsorder) do
		if controlgroup.mapable or (newinputtype ~= 1) then
			for _, control in ipairs(controlgroup) do
				if control[1] == "functions" then
					if hasContext(menu.controls[control[1]][control[2]].contexts or 1) then
						for _, functionaction in ipairs(menu.controls[control[1]][control[2]].actions) do
							local inputs = menu.controls.actions[functionaction]
							if type(inputs) == "table" then
								for i, input in ipairs(inputs) do
									checkInput(inputs, i, input)
								end
							end
						end
						for _, functionstate in ipairs(menu.controls[control[1]][control[2]].states) do
							local inputs = menu.controls.states[functionstate]
							if type(inputs) == "table" then
								for i, input in ipairs(inputs) do
									checkInput(inputs, i, input)
								end
							end
						end
						for _, functionrange in ipairs(menu.controls[control[1]][control[2]].ranges) do
							local inputs = menu.controls.ranges[functionrange]
							if type(inputs) == "table" then
								for i, input in ipairs(inputs) do
									checkInput(inputs, i, input)
								end
							end
						end
					end
				else
					if hasContext(control[3] or 1) then
						if type(menu.controls[control[1]][control[2]]) == "table" then
							for i, input in ipairs(menu.controls[control[1]][control[2]]) do
								checkInput(menu.controls[control[1]][control[2]], i, input)
							end
						end
					end
				end
			end
		end
	end

	local function insertInput(controltype, controlcode)
		if not menu.controls[controltype][controlcode] then
			menu.controls[controltype][controlcode] = { { newinputtype, newinputcode, (menu.remapControl.controltype == "ranges") and 0 or newinputsgn } }
		else
			table.insert(menu.controls[controltype][controlcode], { newinputtype, newinputcode, (menu.remapControl.controltype == "ranges") and 0 or newinputsgn })
		end
	end
		
	if menu.remapControl.oldinputcode == -1 then
		if menu.remapControl.controltype == "functions" then
			for _, functionaction in ipairs(menu.controls[menu.remapControl.controltype][menu.remapControl.controlcode].actions) do
				insertInput("actions", functionaction)
			end
			for _, functionstate in ipairs(menu.controls[menu.remapControl.controltype][menu.remapControl.controlcode].states) do
				insertInput("states", functionstate)
			end
			for _, functionrange in ipairs(menu.controls[menu.remapControl.controltype][menu.remapControl.controlcode].ranges) do
				insertInput("ranges", functionrange)
			end
		else
			insertInput(menu.remapControl.controltype, menu.remapControl.controlcode)
		end
	else
		for _, controlgroup in ipairs(menu.controlsorder) do
			for _, control in ipairs(controlgroup) do
				if control[1] == "functions" then
					for _, functionaction in ipairs(menu.controls[control[1]][control[2]].actions) do
						local inputs = menu.controls.actions[functionaction]
						if inputs then
							for i, input in ipairs(inputs) do
								resolveInput(input)
							end
						end
					end
					for _, functionstate in ipairs(menu.controls[control[1]][control[2]].states) do
						local inputs = menu.controls.states[functionstate]
						if inputs then
							for i, input in ipairs(inputs) do
								resolveInput(input)
							end
						end
					end
					for _, functionrange in ipairs(menu.controls[control[1]][control[2]].ranges) do
						local inputs = menu.controls.ranges[functionrange]
						if inputs then
							for i, input in ipairs(inputs) do
								resolveInput(input)
							end
						end
					end
				else
					if type(menu.controls[control[1]][control[2]]) == "table" then
						for i, input in ipairs(menu.controls[control[1]][control[2]]) do
							resolveInput(input)
						end
					end
				end
			end
		end
	end

	-- save new controls
	SaveInputSettings(menu.controls.actions, menu.controls.states, menu.controls.ranges)

	-- reload controls menu
	menu.pretoprow = GetTopRow(menu.infotable)
	menu.preselectrow = menu.remapControl.row
	menu.preselectcol = menu.remapControl.col
	openControlsSetupMenu(menu.controlcontext)

	menu.remapControl = nil
end

function menu.keyboardInput(_, keycode)
	menu.remapInput(1, keycode, 0)
end

menu.joyaxesInputPosSgn = {}
menu.joyaxesInputNegSgn = {}
menu.joybuttonsInput = {}

for i = 1, 8 do
	table.insert(menu.joyaxesInputPosSgn, function (_, keycode) menu.remapInput(i + 1, keycode, 1) end)
	table.insert(menu.joyaxesInputNegSgn, function (_, keycode) menu.remapInput(i + 1, keycode, -1) end)
	table.insert(menu.joybuttonsInput, function (_, keycode) menu.remapInput(i + 9, keycode, 0) end)
end

function menu.mousebuttonsInput(_, keycode)
	menu.remapInput(19, keycode, 0)
end

function menu.buttonScript(row, rowdata)
	rowdata = rowdata or menu.rowDataMap[row]
	if menu.title == "Controls Setup Menu" then
		if rowdata and not menu.remapControl then
			-- set update to blink "_" and pass variables on to menu.remapInput
			menu.remapControl = { row = row, col = rowdata[6], controltype = rowdata[1], controlcode = rowdata[2], controlcontext = rowdata[8] or 1, oldinputtype = rowdata[3], oldinputcode = rowdata[4], oldinputsgn = rowdata[5], nokeyboard = rowdata[7] }

			-- call function listening to input and get result
			RegisterEvent("keyboardInput", menu.keyboardInput)
			for i = 1, 8 do
				RegisterEvent("joyaxesInputPosSgn" .. i, menu.joyaxesInputPosSgn[i])
				RegisterEvent("joyaxesInputNegSgn" .. i, menu.joyaxesInputNegSgn[i])
				RegisterEvent("joybuttonsInput" .. i, menu.joybuttonsInput[i])
			end
			RegisterEvent("mousebuttonsInput", menu.mousebuttonsInput)

			ListenForInput()
		end
	end
end

function menu.onSelectElement()
	local row = Helper.currentTableRow
	local rowdata = Helper.currentTableRowData
	if menu.title == "Options Menu" then
		if rowdata == "exit" then
			openExitMenu()
		elseif rowdata == "quit" then
			openExitMenu(true)
		elseif rowdata == "continue" then
			if GetCurrentModuleName() == "startmenu" then
				-- no need to set menu.savegames again - it's already populated, otherwise we could not have selected the row
				table.sort(menu.savegames, function (a, b) return a.rawtime > b.rawtime end)
				LoadGame(menu.savegames[1].filename)
				Helper.closeMenuAndReturn(menu)
				menu.cleanup()
			else
				menu.onCloseElement()
			end
		elseif rowdata == "new" then
			openNewMenu()
		elseif rowdata == "credits" then
			PlayCredits()
		elseif rowdata == "load" then
			openLoadMenu()
		elseif rowdata == "save" then
			openSaveMenu()
		elseif rowdata == "tutorials" then
			openTutorialsMenu()
		elseif rowdata == "extensions" then
			openExtensionsMenu()
		elseif rowdata == "bonus" then
			if IsSteamworksEnabled() then
				local bonuscontent = GetBonusContentData()
				local owned = false
				for _, bonus in ipairs(bonuscontent) do
					if bonus.owned then
						owned = true
						break
					end
				end
				if owned then
					openBonusMenu()
				else
					OpenSteamOverlayStorePage()
				end
			end
		elseif rowdata == "settings" then
			openSettingsMenu()
		end
	elseif menu.title == "Settings Menu" then
		if rowdata == "graphic" then
			openGraphicsMenu()
		elseif rowdata == "sound" then
			openSoundMenu()
		elseif rowdata == "game" then
			openGameMenu()
		elseif rowdata == "controls" then
			openControlsMenu()
		elseif rowdata == "privacy" then
			openPrivacyMenu()
		end
	elseif menu.title == "Exit Game?" then
		if rowdata == "no" then
			if menu.openParam then
				Helper.closeMenuAndReturn(menu)
				menu.cleanup()
			else
				if menu.quit then
					menu.preselectrow = 11 + (GetCurrentModuleName() == "startmenu" and 1 or 0)
				else
					menu.preselectrow = 10 + (GetCurrentModuleName() == "startmenu" and 1 or 0)
				end
				menu.quit = nil
				openOptionsMenu()
			end
		elseif rowdata == "yes" then
			if GetCurrentModuleName() == "startmenu" then
				QuitGame()
			else
				if menu.quit then
					QuitGame()
				else
					QuitModule()
				end
				menu.quit = nil
			end
			Helper.closeMenuAndReturn(menu)
			menu.cleanup()
		end
	elseif menu.title == "Override Savegame" then
		if rowdata == "no" then
			menu.preselectrow = 3
			openSaveMenu()
		elseif rowdata == "yes" then
			if type(menu.overridesavegame) == "table" then
				SaveGame(menu.overridesavegame.filename, menu.overridesavegame.name)
				menu.overridesavegame = nil
				Helper.closeMenuAndReturn(menu)
				menu.cleanup()
			end
		end
	elseif menu.title == "Keep settings?" then
		if rowdata == "no" then
			if menu.restored == 1 then
				local oldresolution = GetResolutionOption(true)
				SetResolutionOption(oldresolution.width, oldresolution.height, false)
				openResolutionMenu()
			elseif menu.restored == 5 then
				local setting
				if __CORE_GAMEOPTIONS_RESTOREINFO.oldfullscreen then
					setting = 1
				else
					if __CORE_GAMEOPTIONS_RESTOREINFO.oldborderless then
						setting = 3
					else
						setting = 2
					end
				end
				SetFullscreenOption(setting, false)
				menu.preselectrow = 4 + menu.getVRVersionGraphicOptionOffset()
				openGraphicsMenu()
			end
			menu.time = nil
		elseif rowdata == "yes" then
			StopRestoringOptionsMenu()
			if menu.restored == 1 then
				SaveResolutionOption()
				menu.preselectrow = C.IsVRVersion() and 9 or 2
				openGraphicsMenu()
			elseif menu.restored == 5 then
				SaveFullscreenOption()
				__CORE_GAMEOPTIONS_RESTOREINFO.oldfullscreen = nil
				__CORE_GAMEOPTIONS_RESTOREINFO.oldborderless = nil
				menu.preselectrow = 4 + menu.getVRVersionGraphicOptionOffset()
				openGraphicsMenu()
			end
			menu.time = nil
		end
	elseif menu.title == "Restore Defaults?" then
		if menu.defaultmenutype == "graphics" then
			local reloadui
			if rowdata == "yes" then
				reloadui = RestoreGraphicOptions()
			end
			if not reloadui then
				menu.pretoprow = 13 + menu.getVRVersionGraphicOptionOffset()
				menu.preselectrow = 23 + menu.getVRVersionGraphicOptionOffset()
				openGraphicsMenu()
			end
		elseif menu.defaultmenutype == "sound" then	
			if rowdata == "yes" then
				RestoreSoundOptions()
			end
			menu.preselectrow = 9
			openSoundMenu()
		elseif menu.defaultmenutype == "game" then
			if rowdata == "yes" then
				RestoreGameOptions()
			end
			menu.pretoprow = 12 + (C.IsVRVersion() and 1 or 0)
			menu.preselectrow = 21 + (C.IsVRVersion() and 1 or 0)
			openGameMenu()
		elseif menu.defaultmenutype == "controls" then
			if rowdata == "yes" then
				RestoreInputOptions()
			end
			menu.pretoprow = 9
			menu.preselectrow = 18
			openControlsMenu()
		elseif menu.defaultmenutype == "extension" then
			if rowdata == "yes" then
				ResetAllExtensionSettings()
			end
			menu.preselectrow = 1
			openExtensionsMenu()
		end
	elseif menu.title == "New Game" then
		if rowdata then
			for _, module in ipairs(menu.gamemodules) do
				if module.id == rowdata then
					if module.available then
						openDifficultyMenu(rowdata)
					end
				end
			end
		end
	elseif menu.title == "Difficulty Menu" then
		if rowdata then
			if menu.selectedmodule then
				NewGame(menu.selectedmodule, rowdata)
				Helper.closeMenuAndReturn(menu)
				menu.cleanup()
			else
				SetDifficultyOption(rowdata)
				openGameMenu()
			end
		end
	elseif menu.title == "Load Game" then
		if rowdata and ((not rowdata.error and not rowdata.invalidpatches and not rowdata.invalidversion and not rowdata.invalidgameid) or IsCheatVersion()) then
			LoadGame(rowdata.filename)
			Helper.closeMenuAndReturn(menu)
			menu.cleanup()
		end
	elseif menu.title == "Save Game" then
		if rowdata then
			if type(rowdata) == "table" then
				menu.overridesavegame = rowdata
				openOverrideSavegameMenu()
			elseif type(rowdata) == "string" then
				SaveGame("tnf_save_" .. rowdata, "#" .. rowdata)
				Helper.closeMenuAndReturn(menu)
				menu.cleanup()
			end
		end
	elseif menu.title == "Tutorials Menu" then
		if GetFullscreenOption() then
			__CORE_GAMEOPTIONS_RESTORE = 11
			__CORE_GAMEOPTIONS_RESTOREINFO.oldrow = row
		end
		C.OpenWebBrowser(ReadText(1027, rowdata[1] + 1))
	elseif menu.title == "Extension Menu" then
		if rowdata == "defaults" then
			menu.defaultmenutype = "extension"
			openRestoreDefaultsMenu()
		elseif rowdata == "workshop" then
			OpenWorkshop("", false)
		elseif rowdata == "globalsync" then
			local extensionSettings = GetAllExtensionSettings()
			local globalsync
			local globalsynccolor = { r = 255, g = 255, b = 255, a = 100 }
			if extensionSettings[0] ~= nil and extensionSettings[0].sync ~= nil then
				globalsync = extensionSettings[0].sync
				if globalsync == GetGlobalSyncSetting() then
					globalsynccolor = { r = 255, g = 0, b = 0, a = 100 }
				end
			else
				globalsync = GetGlobalSyncSetting()
				globalsynccolor = { r = 255, g = 0, b = 0, a = 100 }
			end
			SetExtensionSettings("", false, "sync", not globalsync)
			Helper.updateCellText(menu.infotable, row, 3, (not globalsync) and ReadText(1001, 2617) or ReadText(1001, 2618), globalsynccolor)
			if HaveExtensionSettingsChanged() then
				Helper.updateCellText(menu.titletable, 2, 1, ReadText(1001, 2689), { r = 255, g = 0, b = 0, a = 100 })
			else
				Helper.updateCellText(menu.titletable, 2, 1, GetExtensionUpdateWarningText("", false) or "", { r = 255, g = 255, b = 0, a = 100 })
			end
		elseif rowdata then
			openExtensionSettingsMenu(rowdata)
		end
	elseif menu.title == "Extension Settings Menu" then
		if rowdata == "enable" then
			local extensionSettings = GetAllExtensionSettings()
			local enabled
			if extensionSettings[menu.selectedextension.index] ~= nil and extensionSettings[menu.selectedextension.index].enabled ~= nil then
				enabled = not extensionSettings[menu.selectedextension.index].enabled
			elseif extensionSettings[0] ~= nil and extensionSettings[0].enabled ~= nil then
				enabled = not extensionSettings[0].enabled
			else
				enabled = not menu.selectedextension.enabled
			end
			SetExtensionSettings(menu.selectedextension.id, menu.selectedextension.personal, "enable", enabled)
			extensionSettings = GetAllExtensionSettings()
			local status
			local statuscolor = { r = 255, g = 255, b = 255, a = 100 }
			if extensionSettings[menu.selectedextension.index] ~= nil and extensionSettings[menu.selectedextension.index].enabled ~= nil then
				if extensionSettings[menu.selectedextension.index].enabled ~= menu.selectedextension.enabled then
					statuscolor = { r = 255, g = 0, b = 0, a = 100 }
				end
				status = extensionSettings[menu.selectedextension.index].enabled and ReadText(1001, 2617) or ReadText(1001, 2618)
			elseif extensionSettings[0] ~= nil and extensionSettings[0].enabled ~= nil then
				if extensionSettings[0].enabled ~= menu.selectedextension.enabled then
					statuscolor = { r = 255, g = 0, b = 0, a = 100 }
				end
				status = extensionSettings[0].enabled and ReadText(1001, 2617) or ReadText(1001, 2618)
			else
				status = menu.selectedextension.enabled and ReadText(1001, 2617) or ReadText(1001, 2618)
			end
			if not menu.selectedextension.error and not menu.selectedextension.warningtext then
				Helper.updateCellText(menu.infotable, 2, 1, HaveExtensionSettingsChanged() and ReadText(1001, 2689) or "", {r = 255, g = 0, b = 0, a = 100})
			end
			Helper.updateCellText(menu.infotable, row, 3, status, statuscolor)
		elseif rowdata == "sync" then
			local extensionSettings = GetAllExtensionSettings()
			local sync
			if extensionSettings[menu.selectedextension.index] ~= nil and extensionSettings[menu.selectedextension.index].sync ~= nil then
				sync = not extensionSettings[menu.selectedextension.index].sync
			elseif extensionSettings[0] ~= nil and extensionSettings[0].sync ~= nil then
				sync = not extensionSettings[0].sync
			else
				sync = not menu.selectedextension.sync
			end
			SetExtensionSettings(menu.selectedextension.id, menu.selectedextension.personal, "sync", sync)
			extensionSettings = GetAllExtensionSettings()
			local status
			local statuscolor = { r = 255, g = 255, b = 255, a = 100 }
			if extensionSettings[menu.selectedextension.index] ~= nil and extensionSettings[menu.selectedextension.index].sync ~= nil then
				if extensionSettings[menu.selectedextension.index].sync ~= menu.selectedextension.sync then
					statuscolor = { r = 255, g = 0, b = 0, a = 100 }
				end
				status = extensionSettings[menu.selectedextension.index].sync and ReadText(1001, 2617) or ReadText(1001, 2618)
			elseif extensionSettings[0] ~= nil and extensionSettings[0].sync ~= nil then
				if extensionSettings[0].sync ~= menu.selectedextension.sync then
					statuscolor = { r = 255, g = 0, b = 0, a = 100 }
				end
				status = extensionSettings[0].sync and ReadText(1001, 2617) or ReadText(1001, 2618)
			else
				status = menu.selectedextension.sync and ReadText(1001, 2617) or ReadText(1001, 2618)
			end
			Helper.updateCellText(menu.infotable, row, 3, status, statuscolor)
		elseif rowdata == "workshop" then
			OpenWorkshop(menu.selectedextension.id, menu.selectedextension.personal)
		end
	elseif menu.title == "Extension Warning Menu" then
		menu.preselectrow = 7
		openOptionsMenu()
	elseif menu.title == "Bonus Menu" then
		if rowdata.owned then
			if rowdata.optional and not rowdata.changed then
				if rowdata.installed then
					UninstallSteamDLC(rowdata.appid)
				else
					InstallSteamDLC(rowdata.appid)
				end
				menu.preselectrow = row
				openBonusMenu()
			end
		elseif rowdata.appid == 325580 or rowdata.appid == 415800 then			-- The Teladi Outpost / Home of Light
			OpenSteamOverlayStorePage(rowdata.appid)
		else
			OpenSteamOverlayStorePage()
		end
	elseif menu.title == "Graphics Menu" then
		if rowdata == "shadows" then
			openShadowsMenu()
		elseif rowdata == "softshadows" then
			SetSoftShadowsOption()
			Helper.updateCellText(menu.infotable, Helper.currentTableRow, 3, GetSoftShadowsOption() and ReadText(1001, 2648) or ReadText(1001, 2649))
		elseif rowdata == "gfxquality" then
			openGfxQualityMenu()
		elseif rowdata == "ssao" then
			openSSAOMenu()
		elseif rowdata == "glow" then
			openGlowMenu()
		elseif rowdata == "distortion" then
			SetDistortionOption()
			Helper.updateCellText(menu.infotable, Helper.currentTableRow, 3, GetDistortionOption() and ReadText(1001, 2648) or ReadText(1001, 2649))
		elseif rowdata == "lod" then
			openLODMenu()
		elseif rowdata == "viewdistance" then
			openViewDistanceMenu()
		elseif rowdata == "effectdistance" then
			openEffectDistanceMenu()
		elseif rowdata == "shaderquality" then
			openShaderQualityMenu()
		elseif rowdata == "resolution" then
			openResolutionMenu()
		elseif rowdata == "antialias" then
			openAntiAliasMenu()
		elseif rowdata == "fullscreen" then
			openDisplayModeMenu()
		elseif rowdata == "screendisplay" then
			C.ToggleScreenDisplayOption()
			menu.pretoprow = GetTopRow(menu.infotable)
			menu.preselectrow = Helper.currentTableRow
			openGraphicsMenu()
		elseif rowdata == "vsync" then
			SetVSyncOption()
		elseif rowdata == "radar" then
			openRadarMenu()
		elseif rowdata == "gamma" then
			openGammaMenu()
		elseif rowdata == "adapter" then
			openAdapterMenu()
		elseif rowdata == "capturehq" then
			SetCaptureHQOption()
			Helper.updateCellText(menu.infotable, Helper.currentTableRow, 3, GetCaptureHQOption() and ReadText(1001, 2648) or ReadText(1001, 2649))
		elseif rowdata == "default" then
			menu.defaultmenutype = "graphics"
			openRestoreDefaultsMenu()
		end
	elseif menu.title == "Change Display Mode" then
		if rowdata then
			local fullscreen, borderless = GetFullscreenOption()
			__CORE_GAMEOPTIONS_RESTOREINFO.oldfullscreen = fullscreen
			__CORE_GAMEOPTIONS_RESTOREINFO.oldborderless = borderless
			SetFullscreenOption(rowdata)
			if C.IsVRVersion() then
				menu.time = GetCurRealTime() + 15.0
				menu.restored = 5
				openChangedParameterMenu()
			end
		end
	elseif menu.title == "Change Resolution" then
		if rowdata then
			SetResolutionOption(rowdata[1], rowdata[2])
			if C.IsVRVersion() then
				menu.time = GetCurRealTime() + 15.0
				menu.restored = 1
				openChangedParameterMenu()
			end
		end
	elseif menu.title == "Change Antialiasing" then
		if rowdata then
			if rowdata[1] == "aa" then
				C.SetFXAAOption(0)
				SetAntiAliasModeOption(rowdata[2])
			elseif rowdata[1] == "fxaa" then
				C.SetFXAAOption(rowdata[2])
				SetAntiAliasModeOption(0)
			end
			menu.preselectrow = 3
			openGraphicsMenu()
		end
	elseif menu.title == "Change Shader Quality" then
		if rowdata then
			SetShaderQualityOption(rowdata)
		end
		menu.pretoprow = 9 + menu.getVRVersionGraphicOptionOffset()
		menu.preselectrow = 18 + menu.getVRVersionGraphicOptionOffset()
		openGraphicsMenu()
	elseif menu.title == "Change SSAO" then
		if rowdata then
			SetSSAOOption(rowdata)
		end
		menu.pretoprow = 3 + menu.getVRVersionGraphicOptionOffset()
		menu.preselectrow = 12 + menu.getVRVersionGraphicOptionOffset()
		openGraphicsMenu()
	elseif menu.title == "Change Radar" then
		if rowdata then
			SetRadarOption(rowdata)
		end
		menu.pretoprow = 11 + menu.getVRVersionGraphicOptionOffset()
		menu.preselectrow = 19 + menu.getVRVersionGraphicOptionOffset()
		openGraphicsMenu()
	elseif menu.title == "Change Shadows" then
		if rowdata then
			SetShadowOption(rowdata)
		end
		local offset = menu.getVRVersionGraphicOptionOffset()
		menu.pretoprow = (offset > 0) and (4 + offset) or nil
		menu.preselectrow = 10 + offset
		openGraphicsMenu()
	elseif menu.title == "Change Gfx Quality" then
		if rowdata then
			SetGfxQualityOption(rowdata)
		end
		local offset = menu.getVRVersionGraphicOptionOffset()
		menu.pretoprow = (offset > 0) and (3 + offset) or nil
		menu.preselectrow = 9 + offset
		openGraphicsMenu()
	elseif menu.title == "Change Glow" then
		if rowdata then
			SetGlowOption(rowdata)
		end
		menu.pretoprow = 4 + menu.getVRVersionGraphicOptionOffset()
		menu.preselectrow = 13 + menu.getVRVersionGraphicOptionOffset()
		openGraphicsMenu()
	elseif menu.title == "Change Adapter" then
		if rowdata then
			SetAdapterOption(rowdata)
		end
	elseif menu.title == "Gamma Menu" then
		local offset = menu.getVRVersionGraphicOptionOffset()
		menu.pretoprow = (offset > 0) and (1 + offset) or nil
		menu.preselectrow = 7 + offset
		openGraphicsMenu()
	elseif menu.title == "LOD Menu" then
		menu.pretoprow = 6 + menu.getVRVersionGraphicOptionOffset()
		menu.preselectrow = 15 + menu.getVRVersionGraphicOptionOffset()
		openGraphicsMenu()
	elseif menu.title == "View Distance Menu" then
		menu.pretoprow = 7 + menu.getVRVersionGraphicOptionOffset()
		menu.preselectrow = 16 + menu.getVRVersionGraphicOptionOffset()
		openGraphicsMenu()
	elseif menu.title == "Effect Distance Menu" then
		menu.pretoprow = 8 + menu.getVRVersionGraphicOptionOffset()
		menu.preselectrow = 17 + menu.getVRVersionGraphicOptionOffset()
		openGraphicsMenu()
	elseif menu.title == "Sound Menu" then
		if rowdata == "sound" then
			SetSoundOption()
			Helper.updateCellText(menu.infotable, Helper.currentTableRow, 3, GetSoundOption() and ReadText(1001, 2648) or ReadText(1001, 2649))
			Helper.updateCellText(menu.infotable, Helper.currentTableRow + 1, 3, math.floor(GetVolumeOption("master") * 100))
		elseif rowdata == "default" then
			menu.defaultmenutype = "sound"
			openRestoreDefaultsMenu()
		elseif rowdata then
			menu.volumetype = rowdata
			openVolumeMenu()
		end
	elseif menu.title == "Volume Menu" then
		if menu.volumetype == "master" then
			menu.preselectrow = 3
		elseif menu.volumetype == "music" then
			menu.preselectrow = 4
		elseif menu.volumetype == "voice" then
			menu.preselectrow = 5
		elseif menu.volumetype == "ambient" then
			menu.preselectrow = 6
		elseif menu.volumetype == "ui" then
			menu.preselectrow = 7
		elseif menu.volumetype == "effect" then
			menu.preselectrow = 8
		end
		openSoundMenu()
	elseif menu.title == "Game Menu" then
		if rowdata == "subtitles" then
			local subtitle = GetSubtitleOption()
			local option, text
			if subtitle == "auto" then
				option = "true"
				text = ReadText(1001, 2648) 
			elseif subtitle == "true" then
				option = "false"
				text = ReadText(1001, 2649)
			elseif subtitle == "false" then
				option = "auto"
				text = ReadText(1001, 4806)
			end
			SetSubtitleOption(option)
			Helper.updateCellText(menu.infotable, Helper.currentTableRow, 3, text)
		elseif rowdata == "difficulty" then
			openDifficultyMenu()
		elseif rowdata == "autosave" then
			SetAutosaveOption()
			Helper.updateCellText(menu.infotable, Helper.currentTableRow, 3, GetAutosaveOption() and ReadText(1001, 2648) or ReadText(1001, 2649))
		elseif rowdata == "autoroll" then
			SetAutorollOption()
			Helper.updateCellText(menu.infotable, Helper.currentTableRow, 3, GetAutorollOption() and ReadText(1001, 2648) or ReadText(1001, 2649))
		elseif rowdata == "boost" then
			SetBoostToggleOption()
			Helper.updateCellText(menu.infotable, Helper.currentTableRow, 3, GetBoostToggleOption() and ReadText(1001, 2648) or ReadText(1001, 2649))
		elseif rowdata == "mouselook" then
			SetMouseLookToggleOption()
			Helper.updateCellText(menu.infotable, Helper.currentTableRow, 3, GetMouseLookToggleOption() and ReadText(1001, 2648) or ReadText(1001, 2649))
		elseif rowdata == "rumble" then
			openRumbleMenu()
		elseif rowdata == "aimassist" then
			openAimAssistMenu()
		elseif rowdata == "collision" then
			SetCollisionAvoidanceAssistOption()
			Helper.updateCellText(menu.infotable, Helper.currentTableRow, 3, GetCollisionAvoidanceAssistOption() and ReadText(1001, 2648) or ReadText(1001, 2649))
		elseif rowdata == "steering" then
			SetSteeringNoteOption()
			Helper.updateCellText(menu.infotable, Helper.currentTableRow, 3, GetSteeringNoteOption() and ReadText(1001, 2648) or ReadText(1001, 2649))
		elseif rowdata == "fullscreendetailmonitor" then
			SetFullscreenDetailmonitorOption()
		elseif rowdata == "largeHUDMenus" then
			C.SetLargeHUDMenusOption(not C.GetLargeHUDMenusOption())
			Helper.updateCellText(menu.infotable, Helper.currentTableRow, 3, C.GetLargeHUDMenusOption() and ReadText(1001, 2648) or ReadText(1001, 2649))
		elseif rowdata == "stopshipinmenu" then
			SetStopShipInMenuOption()
			Helper.updateCellText(menu.infotable, Helper.currentTableRow, 3, GetStopShipInMenuOption() and ReadText(1001, 2649) or ReadText(1001, 2648))
		elseif rowdata == "legacymainmenu" then
			SetLegacyMainMenuOption()
			Helper.updateCellText(menu.infotable, Helper.currentTableRow, 3, GetLegacyMainMenuOption() and ReadText(1001, 4890) or ReadText(1001, 4889))
		elseif rowdata == "nonsquadshipsfortradeoffers" then
			SetNonSquadShipsForTradeOffersOption()
			Helper.updateCellText(menu.infotable, Helper.currentTableRow, 3, GetNonSquadShipsForTradeOffersOption() and ReadText(1001, 2648) or ReadText(1001, 2649))
		elseif rowdata == "mouseover" then
			C.SetMouseOverTextOption(not C.GetMouseOverTextOption())
			Helper.updateCellText(menu.infotable, Helper.currentTableRow, 3, C.GetMouseOverTextOption() and ReadText(1001, 2648) or ReadText(1001, 2649))
		elseif rowdata == "uiscale" then
			openUIScaleMenu()
		elseif rowdata == "savecompression" then
			C.SetSavesCompressedOption(not C.GetSavesCompressedOption())
			Helper.updateCellText(menu.infotable, Helper.currentTableRow, 3, C.GetSavesCompressedOption() and ReadText(1001, 2648) or ReadText(1001, 2649))
		elseif rowdata == "default" then
			menu.defaultmenutype = "game"
			openRestoreDefaultsMenu()
		end
	elseif menu.title == "Privacy Menu" then
		if rowdata == "crashreport" then
			SetCrashReportOption()
			Helper.updateCellText(menu.infotable, Helper.currentTableRow, 3, GetCrashReportOption() and ReadText(1001, 2617) or ReadText(1001, 2618))
		elseif rowdata == "senduserid" then
			SetPersonalizedCrashReportsOption()
			Helper.updateCellText(menu.infotable, Helper.currentTableRow, 3, GetPersonalizedCrashReportsOption() and ReadText(1001, 2617) or ReadText(1001, 2618))
		end
	elseif menu.title == "Rumble Menu" then
		menu.preselectrow = 8
		openGameMenu()
	elseif menu.title == "UIScale Menu" then
		value1, value2, value3, value4 = GetSliderValue(menu.infotable)
		if menu.data ~= value1 then
			menu.data = value1
			C.SetUIScale(value1)
		end
	elseif menu.title == "Change Aim Assist" then
		if rowdata then
			SetAimAssistOption(rowdata)
		end
		menu.preselectrow = 9
		openGameMenu()
	elseif menu.title == "Change Gamepad Mode" then
		if rowdata then
			SetGamepadModeOption(rowdata)
		end
		menu.pretoprow = 5
		menu.preselectrow = 12
		openControlsMenu()
	elseif menu.title == "Joystick Setup Menu" then
		openJoystickMenu(rowdata)
	elseif menu.title == "Controls Menu" then
		if rowdata then
			if rowdata == "loadinputprofile" then
				openLoadInputProfileMenu()
			elseif rowdata == "saveinputprofile" then
				openSaveInputProfileMenu()
			elseif rowdata == "renameinputprofile" then
				openRenameInputProfileMenu()
			elseif rowdata == "joystick_invert" or rowdata == "mouse_invert" then
				openInvertAxesMenu(rowdata)
			elseif rowdata == "joystick_sensitivity" or rowdata == "mouse_sensitivity" then
				openSensitivityMenu(rowdata)
			elseif rowdata == "mouse_capture" then
				SetConfineMouseOption()
				Helper.updateCellText(menu.infotable, Helper.currentTableRow, 3, GetConfineMouseOption() and ReadText(1001, 2648) or ReadText(1001, 2649))
			elseif rowdata == "joystick_deadzone" then
				openJoystickDeadzoneMenu()
			elseif rowdata == "joysticks" then
				openJoystickSetupMenu()
			elseif rowdata == "gamepadmode" then
				openGamepadModeMenu()
			else
				openControlsSetupMenu(rowdata)
			end
		end
	elseif menu.title == "Load Input Profile Menu" then
		if rowdata then
			openConfirmInputProfileMenu(rowdata, true)
		end
	elseif menu.title == "Save Input Profile Menu" then
		if rowdata then
			if rowdata.exists then
				openConfirmInputProfileMenu(rowdata, false)
			else
				SaveInputProfile(rowdata.filename, rowdata.id, rowdata.customname)
				menu.preselectrow = row
				openSaveInputProfileMenu()
			end
		end
	elseif menu.title == "Rename Input Profile Menu" then
		if rowdata then
			openRenameInputProfileMenu(rowdata)
		end
	elseif menu.title == "Confirm Input Profile Menu" then
		if rowdata == "yes" then
			if menu.selectedprofile[2] then
				LoadInputProfile(menu.selectedprofile[1].filename, menu.selectedprofile[1].personal)
			else
				SaveInputProfile(menu.selectedprofile[1].filename, menu.selectedprofile[1].id, menu.selectedprofile[1].customname)
			end
		end
		if menu.selectedprofile[2] then
			openLoadInputProfileMenu()
		else
			openSaveInputProfileMenu()
		end
		menu.selectedprofile = nil
	elseif menu.title == "Joystick Deadzone Menu" then
		menu.pretoprow = 4
		menu.preselectrow = 11
		openControlsMenu()
	elseif menu.title == "Invert Axes Menu" then
		if rowdata then
			SetInversionSetting(rowdata[1], rowdata[2])
			Helper.updateCellText(menu.infotable, Helper.currentTableRow, 3, GetInversionSetting(rowdata[1]) and ReadText(1001, 2676) or ReadText(1001, 2677))
		end
	elseif menu.title == "Sensitivity Menu" then
		if rowdata then
			openSensitivitySliderMenu(rowdata)
		end
	elseif menu.title == "Sensitivity Slider Menu" then
		menu.pretoprow = menu.controlcontext[5]
		menu.preselectrow = menu.controlcontext[4]
		openSensitivityMenu(menu.controlcontext[3])
	elseif menu.title == "Joystick Menu" then
		SetJoysticksOption(menu.controlcontext, rowdata)
		menu.preselectrow = menu.controlcontext + 1
		openJoystickSetupMenu()
	end
end

function menu.updateSavegameRelatedEntries()
	if not C.IsSaveListLoadingComplete() then
		return -- not yet ready
	end

	-- we are ready to retrieve the list - so let's populate it now
	menu.savegames = GetSaveList2()

	-- rebuild the menu (since the current rows are simple (aka: fontstring/unselectable) rows and we cannot just reset them to selectable ones
	-- TODO: #Florian - add support to change whether a row is selectable or not and then replace rebuilding the menu here with simply adjusting the two relevant rows
	menu.preselectrow = menu.selectedrow
	openOptionsMenu()
end

function openOptionsMenu()
	menu.lock = getElapsedTime()
	Helper.removeAllButtonScripts(menu)
	Helper.removeAllMenuScripts(menu)

	menu.title = "Options Menu"
	if GetCurrentModuleName() == "startmenu" then
		menu.textdbtitle = ReadText(1001, 2681)
	else
		menu.textdbtitle = ReadText(1001, 2600)
	end
	menu.selectedrow = 2

	local heightextension = 170

	local setup = Helper.createTableSetup(menu)
	setup:addSimpleRow({
		Helper.createFontString(menu.textdbtitle, "left", 255, 255, 255, 100, config.headerEntryFont, config.headerEntrySize, false, config.headerEntryOffsetx, config.headerEntryOffsety, config.headerEntryHeight, 0),
		Helper.createFontString(ReadText(1001, 2655) .. ReadText(1001, 120) .. " " .. ffi.string(C.GetBuildVersionSuffix()) .. "\n" .. GetVersionString(), "left", 255, 255, 255, 100, config.tableEntryFont, 11, true, config.headerEntryOffsetx, config.headerEntryOffsety, config.headerEntryHeight, 0)
	}, nil, {3, 1}, config.headerEntryBGColor)

	local currentmodule = GetCurrentModuleName()
	if currentmodule == "startmenu" then
		if C.IsSaveListLoadingComplete() then
			menu.savegames = menu.savegames or GetSaveList2()
			if next(menu.savegames) then
				table.sort(menu.savegames, function (a, b) return a.rawtime > b.rawtime end)
				if menu.savegames[1].invalidpatches or menu.savegames[1].invalidversion or menu.savegames[1].invalidgameid then
					setup:addSimpleRow({
						Helper.emptyCellDescriptor, 
						Helper.createFontString(ReadText(1001, 2614) .. "\n   (" .. ReadText(1001, 2694) .. ")", "left", config.greyTextColor.r, config.greyTextColor.g, config.greyTextColor.b, config.greyTextColor.a, config.tableEntryFont, config.tableEntrySize, true, config.tableEntryOffsetx, config.tableEntryOffsety, 0, config.tableSecondColumn1Width)
					}, "continue", {1, 3})
				else
					local isquicksave = (menu.savegames[1].filename == "quicksave")
					local isautosave = string.find(menu.savegames[1].filename, "autosave_", 1, true)
					local entry = ReadText(1001, 2614) .. ReadText(1001, 120) .. " " .. menu.savegames[1].location .. (isquicksave and " (" .. ReadText(1001, 400) .. ")" or (isautosave and " (" .. ReadText(1001, 406) .. ")" or "")) .. " - " .. menu.savegames[1].time .. "\n(" .. menu.savegames[1].playername .. " - " .. ConvertMoneyString(menu.savegames[1].money, false, true, 0, true, false) .. " " .. ReadText(1001, 101) .. " - " .. ConvertTimeString(menu.savegames[1].playtime, "%d" .. ReadText(1001, 104) .. " %H" .. ReadText(1001, 102) .. " %M" .. ReadText(1001, 103)) .. " - " .. ReadText(1001, 2655) .. ReadText(1001, 120) .. " " .. menu.savegames[1].version .. ")"
					setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(entry, "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, true, config.tableEntryOffsetx, config.tableEntryOffsety, 0, config.tableSecondColumn1Width) }, "continue", {1, 3})
				end
			else
				setup:addSimpleRow({
					Helper.emptyCellDescriptor, 
					Helper.createFontString(ReadText(1001, 2614), "left", config.greyTextColor.r, config.greyTextColor.g, config.greyTextColor.b, config.greyTextColor.a, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight)
				}, "continue", {1, 3})
			end
		else
			setup:addSimpleRow({
				Helper.emptyCellDescriptor, 
				Helper.createFontString(ReadText(1001, 7203), "left", config.greyTextColor.r, config.greyTextColor.g, config.greyTextColor.b, config.greyTextColor.a, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight)
			}, "continue", {1, 3})
		end
	else
		setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 2615), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) }, "continue", {1, 3})
	end
	setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 2603), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) }, "new", {1, 3})
	if C.IsSaveListLoadingComplete() then
		if C.HasSavegame() then
			setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 2604), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) }, "load", {1, 3})
		else
			setup:addSimpleRow({
				Helper.emptyCellDescriptor,
				Helper.createFontString(ReadText(1001, 2604), "left", config.greyTextColor.r, config.greyTextColor.g, config.greyTextColor.b, config.greyTextColor.a, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight)
			}, "load", {1, 3})
		end
	else
		setup:addSimpleRow({
			Helper.emptyCellDescriptor,
			Helper.createFontString(ReadText(1001, 7203), "left", config.greyTextColor.r, config.greyTextColor.g, config.greyTextColor.b, config.greyTextColor.a, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight)
		}, "load", {1, 3})
	end
	if currentmodule == "startmenu" or not IsSavingPossible() then
		setup:addSimpleRow({
			Helper.emptyCellDescriptor,
			Helper.createFontString(ReadText(1001, 2605), "left", config.greyTextColor.r, config.greyTextColor.g, config.greyTextColor.b, config.greyTextColor.a, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight)
		}, "save", {1, 3})
	else
		setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 2605), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) }, "save", {1, 3})
	end
	if C.CanOpenWebBrowser() then
		setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 4891), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) }, "tutorials", {1, 3})
	else
		setup:addSimpleRow({
			Helper.emptyCellDescriptor,
			Helper.createFontString(ReadText(1001, 4891), "left", config.greyTextColor.r, config.greyTextColor.g, config.greyTextColor.b, config.greyTextColor.a, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight, nil, ReadText(1026, 2621))
		}, "tutorials", {1, 3})
	end
	local extensions = GetExtensionList()
	local haserror = false
	local haswarning = HaveExtensionSettingsChanged() or GetExtensionUpdateWarningText("", false) ~= nil
	for _, extension in ipairs(extensions) do
		if extension.error and extension.enabled then
			haserror = true
			break
		end
		if extension.warning then
			haswarning = true
		end
	end
	if C.IsDemoVersion() then
		setup:addSimpleRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 2697), "left", config.greyTextColor.r, config.greyTextColor.g, config.greyTextColor.b, config.greyTextColor.a, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) }, "extensions", {1, 3})
	elseif haserror then
		setup:addSelectRow({ Helper.emptyCellDescriptor, CreateIcon("workshop_error", 255, 0, 0, 100, 0, 0, config.arrowiconHeight, config.arrowiconHeight), Helper.createFontString(ReadText(1001, 2697), "left", 255, 0, 0, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) }, "extensions", {1, 1, 2})
	elseif haswarning then
		setup:addSelectRow({ Helper.emptyCellDescriptor, CreateIcon("workshop_error", 255, 255, 0, 100, 0, 0, config.arrowiconHeight, config.arrowiconHeight), Helper.createFontString(ReadText(1001, 2697), "left", 255, 255, 0, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) }, "extensions", {1, 1, 2})
	else
		setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 2697), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) }, "extensions", {1, 3})
	end
	if C.IsDemoVersion() then
		setup:addSimpleRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 4800), "left", config.greyTextColor.r, config.greyTextColor.g, config.greyTextColor.b, config.greyTextColor.a, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) }, "bonus", {1, 3})
	elseif IsSteamworksEnabled() then
		setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 4800), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) }, "bonus", {1, 3})
	else
		setup:addSimpleRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 4800), "left", config.greyTextColor.r, config.greyTextColor.g, config.greyTextColor.b, config.greyTextColor.a, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) }, "bonus", {1, 3})
	end
	if CheckInputProfileRegression() then
		setup:addSelectRow({ Helper.emptyCellDescriptor, CreateIcon("workshop_error", 255, 255, 0, 100, 0, 0, config.arrowiconHeight, config.arrowiconHeight), Helper.createFontString(ReadText(1001, 2679), "left", 255, 255, 0, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) }, "settings", {1, 1, 2})
	else
		setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 2679), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) }, "settings", {1, 3})
	end
	if currentmodule == "startmenu" then
		setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 4811), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) }, "credits", {1, 3})
	end
	setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 2616), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) }, "exit", {1, 3})
	if currentmodule ~= "startmenu" then
		setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 4876), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) }, "quit", {1, 3})
	end
	
	local infodesc = setup:createCustomWidthTable({config.tableFirstColumnWidth, config.arrowiconHeight, config.tableSecondColumn1Width - 210 - config.arrowiconHeight, 200}, false, config.borderEnabled, 1, 1, config.offsetx, config.tableOffsety, config.tableHeight + heightextension, menu.pretoprow, menu.preselectrow)
	menu.pretoprow = nil
	menu.preselectrow = nil

	-- create tableview
	menu.infotable = Helper.displayTableView(menu, infodesc, true, config.bgTexture, config.fgTexture, config.frameWidth, config.frameHeight, config.frameOffsetx, config.frameOffsety, "none")

	-- clear descriptors again
	Helper.releaseDescriptors()
end

function openSettingsMenu()
	Helper.removeAllButtonScripts(menu)
	Helper.removeAllMenuScripts(menu)

	menu.title = "Settings Menu"
	menu.textdbtitle = ReadText(1001, 2679)
	menu.selectedrow = 2

	local setup = Helper.createTableSetup(menu)
	setup:addSimpleRow({
		Helper.createFontString(menu.textdbtitle, "left", 255, 255, 255, 100, config.headerEntryFont, config.headerEntrySize, false, config.headerEntryOffsetx, config.headerEntryOffsety, config.headerEntryHeight, 0)
	}, nil, {3}, config.headerEntryBGColor)

	setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 2606), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) }, "graphic", {1, 2})
	setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 2611), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) }, "sound", {1, 2})
	setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 2613), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) }, "game", {1, 2})
	
	if CheckInputProfileRegression() then
		setup:addSelectRow({ Helper.emptyCellDescriptor, CreateIcon("workshop_error", 255, 255, 0, 100, 0, 0, config.arrowiconHeight, config.arrowiconHeight), Helper.createFontString(ReadText(1001, 2656), "left", 255, 255, 0, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) }, "controls")
	else
		setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 2656), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) }, "controls", {1, 2})
	end
	setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 4870), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) }, "privacy", {1, 2})
	local infodesc = setup:createCustomWidthTable({config.tableFirstColumnWidth, config.arrowiconHeight, config.tableSecondColumn1Width - config.arrowiconHeight - 5}, false, config.borderEnabled, 1, 1, config.offsetx, config.tableOffsety, config.tableHeight, menu.pretoprow, menu.preselectrow)
	menu.pretoprow = nil
	menu.preselectrow = nil

	-- create tableview
	menu.infotable = Helper.displayTableView(menu, infodesc, true, config.bgTexture, config.fgTexture, config.frameWidth, config.frameHeight, config.frameOffsetx, config.frameOffsety, "none")

	-- clear descriptors again
	Helper.releaseDescriptors()
end

function openExitMenu(quit)
	Helper.removeAllButtonScripts(menu)
	Helper.removeAllMenuScripts(menu)

	menu.title = "Exit Game?"
	if GetCurrentModuleName() == "startmenu" then
		menu.textdbtitle = ReadText(1001, 2601)
	else
		if quit then
			menu.textdbtitle = ReadText(1001, 4876)
			menu.quit = quit
		else
			menu.textdbtitle = ReadText(1001, 2645)
		end
	end
	menu.selectedrow = 2

	local setup = Helper.createTableSetup(menu)
	setup:addSimpleRow({
		Helper.createFontString(menu.textdbtitle, "left", 255, 255, 255, 100, config.headerEntryFont, config.headerEntrySize, false, config.headerEntryOffsetx, config.headerEntryOffsety, config.headerEntryHeight, 0)
	}, nil, {2}, config.headerEntryBGColor)

	setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 2618), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) }, "no")
	setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 2617), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) }, "yes")
	local infodesc = setup:createCustomWidthTable({config.tableFirstColumnWidth, config.tableSecondColumn1Width}, false, config.borderEnabled, 1, 1, config.offsetx, config.tableOffsety, config.tableHeight, menu.pretoprow, menu.preselectrow)
	menu.pretoprow = nil
	menu.preselectrow = nil

	-- create tableview
	menu.infotable = Helper.displayTableView(menu, infodesc, true, config.bgTexture, config.fgTexture, config.frameWidth, config.frameHeight, config.frameOffsetx, config.frameOffsety, "none")

	-- clear descriptors again
	Helper.releaseDescriptors()
end

function openOverrideSavegameMenu()
	Helper.removeAllButtonScripts(menu)
	Helper.removeAllMenuScripts(menu)

	menu.title = "Override Savegame"
	menu.textdbtitle = ReadText(1001, 4813)
	menu.selectedrow = 2

	local setup = Helper.createTableSetup(menu)
	setup:addSimpleRow({
		Helper.createFontString(menu.textdbtitle, "left", 255, 255, 255, 100, config.headerEntryFont, config.headerEntrySize, false, config.headerEntryOffsetx, config.headerEntryOffsety, config.headerEntryHeight, 0)
	}, nil, {2}, config.headerEntryBGColor)

	setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 2618), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) }, "no")
	setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 2617), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) }, "yes")
	local infodesc = setup:createCustomWidthTable({config.tableFirstColumnWidth, config.tableSecondColumn1Width}, false, config.borderEnabled, 1, 1, config.offsetx, config.tableOffsety, config.tableHeight, menu.pretoprow, menu.preselectrow)
	menu.pretoprow = nil
	menu.preselectrow = nil

	-- create tableview
	menu.infotable = Helper.displayTableView(menu, infodesc, true, config.bgTexture, config.fgTexture, config.frameWidth, config.frameHeight, config.frameOffsetx, config.frameOffsety, "none")

	-- clear descriptors again
	Helper.releaseDescriptors()
end

function openChangedParameterMenu()
	Helper.removeAllButtonScripts(menu)
	Helper.removeAllMenuScripts(menu)

	menu.title = "Keep settings?"
	menu.textdbtitle = ReadText(1001, 2602)
	menu.selectedrow = 2

	local setup = Helper.createTableSetup(menu)
	setup:addSimpleRow({
		Helper.createFontString(menu.textdbtitle, "left", 255, 255, 255, 100, config.headerEntryFont, config.headerEntrySize, false, config.headerEntryOffsetx, config.headerEntryOffsety, config.headerEntryHeight, 0)
	}, nil, {2}, config.headerEntryBGColor)

	setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 2618), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) }, "no")
	setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 2617), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) }, "yes")
	local infodesc = setup:createCustomWidthTable({config.tableFirstColumnWidth, config.tableSecondColumn1Width}, false, config.borderEnabled, 1, 1, config.offsetx, config.tableOffsety, config.tableHeight, menu.pretoprow, menu.preselectrow)
	menu.pretoprow = nil
	menu.preselectrow = nil

	-- create tableview
	menu.infotable = Helper.displayTableView(menu, infodesc, true, config.bgTexture, config.fgTexture, config.frameWidth, config.frameHeight, config.frameOffsetx, config.frameOffsety, "none")

	-- clear descriptors again
	Helper.releaseDescriptors()
end

function openRestoreDefaultsMenu()
	Helper.removeAllButtonScripts(menu)
	Helper.removeAllMenuScripts(menu)

	menu.title = "Restore Defaults?"
	menu.textdbtitle = ReadText(1001, 2653)
	menu.selectedrow = 2

	local setup = Helper.createTableSetup(menu)
	setup:addSimpleRow({
		Helper.createFontString(menu.textdbtitle, "left", 255, 255, 255, 100, config.headerEntryFont, config.headerEntrySize, false, config.headerEntryOffsetx, config.headerEntryOffsety, config.headerEntryHeight, 0)
	}, nil, {2}, config.headerEntryBGColor)

	setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 2618), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) }, "no")
	setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 2617), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) }, "yes")
	local infodesc = setup:createCustomWidthTable({config.tableFirstColumnWidth, config.tableSecondColumn1Width}, false, config.borderEnabled, 1, 1, config.offsetx, config.tableOffsety, config.tableHeight, menu.pretoprow, menu.preselectrow)
	menu.pretoprow = nil
	menu.preselectrow = nil

	-- create tableview
	menu.infotable = Helper.displayTableView(menu, infodesc, true, config.bgTexture, config.fgTexture, config.frameWidth, config.frameHeight, config.frameOffsetx, config.frameOffsety, "none")

	-- clear descriptors again
	Helper.releaseDescriptors()
end

function openLoadInputProfileMenu()
	Helper.removeAllButtonScripts(menu)
	Helper.removeAllMenuScripts(menu)

	menu.title = "Load Input Profile Menu"
	menu.textdbtitle = ReadText(1001, 4859)
	menu.selectedrow = 2

	local setup = Helper.createTableSetup(menu)
	setup:addSimpleRow({
		Helper.createFontString(menu.textdbtitle, "left", 255, 255, 255, 100, config.headerEntryFont, config.headerEntrySize, false, config.headerEntryOffsetx, config.headerEntryOffsety, config.headerEntryHeight, 0)
	}, nil, {2}, config.headerEntryBGColor)

	local userprofiles = {}
	local inputprofiles = GetInputProfiles()

	for i, profile in ipairs(inputprofiles) do
		if not profile.personal then
			setup:addSelectRow({ 
				Helper.emptyCellDescriptor, 
				Helper.createFontString(profile.name, "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) 
			}, profile, {1, 1})
		else 
			userprofiles[profile.filename] = i
		end
	end

	setup:addHeaderRow({ Helper.emptyCellDescriptorSmall }, nil, {2})

	for i = 1, 5 do
		local filename = "inputmap_" .. i
		if userprofiles[filename] then
			local profile = inputprofiles[userprofiles[filename]]
			setup:addSelectRow({ 
				Helper.emptyCellDescriptor, 
				Helper.createFontString(profile.name, "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) 
			}, profile, {1, 1})
		else
			setup:addSimpleRow({ 
				Helper.emptyCellDescriptor, 
				Helper.createFontString(ReadText(1001, 4812), "left", config.greyTextColor.r, config.greyTextColor.g, config.greyTextColor.b, config.greyTextColor.a, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) 
			}, nil, {1, 1})
		end
	end
	local infodesc = setup:createCustomWidthTable({config.tableFirstColumnWidth, config.tableSecondColumn1Width}, false, config.borderEnabled, 1, 1, config.offsetx, config.tableOffsety, config.tableHeight, menu.pretoprow, menu.preselectrow)
	menu.pretoprow = nil
	menu.preselectrow = nil

	-- create tableview
	menu.infotable = Helper.displayTableView(menu, infodesc, true, config.bgTexture, config.fgTexture, config.frameWidth, config.frameHeight, config.frameOffsetx, config.frameOffsety, "none")

	-- clear descriptors again
	Helper.releaseDescriptors()
end

function openSaveInputProfileMenu()
	Helper.removeAllButtonScripts(menu)
	Helper.removeAllMenuScripts(menu)

	menu.title = "Save Input Profile Menu"
	menu.textdbtitle = ReadText(1001, 4858)
	menu.selectedrow = 2

	local setup = Helper.createTableSetup(menu)
	setup:addSimpleRow({
		Helper.createFontString(menu.textdbtitle, "left", 255, 255, 255, 100, config.headerEntryFont, config.headerEntrySize, false, config.headerEntryOffsetx, config.headerEntryOffsety, config.headerEntryHeight, 0)
	}, nil, {2}, config.headerEntryBGColor)

	local userprofiles = {}
	local inputprofiles = GetInputProfiles()

	for i, profile in ipairs(inputprofiles) do
		if profile.personal then
			userprofiles[profile.filename] = i
		end
	end
	for i = 1, 5 do
		local filename = "inputmap_" .. i
		if userprofiles[filename] then
			local profile = inputprofiles[userprofiles[filename]]
			profile.exists = true
			setup:addSelectRow({ 
				Helper.emptyCellDescriptor, 
				Helper.createFontString(profile.name, "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) 
			}, profile, {1, 1})
		else
			setup:addSelectRow({ 
				Helper.emptyCellDescriptor, 
				Helper.createFontString(ReadText(1001, 4812), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) 
			}, { filename = filename, id = 100 + i, name = ReadText(1023, 100 + i), customname = "" }, {1, 1})
		end
	end

	local infodesc = setup:createCustomWidthTable({config.tableFirstColumnWidth, config.tableSecondColumn1Width}, false, config.borderEnabled, 1, 1, config.offsetx, config.tableOffsety, config.tableHeight, menu.pretoprow, menu.preselectrow)
	menu.pretoprow = nil
	menu.preselectrow = nil

	-- create tableview
	menu.infotable = Helper.displayTableView(menu, infodesc, true, config.bgTexture, config.fgTexture, config.frameWidth, config.frameHeight, config.frameOffsetx, config.frameOffsety, "none")

	-- clear descriptors again
	Helper.releaseDescriptors()
end

function menu.editboxUpdateText(_, text, textchanged)
	if textchanged then
		SaveInputProfile(menu.selectedprofile[1].filename, menu.selectedprofile[1].id, text, true)
	end
	menu.preselectrow = menu.selectedprofile[2]
	menu.selectedprofile = nil
	openRenameInputProfileMenu()
end

function openRenameInputProfileMenu(editbox)
	Helper.removeAllButtonScripts(menu)
	Helper.removeAllMenuScripts(menu)

	menu.title = "Rename Input Profile Menu"
	menu.textdbtitle = ReadText(1001, 4862)
	menu.selectedrow = 2

	local setup = Helper.createTableSetup(menu)
	setup:addSimpleRow({
		Helper.createFontString(menu.textdbtitle, "left", 255, 255, 255, 100, config.headerEntryFont, config.headerEntrySize, false, config.headerEntryOffsetx, config.headerEntryOffsety, config.headerEntryHeight, 0)
	}, nil, {2}, config.headerEntryBGColor)

	local userprofiles = {}
	local inputprofiles = GetInputProfiles()

	for i, profile in ipairs(inputprofiles) do
		if profile.personal then
			userprofiles[profile.filename] = i
		end
	end
	for i = 1, 5 do
		local filename = "inputmap_" .. i
		if userprofiles[filename] then
			local profile = inputprofiles[userprofiles[filename]]
			if i == editbox then
				menu.selectedprofile = { profile, i + 1 }
				setup:addSelectRow({ 
					Helper.emptyCellDescriptor, 
					Helper.createEditBox(Helper.createButtonText(profile.name, "left", config.tableEntryFont, config.tableEntrySize, 255, 255, 255, 100), 0, 0, config.tableSecondColumn1Width, nil, nil, nil, true) 
				}, nil, {1, 1})
			elseif editbox then
				setup:addSimpleRow({ 
					Helper.emptyCellDescriptor, 
					Helper.createFontString(profile.name, "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) 
				}, nil, {1, 1}, Helper.defaultSelectBackgroundColor)
			else
				setup:addSelectRow({ 
					Helper.emptyCellDescriptor, 
					Helper.createFontString(profile.name, "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) 
				}, i, {1, 1})
			end
		else
			setup:addSimpleRow({ 
				Helper.emptyCellDescriptor, 
				Helper.createFontString(ReadText(1001, 4812), "left", config.greyTextColor.r, config.greyTextColor.g, config.greyTextColor.b, config.greyTextColor.a, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) 
			}, nil, {1, 1})
		end
	end

	local infodesc = setup:createCustomWidthTable({config.tableFirstColumnWidth, config.tableSecondColumn1Width}, false, config.borderEnabled, 1, 1, config.offsetx, config.tableOffsety, config.tableHeight, menu.pretoprow, menu.preselectrow)
	menu.pretoprow = nil
	menu.preselectrow = nil

	-- create tableview
	menu.infotable = Helper.displayTableView(menu, infodesc, true, config.bgTexture, config.fgTexture, config.frameWidth, config.frameHeight, config.frameOffsetx, config.frameOffsety, "none")

	if editbox then
		Helper.setEditBoxScript(menu, nil, menu.infotable, editbox + 1, 2, menu.editboxUpdateText)
		menu.activateEditBox = editbox
	end

	-- clear descriptors again
	Helper.releaseDescriptors()
end

function openConfirmInputProfileMenu(profile, load)
	Helper.removeAllButtonScripts(menu)
	Helper.removeAllMenuScripts(menu)

	menu.title = "Confirm Input Profile Menu"
	menu.textdbtitle = (load and ReadText(1001, 4859) or ReadText(1001, 4858)) .. " - \"" .. profile.name .. "\""
	menu.selectedrow = 2

	menu.selectedprofile = {profile, load}

	local setup = Helper.createTableSetup(menu)
	setup:addSimpleRow({
		Helper.createFontString(menu.textdbtitle, "left", 255, 255, 255, 100, config.headerEntryFont, config.headerEntrySize, false, config.headerEntryOffsetx, config.headerEntryOffsety, config.headerEntryHeight, 0)
	}, nil, {2}, config.headerEntryBGColor)

	setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 2618), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) }, "no")
	setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 2617), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) }, "yes")
	local infodesc = setup:createCustomWidthTable({config.tableFirstColumnWidth, config.tableSecondColumn1Width}, false, config.borderEnabled, 1, 1, config.offsetx, config.tableOffsety, config.tableHeight, menu.pretoprow, menu.preselectrow)
	menu.pretoprow = nil
	menu.preselectrow = nil

	-- create tableview
	menu.infotable = Helper.displayTableView(menu, infodesc, true, config.bgTexture, config.fgTexture, config.frameWidth, config.frameHeight, config.frameOffsetx, config.frameOffsety, "none")

	-- clear descriptors again
	Helper.releaseDescriptors()
end

function openNewMenu()
	Helper.removeAllButtonScripts(menu)
	Helper.removeAllMenuScripts(menu)

	menu.title = "New Game"
	menu.textdbtitle = ReadText(1001, 2603)
	menu.selectedrow = 1

	local offset = config.headerEntryHeight + 5
	local listcolumn2 = 420
	local listcolumn1 = config.headerWidth - listcolumn2 - config.tableFirstColumnWidth - 8
	local overviewoffset = config.headerWidth - listcolumn2
	local heightextension = 170

	-- titletable
	local setup = Helper.createTableSetup(menu)
	setup:addSimpleRow({
		Helper.createFontString(menu.textdbtitle, "left", 255, 255, 255, 100, config.headerEntryFont, config.headerEntrySize, false, config.headerEntryOffsetx, config.headerEntryOffsety, config.headerEntryHeight, 0)
	}, nil, nil, config.headerEntryBGColor)

	local titledesc = setup:createCustomWidthTable({ config.headerWidth }, false, config.borderEnabled, 0, 0, config.offsetx, config.tableOffsety)
	
	-- infotable
	setup = Helper.createTableSetup(menu)
	
	menu.gamemodules = GetRegisteredModules()
	local groups = {}
	for _, module in ipairs(menu.gamemodules) do
		if not menu.selectedmodule then
			menu.selectedmodule = module.id
		end
		local index
		for i, group in ipairs(groups) do
			if group.group == module.group then
				index = i
				break
			end
		end

		if index then
			table.insert(groups[index], module)
		else
			table.insert(groups, { group = module.group, [1] = module })
		end
	end
	
	local selectedmodule
	local nooflines = 1
	for i, group in ipairs(groups) do
		if i ~= 1 then
			setup:addHeaderRow({ Helper.emptyCellDescriptorSmall }, nil, {2})
			nooflines = nooflines + 1
		end
		for _, module in ipairs(group) do
			if module.available or (not (C.IsDemoVersion() and C.IsAppStoreVersion())) then
				if module.id == menu.selectedmodule then
					selectedmodule = module
					menu.preselectrow = nooflines
					if not menu.pretoprow then
						if nooflines > 17 then
							menu.pretoprow = nooflines - 16
						end
					end
				end
				local color = (not module.available) and config.greyTextColor or config.white
				setup:addSelectRow({
					Helper.emptyCellDescriptor, 
					Helper.createFontString(module.name, "left", color.r, color.g, color.b, color.a, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) 
				}, module.id, nil, (not module.available) and Helper.defaultSimpleBackgroundColor or nil)
				nooflines = nooflines + 1
			end
		end
	end

	local columnwidth = 0
	if #menu.gamemodules > config.maxTableRowWithoutScrollbar then
		columnwidth = config.tableScrollbarWidth
	end
	local infodesc = setup:createCustomWidthTable({config.tableFirstColumnWidth, listcolumn1 + columnwidth}, false, config.borderEnabled, 1, 0, config.offsetx, config.tableOffsety + offset, config.tableHeight - offset + heightextension, menu.pretoprow, menu.preselectrow)
	menu.pretoprow = nil
	menu.preselectrow = nil
	
	-- Overview table
	setup = Helper.createTableSetup(menu)
	
	local maxheight = config.tableHeight - offset + heightextension
	local currentheight = 0
	if menu.selectedmodule then
		local figureheight = listcolumn2 * 3 / 8
		if currentheight + figureheight <= maxheight then
			currentheight = currentheight + figureheight + 5
			setup:addSimpleRow({
				Helper.createIcon((selectedmodule.image == "") and "gamestart_default" or selectedmodule.image, nil, nil, nil, nil, 0, 0, figureheight, listcolumn2)
			}, nil, nil, config.headerEntryBGColor)
		end
		if selectedmodule.requirement ~= "" then
			local textheight = GetTextHeightExact(selectedmodule.requirement, config.tableEntryFont, 11, listcolumn2 - config.tableEntryOffsetx, true)
			if currentheight + textheight + 6 <= maxheight then
				currentheight = currentheight + textheight + 6 + 5
				setup:addSimpleRow({
					Helper.createFontString(selectedmodule.requirement, "left", 255, 0, 0, 100, config.tableEntryFont, 11, true, config.tableEntryOffsetx, 3, textheight + 6, listcolumn2)
				}, nil, nil, config.headerEntryBGColor)
			end
		end

		local textheight = GetTextHeightExact(selectedmodule.description, config.tableEntryFont, 11, listcolumn2 - config.tableEntryOffsetx, true)
		if currentheight + textheight + 6 <= maxheight then
			currentheight = currentheight + textheight + 6 + 5
			setup:addSimpleRow({
				Helper.createFontString(selectedmodule.description, "left", 255, 255, 255, 100, config.tableEntryFont, 11, true, config.tableEntryOffsetx, 3, textheight + 6, listcolumn2)
			}, nil, nil, config.headerEntryBGColor)
		end

		if IsCheatVersion() then
			local textheight = GetTextHeightExact(selectedmodule.id, config.tableEntryFont, 11, listcolumn2 - config.tableEntryOffsetx, true)
			if currentheight + textheight + 6 <= maxheight then
				currentheight = currentheight + textheight + 6 + 5
				setup:addSimpleRow({
					Helper.createFontString("Gamestart ID: " .. selectedmodule.id, "left", 255, 255, 255, 100, config.tableEntryFont, 11, true, config.tableEntryOffsetx, 3, textheight + 6, listcolumn2)
				}, nil, nil, config.headerEntryBGColor)
			end
		end

		for _, entry in ipairs(selectedmodule.info) do
			textheight = GetTextHeightExact(entry.info .. ReadText(1001, 120) .. " \027A" .. entry.description .. "\027X", config.tableEntryFont, 11, listcolumn2 - config.tableEntryOffsetx, true)
			if currentheight + textheight + 6 <= maxheight then
				currentheight = currentheight + textheight + 6 + 5
				setup:addSimpleRow({
					Helper.createFontString(entry.info .. ReadText(1001, 120) .. " \027A" .. entry.description .. "\027X", "left", 255, 255, 255, 100, config.tableEntryFont, 11, true, config.tableEntryOffsetx, 3, textheight + 6, listcolumn2)
				}, nil, nil, config.headerEntryBGColor)
			end
		end
	else
		setup:addSimpleRow({
			Helper.createIcon("gamestart_default", nil, nil, nil, nil, 0, 0, listcolumn2 * 3 / 8, listcolumn2)
		}, nil, nil, config.headerEntryBGColor)

		setup:addSimpleRow({
			Helper.createFontString("", "left", 255, 255, 255, 100, config.tableEntryFont, 11, true, config.tableEntryOffsetx, config.tableEntryOffsety, config.tableHeight - offset + heightextension - (listcolumn2 * 3 / 8) - 5)
		}, nil, nil, config.headerEntryBGColor)
	end

	local overviewdesc = setup:createCustomWidthTable({ listcolumn2 }, false, config.borderEnabled, 2, 0, config.offsetx + overviewoffset, config.tableOffsety + offset, config.tableHeight - offset + heightextension)

	-- create tableview
	menu.titletable, menu.infotable, menu.overviewtable = Helper.displayThreeTableView(menu, titledesc, infodesc, overviewdesc, true, config.bgTexture, config.fgTexture, config.frameWidth, config.frameHeight, config.frameOffsetx, config.frameOffsety, "none")

	PlaySound("ui_menu_start_change")

	-- clear descriptors again
	Helper.releaseDescriptors()
end

function menu.addSavegameRow(setup, savegame, entry)
	local linecount = 1
	local textcolor = config.white
	local bgcolor = nil
	
	if savegame.error then
		textcolor = config.greyTextColor
		bgcolor = Helper.defaultSimpleBackgroundColor
		entry = entry .. " " .. ReadText(1001, 4888)
	elseif savegame.invalidgameid then
		textcolor = config.greyTextColor
		bgcolor = Helper.defaultSimpleBackgroundColor
		entry = entry .. "\n" .. ReadText(1001, 4894)		-- Savegame is incompatible with game.
		linecount = linecount + 1
	elseif savegame.invalidversion then
		textcolor = config.greyTextColor
		bgcolor = Helper.defaultSimpleBackgroundColor
		entry = entry .. "\n" .. ReadText(1001, 4885) .. ReadText(1001, 120) .. " " .. savegame.version		-- Unknown game version required:
		linecount = linecount + 1
	elseif savegame.invalidpatches then
		textcolor = config.greyTextColor
		bgcolor = Helper.defaultSimpleBackgroundColor
		entry = entry .. "\n" .. ReadText(1001, 2685) .. ReadText(1001, 120)			-- Missing, old or disabled extensions:
		linecount = linecount + 1
		for i, patch in ipairs(savegame.invalidpatches) do
			if i > 4 then
				entry = entry .. "\n- ..."
				linecount = linecount + 1
				break
			end
			entry = entry .. "\n- " .. patch.name .. " (" .. patch.id .. " - " .. patch.requiredversion .. ")"
			linecount = linecount + 1
			if patch.state == 2 then
				entry = entry .. " " .. ReadText(1001, 2686)
			elseif patch.state == 3 then
				entry = entry .. " " .. ReadText(1001, 2687)
			elseif patch.state == 4 then
				entry = entry .. " " .. string.format(ReadText(1001, 2688), patch.installedversion)
			end
		end
	end

	setup:addSelectRow({ 
		Helper.emptyCellDescriptor, 
		Helper.createFontString(entry, "left", textcolor.r, textcolor.g, textcolor.b, textcolor.a, config.tableEntryFont, config.tableEntrySize, true, config.tableEntryOffsetx, config.tableEntryOffsety, 0, config.tableSecondColumn4Width),
		Helper.createFontString(savegame.error and "" or savegame.time, "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, true, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) 
	}, savegame, nil, bgcolor)

	return linecount
end

function openLoadMenu()
	Helper.removeAllButtonScripts(menu)
	Helper.removeAllMenuScripts(menu)
	menu.rowDataMap = {}

	menu.title = "Load Game"
	menu.textdbtitle = ReadText(1001, 2604)
	menu.selectedrow = 3

	local setup = Helper.createTableSetup(menu)
	setup:addSimpleRow({
		Helper.createFontString(menu.textdbtitle, "left", 255, 255, 255, 100, config.headerEntryFont, config.headerEntrySize, false, config.headerEntryOffsetx, config.headerEntryOffsety, config.headerEntryHeight, 0)
	}, nil, {3}, config.headerEntryBGColor)
	setup:addSimpleRow({ 
		Helper.createFontString("", "left", 255, 255, 255, 100, config.tableEntryFont, 14, false, config.headerEntryOffsetx, config.headerEntryOffsety, 25)
	}, nil, {3}, config.headerEntryBGColor)

	local heightextension = 170

	-- if we are inside the load menu, we certainly need the fully processed list --- we should have it actually already, except for cases where we by-pass the normal options menu and enter the load game menu
	-- prior to the save list having been processed --- in this case waiting until processing the list is done, is deemed acceptable however
	-- TODO #FlorianLow - could be improved further - aka: make it just populate the savegame list while the menu is visible

	while not C.IsSaveListLoadingComplete() do
		-- wait until loading the savegame list is complete
	end

	menu.savegames = menu.savegames or GetSaveList2()

	local usedsavegamenames = {}
	local autosaves = {}
	local quicksavegame
	for i, savegame in ipairs(menu.savegames) do
		if savegame.filename == "quicksave" then
			quicksavegame = i
		elseif string.find(savegame.filename, "autosave_", 1, true) then
			table.insert(autosaves, savegame)
		else
			usedsavegamenames[savegame.filename] = i
		end
	end

	local nooflines = 3
	local noofvisuallines = 2
	local latestrawtime = 0
	if quicksavegame then
		local savegame = menu.savegames[quicksavegame]
		local entry = ((savegame.description ~= "") and savegame.description or savegame.location) .. " (" .. ReadText(1001, 400) .. ")"
		noofvisuallines = noofvisuallines + menu.addSavegameRow(setup, savegame, entry)
		if savegame.rawtime > latestrawtime then
			latestrawtime = savegame.rawtime
			-- TODO Florian: reenable if it becomes possible to predict the "real" menu height
			-- menu.preselectrow = nooflines
		end
		nooflines = nooflines + 1
	end
	if #autosaves > 0 then
		table.sort(autosaves, function (a, b) return a.rawtime > b.rawtime end)
		for i, savegame in ipairs(autosaves) do
			if i <= 3 then
				local entry = string.format("%s (%s)", (savegame.description ~= "") and savegame.description or savegame.location, ReadText(1001, 406))
				noofvisuallines = noofvisuallines + menu.addSavegameRow(setup, savegame, entry)
				if savegame.rawtime > latestrawtime then
					latestrawtime = savegame.rawtime
					-- TODO Florian: reenable if it becomes possible to predict the "real" menu height
					-- menu.preselectrow = nooflines
				end
				nooflines = nooflines + 1
			end
		end
	end
	for i = 1, 50 do
		local savegamestring = string.format("%03d", i)
		if usedsavegamenames["tnf_save_" .. savegamestring] then
			local savegame = menu.savegames[usedsavegamenames["tnf_save_" .. savegamestring]]
			local entry = string.format("#%02d%s %s", i, ReadText(1001, 120), (savegame.description ~= "") and savegame.description or savegame.location)
			noofvisuallines = noofvisuallines + menu.addSavegameRow(setup, savegame, entry)
			if savegame.rawtime > latestrawtime then
				latestrawtime = savegame.rawtime
				-- TODO Florian: reenable if it becomes possible to predict the "real" menu height
				-- menu.preselectrow = nooflines
				if noofvisuallines > 11 then
					-- TODO Florian: reenable if it becomes possible to predict the "real" menu height
					-- menu.pretoprow = noofvisuallines - 8
				end
			end
			nooflines = nooflines + 1
		else
			setup:addSelectRow({ 
				Helper.emptyCellDescriptor, 
				Helper.createFontString(string.format("#%02d%s %s", i, ReadText(1001, 120), ReadText(1001, 4812)), "left", config.greyTextColor.r, config.greyTextColor.g, config.greyTextColor.b, config.greyTextColor.a, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight),
				Helper.createFontString("---", "left", config.greyTextColor.r, config.greyTextColor.g, config.greyTextColor.b, config.greyTextColor.a, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) 
			}, nil, nil, Helper.defaultSimpleBackgroundColor)
			nooflines = nooflines + 1
		end
	end

	local infodesc = setup:createCustomWidthTable({config.tableFirstColumnWidth, config.tableSecondColumn4Width, config.tableThirdColumn3Width}, false, config.borderEnabled, 1, 2, config.offsetx, config.tableOffsety, config.tableHeight + heightextension, menu.pretoprow, menu.preselectrow)
	menu.pretoprow = nil
	menu.preselectrow = nil

	-- create tableview
	menu.infotable = Helper.displayTableView(menu, infodesc, true, config.bgTexture, config.fgTexture, config.frameWidth, config.frameHeight, config.frameOffsetx, config.frameOffsety, "none")

	-- clear descriptors again
	Helper.releaseDescriptors()
end

function openSaveMenu()
	Helper.removeAllButtonScripts(menu)
	Helper.removeAllMenuScripts(menu)

	menu.title = "Save Game"
	menu.textdbtitle = ReadText(1001, 2605)
	menu.selectedrow = 3

	local setup = Helper.createTableSetup(menu)
	setup:addSimpleRow({
		Helper.createFontString(menu.textdbtitle, "left", 255, 255, 255, 100, config.headerEntryFont, config.headerEntrySize, false, config.headerEntryOffsetx, config.headerEntryOffsety, config.headerEntryHeight, 0)
	}, nil, {3}, config.headerEntryBGColor)
	setup:addSimpleRow({ 
		Helper.createFontString("", "left", 255, 255, 255, 100, config.tableEntryFont, 14, false, config.headerEntryOffsetx, config.headerEntryOffsety, 25)
	}, nil, {3}, config.headerEntryBGColor)

	-- if we are inside the save menu, we certainly need the fully processed list --- we should have it actually already, except for cases where we by-pass the normal options menu and enter the save game menu
	-- prior to the save list having been processed --- in this case waiting until processing the list is done, is deemed acceptable however
	-- TODO #FlorianLow - could be improved further - aka: make it just populate the savegame list while the menu is visible

	while not C.IsSaveListLoadingComplete() do
		-- wait until loading the savegame list is complete
	end

	menu.savegames = menu.savegames or GetSaveList2()

	local usedsavegamenames = {}
	local quicksavegame
	for i, savegame in ipairs(menu.savegames) do
		if savegame.filename == "quicksave" then
			quicksavegame = i
		else
			usedsavegamenames[savegame.filename] = i
		end
	end
	
	local nooflines = 3
	local latestrawtime = 0
	if quicksavegame then
		local savegame = menu.savegames[quicksavegame]
		setup:addSelectRow({ 
			Helper.emptyCellDescriptor, 
			Helper.createFontString(((savegame.description ~= "") and savegame.description or savegame.location) .. " (" .. ReadText(1001, 400) .. ")", "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight),
			Helper.createFontString(savegame.time, "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) 
		}, savegame)
		if savegame.rawtime > latestrawtime then
			latestrawtime = savegame.rawtime
			-- TODO Florian: reenable if it becomes possible to predict the "real" menu height
			-- menu.preselectrow = nooflines
		end
		nooflines = nooflines + 1
	end
	for i = 1, 50 do
		local savegamestring = string.format("%03d", i)
		if usedsavegamenames["tnf_save_" .. savegamestring] then
			local savegame = menu.savegames[usedsavegamenames["tnf_save_" .. savegamestring]]
			setup:addSelectRow({ 
				Helper.emptyCellDescriptor, 
				Helper.createFontString(string.format("#%02d%s %s", i, ReadText(1001, 120), savegame.error and ReadText(1001, 4888) or ((savegame.description ~= "") and savegame.description or savegame.location)), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight),
				Helper.createFontString(savegame.error and "" or savegame.time, "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) 
			}, savegame)
			if savegame.rawtime > latestrawtime then
				latestrawtime = savegame.rawtime
				-- TODO Florian: reenable if it becomes possible to predict the "real" menu height
				-- menu.preselectrow = nooflines
				if nooflines > 11 then
					-- TODO Florian: reenable if it becomes possible to predict the "real" menu height
					-- menu.pretoprow = nooflines - 8
				end
			end
			nooflines = nooflines + 1
		else
			setup:addSelectRow({ 
				Helper.emptyCellDescriptor, 
				Helper.createFontString(string.format("#%02d%s %s", i, ReadText(1001, 120), ReadText(1001, 4812)), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight),
				Helper.createFontString("---", "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) 
			}, savegamestring)
			nooflines = nooflines + 1
		end
	end

	local columnwidth = config.tableScrollbarWidth
	local infodesc = setup:createCustomWidthTable({config.tableFirstColumnWidth, config.tableSecondColumn2Width + columnwidth, config.tableThirdColumnWidth}, false, config.borderEnabled, 1, 2, config.offsetx, config.tableOffsety, config.tableHeight, menu.pretoprow, menu.preselectrow)
	menu.pretoprow = nil
	menu.preselectrow = nil

	-- create tableview
	menu.infotable = Helper.displayTableView(menu, infodesc, true, config.bgTexture, config.fgTexture, config.frameWidth, config.frameHeight, config.frameOffsetx, config.frameOffsety, "none")

	-- clear descriptors again
	Helper.releaseDescriptors()
end

function openTutorialsMenu()
	Helper.removeAllButtonScripts(menu)
	Helper.removeAllMenuScripts(menu)

	menu.title = "Tutorials Menu"
	menu.textdbtitle = ReadText(1001, 4891)
	menu.selectedrow = 1

	local offset = config.headerEntryHeight + 5 + config.arrowiconHeight + 5
	local listcolumn2 = 350
	local listcolumn1 = config.headerWidth - listcolumn2 - config.tableFirstColumnWidth - 10
	local overviewoffset = config.headerWidth - listcolumn2
	local heightextension = 170

	-- titletable
	local setup = Helper.createTableSetup(menu)
	setup:addSimpleRow({
		Helper.createFontString(menu.textdbtitle, "left", 255, 255, 255, 100, config.headerEntryFont, config.headerEntrySize, false, config.headerEntryOffsetx, config.headerEntryOffsety, config.headerEntryHeight, 0)
	}, nil, nil, config.headerEntryBGColor)
	setup:addSimpleRow({
		Helper.createFontString(ReadText(1001, 4892), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight, 0) -- TODO change by checking if video will go to steam overlay or browser
	}, nil, nil, config.headerEntryBGColor)

	local titledesc = setup:createCustomWidthTable({ config.headerWidth }, false, config.borderEnabled, 0, 0, config.offsetx, config.tableOffsety)
	
	-- infotable
	setup = Helper.createTableSetup(menu)

	local tutorials = {
		[1] = { id = 10, icon = "tut_overview" },
		[2] = { id = 20, icon = "tut_exploration" },
		[3] = { id = 30, icon = "tut_fleetcontrol" },
		[4] = { id = 40, icon = "tut_teachnpc" },
		[5] = { id = 50, icon = "tut_stealing" },
		[6] = { id = 60, icon = "tut_trading" },
		[7] = { id = 70, icon = "tut_building" },
		[8] = { id = 80, icon = "tut_boarding" },
		[9] = { id = 90, icon = "tut_diplomaid" },
		[10] = { id = 100, icon = "tut_offers" }
	}
	if IsSteamworksEnabled() then
		table.insert(tutorials, { id = 110, icon = "tut_upkeep" })
	end
	
	for _, tutorial in ipairs(tutorials) do
		setup:addSelectRow({
			Helper.emptyCellDescriptor, 
			Helper.createFontString(ReadText(1027, tutorial.id), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight)
		}, {tutorial.id, tutorial.icon})
	end

	local columnwidth = 0 --config.tableScrollbarWidth
	local infodesc = setup:createCustomWidthTable({config.tableFirstColumnWidth, listcolumn1 + columnwidth}, false, config.borderEnabled, 1, 0, config.offsetx, config.tableOffsety + offset, config.tableHeight - offset + heightextension, menu.pretoprow, menu.preselectrow)
	menu.pretoprow = nil
	menu.preselectrow = nil
	
	-- Overview table
	setup = Helper.createTableSetup(menu)
	
	local maxheight = config.tableHeight - offset + heightextension

	local figureheight = listcolumn2 * 9 / 16
	setup:addSimpleRow({
		Helper.createIcon("gamestart_default", 100, 100, 100, 100, 0, 0, figureheight, listcolumn2)
	}, nil, nil, config.headerEntryBGColor)

	setup:addSimpleRow({
		Helper.createFontString("Lorem ipsum", "left", 255, 255, 255, 100, config.tableEntryFont, 11, true, config.tableEntryOffsetx, 3, maxheight - figureheight- 5, listcolumn2)
	}, nil, nil, config.headerEntryBGColor)

	local overviewdesc = setup:createCustomWidthTable({ listcolumn2 }, false, config.borderEnabled, 2, 0, config.offsetx + overviewoffset, config.tableOffsety + offset, config.tableHeight - offset + heightextension)

	-- create tableview
	menu.titletable, menu.infotable, menu.overviewtable = Helper.displayThreeTableView(menu, titledesc, infodesc, overviewdesc, true, config.bgTexture, config.fgTexture, config.frameWidth, config.frameHeight, config.frameOffsetx, config.frameOffsety, "none")

	-- clear descriptors again
	Helper.releaseDescriptors()
end

function openExtensionsMenu()
	Helper.removeAllButtonScripts(menu)
	Helper.removeAllMenuScripts(menu)
	menu.rowDataMap = {}

	menu.title = "Extension Menu"
	menu.textdbtitle = ReadText(1001, 2697)
	menu.selectedrow = 1

	local extensions = GetExtensionList()
	local extensionSettings = GetAllExtensionSettings()

	local columnwidth = 0
	if #extensions > (config.maxTableRowWithoutScrollbar - 4) then
		columnwidth = config.tableScrollbarWidth
	end

	local offset = config.headerEntryHeight + 35
	local listcolumn2 = 85
	local listcolumn1 =(config.headerWidth - listcolumn2 - config.tableFirstColumnWidth - 15) / 2
	local overviewoffset = listcolumn1 + listcolumn2 + config.tableFirstColumnWidth + 15

	-- Title table
	local setup = Helper.createTableSetup(menu)
	setup:addSimpleRow({
		Helper.createFontString(menu.textdbtitle, "left", 255, 255, 255, 100, config.headerEntryFont, config.headerEntrySize, false, config.headerEntryOffsetx, config.headerEntryOffsety, config.headerEntryHeight, 0)
	}, nil, nil, config.headerEntryBGColor)
	if HaveExtensionSettingsChanged() then
		setup:addSimpleRow({ 
			Helper.createFontString(ReadText(1001, 2689), "left", 255, 0, 0, 100, config.tableEntryFont, 14, false, config.headerEntryOffsetx, config.headerEntryOffsety, 25)
		}, nil, nil, config.headerEntryBGColor)
	else
		setup:addSimpleRow({ 
			Helper.createFontString(GetExtensionUpdateWarningText("", false) or "", "left", 255, 255, 0, 100, config.tableEntryFont, 14, false, config.headerEntryOffsetx, config.headerEntryOffsety, 25)
		}, nil, nil, config.headerEntryBGColor)
	end

	local titledesc = setup:createCustomWidthTable({ config.headerWidth }, false, config.borderEnabled, 0, 0, config.offsetx, config.tableOffsety)

	-- Info table
	setup = Helper.createTableSetup(menu)

	local globalsync
	local globalsynccolor = { r = 255, g = 255, b = 255, a = 100 }
	if extensionSettings[0] ~= nil and extensionSettings[0].sync ~= nil then
		globalsync = extensionSettings[0].sync
		if globalsync ~= GetGlobalSyncSetting() then
			globalsynccolor = { r = 255, g = 0, b = 0, a = 100 }
		end
	else
		globalsync = GetGlobalSyncSetting()
	end
	if IsSteamworksEnabled() then
		setup:addSelectRow({ 
			Helper.emptyCellDescriptor, 
			Helper.createFontString(ReadText(1001, 4830), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight),
			Helper.createFontString(globalsync and ReadText(1001, 2617) or ReadText(1001, 2618), "left", globalsynccolor.r, globalsynccolor.g, globalsynccolor.b, globalsynccolor.a, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight)
		}, "globalsync")

		setup:addSelectRow({ 
			Helper.emptyCellDescriptor, 
			Helper.createFontString(ReadText(1001, 4831), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight)
		}, "workshop", {1, 2})
	end

	if #extensions > 0 then
		setup:addSelectRow({ 
			Helper.emptyCellDescriptor, 
			Helper.createFontString(ReadText(1001, 2647), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight)
		}, "defaults", {1, 2})
	end

	setup:addSimpleRow({ 
		CreateFontString("", "left", 255, 255, 255, 100, config.tableEntryFont, 6)
	}, nil, {3})

	if #extensions > 0 then
		for i, extension in ipairs(extensions) do
			if menu.selectedextension and (extension.id == menu.selectedextension.id) and (extension.personal == menu.selectedextension.personal) then
				menu.preselectrow = i + 2 + (IsSteamworksEnabled() and 2 or 0)
			end
			local status
			local statuscolor = { r = 255, g = 255, b = 255, a = 100 }
			if extensionSettings[extension.index] ~= nil and extensionSettings[extension.index].enabled ~= nil then
				if extensionSettings[extension.index].enabled ~= extension.enabled then
					statuscolor = { r = 255, g = 0, b = 0, a = 100 }
				end
				status = extensionSettings[extension.index].enabled and ReadText(1001, 2648) or ReadText(1001, 2649)
			elseif extensionSettings[0] ~= nil and extensionSettings[0].enabled ~= nil then
				if extensionSettings[0].enabled ~= extension.enabled then
					statuscolor = { r = 255, g = 0, b = 0, a = 100 }
				end
				status = extensionSettings[0].enabled and ReadText(1001, 2648) or ReadText(1001, 2649)
			else
				status = extension.enabled and ReadText(1001, 2648) or ReadText(1001, 2649)
			end
			local textcolor = { r = 255, g = 255, b = 255, a = 100 }
			if extension.error and extension.enabled then
				textcolor = { r = 255, g = 0, b = 0, a = 100 }
			elseif extension.warning then
				textcolor = { r = 255, g = 255, b = 0, a = 100 }
			end
			setup:addSelectRow({ 
				Helper.emptyCellDescriptor, 
				Helper.createFontString(extension.name, "left", textcolor.r, textcolor.g, textcolor.b, textcolor.a, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight), 
				Helper.createFontString(status, "left", statuscolor.r, statuscolor.g, statuscolor.b, statuscolor.a, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight)
			}, extension)
		end
	else
		setup:addSelectRow({ 
			Helper.emptyCellDescriptor, 
			Helper.createFontString(ReadText(1001, 2693), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight)
		}, nil, {1, 2})
	end

	local infodesc = setup:createCustomWidthTable({config.tableFirstColumnWidth, listcolumn1 + columnwidth, listcolumn2}, false, config.borderEnabled, 1, 0, config.offsetx, config.tableOffsety + offset, config.tableHeight - offset, menu.pretoprow, menu.preselectrow)
	menu.selectedextension = nil
	menu.pretoprow = nil
	menu.preselectrow = nil

	-- Overview table
	setup = Helper.createTableSetup(menu)
	
	setup:addSimpleRow({
		Helper.createFontString("", "left", 255, 255, 255, 100, config.tableEntryFont, 11, true, config.tableEntryOffsetx, config.tableEntryOffsety, config.tableHeight - offset)
	}, nil, nil, config.headerEntryBGColor)

	local overviewdesc = setup:createCustomWidthTable({ listcolumn1 }, false, config.borderEnabled, 2, 0, config.offsetx + overviewoffset, config.tableOffsety + offset, config.tableHeight - offset)

	-- create tableview
	menu.titletable, menu.infotable, menu.overviewtable = Helper.displayThreeTableView(menu, titledesc, infodesc, overviewdesc, true, config.bgTexture, config.fgTexture, config.frameWidth, config.frameHeight, config.frameOffsetx, config.frameOffsety, "none")

	-- clear descriptors again
	Helper.releaseDescriptors()
end

function openExtensionSettingsMenu(extension)
	Helper.removeAllButtonScripts(menu)
	Helper.removeAllMenuScripts(menu)
	menu.rowDataMap = {}

	menu.selectedextension = extension

	menu.title = "Extension Settings Menu"
	menu.textdbtitle = ReadText(1001, 2697) .. " - " .. extension.name
	menu.selectedrow = 3

	local offset = config.headerEntryHeight + 35

	local extensionSettings = GetAllExtensionSettings()

	-- Title table
	local setup = Helper.createTableSetup(menu)
	setup:addSimpleRow({
		Helper.createFontString(menu.textdbtitle, "left", 255, 255, 255, 100, config.headerEntryFont, config.headerEntrySize, false, config.headerEntryOffsetx, config.headerEntryOffsety, config.headerEntryHeight, 0)
	}, nil, {3}, config.headerEntryBGColor)
	if extension.error then
		setup:addSimpleRow({ 
			Helper.createFontString(extension.errortext, "left", 255, 0, 0, 100, config.tableEntryFont, 14, false, config.headerEntryOffsetx, config.headerEntryOffsety, 25)
		}, nil, {3}, config.headerEntryBGColor)
	elseif extension.warningtext then
		setup:addSimpleRow({ 
			Helper.createFontString(extension.warningtext, "left", 255, 255, 0, 100, config.tableEntryFont, 14, false, config.headerEntryOffsetx, config.headerEntryOffsety, 25)
		}, nil, {3}, config.headerEntryBGColor)
	else
		setup:addSimpleRow({ 
			Helper.createFontString(HaveExtensionSettingsChanged() and ReadText(1001, 2689) or "", "left", 255, 0, 0, 100, config.tableEntryFont, 14, false, config.headerEntryOffsetx, config.headerEntryOffsety, 25)
		}, nil, {3}, config.headerEntryBGColor)
	end

	local status
	local statuscolor = { r = 255, g = 255, b = 255, a = 100 }
	if extensionSettings[extension.index] ~= nil and extensionSettings[extension.index].enabled ~= nil then
		if extensionSettings[extension.index].enabled ~= extension.enabled then
			statuscolor = { r = 255, g = 0, b = 0, a = 100 }
		end
		status = extensionSettings[extension.index].enabled and ReadText(1001, 2617) or ReadText(1001, 2618)
	elseif extensionSettings[0] ~= nil and extensionSettings[0].enabled ~= nil then
		if extensionSettings[0].enabled ~= extension.enabled then
			statuscolor = { r = 255, g = 0, b = 0, a = 100 }
		end
		status = extensionSettings[0].enabled and ReadText(1001, 2617) or ReadText(1001, 2618)
	else
		status = extension.enabled and ReadText(1001, 2617) or ReadText(1001, 2618)
	end
	setup:addSelectRow({ 
		Helper.emptyCellDescriptor, 
		Helper.createFontString((extension.isworkshop and extension.sync) and ReadText(1001, 4832) or ReadText(1001, 4825), "left", 255, 255, 255, 100, config.tableEntryFont, 14, false, config.headerEntryOffsetx, config.headerEntryOffsety, 25), 
		Helper.createFontString(status, "left", statuscolor.r, statuscolor.g, statuscolor.b, statuscolor.a, config.tableEntryFont, 14, false, config.headerEntryOffsetx, config.headerEntryOffsety, 25)
	}, "enable", nil, config.headerEntryBGColor)
	if extension.isworkshop then
		statuscolor = { r = 255, g = 255, b = 255, a = 100 }
		if extensionSettings[extension.index] ~= nil and extensionSettings[extension.index].sync ~= nil then
			if extensionSettings[extension.index].sync ~= extension.sync then
				statuscolor = { r = 255, g = 0, b = 0, a = 100 }
			end
			status = extensionSettings[extension.index].sync and ReadText(1001, 2617) or ReadText(1001, 2618)
		elseif extensionSettings[0] ~= nil and extensionSettings[0].sync ~= nil then
			if extensionSettings[0].sync ~= extension.sync then
				statuscolor = { r = 255, g = 0, b = 0, a = 100 }
			end
			status = extensionSettings[0].sync and ReadText(1001, 2617) or ReadText(1001, 2618)
		else
			status = extension.sync and ReadText(1001, 2617) or ReadText(1001, 2618)
		end
		setup:addSelectRow({ 
			Helper.emptyCellDescriptor,
			Helper.createFontString(ReadText(1001, 4824), "left", 255, 255, 255, 100, config.tableEntryFont, 14, false, config.headerEntryOffsetx, config.headerEntryOffsety, 25), 
			Helper.createFontString(status, "left", statuscolor.r, statuscolor.g, statuscolor.b, statuscolor.a, config.tableEntryFont, 14, false, config.headerEntryOffsetx, config.headerEntryOffsety, 25)
		}, "sync", nil, config.headerEntryBGColor)
		setup:addSelectRow({ 
			Helper.emptyCellDescriptor,
			Helper.createFontString(ReadText(1001, 4828), "left", 255, 255, 255, 100, config.tableEntryFont, 14, false, config.headerEntryOffsetx, config.headerEntryOffsety, 25)
		}, "workshop", {1, 2}, config.headerEntryBGColor)
	end

	local infodesc = setup:createCustomWidthTable({config.tableFirstColumnWidth, config.tableSecondColumn2Width, config.tableThirdColumnWidth}, false, config.borderEnabled, 1, 2, config.offsetx, config.tableOffsety , config.tableHeight - offset, menu.pretoprow, menu.preselectrow)
	menu.pretoprow = nil
	menu.preselectrow = nil

	-- create tableview
	menu.infotable = Helper.displayTableView(menu, infodesc, true, config.bgTexture, config.fgTexture, config.frameWidth, config.frameHeight, config.frameOffsetx, config.frameOffsety, "none")

	-- clear descriptors again
	Helper.releaseDescriptors()
end

function openExtensionsWarningMenu()
	Helper.removeAllButtonScripts(menu)
	Helper.removeAllMenuScripts(menu)
	menu.rowDataMap = {}

	menu.title = "Extension Warning Menu"
	menu.textdbtitle = ReadText(1001, 2689)
	menu.selectedrow = 2

	menu.displayedextensionwarning = true

	-- Title table
	local setup = Helper.createTableSetup(menu)
	setup:addSimpleRow({
		Helper.createFontString(menu.textdbtitle, "left", 255, 255, 255, 100, config.headerEntryFont, config.headerEntrySize, false, config.headerEntryOffsetx, config.headerEntryOffsety, config.headerEntryHeight, 0)
	}, nil, {2}, config.headerEntryBGColor)

	setup:addSelectRow({ 
		Helper.emptyCellDescriptor, 
		Helper.createFontString(ReadText(1001, 14), "left", 255, 255, 255, 100, config.tableEntryFont, 14, false, config.headerEntryOffsetx, config.headerEntryOffsety, 25)
	}, "ok", nil, config.headerEntryBGColor)

	local infodesc = setup:createCustomWidthTable({config.tableFirstColumnWidth, config.tableSecondColumn1Width}, false, config.borderEnabled, 1, 1, config.offsetx, config.tableOffsety, config.tableHeight, menu.pretoprow, menu.preselectrow)
	menu.pretoprow = nil
	menu.preselectrow = nil

	-- create tableview
	menu.infotable = Helper.displayTableView(menu, infodesc, true, config.bgTexture, config.fgTexture, config.frameWidth, config.frameHeight, config.frameOffsetx, config.frameOffsety, "none")

	-- clear descriptors again
	Helper.releaseDescriptors()
end

function openDifficultyMenu(module)
	Helper.removeAllButtonScripts(menu)
	Helper.removeAllMenuScripts(menu)

	menu.title = "Difficulty Menu"
	menu.textdbtitle = ReadText(1001, 4844)
	menu.selectedrow = 3
	menu.selectedmodule = module

	local setup = Helper.createTableSetup(menu)
	setup:addSimpleRow({
		Helper.createFontString(menu.textdbtitle, "left", 255, 255, 255, 100, config.headerEntryFont, config.headerEntrySize, false, config.headerEntryOffsetx, config.headerEntryOffsety, config.headerEntryHeight, 0)
	}, nil, {2}, config.headerEntryBGColor)
	if not module then
		setup:addSimpleRow({
			Helper.createFontString(module and "" or ReadText(1001, 4845), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, true, config.tableEntryOffsetx, config.tableEntryOffsety, 2 * config.arrowiconHeight, 0)
		}, nil, {2}, config.headerEntryBGColor)
	end

	setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 4852), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) }, "easy")
	setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 4853), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) }, "medium")
	setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 4854), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) }, "hard")
	setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 4855), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) }, "extreme")
	local difficulty = GetDifficultyOption()
	if difficulty == "easy" then
		menu.preselectrow = 2 + (module and 0 or 1)
	elseif difficulty == "medium" then
		menu.preselectrow = 3 + (module and 0 or 1)
	elseif difficulty == "hard" then
		menu.preselectrow = 4 + (module and 0 or 1)
	elseif difficulty == "extreme" then
		menu.preselectrow = 5 + (module and 0 or 1)
	end
	local infodesc = setup:createCustomWidthTable({config.tableFirstColumnWidth, config.tableSecondColumn1Width}, false, config.borderEnabled, 1, 1, config.offsetx, config.tableOffsety, config.tableHeight, menu.pretoprow, menu.preselectrow)
	menu.pretoprow = nil
	menu.preselectrow = nil

	-- create tableview
	menu.infotable = Helper.displayTableView(menu, infodesc, true, config.bgTexture, config.fgTexture, config.frameWidth, config.frameHeight, config.frameOffsetx, config.frameOffsety, "none")

	-- clear descriptors again
	Helper.releaseDescriptors()
end

function openBonusMenu()
	Helper.removeAllButtonScripts(menu)
	Helper.removeAllMenuScripts(menu)
	menu.rowDataMap = {}

	menu.title = "Bonus Menu"
	menu.textdbtitle = ReadText(1001, 4800)
	menu.selectedrow = 2

	local bonuscontent = GetBonusContentData()

	local columnwidth = 0
	if #bonuscontent > (config.maxTableRowWithoutScrollbar - 2) then
		columnwidth = config.tableScrollbarWidth
	end

	local offset = config.headerEntryHeight + 5
	local overviewHeight = 100

	-- Title table
	local setup = Helper.createTableSetup(menu)
	setup:addSimpleRow({
		Helper.createFontString(menu.textdbtitle, "left", 255, 255, 255, 100, config.headerEntryFont, config.headerEntrySize, false, config.headerEntryOffsetx, config.headerEntryOffsety, config.headerEntryHeight, 0)
	}, nil, nil, config.headerEntryBGColor)

	local titledesc = setup:createCustomWidthTable({ config.headerWidth }, false, config.borderEnabled, 0, 0, config.offsetx, config.tableOffsety)

	-- Info table
	setup = Helper.createTableSetup(menu)

	if #bonuscontent > 0 then
		for i, bonus in ipairs(bonuscontent) do
			local status
			if bonus.owned then
				if bonus.installed then
					status = ReadText(1001, 4805)			-- Installed
				else
					status = ReadText(1001, 4808)			-- Not installed
				end
				if bonus.optional and not bonus.changed then
					if bonus.installed then
						status = status .. " - " .. ReadText(1001, 4804)		-- Uninstall
					else
						status = status .. " - " .. ReadText(1001, 4803)		-- Install
					end
				end
			else
				status = ReadText(1001, 4802)				-- View in Store
			end
			setup:addSelectRow({ 
				Helper.emptyCellDescriptor, 
				Helper.createFontString(bonus.name, "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, nil),
				Helper.createFontString(status, "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, nil)
			}, bonus)
		end
	else
		setup:addSelectRow({ 
			Helper.emptyCellDescriptor, 
			Helper.createFontString(ReadText(1001, 2693), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight)
		}, nil, {1, 1})
	end

	local infodesc = setup:createCustomWidthTable({config.tableFirstColumnWidth, config.tableSecondColumn2Width + columnwidth, config.tableThirdColumnWidth }, false, config.borderEnabled, 1, 0, config.offsetx, config.tableOffsety + offset + overviewHeight + 5, config.tableHeight - offset - overviewHeight - 5, menu.pretoprow, menu.preselectrow)
	menu.pretoprow = nil
	menu.preselectrow = nil

	-- Overview table
	setup = Helper.createTableSetup(menu)
	
	setup:addSimpleRow({
		Helper.createFontString("", "left", 255, 255, 255, 100, config.tableEntryFont, 11, true, config.tableEntryOffsetx, config.tableEntryOffsety, overviewHeight, config.tableFirstColumnWidth + config.tableSecondColumn1Width + 5)
	}, nil, nil, config.headerEntryBGColor)

	local overviewdesc = setup:createCustomWidthTable({ config.tableFirstColumnWidth + config.tableSecondColumn1Width + 5 }, false, config.borderEnabled, 2, 0, config.offsetx, config.tableOffsety + offset, overviewHeight)

	-- create tableview
	menu.titletable, menu.infotable, menu.overviewtable = Helper.displayThreeTableView(menu, titledesc, infodesc, overviewdesc, true, config.bgTexture, config.fgTexture, config.frameWidth, config.frameHeight, config.frameOffsetx, config.frameOffsety, "none")

	-- clear descriptors again
	Helper.releaseDescriptors()
end

function openGraphicsMenu()
	Helper.removeAllButtonScripts(menu)
	Helper.removeAllMenuScripts(menu)
	menu.rowDataMap = {}

	menu.title = "Graphics Menu"
	menu.textdbtitle = ReadText(1001, 2606)
	menu.selectedrow = 2

	local setup = Helper.createTableSetup(menu)
	setup:addSimpleRow({
		Helper.createFontString(menu.textdbtitle, "left", 255, 255, 255, 100, config.headerEntryFont, config.headerEntrySize, false, config.headerEntryOffsetx, config.headerEntryOffsety, config.headerEntryHeight, 0)
	}, nil, {3}, config.headerEntryBGColor)

	if C.IsVRVersion() then
		-- HMD Resolution
		local renderresolution = C.GetRenderResolutionOption()
		setup:addSimpleRow({
			Helper.emptyCellDescriptor,
			Helper.createFontString(ReadText(1001, 2619), "left", config.greyTextColor.r, config.greyTextColor.g, config.greyTextColor.b, config.greyTextColor.a, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight),
			Helper.createFontString(renderresolution.x .. ReadText(1001, 42) .. renderresolution.y, "left", config.greyTextColor.r, config.greyTextColor.g, config.greyTextColor.b, config.greyTextColor.a, config.tableEntryFont)
		}, "hmd_resolution")
		-- Anti Aliasing
		local aastring = ""
		local fxaa = C.GetFXAAOption()
		if fxaa > 0 then
			if fxaa == 1 then
				aastring = ReadText(1001, 4881) .. " - " .. ReadText(1001, 2650)
			elseif fxaa == 2 then
				aastring = ReadText(1001, 4881) .. " - " .. ReadText(1001, 2652)
			else
				aastring = ReadText(1001, 4881) .. " - " .. ReadText(1001, 2651)
			end
		else
			aastring = GetAntiAliasModeOption() .. ReadText(1001, 42)
		end
		setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 2620), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight), Helper.createFontString(aastring, "left", 255, 255, 255, 100, config.tableEntryFont) }, "antialias")
		-- HMD Fullscreen
		setup:addSimpleRow({
			Helper.emptyCellDescriptor,
			Helper.createFontString(ReadText(1001, 4817), "left", config.greyTextColor.r, config.greyTextColor.g, config.greyTextColor.b, config.greyTextColor.a, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight),
			Helper.createFontString(ReadText(1001, 2622), "left", config.greyTextColor.r, config.greyTextColor.g, config.greyTextColor.b, config.greyTextColor.a, config.tableEntryFont)
		}, "hmd_fullscreen")
		-- HMD SDK
		setup:addSimpleRow({
			Helper.emptyCellDescriptor,
			Helper.createFontString(ReadText(1001, 7214), "left", config.greyTextColor.r, config.greyTextColor.g, config.greyTextColor.b, config.greyTextColor.a, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight),
			Helper.createFontString(ffi.string(C.GetTrackerSDKOption()), "left", config.greyTextColor.r, config.greyTextColor.g, config.greyTextColor.b, config.greyTextColor.a, config.tableEntryFont)
		}, "hmd_sdk")
		-- HMD Adapter
		setup:addSimpleRow({
			Helper.emptyCellDescriptor,
			Helper.createFontString(ReadText(1001, 2623), "left", config.greyTextColor.r, config.greyTextColor.g, config.greyTextColor.b, config.greyTextColor.a, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight),
			Helper.createFontString(ffi.string(C.GetTrackerNameOption()), "left", config.greyTextColor.r, config.greyTextColor.g, config.greyTextColor.b, config.greyTextColor.a, config.tableEntryFont)
		}, "hmd_adapter")
		
		setup:addHeaderRow({ Helper.emptyCellDescriptorSmall }, nil, {3})
		-- Screen Display
		local screendisplay = C.GetScreenDisplayOption()
		setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 7210), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight), Helper.createFontString(screendisplay and ReadText(1001, 2649) or ReadText(1001, 2648), "left", 255, 255, 255, 100, config.tableEntryFont) }, "screendisplay")
		-- Resolution
		local resolution = GetResolutionOption()
		local fullscreen, borderless = GetFullscreenOption()
		if screendisplay or borderless then
			setup:addSimpleRow({
				Helper.emptyCellDescriptor,
				Helper.createFontString(ReadText(1001, 7211), "left", config.greyTextColor.r, config.greyTextColor.g, config.greyTextColor.b, config.greyTextColor.a, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight),
				Helper.createFontString(resolution.width .. ReadText(1001, 42) .. resolution.height, "left", config.greyTextColor.r, config.greyTextColor.g, config.greyTextColor.b, config.greyTextColor.a, config.tableEntryFont)
			}, "resolution")
		else
			setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 7211), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight), Helper.createFontString(resolution.width .. ReadText(1001, 42) .. resolution.height, "left", 255, 255, 255, 100, config.tableEntryFont) }, "resolution")
		end
		-- Fullscreen
		local fullscreentext
		if fullscreen then
			fullscreentext = ReadText(1001, 2622)
		else
			if borderless then
				fullscreentext = ReadText(1001, 4819)
			else
				fullscreentext = ReadText(1001, 4818)
			end
		end
		if screendisplay then
			setup:addSimpleRow({
				Helper.emptyCellDescriptor,
				Helper.createFontString(ReadText(1001, 7213), "left", config.greyTextColor.r, config.greyTextColor.g, config.greyTextColor.b, config.greyTextColor.a, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight),
				Helper.createFontString(fullscreentext, "left", config.greyTextColor.r, config.greyTextColor.g, config.greyTextColor.b, config.greyTextColor.a, config.tableEntryFont)
			}, "fullscreen")
		else
			setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 7213), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight), Helper.createFontString(fullscreentext, "left", 255, 255, 255, 100, config.tableEntryFont) }, "fullscreen")
		end
		-- Adapter
		if screendisplay then
			setup:addSimpleRow({
				Helper.emptyCellDescriptor,
				Helper.createFontString(ReadText(1001, 7212), "left", config.greyTextColor.r, config.greyTextColor.g, config.greyTextColor.b, config.greyTextColor.a, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight),
				Helper.createFontString(GetAdapterOption(), "left", config.greyTextColor.r, config.greyTextColor.g, config.greyTextColor.b, config.greyTextColor.a, config.tableEntryFont)
			}, "adapter")
		else
			setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 7212), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight), Helper.createFontString(GetAdapterOption(), "left", 255, 255, 255, 100, config.tableEntryFont) }, "adapter")
		end
	else
		-- Resolution
		local resolution = GetResolutionOption()
		local fullscreen, borderless = GetFullscreenOption()
		if borderless then
			setup:addSimpleRow({
				Helper.emptyCellDescriptor,
				Helper.createFontString(ReadText(1001, 2619), "left", config.greyTextColor.r, config.greyTextColor.g, config.greyTextColor.b, config.greyTextColor.a, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight),
				Helper.createFontString(resolution.width .. ReadText(1001, 42) .. resolution.height, "left", config.greyTextColor.r, config.greyTextColor.g, config.greyTextColor.b, config.greyTextColor.a, config.tableEntryFont)
			}, "resolution")
		else
			setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 2619), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight), Helper.createFontString(resolution.width .. ReadText(1001, 42) .. resolution.height, "left", 255, 255, 255, 100, config.tableEntryFont) }, "resolution")
		end
		-- Anti Aliasing
		local aastring = ""
		local fxaa = C.GetFXAAOption()
		if fxaa > 0 then
			if fxaa == 1 then
				aastring = ReadText(1001, 4881) .. " - " .. ReadText(1001, 2650)
			elseif fxaa == 2 then
				aastring = ReadText(1001, 4881) .. " - " .. ReadText(1001, 2652)
			else
				aastring = ReadText(1001, 4881) .. " - " .. ReadText(1001, 2651)
			end
		else
			aastring = GetAntiAliasModeOption() .. ReadText(1001, 42)
		end
		setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 2620), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight), Helper.createFontString(aastring, "left", 255, 255, 255, 100, config.tableEntryFont) }, "antialias")
		-- Fullscreen
		local fullscreentext
		if fullscreen then
			fullscreentext = ReadText(1001, 2622)
		else
			if borderless then
				fullscreentext = ReadText(1001, 4819)
			else
				fullscreentext = ReadText(1001, 4818)
			end
		end
		setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 4817), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight), Helper.createFontString(fullscreentext, "left", 255, 255, 255, 100, config.tableEntryFont) }, "fullscreen")
		-- Adapter
		setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 2623), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight), Helper.createFontString(GetAdapterOption(), "left", 255, 255, 255, 100, config.tableEntryFont) }, "adapter")
	end
	-- V-Sync
	setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 2624), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight), Helper.createFontString(GetVSyncOption() and ReadText(1001, 2648) or ReadText(1001, 2649), "left", 255, 255, 255, 100, config.tableEntryFont) }, "vsync")
	-- Gamma
	local isfullscreen = GetFullscreenOption()
	local color = isfullscreen and config.white or config.greyTextColor
	setup:addSelectRow({
		Helper.emptyCellDescriptor,
		Helper.createFontString(ReadText(1001, 2629), "left", color.r, color.g, color.b, color.a, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight),
		Helper.createFontString(math.floor(GetGammaOption() * 100), "left", color.r, color.g, color.b, color.a, config.tableEntryFont)
	}, isfullscreen and "gamma" or nil, nil, isfullscreen and Helper.defaultSelectBackgroundColor or Helper.defaultSimpleBackgroundColor)

	setup:addHeaderRow({ Helper.emptyCellDescriptorSmall }, nil, {3})
	-- GFX quality
	local gfxquality = GetGfxQualityOption()
	local gfxqualityoption = ""
	local textcolor = config.greyTextColor
	local bgcolor = Helper.defaultSimpleBackgroundColor
	local allowrowdata = false
	if gfxquality == 0 then
		textcolor = config.white
		bgcolor = Helper.defaultSelectBackgroundColor
		allowrowdata = true
		gfxqualityoption = ReadText(1001, 4839)
	elseif gfxquality == 1 then
		gfxqualityoption = ReadText(1001, 2650)
	elseif gfxquality == 2 then
		gfxqualityoption = ReadText(1001, 4838)
	elseif gfxquality == 3 then
		gfxqualityoption = ReadText(1001, 2651)
	elseif gfxquality == 4 then
		gfxqualityoption = ReadText(1001, 4837)
	end
	setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 4840), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight), Helper.createFontString(gfxqualityoption, "left", 255, 255, 255, 100, config.tableEntryFont) }, "gfxquality")
	-- Shadows
	local shadowoption
	local shadow = GetShadowOption()
	if shadow == 0 then
		shadowoption = ReadText(1001, 2649)
	elseif shadow == 1 then
		shadowoption = ReadText(1001, 2652)
	else
		shadowoption = ReadText(1001, 2651)
	end
	setup:addSelectRow({
		Helper.emptyCellDescriptor,
		Helper.createFontString(ReadText(1001, 2625), "left", textcolor.r, textcolor.g, textcolor.b, textcolor.a, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight),
		Helper.createFontString(shadowoption, "left", textcolor.r, textcolor.g, textcolor.b, textcolor.a, config.tableEntryFont)
	}, allowrowdata and "shadows" or nil, nil, bgcolor)
	-- Soft Shadows
	setup:addSelectRow({
		Helper.emptyCellDescriptor,
		Helper.createFontString(ReadText(1001, 4841), "left", textcolor.r, textcolor.g, textcolor.b, textcolor.a, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight),
		Helper.createFontString(GetSoftShadowsOption() and ReadText(1001, 2648) or ReadText(1001, 2649), "left", textcolor.r, textcolor.g, textcolor.b, textcolor.a, config.tableEntryFont)
	}, allowrowdata and "softshadows" or nil, nil, bgcolor)
	-- SSAO
	local ssaooption
	local ssao = GetSSAOOption()
	if ssao == 0 then
		ssaooption = ReadText(1001, 2649)
	elseif ssao == 1 then
		ssaooption = ReadText(1001, 2650)
	elseif ssao == 2 then
		ssaooption = ReadText(1001, 2652)
	else
		ssaooption = ReadText(1001, 2651)
	end
	setup:addSelectRow({
		Helper.emptyCellDescriptor,
		Helper.createFontString(ReadText(1001, 2626), "left", textcolor.r, textcolor.g, textcolor.b, textcolor.a, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight),
		Helper.createFontString(ssaooption, "left", textcolor.r, textcolor.g, textcolor.b, textcolor.a, config.tableEntryFont)
	}, allowrowdata and "ssao" or nil, nil, bgcolor)
	-- Glow
	local glowoption
	local glow = GetGlowOption()
	if glow == 0 then
		glowoption = ReadText(1001, 2649)
	elseif glow == 1 then
		glowoption = ReadText(1001, 2650)
	elseif glow == 2 then
		glowoption = ReadText(1001, 2652)
	else
		glowoption = ReadText(1001, 2651)
	end
	setup:addSelectRow({
		Helper.emptyCellDescriptor,
		Helper.createFontString(ReadText(1001, 4821),"left", textcolor.r, textcolor.g, textcolor.b, textcolor.a, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight),
		Helper.createFontString(glowoption, "left", textcolor.r, textcolor.g, textcolor.b, textcolor.a, config.tableEntryFont)
	}, allowrowdata and "glow" or nil, nil, bgcolor)
	-- Distortion
	setup:addSelectRow({
		Helper.emptyCellDescriptor,
		Helper.createFontString(ReadText(1001, 4822), "left", textcolor.r, textcolor.g, textcolor.b, textcolor.a, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight),
		Helper.createFontString(GetDistortionOption() and ReadText(1001, 2648) or ReadText(1001, 2649), "left", textcolor.r, textcolor.g, textcolor.b, textcolor.a, config.tableEntryFont)
	}, allowrowdata and "distortion" or nil, nil, bgcolor)
	-- LOD
	local lodfactor = Helper.round(GetLODOption() * 100)
	setup:addSelectRow({
		Helper.emptyCellDescriptor,
		Helper.createFontString(ReadText(1001, 2628), "left", textcolor.r, textcolor.g, textcolor.b, textcolor.a, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight),
		Helper.createFontString(lodfactor, "left", textcolor.r, textcolor.g, textcolor.b, textcolor.a, config.tableEntryFont)
	}, allowrowdata and "lod" or nil, nil, bgcolor)
	-- View Distance
	local viewdistance = Helper.round(GetViewDistanceOption() * 100)
	setup:addSelectRow({
		Helper.emptyCellDescriptor,
		Helper.createFontString(ReadText(1001, 2682), "left", textcolor.r, textcolor.g, textcolor.b, textcolor.a, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight),
		Helper.createFontString(viewdistance, "left", textcolor.r, textcolor.g, textcolor.b, textcolor.a, config.tableEntryFont)
	}, allowrowdata and "viewdistance" or nil, nil, bgcolor)
	-- Effect Distance
	local effectdistance = Helper.round(GetEffectDistanceOption() * 100)
	setup:addSelectRow({
		Helper.emptyCellDescriptor,
		Helper.createFontString(ReadText(1001, 2699), "left", textcolor.r, textcolor.g, textcolor.b, textcolor.a, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight),
		Helper.createFontString(effectdistance, "left", textcolor.r, textcolor.g, textcolor.b, textcolor.a, config.tableEntryFont)
	}, allowrowdata and "effectdistance" or nil, nil, bgcolor)
	-- Shader Quality
	local shaderqualityoption
	local shaderquality = GetShaderQualityOption()
	if shaderquality == 0 then
		shaderqualityoption = ReadText(1001, 2650)
	elseif shaderquality == 2 then
		shaderqualityoption = ReadText(1001, 2651)
	else
		shaderqualityoption = ReadText(1001, 2652)
	end
	setup:addSelectRow({
		Helper.emptyCellDescriptor,
		Helper.createFontString(ReadText(1001, 2680), "left", textcolor.r, textcolor.g, textcolor.b, textcolor.a, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight),
		Helper.createFontString(shaderqualityoption, "left", textcolor.r, textcolor.g, textcolor.b, textcolor.a, config.tableEntryFont)
	}, allowrowdata and "shaderquality" or nil, nil, bgcolor)
	-- Radar
	local radarqualityoption
	local radarquality = GetRadarOption()
	if radarquality == 0 then
		radarqualityoption = ReadText(1001, 2649)
	elseif radarquality == 2 then
		radarqualityoption = ReadText(1001, 2651)
	else
		radarqualityoption = ReadText(1001, 2650)
	end
	setup:addSelectRow({
		Helper.emptyCellDescriptor,
		Helper.createFontString(ReadText(1001, 1706), "left", textcolor.r, textcolor.g, textcolor.b, textcolor.a, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight),
		Helper.createFontString(radarqualityoption, "left", textcolor.r, textcolor.g, textcolor.b, textcolor.a, config.tableEntryFont)
	},allowrowdata and "radar" or nil, nil, bgcolor)

	setup:addHeaderRow({ Helper.emptyCellDescriptorSmall }, nil, {3})
	-- Capture HQ
	setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 4816), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight), GetCaptureHQOption() and ReadText(1001, 2648) or ReadText(1001, 2649) }, "capturehq")
	
	setup:addHeaderRow({ Helper.emptyCellDescriptorSmall }, nil, {3})
	-- Defaults
	setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 2647), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) }, "default")
	
	
	local infodesc = setup:createCustomWidthTable({config.tableFirstColumnWidth, config.tableSecondColumn2Width + config.tableScrollbarWidth, config.tableThirdColumnWidth}, false, config.borderEnabled, 1, 1, config.offsetx, config.tableOffsety, config.tableHeight, menu.pretoprow, menu.preselectrow)
	menu.pretoprow = nil
	menu.preselectrow = nil

	-- create tableview
	menu.infotable = Helper.displayTableView(menu, infodesc, true, config.bgTexture, config.fgTexture, config.frameWidth, config.frameHeight, config.frameOffsetx, config.frameOffsety, "none")

	-- clear descriptors again
	Helper.releaseDescriptors()
end

function openResolutionMenu()
	Helper.removeAllButtonScripts(menu)
	Helper.removeAllMenuScripts(menu)

	menu.title = "Change Resolution"
	menu.textdbtitle = ReadText(1001, 2607)
	menu.selectedrow = 2

	local setup = Helper.createTableSetup(menu)
	setup:addSimpleRow({
		Helper.createFontString(menu.textdbtitle, "left", 255, 255, 255, 100, config.headerEntryFont, config.headerEntrySize, false, config.headerEntryOffsetx, config.headerEntryOffsety, config.headerEntryHeight, 0)
	}, nil, {2}, config.headerEntryBGColor)

	local oldresolution = GetResolutionOption()
	local resolutions = GetPossibleResolutions()
	function resolutionsort (a, b)
		local result = false
		if a.width < b.width then 
			result = true 
		elseif a.width == b.width then 
			result = a.height < b. height
		end
		return result
	end
	table.sort(resolutions, resolutionsort)
	for i, resolution in ipairs(resolutions) do
		setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(resolution.width .. ReadText(1001, 42) .. resolution.height, "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) }, {resolution.width, resolution.height})
		if oldresolution.height == resolution.height and oldresolution.width == resolution.width then
			if i > 9 then
				menu.pretoprow = i - 5
			end
			menu.preselectrow = i + 1
		end
	end
	local columnwidth = 0
	if #resolutions > config.maxTableRowWithoutScrollbar then
		columnwidth = config.tableScrollbarWidth
	end
	local infodesc = setup:createCustomWidthTable({config.tableFirstColumnWidth, config.tableSecondColumn1Width + columnwidth}, false, config.borderEnabled, 1, 1, config.offsetx, config.tableOffsety, config.tableHeight, menu.pretoprow, menu.preselectrow)
	menu.pretoprow = nil
	menu.preselectrow = nil

	-- create tableview
	menu.infotable = Helper.displayTableView(menu, infodesc, true, config.bgTexture, config.fgTexture, config.frameWidth, config.frameHeight, config.frameOffsetx, config.frameOffsety, "none")

	-- clear descriptors again
	Helper.releaseDescriptors()
end

function openAntiAliasMenu()
	Helper.removeAllButtonScripts(menu)
	Helper.removeAllMenuScripts(menu)

	menu.title = "Change Antialiasing"
	menu.textdbtitle = ReadText(1001, 2608)
	menu.selectedrow = 2

	local setup = Helper.createTableSetup(menu)
	setup:addSimpleRow({
		Helper.createFontString(menu.textdbtitle, "left", 255, 255, 255, 100, config.headerEntryFont, config.headerEntrySize, false, config.headerEntryOffsetx, config.headerEntryOffsety, config.headerEntryHeight, 0)
	}, nil, {2}, config.headerEntryBGColor)

	local oldmode = GetAntiAliasModeOption()
	local modes = GetAntiAliasModes()
	for i, mode in ipairs(modes) do
		setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(mode .. ReadText(1001, 42), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) }, {"aa", mode})
		if oldmode == mode then
			if i > 9 then
				menu.pretoprow = i - 5
			end
			menu.preselectrow = i + 1
		end
	end

	local oldfxaa = C.GetFXAAOption()
	if oldfxaa > 0 then
		local index = oldfxaa + #modes
		if index > 9 then
			menu.pretoprow = index - 5
		end
		menu.preselectrow = index + 1
	end
	setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 4881) .. " - " .. ReadText(1001, 2650), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) }, {"fxaa", 1})
	setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 4881) .. " - " .. ReadText(1001, 2652), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) }, {"fxaa", 2})
	setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 4881) .. " - " .. ReadText(1001, 2651), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) }, {"fxaa", 3})

	local columnwidth = 0
	if #modes > config.maxTableRowWithoutScrollbar then
		columnwidth = config.tableScrollbarWidth
	end
	local infodesc = setup:createCustomWidthTable({config.tableFirstColumnWidth, config.tableSecondColumn1Width + columnwidth}, false, config.borderEnabled, 1, 1, config.offsetx, config.tableOffsety, config.tableHeight, menu.pretoprow, menu.preselectrow)
	menu.pretoprow = nil
	menu.preselectrow = nil

	-- create tableview
	menu.infotable = Helper.displayTableView(menu, infodesc, true, config.bgTexture, config.fgTexture, config.frameWidth, config.frameHeight, config.frameOffsetx, config.frameOffsety, "none")

	-- clear descriptors again
	Helper.releaseDescriptors()
end

function openShaderQualityMenu()
	Helper.removeAllButtonScripts(menu)
	Helper.removeAllMenuScripts(menu)

	menu.title = "Change Shader Quality"
	menu.textdbtitle = ReadText(1001, 2680)
	menu.selectedrow = 2

	local setup = Helper.createTableSetup(menu)
	setup:addSimpleRow({
		Helper.createFontString(menu.textdbtitle, "left", 255, 255, 255, 100, config.headerEntryFont, config.headerEntrySize, false, config.headerEntryOffsetx, config.headerEntryOffsety, config.headerEntryHeight, 0)
	}, nil, {2}, config.headerEntryBGColor)

	setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 2650), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) }, 0)
	setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 2652), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) }, 1)
	setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 2651), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) }, 2)
	local shaderquality = GetShaderQualityOption()
	menu.preselectrow = shaderquality + 2
	local infodesc = setup:createCustomWidthTable({config.tableFirstColumnWidth, config.tableSecondColumn1Width}, false, config.borderEnabled, 1, 1, config.offsetx, config.tableOffsety, config.tableHeight, menu.pretoprow, menu.preselectrow)
	menu.pretoprow = nil
	menu.preselectrow = nil

	-- create tableview
	menu.infotable = Helper.displayTableView(menu, infodesc, true, config.bgTexture, config.fgTexture, config.frameWidth, config.frameHeight, config.frameOffsetx, config.frameOffsety, "none")

	-- clear descriptors again
	Helper.releaseDescriptors()
end

function openShadowsMenu()
	Helper.removeAllButtonScripts(menu)
	Helper.removeAllMenuScripts(menu)

	menu.title = "Change Shadows"
	menu.textdbtitle = ReadText(1001, 2625)
	menu.selectedrow = 2

	local setup = Helper.createTableSetup(menu)
	setup:addSimpleRow({
		Helper.createFontString(menu.textdbtitle, "left", 255, 255, 255, 100, config.headerEntryFont, config.headerEntrySize, false, config.headerEntryOffsetx, config.headerEntryOffsety, config.headerEntryHeight, 0)
	}, nil, {2}, config.headerEntryBGColor)

	setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 2649), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) }, 0)
	setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 2652), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) }, 1)
	setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 2651), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) }, 2)
	local shadow = GetShadowOption()
	menu.preselectrow = shadow + 2
	local infodesc = setup:createCustomWidthTable({config.tableFirstColumnWidth, config.tableSecondColumn1Width}, false, config.borderEnabled, 1, 1, config.offsetx, config.tableOffsety, config.tableHeight, menu.pretoprow, menu.preselectrow)
	menu.pretoprow = nil
	menu.preselectrow = nil

	-- create tableview
	menu.infotable = Helper.displayTableView(menu, infodesc, true, config.bgTexture, config.fgTexture, config.frameWidth, config.frameHeight, config.frameOffsetx, config.frameOffsety, "none")

	-- clear descriptors again
	Helper.releaseDescriptors()
end

function openGfxQualityMenu()
	Helper.removeAllButtonScripts(menu)
	Helper.removeAllMenuScripts(menu)

	menu.title = "Change Gfx Quality"
	menu.textdbtitle = ReadText(1001, 4840)
	menu.selectedrow = 2

	local setup = Helper.createTableSetup(menu)
	setup:addSimpleRow({
		Helper.createFontString(menu.textdbtitle, "left", 255, 255, 255, 100, config.headerEntryFont, config.headerEntrySize, false, config.headerEntryOffsetx, config.headerEntryOffsety, config.headerEntryHeight, 0)
	}, nil, {2}, config.headerEntryBGColor)

	setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 2650), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) }, 1)
	setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 4838), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) }, 2)
	setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 2651), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) }, 3)
	setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 4837), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) }, 4)
	setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 4839), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) }, 0)
	local gfxquality = GetGfxQualityOption()
	menu.preselectrow = (gfxquality == 0) and 6 or (gfxquality + 1)
	local infodesc = setup:createCustomWidthTable({config.tableFirstColumnWidth, config.tableSecondColumn1Width}, false, config.borderEnabled, 1, 1, config.offsetx, config.tableOffsety, config.tableHeight, menu.pretoprow, menu.preselectrow)
	menu.pretoprow = nil
	menu.preselectrow = nil

	-- create tableview
	menu.infotable = Helper.displayTableView(menu, infodesc, true, config.bgTexture, config.fgTexture, config.frameWidth, config.frameHeight, config.frameOffsetx, config.frameOffsety, "none")

	-- clear descriptors again
	Helper.releaseDescriptors()
end

function openSSAOMenu()
	Helper.removeAllButtonScripts(menu)
	Helper.removeAllMenuScripts(menu)

	menu.title = "Change SSAO"
	menu.textdbtitle = ReadText(1001, 2626)
	menu.selectedrow = 2

	local setup = Helper.createTableSetup(menu)
	setup:addSimpleRow({
		Helper.createFontString(menu.textdbtitle, "left", 255, 255, 255, 100, config.headerEntryFont, config.headerEntrySize, false, config.headerEntryOffsetx, config.headerEntryOffsety, config.headerEntryHeight, 0)
	}, nil, {2}, config.headerEntryBGColor)

	setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 2649), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) }, 0)
	setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 2650), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) }, 1)
	setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 2652), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) }, 2)
	setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 2651), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) }, 3)
	local ssao = GetSSAOOption()
	menu.preselectrow = ssao + 2
	local infodesc = setup:createCustomWidthTable({config.tableFirstColumnWidth, config.tableSecondColumn1Width}, false, config.borderEnabled, 1, 1, config.offsetx, config.tableOffsety, config.tableHeight, menu.pretoprow, menu.preselectrow)
	menu.pretoprow = nil
	menu.preselectrow = nil

	-- create tableview
	menu.infotable = Helper.displayTableView(menu, infodesc, true, config.bgTexture, config.fgTexture, config.frameWidth, config.frameHeight, config.frameOffsetx, config.frameOffsety, "none")

	-- clear descriptors again
	Helper.releaseDescriptors()
end

function openRadarMenu()
	Helper.removeAllButtonScripts(menu)
	Helper.removeAllMenuScripts(menu)

	menu.title = "Change Radar"
	menu.textdbtitle = ReadText(1001, 1706)
	menu.selectedrow = 2

	local setup = Helper.createTableSetup(menu)
	setup:addSimpleRow({
		Helper.createFontString(menu.textdbtitle, "left", 255, 255, 255, 100, config.headerEntryFont, config.headerEntrySize, false, config.headerEntryOffsetx, config.headerEntryOffsety, config.headerEntryHeight, 0)
	}, nil, {2}, config.headerEntryBGColor)

	setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 2649), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) }, 0)
	setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 2650), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) }, 1)
	setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 2651), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) }, 2)
	local radarquality = GetRadarOption()
	menu.preselectrow = radarquality + 2
	local infodesc = setup:createCustomWidthTable({config.tableFirstColumnWidth, config.tableSecondColumn1Width}, false, config.borderEnabled, 1, 1, config.offsetx, config.tableOffsety, config.tableHeight, menu.pretoprow, menu.preselectrow)
	menu.pretoprow = nil
	menu.preselectrow = nil

	-- create tableview
	menu.infotable = Helper.displayTableView(menu, infodesc, true, config.bgTexture, config.fgTexture, config.frameWidth, config.frameHeight, config.frameOffsetx, config.frameOffsety, "none")

	-- clear descriptors again
	Helper.releaseDescriptors()
end

function openGlowMenu()
	Helper.removeAllButtonScripts(menu)
	Helper.removeAllMenuScripts(menu)

	menu.title = "Change Glow"
	menu.textdbtitle = ReadText(1001, 4821)
	menu.selectedrow = 2

	local setup = Helper.createTableSetup(menu)
	setup:addSimpleRow({
		Helper.createFontString(menu.textdbtitle, "left", 255, 255, 255, 100, config.headerEntryFont, config.headerEntrySize, false, config.headerEntryOffsetx, config.headerEntryOffsety, config.headerEntryHeight, 0)
	}, nil, {2}, config.headerEntryBGColor)

	setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 2649), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) }, 0)
	setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 2650), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) }, 1)
	setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 2652), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) }, 2)
	setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 2651), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) }, 3)
	local glow = GetGlowOption()
	menu.preselectrow = glow + 2
	local infodesc = setup:createCustomWidthTable({config.tableFirstColumnWidth, config.tableSecondColumn1Width}, false, config.borderEnabled, 1, 1, config.offsetx, config.tableOffsety, config.tableHeight, menu.pretoprow, menu.preselectrow)
	menu.pretoprow = nil
	menu.preselectrow = nil

	-- create tableview
	menu.infotable = Helper.displayTableView(menu, infodesc, true, config.bgTexture, config.fgTexture, config.frameWidth, config.frameHeight, config.frameOffsetx, config.frameOffsety, "none")

	-- clear descriptors again
	Helper.releaseDescriptors()
end

function openDisplayModeMenu()
	Helper.removeAllButtonScripts(menu)
	Helper.removeAllMenuScripts(menu)

	menu.title = "Change Display Mode"
	menu.textdbtitle = ReadText(1001, 4817)
	menu.selectedrow = 2

	local setup = Helper.createTableSetup(menu)
	setup:addSimpleRow({
		Helper.createFontString(menu.textdbtitle, "left", 255, 255, 255, 100, config.headerEntryFont, config.headerEntrySize, false, config.headerEntryOffsetx, config.headerEntryOffsety, config.headerEntryHeight, 0)
	}, nil, {2}, config.headerEntryBGColor)

	setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 2622), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) }, 1)
	setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 4818), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) }, 2)
	setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 4819), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) }, 3)

	local fullscreen, borderless = GetFullscreenOption()
	if fullscreen then
		menu.preselectrow = 2
	else
		if borderless then
			menu.preselectrow = 4
		else
			menu.preselectrow = 3
		end
	end
	local infodesc = setup:createCustomWidthTable({config.tableFirstColumnWidth, config.tableSecondColumn1Width}, false, config.borderEnabled, 1, 1, config.offsetx, config.tableOffsety, config.tableHeight, menu.pretoprow, menu.preselectrow)
	menu.pretoprow = nil
	menu.preselectrow = nil

	-- create tableview
	menu.infotable = Helper.displayTableView(menu, infodesc, true, config.bgTexture, config.fgTexture, config.frameWidth, config.frameHeight, config.frameOffsetx, config.frameOffsety, "none")

	-- clear descriptors again
	Helper.releaseDescriptors()
end

function openAdapterMenu()
	Helper.removeAllButtonScripts(menu)
	Helper.removeAllMenuScripts(menu)

	menu.title = "Change Adapter"
	menu.textdbtitle = ReadText(1001, 2609)
	menu.selectedrow = 2

	local setup = Helper.createTableSetup(menu)
	setup:addSimpleRow({
		Helper.createFontString(menu.textdbtitle, "left", 255, 255, 255, 100, config.headerEntryFont, config.headerEntrySize, false, config.headerEntryOffsetx, config.headerEntryOffsety, config.headerEntryHeight, 0)
	}, nil, {2}, config.headerEntryBGColor)

	local oldadapter = GetAdapterOption()
	local adapters = GetPossibleAdapters()
	for i, adapter in ipairs(adapters) do
		setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(adapter.name, "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) }, adapter.ordinal)
		if oldadapter == adapter.name then
			if i > 9 then
				menu.pretoprow = i - 5
			end
			menu.preselectrow = i + 1 
		end
	end
	local columnwidth = 0
	if #adapters > config.maxTableRowWithoutScrollbar then
		columnwidth = config.tableScrollbarWidth
	end
	local infodesc = setup:createCustomWidthTable({config.tableFirstColumnWidth, config.tableSecondColumn1Width + columnwidth}, false, config.borderEnabled, 1, 1, config.offsetx, config.tableOffsety, config.tableHeight, menu.pretoprow, menu.preselectrow)
	menu.pretoprow = nil
	menu.preselectrow = nil

	-- create tableview
	menu.infotable = Helper.displayTableView(menu, infodesc, true, config.bgTexture, config.fgTexture, config.frameWidth, config.frameHeight, config.frameOffsetx, config.frameOffsety, "none")

	-- clear descriptors again
	Helper.releaseDescriptors()
end

function openGammaMenu()
	Helper.removeAllButtonScripts(menu)
	Helper.removeAllMenuScripts(menu)

	menu.title = "Gamma Menu"
	menu.textdbtitle = ReadText(1001, 2610)
	menu.selectedrow = 1

	local setup = Helper.createTableSetup(menu)
	setup:addSimpleRow({
		Helper.createFontString(menu.textdbtitle, "left", 255, 255, 255, 100, config.headerEntryFont, config.headerEntrySize, false, config.headerEntryOffsetx, config.headerEntryOffsety, config.headerEntryHeight, 0)
	}, nil, nil, config.headerEntryBGColor)
	local headerdesc = setup:createCustomWidthTable({config.headerWidth}, false, config.borderEnabled, 0, 0, config.offsetx, config.headerOffsety)

	-- collect slider value parameters
	local gamma = math.floor(GetGammaOption() * 100)
	local start = nil
	if gamma < 50 then
		start = 50
	elseif gamma >= 200 then
		start = 200
	else
		start = gamma
	end
	
	local sliderinfo = {
		["background"] = "tradesellbuy_blur",
		["captionCenter"] = ReadText(1001, 2629),
		["min"]= 0,
		["max"] = 150,
		["start"] = start - 50
	}
	local scale1info = { 
		["left"] = 50,
		["right"] = nil,
		["center"] = false,
		["inverted"] = true,
		["suffix"] = nil 
	}

	local sliderdesc = Helper.createSlider(sliderinfo, scale1info, nil, 1, config.offsetx, config.sliderOffsety)

	-- create tableview
	menu.headertable, menu.infotable = Helper.displaySliderTableView(menu, sliderdesc, headerdesc, true, config.bgTexture, config.fgTexture, config.frameWidth, config.frameHeight, config.frameOffsetx, config.frameOffsety, "none")

	-- clear descriptors again
	Helper.releaseDescriptors()
end

function openJoystickDeadzoneMenu()
	Helper.removeAllButtonScripts(menu)
	Helper.removeAllMenuScripts(menu)

	menu.title = "Joystick Deadzone Menu"
	menu.textdbtitle = ReadText(1001, 4835)
	menu.selectedrow = 1

	local setup = Helper.createTableSetup(menu)
	setup:addSimpleRow({
		Helper.createFontString(menu.textdbtitle, "left", 255, 255, 255, 100, config.headerEntryFont, config.headerEntrySize, false, config.headerEntryOffsetx, config.headerEntryOffsety, config.headerEntryHeight, 0)
	}, nil, nil, config.headerEntryBGColor)
	local headerdesc = setup:createCustomWidthTable({config.headerWidth}, false, config.borderEnabled, 0, 0, config.offsetx, config.headerOffsety)

	-- collect slider value parameters
	local deadzone = GetDeadzoneOption()
	local start = nil
	if deadzone < 0 then
		start = 0
	elseif deadzone >= 100 then
		start = 100
	else
		start = deadzone
	end
	
	local sliderinfo = {
		["background"] = "tradesellbuy_blur",
		["captionCenter"] = ReadText(1001, 4835),
		["min"]= 0,
		["max"] = 100,
		["start"] = start
	}
	local scale1info = { 
		["left"] = 0,
		["right"] = nil,
		["center"] = false,
		["inverted"] = true,
		["suffix"] = nil 
	}

	local sliderdesc = Helper.createSlider(sliderinfo, scale1info, nil, 1, config.offsetx, config.sliderOffsety)

	-- create tableview
	menu.headertable, menu.infotable = Helper.displaySliderTableView(menu, sliderdesc, headerdesc, true, config.bgTexture, config.fgTexture, config.frameWidth, config.frameHeight, config.frameOffsetx, config.frameOffsety, "none")

	-- clear descriptors again
	Helper.releaseDescriptors()
end

function openLODMenu()
	Helper.removeAllButtonScripts(menu)
	Helper.removeAllMenuScripts(menu)

	menu.title = "LOD Menu"
	menu.textdbtitle = ReadText(1001, 2628)
	menu.selectedrow = 1

	local setup = Helper.createTableSetup(menu)
	setup:addSimpleRow({
		Helper.createFontString(menu.textdbtitle, "left", 255, 255, 255, 100, config.headerEntryFont, config.headerEntrySize, false, config.headerEntryOffsetx, config.headerEntryOffsety, config.headerEntryHeight, 0)
	}, nil, nil, config.headerEntryBGColor)
	local headerdesc = setup:createCustomWidthTable({config.headerWidth}, false, config.borderEnabled, 0, 0, config.offsetx, config.headerOffsety)

	-- collect slider value parameters
	local lodfactor = Helper.round(GetLODOption() * 100)
	local start = nil
	if lodfactor < 0 then
		start = 0
	elseif lodfactor >= 100 then
		start = 100
	else
		start = lodfactor
	end
	
	local sliderinfo = {
		["background"] = "tradesellbuy_blur",
		["captionCenter"] = ReadText(1001, 2628),
		["min"]= 0,
		["max"] = 100,
		["start"] = start
	}
	local scale1info = { 
		["left"] = 0,
		["right"] = nil,
		["center"] = false,
		["inverted"] = true,
		["suffix"] = nil 
	}

	local sliderdesc = Helper.createSlider(sliderinfo, scale1info, nil, 1, config.offsetx, config.sliderOffsety)

	-- create tableview
	menu.headertable, menu.infotable = Helper.displaySliderTableView(menu, sliderdesc, headerdesc, true, config.bgTexture, config.fgTexture, config.frameWidth, config.frameHeight, config.frameOffsetx, config.frameOffsety, "none")

	-- clear descriptors again
	Helper.releaseDescriptors()
end

function openViewDistanceMenu()
	Helper.removeAllButtonScripts(menu)
	Helper.removeAllMenuScripts(menu)

	menu.title = "View Distance Menu"
	menu.textdbtitle = ReadText(1001, 2682)
	menu.selectedrow = 1

	local setup = Helper.createTableSetup(menu)
	setup:addSimpleRow({
		Helper.createFontString(menu.textdbtitle, "left", 255, 255, 255, 100, config.headerEntryFont, config.headerEntrySize, false, config.headerEntryOffsetx, config.headerEntryOffsety, config.headerEntryHeight, 0)
	}, nil, nil, config.headerEntryBGColor)
	local headerdesc = setup:createCustomWidthTable({config.headerWidth}, false, config.borderEnabled, 0, 0, config.offsetx, config.headerOffsety)

	-- collect slider value parameters
	local viewdistance = Helper.round(GetViewDistanceOption() * 100)
	local start = nil
	if viewdistance < 0 then
		start = 0
	elseif viewdistance >= 100 then
		start = 100
	else
		start = viewdistance
	end
	
	local sliderinfo = {
		["background"] = "tradesellbuy_blur",
		["captionCenter"] = ReadText(1001, 2682),
		["min"]= 0,
		["max"] = 100,
		["start"] = start
	}
	local scale1info = { 
		["left"] = 0,
		["right"] = nil,
		["center"] = false,
		["inverted"] = true,
		["suffix"] = nil 
	}

	local sliderdesc = Helper.createSlider(sliderinfo, scale1info, nil, 1, config.offsetx, config.sliderOffsety)

	-- create tableview
	menu.headertable, menu.infotable = Helper.displaySliderTableView(menu, sliderdesc, headerdesc, true, config.bgTexture, config.fgTexture, config.frameWidth, config.frameHeight, config.frameOffsetx, config.frameOffsety, "none")

	-- clear descriptors again
	Helper.releaseDescriptors()
end

function openEffectDistanceMenu()
	Helper.removeAllButtonScripts(menu)
	Helper.removeAllMenuScripts(menu)

	menu.title = "Effect Distance Menu"
	menu.textdbtitle = ReadText(1001, 2699)
	menu.selectedrow = 1

	local setup = Helper.createTableSetup(menu)
	setup:addSimpleRow({
		Helper.createFontString(menu.textdbtitle, "left", 255, 255, 255, 100, config.headerEntryFont, config.headerEntrySize, false, config.headerEntryOffsetx, config.headerEntryOffsety, config.headerEntryHeight, 0)
	}, nil, nil, config.headerEntryBGColor)
	local headerdesc = setup:createCustomWidthTable({config.headerWidth}, false, config.borderEnabled, 0, 0, config.offsetx, config.headerOffsety)

	-- collect slider value parameters
	local effectdistance = Helper.round(GetEffectDistanceOption() * 100)
	local start = nil
	if effectdistance < 0 then
		start = 0
	elseif effectdistance >= 100 then
		start = 100
	else
		start = effectdistance
	end
	
	local sliderinfo = {
		["background"] = "tradesellbuy_blur",
		["captionCenter"] = ReadText(1001, 2699),
		["min"]= 0,
		["max"] = 100,
		["start"] = start
	}
	local scale1info = { 
		["left"] = 0,
		["right"] = nil,
		["center"] = false,
		["inverted"] = true,
		["suffix"] = nil 
	}

	local sliderdesc = Helper.createSlider(sliderinfo, scale1info, nil, 1, config.offsetx, config.sliderOffsety)

	-- create tableview
	menu.headertable, menu.infotable = Helper.displaySliderTableView(menu, sliderdesc, headerdesc, true, config.bgTexture, config.fgTexture, config.frameWidth, config.frameHeight, config.frameOffsetx, config.frameOffsety, "none")

	-- clear descriptors again
	Helper.releaseDescriptors()
end

function openSoundMenu()
	Helper.removeAllButtonScripts(menu)
	Helper.removeAllMenuScripts(menu)

	menu.title = "Sound Menu"
	menu.textdbtitle = ReadText(1001, 2611)
	menu.selectedrow = 2

	local setup = Helper.createTableSetup(menu)
	setup:addSimpleRow({
		Helper.createFontString(menu.textdbtitle, "left", 255, 255, 255, 100, config.headerEntryFont, config.headerEntrySize, false, config.headerEntryOffsetx, config.headerEntryOffsety, config.headerEntryHeight, 0)
	}, nil, {3}, config.headerEntryBGColor)

	setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 2630), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight), Helper.createFontString(GetSoundOption() and ReadText(1001, 2648) or ReadText(1001, 2649), "left", 255, 255, 255, 100, config.tableEntryFont) }, "sound")
	setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 2631), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight), Helper.createFontString(math.floor(Helper.round(GetVolumeOption("master"), 2) * 100), "left", 255, 255, 255, 100, config.tableEntryFont) }, "master")
	setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 2632), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight), Helper.createFontString(math.floor(Helper.round(GetVolumeOption("music"), 2) * 100), "left", 255, 255, 255, 100, config.tableEntryFont) }, "music")
	setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 2633), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight), Helper.createFontString(math.floor(Helper.round(GetVolumeOption("voice"), 2) * 100), "left", 255, 255, 255, 100, config.tableEntryFont) }, "voice")
	setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 2634), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight), Helper.createFontString(math.floor(Helper.round(GetVolumeOption("ambient"), 2) * 100), "left", 255, 255, 255, 100, config.tableEntryFont) }, "ambient")
	setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 2635), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight), Helper.createFontString(math.floor(Helper.round(GetVolumeOption("ui"), 2) * 100), "left", 255, 255, 255, 100, config.tableEntryFont) }, "ui")
	setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 2636), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight), Helper.createFontString(math.floor(Helper.round(GetVolumeOption("effect"), 2) * 100), "left", 255, 255, 255, 100, config.tableEntryFont) }, "effect")
	setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 2647), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) }, "default")
	local infodesc = setup:createCustomWidthTable({config.tableFirstColumnWidth, config.tableSecondColumn2Width, config.tableThirdColumnWidth}, false, config.borderEnabled, 1, 1, config.offsetx, config.tableOffsety, config.tableHeight, menu.pretoprow, menu.preselectrow)
	menu.pretoprow = nil
	menu.preselectrow = nil

	-- create tableview
	menu.infotable = Helper.displayTableView(menu, infodesc, true, config.bgTexture, config.fgTexture, config.frameWidth, config.frameHeight, config.frameOffsetx, config.frameOffsety, "none")

	-- clear descriptors again
	Helper.releaseDescriptors()
end

function openVolumeMenu()
	Helper.removeAllButtonScripts(menu)
	Helper.removeAllMenuScripts(menu)

	menu.title = "Volume Menu"
	menu.textdbtitle = ReadText(1001, 2612)
	menu.selectedrow = 1

	local setup = Helper.createTableSetup(menu)
	setup:addSimpleRow({
		Helper.createFontString(menu.textdbtitle, "left", 255, 255, 255, 100, config.headerEntryFont, config.headerEntrySize, false, config.headerEntryOffsetx, config.headerEntryOffsety, config.headerEntryHeight, 0)
	}, nil, nil, config.headerEntryBGColor)
	local headerdesc = setup:createCustomWidthTable({config.headerWidth}, false, config.borderEnabled, 0, 0, config.offsetx, config.headerOffsety)

	-- collect slider value parameters
	local oldvolume = Helper.round(GetVolumeOption(menu.volumetype), 2) * 100

	local caption
	if menu.volumetype == "master" then
		caption = ReadText(1001, 2637)
	elseif menu.volumetype == "ambient" then
		caption = ReadText(1001, 2638)
	elseif menu.volumetype == "music" then
		caption = ReadText(1001, 2639)
	elseif menu.volumetype == "voice" then
		caption = ReadText(1001, 2640)
	elseif menu.volumetype == "effect" then
		caption = ReadText(1001, 2641)
	elseif menu.volumetype == "ui" then
		caption = ReadText(1001, 2642)
	end
	
	local sliderinfo = {
		["background"] = "tradesellbuy_blur",
		["captionCenter"] = caption,
		["min"]= 0, 
		["max"] = 100,
		["zero"] = 0,
		["start"] = math.floor(oldvolume)
	}
	local scale1info = { 
		["left"] = 0,
		["right"] = nil,
		["center"] = false,
		["inverted"] = true,
		["suffix"] = nil
	}
	local sliderdesc = Helper.createSlider(sliderinfo, scale1info, nil, 1, config.offsetx, config.sliderOffsety)

	-- create tableview
	menu.headertable, menu.infotable = Helper.displaySliderTableView(menu, sliderdesc, headerdesc, true, config.bgTexture, config.fgTexture, config.frameWidth, config.frameHeight, config.frameOffsetx, config.frameOffsety, "none")

	-- clear descriptors again
	Helper.releaseDescriptors()
end

function openGameMenu()
	Helper.removeAllButtonScripts(menu)
	Helper.removeAllMenuScripts(menu)

	menu.title = "Game Menu"
	menu.textdbtitle = ReadText(1001, 2613)
	menu.selectedrow = 2

	local setup = Helper.createTableSetup(menu)
	setup:addSimpleRow({
		Helper.createFontString(menu.textdbtitle, "left", 255, 255, 255, 100, config.headerEntryFont, config.headerEntrySize, false, config.headerEntryOffsetx, config.headerEntryOffsety, config.headerEntryHeight, 0)
	}, nil, {3}, config.headerEntryBGColor)

	local difficulty = GetDifficultyOption()
	local difficultytext = ""
	if difficulty == "easy" then
		difficultytext = ReadText(1001, 4852)
	elseif difficulty == "medium" then
		difficultytext = ReadText(1001, 4853)
	elseif difficulty == "hard" then
		difficultytext = ReadText(1001, 4854)
	elseif difficulty == "extreme" then
		difficultytext = ReadText(1001, 4855)
	end
	if GetCurrentModuleName() == "startmenu" then
		setup:addSimpleRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 4843), "left", config.greyTextColor.r, config.greyTextColor.g, config.greyTextColor.b, config.greyTextColor.a, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight), difficultytext }, "difficulty")
	else
		setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 4843), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight), difficultytext }, "difficulty")
	end
	local subtitle = GetSubtitleOption()
	local text = ""
	if subtitle == "auto" then
		text = ReadText(1001, 4806)
	elseif subtitle == "true" then
		text = ReadText(1001, 2648) 
	elseif subtitle == "false" then
		text = ReadText(1001, 2649)
	end
	setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 2643), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight), text }, "subtitles")
	setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 407), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight), GetAutosaveOption() and ReadText(1001, 2648) or ReadText(1001, 2649) }, "autosave")
	setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 2644), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight, nil, ReadText(1026, 2616)), GetAutorollOption() and ReadText(1001, 2648) or ReadText(1001, 2649) }, "autoroll")
	setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 2646), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight, nil--[[, ReadText(1026, 2613)]]), GetBoostToggleOption() and ReadText(1001, 2648) or ReadText(1001, 2649) }, "boost")
	setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 4895), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight, nil), GetMouseLookToggleOption() and ReadText(1001, 2648) or ReadText(1001, 2649) }, "mouselook")
	setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 2678), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight, nil, ReadText(1026, 2619)), math.floor(GetRumbleOption() * 100) }, "rumble")
	local aimassist = GetAimAssistOption()
	local aimassistoption
	if aimassist == 0 then
		aimassistoption = ReadText(1001, 2649)
	elseif aimassist == 2 then
		aimassistoption = ReadText(1001, 2695)
	else
		aimassistoption = ReadText(1001, 2648)
	end
	setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 2696), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight, nil, ReadText(1026, 2618)), aimassistoption }, "aimassist")
	setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 2698), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight, nil, ReadText(1026, 2614)), GetCollisionAvoidanceAssistOption() and ReadText(1001, 2648) or ReadText(1001, 2649) }, "collision")
	setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 4836), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight, nil, ReadText(1026, 2615)), GetFullscreenDetailmonitorOption() and ReadText(1001, 4887) or ReadText(1001, 4886) }, "fullscreendetailmonitor")
	setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 7200), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight, nil, ReadText(1026, 2625)), C.GetLargeHUDMenusOption() and ReadText(1001, 2648) or ReadText(1001, 2649) }, "largeHUDMenus")

	setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 4884), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight, nil, ReadText(1026, 2617)), GetStopShipInMenuOption() and ReadText(1001, 2649) or ReadText(1001, 2648) }, "stopshipinmenu")
	setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 4872), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight), GetLegacyMainMenuOption() and ReadText(1001, 4890) or ReadText(1001, 4889) }, "legacymainmenu")
	setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 4880), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight, nil, ReadText(1026, 2620)), GetNonSquadShipsForTradeOffersOption() and ReadText(1001, 2648) or ReadText(1001, 2649) }, "nonsquadshipsfortradeoffers")
	setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 4882), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight), C.GetMouseOverTextOption() and ReadText(1001, 2648) or ReadText(1001, 2649) }, "mouseover")
	if C.IsVRVersion() then
		setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 7209), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight, nil, ReadText(1026, 2626)), Helper.roundStr(C.GetUIScale(), 1) }, "uiscale")
	end

	setup:addHeaderRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 4815), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) }, nil, {1, 2})
	setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 4861), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight), GetSteeringNoteOption() and ReadText(1001, 2648) or ReadText(1001, 2649) }, "steering")
	setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 4883), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight), C.GetSavesCompressedOption() and ReadText(1001, 2648) or ReadText(1001, 2649) }, "savecompression")
	
	setup:addHeaderRow({ Helper.emptyCellDescriptorSmall }, nil, {3})
	setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 2647), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) }, "default")
	local infodesc = setup:createCustomWidthTable({config.tableFirstColumnWidth, config.tableSecondColumn2Width + config.tableScrollbarWidth, config.tableThirdColumnWidth}, false, config.borderEnabled, 1, 1, config.offsetx, config.tableOffsety, config.tableHeight, menu.pretoprow, menu.preselectrow)
	menu.pretoprow = nil
	menu.preselectrow = nil

	-- create tableview
	menu.infotable = Helper.displayTableView(menu, infodesc, true, config.bgTexture, config.fgTexture, config.frameWidth, config.frameHeight, config.frameOffsetx, config.frameOffsety, "none")

	-- clear descriptors again
	Helper.releaseDescriptors()
end

function openPrivacyMenu()
	Helper.removeAllButtonScripts(menu)
	Helper.removeAllMenuScripts(menu)

	menu.title = "Privacy Menu"
	menu.textdbtitle = ReadText(1001, 4870)
	menu.selectedrow = 1

	local offset = config.headerEntryHeight + 5
	local overviewHeight = 100

	local setup = Helper.createTableSetup(menu)
	setup:addSimpleRow({
		Helper.createFontString(menu.textdbtitle, "left", 255, 255, 255, 100, config.headerEntryFont, config.headerEntrySize, false, config.headerEntryOffsetx, config.headerEntryOffsety, config.headerEntryHeight, 0)
	}, nil, nil, config.headerEntryBGColor)

	local titledesc = setup:createCustomWidthTable({ config.headerWidth }, false, config.borderEnabled, 0, 0, config.offsetx, config.tableOffsety)

	local setup = Helper.createTableSetup(menu)
	
	setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 4871), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight), GetCrashReportOption() and ReadText(1001, 2617) or ReadText(1001, 2618) }, "crashreport")
	if C.AllowPersonalizedData() then
		setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 4873), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight), GetPersonalizedCrashReportsOption() and ReadText(1001, 2617) or ReadText(1001, 2618) }, "senduserid")
	end
	
	local infodesc = setup:createCustomWidthTable({config.tableFirstColumnWidth, config.tableSecondColumn2Width, config.tableThirdColumnWidth}, false, config.borderEnabled, 1, 0, config.offsetx, config.tableOffsety + offset + overviewHeight + 5, config.tableHeight - offset - overviewHeight - 5, menu.pretoprow, menu.preselectrow)
	menu.pretoprow = nil
	menu.preselectrow = nil

	-- Overview table
	setup = Helper.createTableSetup(menu)
	
	setup:addSimpleRow({
		Helper.createFontString("", "left", 255, 255, 255, 100, config.tableEntryFont, 11, true, config.tableEntryOffsetx, config.tableEntryOffsety, overviewHeight, config.tableFirstColumnWidth + config.tableSecondColumn1Width + 5)
	}, nil, nil, config.headerEntryBGColor)

	local overviewdesc = setup:createCustomWidthTable({ config.tableFirstColumnWidth + config.tableSecondColumn1Width + 5 }, false, config.borderEnabled, 2, 0, config.offsetx, config.tableOffsety + offset, overviewHeight)

	-- create tableview
	menu.titletable, menu.infotable, menu.overviewtable = Helper.displayThreeTableView(menu, titledesc, infodesc, overviewdesc, true, config.bgTexture, config.fgTexture, config.frameWidth, config.frameHeight, config.frameOffsetx, config.frameOffsety, "none")

	-- clear descriptors again
	Helper.releaseDescriptors()
end

function openRumbleMenu()
	Helper.removeAllButtonScripts(menu)
	Helper.removeAllMenuScripts(menu)

	menu.title = "Rumble Menu"
	menu.textdbtitle = ReadText(1001, 2678)
	menu.selectedrow = 1

	local setup = Helper.createTableSetup(menu)
	setup:addSimpleRow({
		Helper.createFontString(menu.textdbtitle, "left", 255, 255, 255, 100, config.headerEntryFont, config.headerEntrySize, false, config.headerEntryOffsetx, config.headerEntryOffsety, config.headerEntryHeight, 0)
	}, nil, nil, config.headerEntryBGColor)
	local headerdesc = setup:createCustomWidthTable({config.headerWidth}, false, config.borderEnabled, 0, 0, config.offsetx, config.headerOffsety)

	-- collect slider value parameters
	local rumble = math.floor(GetRumbleOption() * 100)
	
	local sliderinfo = {
		["background"] = "tradesellbuy_blur",
		["captionCenter"] = ReadText(1001, 2678),
		["min"]= 0,
		["max"] = 100,
		["start"] = rumble
	}
	local scale1info = { 
		["left"] = 0,
		["right"] = nil,
		["center"] = false,
		["inverted"] = true,
		["suffix"] = nil
	}

	local sliderdesc = Helper.createSlider(sliderinfo, scale1info, nil, 1, config.offsetx, config.sliderOffsety)

	-- create tableview
	menu.headertable, menu.infotable = Helper.displaySliderTableView(menu, sliderdesc, headerdesc, true, config.bgTexture, config.fgTexture, config.frameWidth, config.frameHeight, config.frameOffsetx, config.frameOffsety, "none")

	-- clear descriptors again
	Helper.releaseDescriptors()
end

function openAimAssistMenu()
	Helper.removeAllButtonScripts(menu)
	Helper.removeAllMenuScripts(menu)

	menu.title = "Change Aim Assist"
	menu.textdbtitle = ReadText(1001, 2696)
	menu.selectedrow = 2

	local setup = Helper.createTableSetup(menu)
	setup:addSimpleRow({
		Helper.createFontString(menu.textdbtitle, "left", 255, 255, 255, 100, config.headerEntryFont, config.headerEntrySize, false, config.headerEntryOffsetx, config.headerEntryOffsety, config.headerEntryHeight, 0)
	}, nil, {2}, config.headerEntryBGColor)

	setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 2649), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) }, 0)
	setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 2648), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) }, 1)
	setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 2695), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) }, 2)
	local aimassist = GetAimAssistOption()
	menu.preselectrow = aimassist + 2
	local infodesc = setup:createCustomWidthTable({config.tableFirstColumnWidth, config.tableSecondColumn1Width}, false, config.borderEnabled, 1, 1, config.offsetx, config.tableOffsety, config.tableHeight, menu.pretoprow, menu.preselectrow)
	menu.pretoprow = nil
	menu.preselectrow = nil

	-- create tableview
	menu.infotable = Helper.displayTableView(menu, infodesc, true, config.bgTexture, config.fgTexture, config.frameWidth, config.frameHeight, config.frameOffsetx, config.frameOffsety, "none")

	-- clear descriptors again
	Helper.releaseDescriptors()
end

function openUIScaleMenu()
	Helper.removeAllButtonScripts(menu)
	Helper.removeAllMenuScripts(menu)

	menu.title = "UIScale Menu"
	menu.textdbtitle = ReadText(1001, 7209)
	menu.selectedrow = 1

	local setup = Helper.createTableSetup(menu)
	setup:addSimpleRow({
		Helper.createFontString(menu.textdbtitle, "left", 255, 255, 255, 100, config.headerEntryFont, config.headerEntrySize, false, config.headerEntryOffsetx, config.headerEntryOffsety, config.headerEntryHeight, 0)
	}, nil, nil, config.headerEntryBGColor)
	local headerdesc = setup:createCustomWidthTable({config.headerWidth}, false, config.borderEnabled, 0, 0, config.offsetx, config.headerOffsety)

	-- collect slider value parameters
	local uiscale = Helper.round(C.GetUIScale() * 10)
	
	local step = 1
	local factor = 0.1
	local minselect = 10
	local maxselect = 30
	local min = 10
	local max = 30
	local start = math.max(minselect, math.min(maxselect, uiscale))

	local sliderinfo = {
		["background"] = "solid", 
		["captionLeft"] = "", 
		["captionCenter"] = "", 
		["captionRight"] = "", 
		["min"] = min,
		["max"] = max,
		["minSelectable"] = minselect,
		["maxSelectable"] = maxselect,
		["zero"] = 0,
		["start"] = start,
		["granularity"] = step
	}
	local scale1info = { 
		["left"] = nil,
		["right"] = nil,
		["center"] = true,
		["factor"] = factor,
		["inverted"] = false,
		["roundingType"] = "none"
	}

	local sliderdesc = Helper.createSlider(sliderinfo, scale1info, nil, 1, config.offsetx, config.sliderOffsety)

	-- create tableview
	menu.headertable, menu.infotable = Helper.displaySliderTableView(menu, sliderdesc, headerdesc, true, config.bgTexture, config.fgTexture, config.frameWidth, config.frameHeight, config.frameOffsetx, config.frameOffsety, "none")

	-- clear descriptors again
	Helper.releaseDescriptors()
end

function openGamepadModeMenu()
	Helper.removeAllButtonScripts(menu)
	Helper.removeAllMenuScripts(menu)

	menu.title = "Change Gamepad Mode"
	menu.textdbtitle = ReadText(1001, 4867)
	menu.selectedrow = 2

	local setup = Helper.createTableSetup(menu)
	setup:addSimpleRow({
		Helper.createFontString(menu.textdbtitle, "left", 255, 255, 255, 100, config.headerEntryFont, config.headerEntrySize, false, config.headerEntryOffsetx, config.headerEntryOffsety, config.headerEntryHeight, 0)
	}, nil, {2}, config.headerEntryBGColor)

	setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 2649), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) }, 0)
	setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 4868), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) }, 1)
	setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 4869), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) }, 2)
	local gamepadnmode = GetGamepadModeOption()
	menu.preselectrow = gamepadnmode + 2
	local infodesc = setup:createCustomWidthTable({config.tableFirstColumnWidth, config.tableSecondColumn1Width}, false, config.borderEnabled, 1, 1, config.offsetx, config.tableOffsety, config.tableHeight, menu.pretoprow, menu.preselectrow)
	menu.pretoprow = nil
	menu.preselectrow = nil

	-- create tableview
	menu.infotable = Helper.displayTableView(menu, infodesc, true, config.bgTexture, config.fgTexture, config.frameWidth, config.frameHeight, config.frameOffsetx, config.frameOffsety, "none")

	-- clear descriptors again
	Helper.releaseDescriptors()
end

function openControlsMenu()
	Helper.removeAllButtonScripts(menu)
	Helper.removeAllMenuScripts(menu)


	menu.title = "Controls Menu"
	menu.textdbtitle = ReadText(1001, 2656)
	menu.selectedrow = 3

	local setup = Helper.createTableSetup(menu)
	setup:addSimpleRow({
		Helper.createFontString(menu.textdbtitle, "left", 255, 255, 255, 100, config.headerEntryFont, config.headerEntrySize, false, config.headerEntryOffsetx, config.headerEntryOffsety, config.headerEntryHeight, 0)
	}, nil, {3}, config.headerEntryBGColor)
	
	if CheckInputProfileRegression() then
		setup:addSimpleRow({
			Helper.createFontString(ReadText(1001, 4879), "left", 255, 255, 0, 100, config.tableEntryFont, 14, true, config.headerEntryOffsetx, config.headerEntryOffsety, 0, config.tableFirstColumnWidth + config.tableSecondColumn2Width + config.tableScrollbarWidth + config.tableThirdColumnWidth + 10)
		}, nil, {3}, config.headerEntryBGColor)
	else
		setup:addSimpleRow({ 
			Helper.createFontString("", "left", 255, 255, 0, 100, config.tableEntryFont, 14, false, config.headerEntryOffsetx, config.headerEntryOffsety, 25)
		}, nil, {3}, config.headerEntryBGColor)
	end
	
	menu.controls = { ["actions"] = GetInputActionMap(), ["states"] = GetInputStateMap(), ["ranges"] = GetInputRangeMap() }
	menu.controltextpage = { ["actions"] = 1005, ["states"] = 1006, ["ranges"] = 1007 }
	menu.forbiddenKeys = { [1] = true, [211] = true }
	menu.forbiddenMouseButtons = { [1] = true, [2] = true, [4] = true, [6] = true, [8] = true, [10] = true }
	menu.cheatControls = { ["actions"] = { [127] = true }, ["states"] = {}, ["ranges"] = {}, ["functions"] = {} }

	-- Define input functions here (serveral actions, states or ranges which can only be changed at the same time)
	-- entry: [keycode] = { ["actions"] = { action1, action2, ... }, ["states"] = {}, ["name"] = name for display }
	menu.controls["functions"] = { 
		[1] = { 
			["name"] = ReadText(1001, 2669), 
			["definingcontrol"] = {"actions", 16}, 
			["actions"] = { 1, 2, 14, 15, 16, 103, 134, 135, 138 }, 
			["states"] = {}, 
			["ranges"] = {} 
		},  
		[2] = { 
			["name"] = ReadText(1001, 2670), 
			["definingcontrol"] = {"actions", 19}, 
			["actions"] = { 1, 2, 14, 15, 19, 104, 134, 135, 138 }, 
			["states"] = {}, 
			["ranges"] = {} 
		},
		[3] = { 
			["name"] = ReadText(1001, 2671), 
			["definingcontrol"] = {"states", 22}, 
			["actions"] = { 124 }, 
			["states"] = { 1, 22, 23 }, 
			["ranges"] = {} 
		},
		[4] = { 
			["name"] = ReadText(1006, 12), 
			["definingcontrol"] = {"states", 12}, 
			["actions"] = { 133 }, 
			["states"] = { 12 }, 
			["ranges"] = {} 
		},
		[5] = { 
			["name"] = ReadText(1005, 128), 
			["definingcontrol"] = {"actions", 128}, 
			["actions"] = { 128, 163 }, 
			["states"] = {}, 
			["ranges"] = {},
			["contexts"]= { 1, 2 }
		},
		[6] = { 
			["name"] = ReadText(1005, 129), 
			["definingcontrol"] = {"actions", 129}, 
			["actions"] = { 129, 164 }, 
			["states"] = {}, 
			["ranges"] = {},
			["contexts"]= { 1, 2 } 
		},
		[7] = { 
			["name"] = ReadText(1006, 10), 
			["definingcontrol"] = {"states", 10}, 
			["actions"] = { 187, 218 }, 
			["states"] = { 10 }, 
			["ranges"] = {} 
		},
		[8] = { 
			["name"] = ReadText(1006, 11), 
			["definingcontrol"] = {"states", 11}, 
			["actions"] = { 186, 217 }, 
			["states"] = { 11 }, 
			["ranges"] = {} 
		},
		[9] = { 
			["name"] = ReadText(1005, 179), 
			["definingcontrol"] = {"actions", 179}, 
			["actions"] = { 179, 208 }, 
			["states"] = {}, 
			["ranges"] = {},
			["contexts"]= { 1, 2 } 
		},
		[10] = { 
			["name"] = ReadText(1005, 175), 
			["definingcontrol"] = {"actions", 175}, 
			["actions"] = { 175, 211 }, 
			["states"] = {}, 
			["ranges"] = {} 
		},
		[11] = { 
			["name"] = ReadText(1005, 114), 
			["definingcontrol"] = {"actions", 114}, 
			["actions"] = { 114, 212 }, 
			["states"] = {}, 
			["ranges"] = {},
			["contexts"]= { 1, 2 } 
		},
		[12] = {
			["name"] = ReadText(1005, 180),
			["definingcontrol"] = {"actions", 180},
			["actions"] = { 180, 231 },
			["states"] = {},
			["ranges"] = {}
		},
		[13] = {
			["name"] = ReadText(1005, 182),
			["definingcontrol"] = {"actions", 182},
			["actions"] = { 182, 232 },
			["states"] = {},
			["ranges"] = {}
		}
	}

	setup:addHeaderRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 2656), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) }, nil, {1, 2})
	setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 2658), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) }, "keyboard_space", {1, 2})
	setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 2659), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) }, "keyboard_firstperson", {1, 2})
	setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 2660), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) }, "keyboard_menus", {1, 2})
	setup:addHeaderRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 2674), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) }, nil, {1, 2})
	setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 2675), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) }, "joystick_invert", {1, 2})
	setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 2684), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) }, "joystick_sensitivity", {1, 2})
	setup:addSelectRow({ 
		Helper.emptyCellDescriptor, 
		Helper.createFontString(ReadText(1001, 4856), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight)  
	}, "joysticks", {1, 2})
	--[[
	setup:addSelectRow({ 
		Helper.emptyCellDescriptor, 
		Helper.createFontString(ReadText(1001, 2674) .. " II", "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight), 
		Helper.createFontString(secondaryjoystick and secondaryjoystick.name or ReadText(1001, 2672), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) 
	}, "joystick_2") --]]
	setup:addSelectRow({ 
		Helper.emptyCellDescriptor, 
		Helper.createFontString(ReadText(1001, 4835), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight), 
		Helper.createFontString(GetDeadzoneOption() .. " %", "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight)
	}, "joystick_deadzone")
	local gamepadmodeoption = GetGamepadModeOption()
	local gamepadmodeoptiontext = ""
	if gamepadmodeoption == 0 then
		gamepadmodeoptiontext = ReadText(1001, 2649)
	elseif gamepadmodeoption == 2 then
		gamepadmodeoptiontext = ReadText(1001, 4869)
	else
		gamepadmodeoptiontext = ReadText(1001, 4868)
	end
	setup:addSelectRow({ 
		Helper.emptyCellDescriptor, 
		Helper.createFontString(ReadText(1001, 4867), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight), 
		Helper.createFontString(gamepadmodeoptiontext, "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight)
	}, "gamepadmode")
	setup:addHeaderRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 2683), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) }, nil, {1, 2})
	setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 2675), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) }, "mouse_invert", {1, 2})
	setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 2684), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) }, "mouse_sensitivity", {1, 2})
	setup:addSelectRow({ 
		Helper.emptyCellDescriptor, 
		Helper.createFontString(ReadText(1001, 4820), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight), 
		Helper.createFontString(GetConfineMouseOption() and ReadText(1001, 2648) or ReadText(1001, 2649), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight)
	}, "mouse_capture")
	setup:addHeaderRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 4857), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) }, nil, {1, 2})
	setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 4859), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) }, "loadinputprofile", {1, 2})
	setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 4858), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) }, "saveinputprofile", {1, 2})
	setup:addSelectRow({ Helper.emptyCellDescriptor, Helper.createFontString(ReadText(1001, 4862), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) }, "renameinputprofile", {1, 2})

	local infodesc = setup:createCustomWidthTable({config.tableFirstColumnWidth, config.tableSecondColumn2Width + config.tableScrollbarWidth, config.tableThirdColumnWidth}, false, config.borderEnabled, 1, 2, config.offsetx, config.tableOffsety, config.tableHeight, menu.pretoprow, menu.preselectrow)
	menu.pretoprow = nil
	menu.preselectrow = nil

	-- create tableview
	menu.infotable = Helper.displayTableView(menu, infodesc, true, config.bgTexture, config.fgTexture, config.frameWidth, config.frameHeight, config.frameOffsetx, config.frameOffsety, "none")

	-- clear descriptors again
	Helper.releaseDescriptors()
end

function openJoystickSetupMenu()
	Helper.removeAllButtonScripts(menu)
	Helper.removeAllMenuScripts(menu)

	menu.title = "Joystick Setup Menu"
	menu.textdbtitle = ReadText(1001, 2674)
	menu.selectedrow = 2

	local setup = Helper.createTableSetup(menu)
	setup:addSimpleRow({
		Helper.createFontString(menu.textdbtitle, "left", 255, 255, 255, 100, config.headerEntryFont, config.headerEntrySize, false, config.headerEntryOffsetx, config.headerEntryOffsety, config.headerEntryHeight, 0)
	}, nil, {2}, config.headerEntryBGColor)
	
	local joysticks = GetJoysticksOption()
	local mappedjoysticks = GetMappedJoysticks()
	for i, joystick in ipairs(mappedjoysticks) do
		if joystick <= 8 then
			local joystickdata = joysticks[joystick]
			setup:addSelectRow({ 
				Helper.emptyCellDescriptor, 
				Helper.createFontString(joystickdata.name, "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight)
			}, i)
		else
			setup:addSelectRow({ 
				Helper.emptyCellDescriptor, 
				Helper.createFontString(ReadText(1001, 4812), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight)
			}, i)
		end
	end

	local infodesc = setup:createCustomWidthTable({config.tableFirstColumnWidth, config.tableSecondColumn1Width}, false, config.borderEnabled, 1, 1, config.offsetx, config.tableOffsety, config.tableHeight, menu.pretoprow, menu.preselectrow)
	menu.pretoprow = nil
	menu.preselectrow = nil

	-- create tableview
	menu.infotable = Helper.displayTableView(menu, infodesc, true, config.bgTexture, config.fgTexture, config.frameWidth, config.frameHeight, config.frameOffsetx, config.frameOffsety, "none")

	-- clear descriptors again
	Helper.releaseDescriptors()
end

function menu.getInputName(source, code, signum)
	local signumstr = ""
	if signum == 1 then
		signumstr = " (+)"
	elseif signum == -1 then
		signumstr = " (-)"
	end
	if source == 1 then
		return GetLocalizedRawKeyName(code)
	elseif source >= 2 and source <= 9 then
		if IsGamepadActive() then
			return ReadText(1008, code) .. ((code ~= 3 and code ~= 6) and signumstr or "") .. (source > 2 and (" (" .. source - 1 .. ")") or "")
		else
			return ReadText(1017, code) .. signumstr .. (source > 2 and (" (" .. source - 1 .. ")") or "")
		end
	elseif source >= 10 and source <= 17 then
		if IsGamepadActive() then
			return string.format(ReadText(1001, 2673), ReadText(1009, code)) .. (source > 10 and (" (" .. source - 9 .. ")") or "")
		else
			return ReadText(1022, code) .. (source > 10 and (" (" .. source - 9 .. ")") or "")
		end
	elseif source == 18 then
		return ReadText(1018, code) .. signumstr
	elseif source == 19 then
		return ReadText(1019, code)
	else
		DebugError("unknown input source '".. source .. "' - this should never happen [Florian]")
		return ""
	end
end

function menu.displayControl(setup, controlsgroup, controltype, code, mapable, mouseovertext)
	if controltype == "functions" then
		local definingcontrol = menu.controls[controltype][code].definingcontrol
		local inputs = menu.controls[definingcontrol[1]][definingcontrol[2]]
		local displayed = 0
		local buttons = {}
		if type(inputs) == "table" then
			for _, input in ipairs(inputs) do
				local keyname = menu.getInputName(input[1], input[2], input[3])
				if keyname ~= "" then
					displayed = displayed + 1
					if (not mapable) and (input[1] == 1) then
						if displayed == 1 then
							buttons[displayed] = {keyname = keyname, notmapable = true}
						else
							buttons[displayed] = buttons[1]
							buttons[1] = {keyname = keyname, notmapable = true}
						end
						mapable = true
					else
						buttons[displayed] = {keyname = keyname}
					end
				end
			end
		end
			
		for i = 1, (next(buttons) and #buttons or 1), 2 do
			menu.nooflines = menu.nooflines + 1
			if menu.nooflines == menu.preselectrow then
				if menu.preselectcol == 3 then
					if buttons[i] and (buttons[i].notmapable ~= nil) then
						menu.preselectcol = nil
					end
				end
				if menu.preselectcol == 4 then
					if buttons[i+1] and (buttons[i+1].notmapable ~= nil) then
						menu.preselectcol = nil
					end
				end
			end
			setup:addSelectRow({ 
				Helper.emptyCellDescriptor, 
				Helper.createFontString(menu.controls[controltype][code].name, "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight, nil, mouseovertext), 
				(buttons[i] and (buttons[i].notmapable ~= nil)) and 
					Helper.createFontString(buttons[i] and buttons[i].keyname or ReadText(1001, 2672), "left", 255, buttons[i] and 255 or 0, buttons[i] and 255 or 0, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) or 
					Helper.createButton(Helper.createButtonText(buttons[i] and buttons[i].keyname or ReadText(1001, 2672), "left", config.tableEntryFont, config.tableEntrySize, 255, buttons[i] and 255 or 0, buttons[i] and 255 or 0, 100), nil, true, 0, 0, 0, 0, nil, nil),
				(buttons[i+1] and (buttons[i+1].notmapable ~= nil)) and 
					Helper.createFontString(buttons[i+1] and buttons[i+1].keyname or ReadText(1001, 2672), "left", 255, buttons[i+1] and 255 or 0, buttons[i+1] and 255 or 0, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) or
					Helper.createButton(Helper.createButtonText(buttons[i+1] and buttons[i+1].keyname or ReadText(1001, 2672), "left", config.tableEntryFont, config.tableEntrySize, 255, buttons[i+1] and 255 or 0, buttons[i+1] and 255 or 0, 100), nil, true, 0, 0, 0, 0, nil, nil)
			})
		end
	else
		local displayed = 0
		local buttons = {}
		if type(menu.controls[controltype][code]) == "table" then
			for _, input in ipairs(menu.controls[controltype][code]) do
				local keyname = menu.getInputName(input[1], input[2], input[3])
				if keyname ~= "" then
					displayed = displayed + 1
					if (not mapable) and (input[1] == 1) then
						if displayed == 1 then
							buttons[displayed] = {keyname = keyname, notmapable = true}
						else
							buttons[displayed] = buttons[1]
							buttons[1] = {keyname = keyname, notmapable = true}
						end
						mapable = true
					else
						buttons[displayed] = {keyname = keyname}
					end
				end
			end
		end

		for i = 1, (next(buttons) and #buttons or 1), 2 do
			menu.nooflines = menu.nooflines + 1
			if menu.nooflines == menu.preselectrow then
				if menu.preselectcol == 3 then
					if buttons[i] and (buttons[i].notmapable ~= nil) then
						menu.preselectcol = nil
					end
				end
				if menu.preselectcol == 4 then
					if buttons[i+1] and (buttons[i+1].notmapable ~= nil) then
						menu.preselectcol = nil
					end
				end
			end
			setup:addSelectRow({ 
				Helper.emptyCellDescriptor, 
				Helper.createFontString(ReadText(menu.controltextpage[controltype], code), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight, nil, mouseovertext), 
				(buttons[i] and (buttons[i].notmapable ~= nil)) and 
					Helper.createFontString(buttons[i] and buttons[i].keyname or ReadText(1001, 2672), "left", 255, buttons[i] and 255 or 0, buttons[i] and 255 or 0, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) or 
					Helper.createButton(Helper.createButtonText(buttons[i] and buttons[i].keyname or ReadText(1001, 2672), "left", config.tableEntryFont, config.tableEntrySize, 255, buttons[i] and 255 or 0, buttons[i] and 255 or 0, 100), nil, true, 0, 0, 0, 0, nil, nil),
				(buttons[i+1] and (buttons[i+1].notmapable ~= nil)) and 
					Helper.createFontString(buttons[i+1] and buttons[i+1].keyname or ReadText(1001, 2672), "left", 255, buttons[i+1] and 255 or 0, buttons[i+1] and 255 or 0, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) or
					Helper.createButton(Helper.createButtonText(buttons[i+1] and buttons[i+1].keyname or ReadText(1001, 2672), "left", config.tableEntryFont, config.tableEntrySize, 255, buttons[i+1] and 255 or 0, buttons[i+1] and 255 or 0, 100), nil, true, 0, 0, 0, 0, nil, nil)
			})
		end
	end
end

function menu.displayControlScript(controlsgroup, controltype, code, context, mapable)
	if controltype == "functions" then
		local definingcontrol = menu.controls[controltype][code].definingcontrol
		local inputs = menu.controls[definingcontrol[1]][definingcontrol[2]]
		local nokeyboard = not mapable
		local displayed = 0
		local buttons = {}
		if type(inputs) == "table" then
			for _, input in ipairs(inputs) do
				local keyname = menu.getInputName(input[1], input[2], input[3])
				if keyname ~= "" then
					displayed = displayed + 1
					if (not mapable) and (input[1] == 1) then
						if displayed == 1 then
							buttons[displayed] = {input1 = input[1], input2 = input[2], input3 = input[3], notmapable = true}
						else
							buttons[displayed] = buttons[1]
							buttons[1] = {input1 = input[1], input2 = input[2], input3 = input[3], notmapable = true}
						end
						mapable = true
					else
						buttons[displayed] = {input1 = input[1], input2 = input[2], input3 = input[3]}
					end
				end
			end
		end

		for i = 1, (next(buttons) and #buttons or 1), 2 do
			local row = menu.nooflines + 1
			if buttons[i] then
				if not buttons[i].notmapable then
					Helper.setButtonScript(menu, menu.infotable, row, 3, function () return menu.buttonScript(row, {controltype, code, buttons[i].input1, buttons[i].input2, buttons[i].input3, 3, nokeyboard, context}) end)
				end
			else
				Helper.setButtonScript(menu, menu.infotable, row, 3, function () return menu.buttonScript(row, {controltype, code, -1, -1, 0, 3, nokeyboard, context}) end)
			end
			if buttons[i+1] then
				if not buttons[i+1].notmapable then
					Helper.setButtonScript(menu, menu.infotable, row, 4, function () return menu.buttonScript(row, {controltype, code, buttons[i+1].input1, buttons[i+1].input2, buttons[i+1].input3, 4, nokeyboard, context}) end)
				end
			else
				Helper.setButtonScript(menu, menu.infotable, row, 4, function () return menu.buttonScript(row, {controltype, code, -1, -1, 0, 4, nokeyboard, context}) end)
			end
			menu.nooflines = menu.nooflines + 1
		end
	else
		local nokeyboard = not mapable
		local displayed = 0
		local buttons = {}
		if type(menu.controls[controltype][code]) == "table" then
			for _, input in ipairs(menu.controls[controltype][code]) do
				local keyname = menu.getInputName(input[1], input[2], input[3])
				if keyname ~= "" then
					displayed = displayed + 1
					if (not mapable) and (input[1] == 1) then
						if displayed == 1 then
							buttons[displayed] = {input1 = input[1], input2 = input[2], input3 = input[3], notmapable = true}
						else
							buttons[displayed] = buttons[1]
							buttons[1] = {input1 = input[1], input2 = input[2], input3 = input[3], notmapable = true}
						end
						mapable = true
					else
						buttons[displayed] = {input1 = input[1], input2 = input[2], input3 = input[3]}
					end
				end
			end
		end
			
		for i = 1, (next(buttons) and #buttons or 1), 2 do
			local row = menu.nooflines + 1
			if buttons[i] then
				if not buttons[i].notmapable then
					Helper.setButtonScript(menu, menu.infotable, row, 3, function () return menu.buttonScript(row, {controltype, code, buttons[i].input1, buttons[i].input2, buttons[i].input3, 3, nokeyboard, context}) end)
				end
			else
				Helper.setButtonScript(menu, menu.infotable, row, 3, function () return menu.buttonScript(row, {controltype, code, -1, -1, 0, 3, nokeyboard, context}) end)
			end
			if buttons[i+1] then
				if not buttons[i+1].notmapable then
					Helper.setButtonScript(menu, menu.infotable, row, 4, function () return menu.buttonScript(row, {controltype, code, buttons[i+1].input1, buttons[i+1].input2, buttons[i+1].input3, 4, nokeyboard, context}) end)
				end
			else
				Helper.setButtonScript(menu, menu.infotable, row, 4, function () return menu.buttonScript(row, {controltype, code, -1, -1, 0, 4, nokeyboard, context}) end)
			end
			menu.nooflines = menu.nooflines + 1
		end
	end
end

function openControlsSetupMenu(context)
	Helper.removeAllButtonScripts(menu)
	Helper.removeAllMenuScripts(menu)
	menu.rowDataMap = {}
	
	menu.title = "Controls Setup Menu"
	if context == "keyboard_space" then
		menu.textdbtitle = ReadText(1001, 2656) .. ReadText(1001, 120) .. " " ..ReadText(1001, 2658)
	elseif context == "keyboard_menus" then
		menu.textdbtitle = ReadText(1001, 2656) .. ReadText(1001, 120) .. " " ..ReadText(1001, 2660)
	elseif context == "keyboard_firstperson" then
		menu.textdbtitle = ReadText(1001, 2656) .. ReadText(1001, 120) .. " " ..ReadText(1001, 2659)
	end
	menu.selectedrow = 2
	menu.controlcontext = context

	local ischeatversion = IsCheatVersion()

	local setup = Helper.createTableSetup(menu)
	setup:addSimpleRow({
		Helper.createFontString(menu.textdbtitle, "left", 255, 255, 255, 100, config.headerEntryFont, config.headerEntrySize, false, config.headerEntryOffsetx, config.headerEntryOffsety, config.headerEntryHeight, 0)
	}, nil, {4}, config.headerEntryBGColor)
	
	if context == "keyboard_space" then
		menu.controlsorder = { 
			[1] = {
				["title"] = ReadText(1001, 4865),
				["mapable"] = true,
				{ "ranges", 1 },
				{ "ranges", 2 },
				{ "ranges", 3 },
				{ "ranges", 5 },
				{ "ranges", 6 },
				{ "ranges", 4 }
			},
			[2] = {
				["title"] = ReadText(1001, 4866),
				["mapable"] = true,
				{ "states", 4 },
				{ "states", 5 },
				{ "states", 2 },
				{ "states", 3 },
				{ "states", 8 },
				{ "states", 9 },
				{ "states", 6 },
				{ "states", 7 },
				{ "states", 13 },
				{ "states", 14 },
				{ "states", 15 },
				{ "states", 16 },
				{ "actions", 123 },
				{ "states", 17 },
				{ "states", 18 },
				{ "states", 19 },
				{ "actions", 7, nil, ReadText(1026, 2600) },
				{ "actions", 221, nil, ReadText(1026, 2601) }
			},
			[3] = {
				["title"] = ReadText(1001, 2663),
				["mapable"] = true,
				{ "states", 24 },
				{ "states", 48 },
				{ "states", 25 },
				{ "actions", 8 },
				{ "actions", 9 },
				{ "actions", 10 },
				{ "actions", 11 }
			},
			[4] = { 
				["title"] = ReadText(1001, 2660),
				["mapable"] = true,
				{ "actions", 115 },
				{ "actions", 113 },
				{ "functions", 11 },
				{ "actions", 159 },
				{ "actions", 228 },
				{ "actions", 209 },
				{ "actions", 210 },
				{ "functions", 3 },
				{ "functions", 5, nil, ReadText(1026, 2602) },
				{ "functions", 6, nil, ReadText(1026, 2603) },
				{ "actions", 216, 2 }
			},
			[5] = {
				["title"] = ReadText(1001, 2667),
				["mapable"] = true,
				{ "states", 21 }
			},
			[6] = { 
				["title"] = ReadText(1001, 2600),
				["mapable"] = true,
				{ "actions", 132 },
				{ "actions", 160 },
				{ "actions", 161 },
				{ "actions", 162 },
				{ "actions", 130 },
				{ "actions", 131 }
			},
			[7] = { 
				["title"] = ReadText(1001, 4860),
				["mapable"] = true,
				{ "states", 81 },
				{ "functions", 12, nil, ReadText(1026, 2605) },
				{ "actions", 181, nil, ReadText(1026, 2606) },
				{ "functions", 13, nil, ReadText(1026, 2607) },
				{ "states", 70 },
				{ "states", 71 },
				{ "states", 72 },
				{ "states", 73 },
				{ "states", 74 },
				{ "states", 75 },
				{ "states", 76 },
				{ "states", 77 },
				{ "states", 78 },
				{ "states", 79 },
				{ "actions", 183 },
				{ "actions", 184 }
			},
			[8] = { 
				["title"] = ReadText(1001, 2664),
				["mapable"] = true,
				{ "functions", 10 },
				{ "actions", 167 },
				{ "actions", 168, nil, ReadText(1026, 2604) },
				{ "actions", 169 },
				{ "actions", 170 },
				{ "actions", 213 },
				{ "actions", 214 },
				{ "actions", 177, nil, ReadText(1026, 2608) },
				{ "actions", 178, nil, ReadText(1026, 2609) },
				{ "functions", 9 },
				{ "actions", 225, nil, ReadText(1026, 2610) },
				{ "actions", 223, nil, ReadText(1026, 2611) },
				{ "actions", 117 },
				{ "actions", 120 },
				{ "actions", 219 },
				{ "states", 80, nil, ReadText(1026, 2612) }
			},
			[9] = { 
				["title"] = ReadText(1001, 2664) .. " II",
				["mapable"] = false,
				{ "functions", 1 },
				{ "functions", 2 }
			},
			[10] = {
				["title"] = ReadText(1001, 4815),
				["mapable"] = true,
				{ "actions", 96 },
				{ "actions", 137 },
				{ "actions", 121 },
				{ "actions", 166 },
				{ "actions", 127, 2 },
				{ "actions", 224 }
			}
		}
		if C.IsVRVersion() then
			table.insert(menu.controlsorder[7], { "actions", 260 })
		end
	elseif context == "keyboard_menus" then
		menu.controlsorder = { 
			[1] = {
				["title"] = ReadText(1001, 2665),
				["mapable"] = false,
				{ "actions", 21 },
				{ "actions", 20 },
				{ "functions", 7 },
				{ "functions", 8 },
				{ "functions", 4 },
				{ "actions", 18 },
				{ "actions", 17 },
				{ "actions", 22 }
			},
			[2] = {
				["title"] = ReadText(1001, 2666),
				["mapable"] = false,
				{ "states", 1 },
				{ "actions", 97 },
				{ "actions", 98 },
				{ "actions", 99 },
				{ "actions", 100 },
				{ "actions", 101 },
				{ "actions", 102 },
				{ "actions", 198 },
				{ "actions", 199 },
				{ "actions", 200 },
				{ "actions", 201 },
				{ "actions", 202 },
				{ "actions", 203 }
			},
			[3] = {
				["title"] = ReadText(1001, 2671),
				["mapable"] = false,
				{ "actions", 204 },
				{ "actions", 205 },
				{ "actions", 206 },
				{ "actions", 207 }
			},
			[4] = {
				["title"] = ReadText(1001, 2667),
				["mapable"] = false,
				{ "actions", 105 },
				{ "actions", 106 },
				{ "actions", 107 },
				{ "actions", 108 },
				{ "actions", 109 },
				{ "actions", 110 },
				{ "actions", 111 },
				{ "actions", 112 }
			},
			[5] = {
				["title"] = ReadText(1001, 2664),
				["mapable"] = false,
				{ "ranges", 11 },
				{ "ranges", 12 }
			}
		}
	elseif context == "keyboard_firstperson" then
		menu.controlsorder = { 
			[1] = {
				["title"] = ReadText(1001, 4877),
				["mapable"] = true,
				{ "ranges", 15 },
				{ "ranges", 16 },
				{ "ranges", 13 },
				{ "ranges", 14 }
			},
			[2] = {
				["title"] = ReadText(1001, 4878),
				["mapable"] = true,
				{ "states", 26 },
				{ "states", 27 },
				{ "states", 32 },
				{ "states", 33 },
				{ "states", 30 },
				{ "states", 31 },
				{ "states", 28 },
				{ "states", 29 },
				{ "states", 34 },
				{ "states", 35 },
				{ "states", 36 },
				{ "actions", 220 }
			}
		}
	end

	menu.nooflines = 1
	for i, controls in ipairs(menu.controlsorder) do
		menu.nooflines = menu.nooflines + 1
		setup:addHeaderRow({ Helper.emptyCellDescriptor, Helper.createFontString(controls.title, "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) }, nil, {1, 3})
		for _, control in ipairs(controls) do
			if ischeatversion or (not menu.cheatControls[control[1]][control[2]]) then
				menu.displayControl(setup, i, control[1], control[2], controls.mapable, control[4])
			end
		end
	end

	local infodesc = setup:createCustomWidthTable({config.tableFirstColumnWidth, config.tableSecondColumn3Width + (menu.nooflines > 10 and config.tableScrollbarWidth or 0), config.tableThirdColumn2Width, config.tableFourthColumnWidth}, false, config.borderEnabled, 1, 1, config.offsetx, config.tableOffsety, config.tableHeight, menu.pretoprow, menu.preselectrow, menu.preselectcol)
	menu.nooflines = nil
	menu.pretoprow = nil
	menu.preselectrow = nil
	menu.preselectcol = nil

	-- create tableview
	menu.infotable = Helper.displayTableView(menu, infodesc, true, config.bgTexture, config.fgTexture, config.frameWidth, config.frameHeight, config.frameOffsetx, config.frameOffsety, "none")

	-- button scripts
	menu.nooflines = 1
	for i, controls in ipairs(menu.controlsorder) do
		menu.nooflines = menu.nooflines + 1
		for _, control in ipairs(controls) do
			if ischeatversion or (not menu.cheatControls[control[1]][control[2]]) then
				local context
				if control[1] == "functions" then
					context = menu.controls[control[1]][control[2]].contexts
				else
					context = control[3]
				end
				menu.displayControlScript(i, control[1], control[2], context, controls.mapable)
			end
		end
	end
	menu.nooflines = nil

	-- clear descriptors again
	Helper.releaseDescriptors()
end

function openInvertAxesMenu(context)
	Helper.removeAllButtonScripts(menu)
	Helper.removeAllMenuScripts(menu)

	menu.title = "Invert Axes Menu"
	if context == "joystick_invert" then
		menu.textdbtitle = ReadText(1001, 2674) .. ReadText(1001, 120) .. " " .. ReadText(1001, 2675)
	elseif context == "mouse_invert" then
		menu.textdbtitle = ReadText(1001, 2683) .. ReadText(1001, 120) .. " " .. ReadText(1001, 2675)
	end
	menu.selectedrow = 2
	menu.controlcontext = context

	local setup = Helper.createTableSetup(menu)
	setup:addSimpleRow({
		Helper.createFontString(menu.textdbtitle, "left", 255, 255, 255, 100, config.headerEntryFont, config.headerEntrySize, false, config.headerEntryOffsetx, config.headerEntryOffsety, config.headerEntryHeight, 0)
	}, nil, {3}, config.headerEntryBGColor)

	local ranges 
	if context == "joystick_invert" then
		ranges = {
			{ "ranges", 1, "invert_steering_yaw"},
			{ "ranges", 2, "invert_steering_pitch" },
			{ "ranges", 3, "invert_steering_roll" },
			{ "ranges", 4, "invert_throttle" },
			{ "ranges", 5, "invert_strafe_left_right" },
			{ "ranges", 6, "invert_strafe_up_down" },
			{ "ranges", 13, "invert_fp_yaw" },
			{ "ranges", 14, "invert_fp_pitch" },
			{ "ranges", 15, "invert_fp_walk" },
			{ "ranges", 16, "invert_fp_strafe" }
		}
	elseif context == "mouse_invert" then
		ranges = {
			{ "ranges", 7, "invert_fp_mouse_yaw"},
			{ "ranges", 8, "invert_fp_mouse_pitch" },
		}
	end

	for _, range in ipairs(ranges) do
		setup:addSelectRow({ 
			Helper.emptyCellDescriptor, 
			Helper.createFontString(ReadText(menu.controltextpage[range[1]], range[2]), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight), 
			Helper.createFontString(GetInversionSetting(range[2]) and ReadText(1001, 2676) or ReadText(1001, 2677), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) 
		}, {range[2], range[3]})
	end

	local infodesc = setup:createCustomWidthTable({config.tableFirstColumnWidth, config.tableSecondColumn2Width, config.tableThirdColumnWidth}, false, config.borderEnabled, 1, 1, config.offsetx, config.tableOffsety, config.tableHeight, menu.pretoprow, menu.preselectrow)
	menu.pretoprow = nil
	menu.preselectrow = nil

	-- create tableview
	menu.infotable = Helper.displayTableView(menu, infodesc, true, config.bgTexture, config.fgTexture, config.frameWidth, config.frameHeight, config.frameOffsetx, config.frameOffsety, "none")

	-- clear descriptors again
	Helper.releaseDescriptors()
end

function openSensitivityMenu(context)
	Helper.removeAllButtonScripts(menu)
	Helper.removeAllMenuScripts(menu)

	menu.title = "Sensitivity Menu"
	if context == "joystick_sensitivity" then
		menu.textdbtitle = ReadText(1001, 2674) .. ReadText(1001, 120) .. " " .. ReadText(1001, 2684)
	elseif context == "mouse_sensitivity" then
		menu.textdbtitle = ReadText(1001, 2683) .. ReadText(1001, 120) .. " " .. ReadText(1001, 2684)
	end
	menu.selectedrow = 2
	menu.controlcontext = context

	local setup = Helper.createTableSetup(menu)
	setup:addSimpleRow({
		Helper.createFontString(menu.textdbtitle, "left", 255, 255, 255, 100, config.headerEntryFont, config.headerEntrySize, false, config.headerEntryOffsetx, config.headerEntryOffsety, config.headerEntryHeight, 0)
	}, nil, {3}, config.headerEntryBGColor)

	local ranges 
	if context == "joystick_sensitivity" then
		ranges = {
			{ "ranges", 13, "sensitivity_fp_yaw" },
			{ "ranges", 14, "sensitivity_fp_pitch" }
		}
	elseif context == "mouse_sensitivity" then
		ranges = {
			{ "ranges", 7, "sensitivity_fp_mouse_yaw"},
			{ "ranges", 8, "sensitivity_fp_mouse_pitch" },
		}
	end

	for i, range in ipairs(ranges) do
		setup:addSelectRow({ 
			Helper.emptyCellDescriptor, 
			Helper.createFontString(ReadText(menu.controltextpage[range[1]], range[2]), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight), 
			Helper.createFontString(Helper.round(GetSensitivitySetting(range[2]) * 100), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight) 
		}, {range[2], range[3], context, i + 1, i >= config.maxTableRowWithoutScrollbar and i - config.maxTableRowWithoutScrollbar + 2 or nil })
	end

	local infodesc = setup:createCustomWidthTable({config.tableFirstColumnWidth, config.tableSecondColumn2Width, config.tableThirdColumnWidth}, false, config.borderEnabled, 1, 1, config.offsetx, config.tableOffsety, config.tableHeight, menu.pretoprow, menu.preselectrow)
	menu.pretoprow = nil
	menu.preselectrow = nil

	-- create tableview
	menu.infotable = Helper.displayTableView(menu, infodesc, true, config.bgTexture, config.fgTexture, config.frameWidth, config.frameHeight, config.frameOffsetx, config.frameOffsety, "none")

	-- clear descriptors again
	Helper.releaseDescriptors()
end

function openSensitivitySliderMenu(context)
	Helper.removeAllButtonScripts(menu)
	Helper.removeAllMenuScripts(menu)

	menu.title = "Sensitivity Slider Menu"
	menu.textdbtitle = ReadText(1001, 2684)
	menu.selectedrow = 1
	menu.controlcontext = context

	local setup = Helper.createTableSetup(menu)
	setup:addSimpleRow({
		Helper.createFontString(menu.textdbtitle, "left", 255, 255, 255, 100, config.headerEntryFont, config.headerEntrySize, false, config.headerEntryOffsetx, config.headerEntryOffsety, config.headerEntryHeight, 0)
	}, nil, nil, config.headerEntryBGColor)
	local headerdesc = setup:createCustomWidthTable({config.headerWidth}, false, config.borderEnabled, 0, 0, config.offsetx, config.headerOffsety)

	-- collect slider value parameters
	local sensitivity = Helper.round(GetSensitivitySetting(context[1]) * 100)
	
	local sliderinfo = {
		["background"] = "tradesellbuy_blur",
		["captionCenter"] = ReadText(1001, 2684),
		["min"]= 0,
		["minSelectable"]= 10,
		["max"] = 100,
		["start"] = sensitivity
	}
	local scale1info = { 
		["left"] = 0,
		["right"] = nil,
		["center"] = false,
		["inverted"] = true,
		["suffix"] = nil
	}

	local sliderdesc = Helper.createSlider(sliderinfo, scale1info, nil, 1, config.offsetx, config.sliderOffsety)

	-- create tableview
	menu.headertable, menu.infotable = Helper.displaySliderTableView(menu, sliderdesc, headerdesc, true, config.bgTexture, config.fgTexture, config.frameWidth, config.frameHeight, config.frameOffsetx, config.frameOffsety, "none")

	-- clear descriptors again
	Helper.releaseDescriptors()
end

function openJoystickMenu(context)
	Helper.removeAllButtonScripts(menu)
	Helper.removeAllMenuScripts(menu)

	menu.title = "Joystick Menu"
	menu.textdbtitle = ReadText(1001, 2674)
	menu.selectedrow = 2
	menu.controlcontext = context

	local setup = Helper.createTableSetup(menu)
	setup:addSimpleRow({
		Helper.createFontString(menu.textdbtitle, "left", 255, 255, 255, 100, config.headerEntryFont, config.headerEntrySize, false, config.headerEntryOffsetx, config.headerEntryOffsety, config.headerEntryHeight, 0)
	}, nil, {2}, config.headerEntryBGColor)
	
	local joysticks = GetJoysticksOption()
	for _, joystick in ipairs(joysticks) do
		setup:addSelectRow({ 
			Helper.emptyCellDescriptor, 
			Helper.createFontString(joystick.name, "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight)
		}, joystick.guid)
	end
	setup:addHeaderRow({ Helper.emptyCellDescriptorSmall }, nil, {2})
	setup:addSelectRow({ 
		Helper.emptyCellDescriptor, 
		Helper.createFontString(ReadText(1001, 5706), "left", 255, 255, 255, 100, config.tableEntryFont, config.tableEntrySize, false, config.tableEntryOffsetx, config.tableEntryOffsety, config.arrowiconHeight)
	}, "")

	local infodesc = setup:createCustomWidthTable({config.tableFirstColumnWidth, config.tableSecondColumn1Width}, false, config.borderEnabled, 1, 1, config.offsetx, config.tableOffsety, config.tableHeight, menu.pretoprow, menu.preselectrow)
	menu.pretoprow = nil
	menu.preselectrow = nil
	
	-- create tableview
	menu.infotable = Helper.displayTableView(menu, infodesc, true, config.bgTexture, config.fgTexture, config.frameWidth, config.frameHeight, config.frameOffsetx, config.frameOffsety, "none")

	-- clear descriptors again
	Helper.releaseDescriptors()
end

function menu.onCloseElement(dueToClose)
	if dueToClose == "close" then
		if menu.remapControl then
			UnregisterEvent("keyboardInput", menu.keyboardInput)
			for i = 1, 8 do
				UnregisterEvent("joyaxesInputPosSgn" .. i, menu.joyaxesInputPosSgn[i])
				UnregisterEvent("joyaxesInputNegSgn" .. i, menu.joyaxesInputNegSgn[i])
				UnregisterEvent("joybuttonsInput" .. i, menu.joybuttonsInput[i])
			end
			UnregisterEvent("mousebuttonsInput", menu.mousebuttonsInput)

			if menu.remapControl.oldinputcode ~= -1 then
				menu.removeInput()
			end

			menu.pretoprow = GetTopRow(menu.infotable)
			menu.preselectrow = Helper.currentTableRow
			openControlsSetupMenu(menu.controlcontext)
			menu.remapControl = nil
		else
			if GetCurrentModuleName() == "startmenu" then
				openOptionsMenu()
			else
				Helper.closeMenuAndReturn(menu)
				menu.cleanup()
			end
		end
	elseif dueToClose == "auto" then
		Helper.closeMenuAndReturn(menu)
		menu.cleanup()
	else
		if menu.title == "Options Menu" then
			if GetCurrentModuleName() == "startmenu" then
				openExitMenu()
			else
				Helper.closeMenuAndReturn(menu)
				menu.cleanup()
			end
		elseif menu.title == "Settings Menu" then
			menu.preselectrow = 9
			openOptionsMenu()
		--[[
		elseif menu.title == "Keep settings?" then
			local oldresolution = GetResolutionOption(true)
			SetResolutionOption(oldresolution.width, oldresolution.height, false)
			openResolutionMenu()
			menu.time = nil --]]
		elseif menu.title == "Restore Defaults?" then
			if menu.defaultmenutype == "graphics" then
				menu.pretoprow = 13 + menu.getVRVersionGraphicOptionOffset()
				menu.preselectrow = 23 + menu.getVRVersionGraphicOptionOffset()
				openGraphicsMenu()
			elseif menu.defaultmenutype == "sound" then
				menu.preselectrow = 9
				openSoundMenu()
			elseif menu.defaultmenutype == "game" then
				menu.pretoprow = 12 + (C.IsVRVersion() and 1 or 0)
				menu.preselectrow = 21 + (C.IsVRVersion() and 1 or 0)
				openGameMenu()
			elseif menu.defaultmenutype == "controls" then
				menu.pretoprow = 9
				menu.preselectrow = 18
				openControlsMenu()
			elseif menu.defaultmenutype == "extension" then
				menu.preselectrow = 1
				openExtensionsMenu()
			end
		elseif menu.title == "Exit Game?" then
			if menu.openParam then
				Helper.closeMenuAndReturn(menu)
				menu.cleanup()
			else
				if menu.quit then
					menu.preselectrow = 11 + (GetCurrentModuleName() == "startmenu" and 1 or 0)
				else
					menu.preselectrow = 10 + (GetCurrentModuleName() == "startmenu" and 1 or 0)
				end
				menu.quit = nil
				openOptionsMenu()
			end
		elseif menu.title == "Override Savegame" then
			menu.preselectrow = 3
			openSaveMenu()
		elseif menu.title == "New Game" then
			menu.preselectrow = 3
			openOptionsMenu()
		elseif menu.title == "Difficulty Menu" then
			if menu.selectedmodule then
				openNewMenu()
			else
				openGameMenu()
			end
		elseif menu.title == "Load Game" then
			if menu.openParam then
				Helper.closeMenuAndReturn(menu)
				menu.cleanup()
			else
				menu.preselectrow = 4
				openOptionsMenu()
			end
		elseif menu.title == "Save Game" then
			if menu.openParam then
				Helper.closeMenuAndReturn(menu)
				menu.cleanup()
			else
				menu.preselectrow = 5
				openOptionsMenu()
			end
		elseif menu.title == "Tutorials Menu" then
			menu.preselectrow = 6
			openOptionsMenu()
		elseif menu.title == "Extension Menu" then
			if HaveExtensionSettingsChanged() and not menu.displayedextensionwarning then
				openExtensionsWarningMenu()
			else
				menu.preselectrow = 7
				openOptionsMenu()
			end
		elseif menu.title == "Extension Settings Menu" then
			openExtensionsMenu()
		elseif menu.title == "Extension Warning Menu" then
			openExtensionsMenu()
		elseif menu.title == "Bonus Menu" then
			menu.preselectrow = 8
			openOptionsMenu()
		elseif menu.title == "Graphics Menu" then
			menu.preselectrow = 2
			openSettingsMenu()
		elseif menu.title == "Change Resolution" then
			menu.preselectrow = C.IsVRVersion() and 9 or 2
			openGraphicsMenu()
		elseif menu.title == "Change Antialiasing" then
			menu.preselectrow = 3
			openGraphicsMenu()
		elseif menu.title == "Change Shader Quality" then
			menu.pretoprow = 9 + menu.getVRVersionGraphicOptionOffset()
			menu.preselectrow = 18 + menu.getVRVersionGraphicOptionOffset()
			openGraphicsMenu()
		elseif menu.title == "Change Shadows" then
			local offset = menu.getVRVersionGraphicOptionOffset()
			menu.pretoprow = (offset > 0) and (4 + offset) or nil
			menu.preselectrow = 10 + offset
			openGraphicsMenu()
		elseif menu.title == "Change Gfx Quality" then
			local offset = menu.getVRVersionGraphicOptionOffset()
			menu.pretoprow = (offset > 0) and (3 + offset) or nil
			menu.preselectrow = 9 + offset
			openGraphicsMenu()
		elseif menu.title == "Change SSAO" then
			menu.pretoprow = 3 + menu.getVRVersionGraphicOptionOffset()
			menu.preselectrow = 12 + menu.getVRVersionGraphicOptionOffset()
			openGraphicsMenu()
		elseif menu.title == "Change Radar" then
			menu.pretoprow = 11 + menu.getVRVersionGraphicOptionOffset()
			menu.preselectrow = 19 + menu.getVRVersionGraphicOptionOffset()
			openGraphicsMenu()
		elseif menu.title == "Change Glow" then
			menu.pretoprow = 4 + menu.getVRVersionGraphicOptionOffset()
			menu.preselectrow = 13 + menu.getVRVersionGraphicOptionOffset()
			openGraphicsMenu()
		elseif menu.title == "Change Display Mode" then
			menu.preselectrow = 4 + menu.getVRVersionGraphicOptionOffset()
			openGraphicsMenu()
		elseif menu.title == "Change Adapter" then
			menu.preselectrow = 5 + menu.getVRVersionGraphicOptionOffset()
			openGraphicsMenu()
		elseif menu.title == "Gamma Menu" then
			local offset = menu.getVRVersionGraphicOptionOffset()
			menu.pretoprow = (offset > 0) and (1 + offset) or nil
			menu.preselectrow = 7 + offset
			openGraphicsMenu()
		elseif menu.title == "LOD Menu" then
			menu.pretoprow = 6 + menu.getVRVersionGraphicOptionOffset()
			menu.preselectrow = 15 + menu.getVRVersionGraphicOptionOffset()
			openGraphicsMenu()
		elseif menu.title == "View Distance Menu" then
			menu.pretoprow = 7 + menu.getVRVersionGraphicOptionOffset()
			menu.preselectrow = 16 + menu.getVRVersionGraphicOptionOffset()
			openGraphicsMenu()
		elseif menu.title == "Effect Distance Menu" then
			menu.pretoprow = 8 + menu.getVRVersionGraphicOptionOffset()
			menu.preselectrow = 17 + menu.getVRVersionGraphicOptionOffset()
			openGraphicsMenu()
		elseif menu.title == "Sound Menu" then
			menu.preselectrow = 3
			openSettingsMenu()
		elseif menu.title == "Volume Menu" then
			if menu.volumetype == "master" then
				menu.preselectrow = 3
			elseif menu.volumetype == "music" then
				menu.preselectrow = 4
			elseif menu.volumetype == "voice" then
				menu.preselectrow = 5
			elseif menu.volumetype == "ambient" then
				menu.preselectrow = 6
			elseif menu.volumetype == "ui" then
				menu.preselectrow = 7
			elseif menu.volumetype == "effect" then
				menu.preselectrow = 8
			end
			openSoundMenu()
		elseif menu.title == "Game Menu" then
			menu.preselectrow = 4
			openSettingsMenu()
		elseif menu.title == "Privacy Menu" then
			menu.preselectrow = 6
			openSettingsMenu()
		elseif menu.title == "Rumble Menu" then
			menu.preselectrow = 8
			openGameMenu()
		elseif menu.title == "Change Aim Assist" then
			menu.preselectrow = 9
			openGameMenu()
		elseif menu.title == "UIScale Menu" then
			menu.pretoprow = 10
			menu.preselectrow = 17
			openGameMenu()
		elseif menu.title == "Change Gamepad Mode" then
			menu.pretoprow = 5
			menu.preselectrow = 12
			openControlsMenu()
		elseif menu.title == "Joystick Setup Menu" then
			menu.pretoprow = 3
			menu.preselectrow = 10
			openControlsMenu()
		elseif menu.title == "Controls Menu" then
			menu.preselectrow = 5
			openSettingsMenu()
		elseif menu.title == "Load Input Profile Menu" then
			menu.pretoprow = 11
			menu.preselectrow = 18
			openControlsMenu()
		elseif menu.title == "Save Input Profile Menu" then
			menu.pretoprow = 12
			menu.preselectrow = 19
			openControlsMenu()
		elseif menu.title == "Rename Input Profile Menu" then
			if menu.selectedprofile then
				menu.preselectrow = menu.selectedprofile[2]
				menu.selectedprofile = nil
				openRenameInputProfileMenu()
			else
				menu.pretoprow = 12
				menu.preselectrow = 20
				openControlsMenu()
			end
		elseif menu.title == "Confirm Input Profile Menu" then
			if menu.selectedprofile[2] then
				openLoadInputProfileMenu()
			else
				openSaveInputProfileMenu()
			end
			menu.selectedprofile = nil
		elseif menu.title == "Joystick Deadzone Menu" then
			menu.pretoprow = 4
			menu.preselectrow = 11
			openControlsMenu()
		elseif menu.title == "Controls Setup Menu" then
			if menu.remapControl then
				UnregisterEvent("keyboardInput", menu.keyboardInput)
				for i = 1, 8 do
					UnregisterEvent("joyaxesInputPosSgn" .. i, menu.joyaxesInputPosSgn[i])
					UnregisterEvent("joyaxesInputNegSgn" .. i, menu.joyaxesInputNegSgn[i])
					UnregisterEvent("joybuttonsInput" .. i, menu.joybuttonsInput[i])
				end
				UnregisterEvent("mousebuttonsInput", menu.mousebuttonsInput)

				menu.pretoprow = GetTopRow(menu.infotable)
				menu.preselectrow = Helper.currentTableRow
				openControlsSetupMenu(menu.controlcontext)
				menu.remapControl = nil
			else
				if menu.controlcontext == "keyboard_space" then
					menu.preselectrow = 4
				elseif menu.controlcontext == "keyboard_firstperson" then
					menu.preselectrow = 5
				elseif menu.controlcontext == "keyboard_menus" then
					menu.preselectrow = 6
				end
				openControlsMenu()
				menu.controlcontext = nil
			end
		elseif menu.title == "Invert Axes Menu" then
			if menu.controlcontext == "joystick_invert" then
				menu.preselectrow = 8
			elseif menu.controlcontext == "mouse_invert" then 
				menu.pretoprow = 7
				menu.preselectrow = 14
			end
			openControlsMenu()
		elseif menu.title == "Sensitivity Menu" then
			if menu.controlcontext == "joystick_sensitivity" then
				menu.preselectrow = 9
			elseif menu.controlcontext == "mouse_sensitivity" then 
				menu.pretoprow = 8
				menu.preselectrow = 15
			end
			openControlsMenu()
		elseif menu.title == "Sensitivity Slider Menu" then
			menu.pretoprow = menu.controlcontext[5]
			menu.preselectrow = menu.controlcontext[4]
			openSensitivityMenu(menu.controlcontext[3])
		elseif menu.title == "Joystick Menu" then
			menu.preselectrow = menu.controlcontext + 1
			openJoystickSetupMenu()
		end
	end
end

init()
