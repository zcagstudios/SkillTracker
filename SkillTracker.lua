------------------------------------------------------------------------
--  COMPATIBILIDAD LUA 5.0.2  (Vanilla no trae string.match)
------------------------------------------------------------------------
if not string.match then
  -- Devuelve solo la primera captura, igual que string.match moderno.
  function string.match(str, pattern)
    local _, _, capture = string.find(str, pattern)
    return capture
  end
end

------------------------------------------------------------------------
--  POSICIÓN DEL MARCO  (NUEVAS FUNCIONES ROBUSTAS)
------------------------------------------------------------------------
function SavePosition()
  if not SkillTrackerFrame then return end

  local point, _, relPoint, xOfs, yOfs = SkillTrackerFrame:GetPoint()
  if not point then
    point, relPoint = "TOPLEFT", "BOTTOMLEFT"
    xOfs, yOfs      = SkillTrackerFrame:GetLeft(), SkillTrackerFrame:GetTop()
  end

  SkillTrackerDB.pos = {
    point         = point,
    relativePoint = relPoint or point,
    x             = xOfs or 0,
    y             = yOfs or 0,
  }
end

function LoadPosition()
  local p = SkillTrackerDB.pos
  if p and p.point and p.relativePoint then
    SkillTrackerFrame:ClearAllPoints()
    SkillTrackerFrame:SetPoint(p.point, UIParent, p.relativePoint, p.x, p.y)
  else
    SkillTrackerFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
  end
end
------------------------------------------------------------------------
--  MARCO PRINCIPAL
------------------------------------------------------------------------
local frame = CreateFrame("Frame", "SkillTrackerFrame", UIParent)
frame:SetWidth(260)
frame:SetHeight(240)
frame:SetMovable(true)
frame:SetResizable(true)
frame:EnableMouse(true)
frame:SetClampedToScreen(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", function() frame:StartMoving() end)
frame:SetScript("OnDragStop", function() frame:StopMovingOrSizing(); SavePosition() end)
frame:Hide()

frame:SetBackdrop({
  bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
  edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
  tile = true, tileSize = 16, edgeSize = 10,
  insets  = { left = 3, right = 3, top = 3, bottom = 3 }
})
frame:SetBackdropColor(0, 0, 0, 0.95)

-- Botón de cerrar
local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
close:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -5, -5)

-- Tirador para redimensionar
local resizer = CreateFrame("Button", nil, frame)
resizer:SetWidth(16)
resizer:SetHeight(16)
resizer:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
resizer:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
resizer:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
resizer:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
resizer:SetScript("OnMouseDown", function() frame:StartSizing("BOTTOMRIGHT") end)
resizer:SetScript("OnMouseUp", function()
  frame:StopMovingOrSizing()
  SavePosition()
end)

-- Botón de ayuda
local helpBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
helpBtn:SetWidth(20)
helpBtn:SetHeight(20)
helpBtn:SetText("?")
helpBtn:SetPoint("TOPLEFT", frame, "TOPLEFT", 5, -5)

-- Ventana de ayuda
local helpDialog = CreateFrame("Frame", "SkillTrackerHelpDialog", UIParent)
helpDialog:SetWidth(450)
helpDialog:SetHeight(270)
helpDialog:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
helpDialog:SetBackdrop({
  bgFile = "Interface/Tooltips/UI-Tooltip-Background",
  edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
  tile = true, tileSize = 16, edgeSize = 10,
  insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
helpDialog:SetBackdropColor(0, 0, 0, 0.9)
helpDialog:SetMovable(true)
helpDialog:EnableMouse(true)
helpDialog:RegisterForDrag("LeftButton")
helpDialog:SetScript("OnDragStart", function() helpDialog:StartMoving() end)
helpDialog:SetScript("OnDragStop", function() helpDialog:StopMovingOrSizing() end)
helpDialog:Hide()

local helpTitle = helpDialog:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
helpTitle:SetPoint("TOP", helpDialog, "TOP", 0, -15)
helpTitle:SetText("SkillTracker - Ayuda")

local helpText = helpDialog:CreateFontString(nil, "OVERLAY", "GameFontNormal")
helpText:SetPoint("TOPLEFT", helpDialog, "TOPLEFT", 20, -40)
helpText:SetJustifyH("LEFT")
helpText:SetText(
  "|cff00ff00Combinaciones de botones y atajos:\n\n" ..
  "|cffffcc00Ejecuta la acción guardada (craftea o lanza):|r |cffffffffClick izquierdo en botón macro|r\n\n" ..
  "|cffffcc00Edita el macro guardado:|r |cffffffffClic derecho en botón macro|r\n\n" ..
  "|cffffcc00Elimina el macro (pide confirmación):|r |cffffffffShift + clic derecho|r\n\n" ..
  "|cffffcc00Abre la ventana de la profesión:|r |cffffffffClick izquierdo en icono de profesión|r\n\n" ..
  "|cffffcc00Agrega un macro para esa profesión:|r |cffffffffClick en '+'|r\n\n" ..
  "|cffffcc00Alterna mostrar solo profesiones o todas las habilidades:|r |cffffffffClic derecho en el marco principal|r\n\n" ..
  "|cffccccccNota: Eliminar solo es posible usando la tecla SHIFT más click (izquierdo o derecho) sobre el macro.|r"
)

local closeHelpBtn = CreateFrame("Button", nil, helpDialog, "UIPanelButtonTemplate")
closeHelpBtn:SetWidth(60)
closeHelpBtn:SetHeight(20)
closeHelpBtn:SetText("Cerrar")
closeHelpBtn:SetPoint("BOTTOM", helpDialog, "BOTTOM", 0, 10)
closeHelpBtn:SetScript("OnClick", function() helpDialog:Hide() end)

helpBtn:SetScript("OnClick", function() helpDialog:Show() end)

------------------------------------------------------------------------
--  LISTA DE PROFESIONES VÁLIDAS
------------------------------------------------------------------------
local professionList = {
  ["Alchemy"] = true, ["Alquimia"] = true,
  ["Blacksmithing"] = true, ["Herrería"] = true,
  ["Enchanting"]  = true, ["Encantamiento"] = true,
  ["Engineering"] = true, ["Ingeniería"] = true,
  ["Herbalism"]   = true, ["Herboristería"] = true,
  ["Mining"]      = true, ["Minería"] = true,
  ["Leatherworking"] = true, ["Peletería"] = true,
  ["Tailoring"]   = true, ["Sastrería"] = true,
  ["Cooking"]     = true, ["Cocina"] = true,
  ["First Aid"]   = true, ["Primeros Auxilios"] = true,
  ["Fishing"]     = true, ["Pesca"] = true,
  ["Survival"]    = true, ["Supervivencia"] = true,
  ["Jewelcrafting"] = true, ["Joyería"] = true,
}

------------------------------------------------------------------------
--  VARIABLES PERSISTENTES
------------------------------------------------------------------------
if not SkillTrackerDB then SkillTrackerDB = {} end
if SkillTrackerDB.onlyProfessions == nil then SkillTrackerDB.onlyProfessions = true end
if SkillTrackerDB.visible == nil then SkillTrackerDB.visible = true end
if not SkillTrackerDB.macros then SkillTrackerDB.macros = {} end

frame.rows = {}

------------------------------------------------------------------------
--  DATOS DE PROFESIONES (icons / spells)  (sin cambios)
------------------------------------------------------------------------
local professionData = {
  ["Sastrería"] = { spell = "Sastrería", icon = "Interface\\Icons\\Trade_Tailoring" },
  ["Tailoring"] = { spell = "Tailoring", icon = "Interface\\Icons\\Trade_Tailoring" },
  ["Herrería"]  = { spell = "Herrería", icon = "Interface\\Icons\\Trade_Blacksmithing" },
  ["Blacksmithing"] = { spell = "Blacksmithing", icon = "Interface\\Icons\\Trade_Blacksmithing" },
  ["Alquimia"]  = { spell = "Alquimia", icon = "Interface\\Icons\\Trade_Alchemy" },
  ["Alchemy"]   = { spell = "Alchemy",  icon = "Interface\\Icons\\Trade_Alchemy" },
  ["Ingeniería"] = { spell = "Ingeniería", icon = "Interface\\Icons\\Trade_Engineering" },
  ["Engineering"]= { spell = "Engineering", icon = "Interface\\Icons\\Trade_Engineering" },
  ["Pesca"]     = { spell = "Pesca",  icon = "Interface\\Icons\\Trade_Fishing" },
  ["Fishing"]   = { spell = "Fishing",icon = "Interface\\Icons\\Trade_Fishing" },
  ["Cocina"]    = { spell = "Cocinar", icon = "Interface\\Icons\\INV_Misc_Food_15" },
  ["Cooking"]   = { spell = "Cooking", icon = "Interface\\Icons\\INV_Misc_Food_15" },
  ["Primeros Auxilios"] = { spell = "Primeros Auxilios", icon = "Interface\\Icons\\Spell_Holy_SealOfSacrifice" },
  ["First Aid"] = { spell = "First Aid", icon = "Interface\\Icons\\Spell_Holy_SealOfSacrifice" },
  ["Herboristería"] = { spell = "Herboristería", icon = "Interface\\Icons\\Spell_Nature_NatureTouchGrow" },
  ["Herbalism"] = { spell = "Herbalism", icon = "Interface\\Icons\\Spell_Nature_NatureTouchGrow" },
  ["Minería"]   = { spell = "Minería", icon = "Interface\\Icons\\Trade_Mining" },
  ["Mining"]    = { spell = "Mining",  icon = "Interface\\Icons\\Trade_Mining" },
  ["Encantamiento"]  = { spell = "Encantamiento", icon = "Interface\\Icons\\Trade_Engraving" },
  ["Enchanting"]     = { spell = "Enchanting", icon = "Interface\\Icons\\Trade_Engraving" },
  ["Peletería"] = { spell = "Peletería", icon = "Interface\\Icons\\INV_Misc_ArmorKit_17" },
  ["Leatherworking"] = { spell = "Leatherworking", icon = "Interface\\Icons\\INV_Misc_ArmorKit_17" },
  ["Supervivencia"]  = { spell = "Supervivencia", icon = "Interface\\Icons\\Trade_Survival" },
  ["Survival"]       = { spell = "Survival", icon = "Interface\\Icons\\Trade_Survival" },
  ["Joyería"]       = { spell = "Joyería",       icon = "Interface\\Icons\\INV_Misc_Gem_01" },
  ["Jewelcrafting"] = { spell = "Jewelcrafting", icon = "Interface\\Icons\\INV_Misc_Gem_01" },
}

-- Tabla para mapear profesión a ventana y hechizo
local professionInfo = {
  ["Alquimia"] = { frame = "TradeSkillFrame", spell = "Alquimia" },
  ["Alchemy"] = { frame = "TradeSkillFrame", spell = "Alchemy" },
  ["Herrería"] = { frame = "TradeSkillFrame", spell = "Herrería" },
  ["Blacksmithing"] = { frame = "TradeSkillFrame", spell = "Blacksmithing" },
  ["Encantamiento"] = { frame = "CraftFrame", spell = "Encantamiento", isEnchanting = true },
  ["Enchanting"] = { frame = "CraftFrame", spell = "Enchanting", isEnchanting = true },
  ["Ingeniería"] = { frame = "TradeSkillFrame", spell = "Ingeniería" },
  ["Engineering"] = { frame = "TradeSkillFrame", spell = "Engineering" },
  ["Herboristería"] = { frame = "TradeSkillFrame", spell = "Herboristería" },
  ["Herbalism"] = { frame = "TradeSkillFrame", spell = "Herbalism" },
  ["Minería"] = { frame = "TradeSkillFrame", spell = "Minería" },
  ["Mining"] = { frame = "TradeSkillFrame", spell = "Mining" },
  ["Peletería"] = { frame = "TradeSkillFrame", spell = "Peletería" },
  ["Leatherworking"] = { frame = "TradeSkillFrame", spell = "Leatherworking" },
  ["Sastrería"] = { frame = "TradeSkillFrame", spell = "Sastrería" },
  ["Tailoring"] = { frame = "TradeSkillFrame", spell = "Tailoring" },
  ["Cocina"] = { frame = "TradeSkillFrame", spell = "Cocina" },
  ["Cooking"] = { frame = "TradeSkillFrame", spell = "Cooking" },
  ["Primeros Auxilios"] = { frame = "TradeSkillFrame", spell = "Primeros Auxilios" },
  ["First Aid"] = { frame = "TradeSkillFrame", spell = "First Aid" },
  ["Pesca"] = { frame = "CastingBarFrame", spell = "Pesca" },
  ["Fishing"] = { frame = "CastingBarFrame", spell = "Fishing" },
  ["Supervivencia"] = { frame = "TradeSkillFrame", spell = "Supervivencia" },
  ["Survival"] = { frame = "TradeSkillFrame", spell = "Survival" },
   ["Joyería"]       = { frame = "TradeSkillFrame", spell = "Joyería"       },
  ["Jewelcrafting"] = { frame = "TradeSkillFrame", spell = "Jewelcrafting" },
}

-- Para manejo de crafts pendientes al abrir ventana
local pendingCraft = nil

local function SkillTracker_DoCraft(profession, macroData)
  local info = professionInfo[profession]
  if not info then
    DEFAULT_CHAT_FRAME:AddMessage("Profesión desconocida: " .. profession)
    return
  end

  -- Caso especial: Pesca solo lanza el hechizo
  if profession == "Pesca" or profession == "Fishing" then
    CastSpellByName(info.spell)
    return
  end

  local frameRef = getglobal(info.frame)
  if not (frameRef and frameRef:IsShown()) then
    pendingCraft = { profession = profession, macroData = macroData }
    CastSpellByName(info.spell)
  else
    if info.isEnchanting then
      if macroData and macroData.skillIndex then
        DoCraft(macroData.skillIndex)
      elseif macroData and macroData.script then
        RunScript(macroData.script)
      end
    else
      if macroData and macroData.skillIndex then
        DoTradeSkill(macroData.skillIndex)
      elseif macroData and macroData.script then
        RunScript(macroData.script)
      end
    end
  end
end

-- Hook al evento TRADE_SKILL_SHOW para completar el craft pendiente
frame:RegisterEvent("TRADE_SKILL_SHOW")
frame:RegisterEvent("CRAFT_SHOW")

local orig_OnEvent = frame:GetScript("OnEvent")
frame:SetScript("OnEvent", function()
  if (event == "TRADE_SKILL_SHOW" or event == "CRAFT_SHOW") and pendingCraft then
    local data = pendingCraft
    pendingCraft = nil
    local info = professionInfo[data.profession]
    if info and info.isEnchanting then
      if data and data.macroData and data.macroData.skillIndex then
        DoCraft(data.macroData.skillIndex)
      elseif data and data.macroData and data.macroData.script then
        RunScript(data.macroData.script)
      end
    else
      if data and data.macroData and data.macroData.skillIndex then
        DoTradeSkill(data.macroData.skillIndex)
      elseif data and data.macroData and data.macroData.script then
        RunScript(data.macroData.script)
      end
    end
  end
  if orig_OnEvent then orig_OnEvent() end
end)

------------------------------------------------------------------------
--  COMPROBAR CAÑA EQUIPADA  (simplificado con string.match alias)
------------------------------------------------------------------------
local function IsFishingPoleEquipped()
  local link = GetInventoryItemLink("player", 16)   -- mano principal
  if not link then return false end
  local name = string.match(link, "%[(.+)%]")
  return name and (string.find(name, "Caña") or string.find(name, "Pole"))
end

------------------------------------------------------------------------
--  FUNCIÓN COMPLETA: UpdateSkillRows()
--  Sustitúyela íntegramente en tu archivo SkillTracker.lua
------------------------------------------------------------------------
function UpdateSkillRows()
  ----------------------------------------------------------------------
  --  CONSTANTES DE DISEÑO
  ----------------------------------------------------------------------
  local ROW_SPACING = 20      -- Alto de cada fila (texto + icono + botones)
  local ROW_START_Y = -30     -- Offset inicial desde el top del frame
  local BAG_PADDING = 24      -- Espacio extra antes de la cabecera de bolsas

  local index = 1             -- Índice de fila profesional que vamos pintando

  ----------------------------------------------------------------------
  --  1.  RECORRER LÍNEAS DE HABILIDAD / PROFESIÓN
  ----------------------------------------------------------------------
  for i = 1, GetNumSkillLines() do
    local name, isHeader, _, rank, _, _, maxRank = GetSkillLineInfo(i)
    if not isHeader and maxRank > 0 then
      if not SkillTrackerDB.onlyProfessions or professionList[name] then

        ----------------------------------------------------------------
        -- 1a.  Texto de la profesión
        ----------------------------------------------------------------
        local row = frame.rows[index]
        if not row then
          row = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
          frame.rows[index] = row
        end
        local rowY = ROW_START_Y - ((index - 1) * ROW_SPACING)
        row:SetPoint("TOPLEFT", frame, "TOPLEFT", 36, rowY)
        row:SetJustifyH("LEFT")

        ----------------------------------------------------------------
        -- 1b.  Botón/Icono de la profesión
        ----------------------------------------------------------------
        if not frame.rows[index .. "_icon"] then
          local iconBtn = CreateFrame("Button", nil, frame)
          iconBtn:SetWidth(16)
          iconBtn:SetHeight(16)
          frame.rows[index .. "_icon"] = iconBtn
        end
        local iconBtn = frame.rows[index .. "_icon"]
        iconBtn:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, rowY)

        ----------------------------------------------------------------
        -- 1c.  Botón '+' (agregar macro) y botones de macro numerados
        ----------------------------------------------------------------
        if not frame.rows[index .. "_addmacro"] then
          local addBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
          addBtn:SetWidth(20); addBtn:SetHeight(20); addBtn:SetText("+")
          frame.rows[index .. "_addmacro"] = addBtn
        end
        local addBtn   = frame.rows[index .. "_addmacro"]
        local addBtnX  = 180
        addBtn:SetPoint("TOPLEFT", frame, "TOPLEFT", addBtnX, rowY)

        -- Acción del botón '+'
        addBtn:SetScript("OnClick", function()
          if not SkillTrackerDB.macros[name] then SkillTrackerDB.macros[name] = {} end
          tinsert(SkillTrackerDB.macros[name], {})
          local macroIndex = getn(SkillTrackerDB.macros[name])
          SkillTracker_EditMacro(name, macroIndex, true)
        end)
        addBtn:Show()

        -- Macro-botones
        if not frame.rows[index .. "_macros"] then
          frame.rows[index .. "_macros"] = {}
        end
        local macroBtns = frame.rows[index .. "_macros"]
        local macros    = SkillTrackerDB.macros[name] or {}

        -- Oculta cualquier botón antiguo sobrante
        for m = 1, getn(macroBtns) do
          if macroBtns[m] then macroBtns[m]:Hide() end
        end

        -- Crea / posiciona botones existentes
        for m = 1, getn(macros) do
          if not macroBtns[m] then
            local btn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
            btn:SetWidth(24); btn:SetHeight(20)
            btn:SetText(m)
            macroBtns[m] = btn
          end
          local btn = macroBtns[m]
          btn:SetPoint("TOPLEFT", frame, "TOPLEFT",
                       addBtnX + 24 + (m - 1) * 26, rowY)
          btn:Show()

          btn:SetScript("OnClick", function()
            local macroData = macros[m]
            SkillTracker_DoCraft(name, macroData)
          end)
          btn:SetScript("OnMouseUp", function()
            if IsShiftKeyDown() and (arg1 == "RightButton" or arg1 == "LeftButton") then
              StaticPopupDialogs["SKILLTRACKER_DELETE_MACRO"] = {
                text = "¿Eliminar este macro?",
                button1 = "Sí",
                button2 = "No",
                OnAccept = function()
                  tremove(SkillTrackerDB.macros[name], m)
                  UpdateSkillRows()
                end,
                timeout = 0, whileDead = true, hideOnEscape = true,
              }
              StaticPopup_Show("SKILLTRACKER_DELETE_MACRO")
            elseif arg1 == "RightButton" then
              SkillTracker_EditMacro(name, m, false)
            end
          end)
          btn:SetScript("OnEnter", function()
            local macroData = macros[m]
            if macroData and macroData.desc and macroData.desc ~= "" then
              GameTooltip:SetOwner(btn, "ANCHOR_RIGHT")
              GameTooltip:SetText(macroData.desc, 1, 1, 1, 1, true)
              GameTooltip:Show()
            end
          end)
          btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
        end

        ----------------------------------------------------------------
        -- 1d.  Texto y comportamiento del icono
        ----------------------------------------------------------------
        local iconData = professionData[name]
        local rowText  = "|cffffff00" .. name .. "|r: |cffffffff" ..
                         rank .. "/" .. maxRank .. "|r"
        row:SetText(rowText); row:Show()

        if iconData then
          iconBtn:SetNormalTexture(iconData.icon)
          iconBtn:SetHighlightTexture(nil)

          if iconData.spell == "Pesca" or iconData.spell == "Fishing" then
            iconBtn:SetScript("OnClick", function()
              if IsFishingPoleEquipped() then
                CastSpellByName("Pesca(Experimentado)")
                CastSpellByName("Fishing(Expert)")
                CastSpellByName("Pesca")
                CastSpellByName("Fishing")
                CastSpellByName("Pescar")
              end
            end)
            if IsFishingPoleEquipped() then
              iconBtn:GetNormalTexture():SetDesaturated(false)
              iconBtn:SetAlpha(1.0); iconBtn:Enable()
            else
              iconBtn:GetNormalTexture():SetDesaturated(true)
              iconBtn:SetAlpha(0.4);  iconBtn:Disable()
            end
          else
            iconBtn:SetScript("OnClick", function()
              -- ► Si es Minería, abre Fundición (Smelting)
			  if iconData.spell == "Minería" or iconData.spell == "Mining" then
			    CastSpellByName("Fundición")        -- castellano
				CastSpellByName("Smelting")      -- inglés (por si acaso)
			  else
			    CastSpellByName(iconData.spell)
			  end
            end)
            iconBtn:GetNormalTexture():SetDesaturated(false)
            iconBtn:SetAlpha(1.0); iconBtn:Enable()
          end
          iconBtn:Show()
        else
          iconBtn:Hide()
        end

        index = index + 1
      end
    end
  end -- for GetNumSkillLines

  ----------------------------------------------------------------------
  -- 2.  OCULTAR FILAS QUE SOBRAN
  ----------------------------------------------------------------------
  for i = index, getn(frame.rows) do
    if frame.rows[i] then frame.rows[i]:Hide() end
    if frame.rows[i .. "_icon"] then frame.rows[i .. "_icon"]:Hide() end
    if frame.rows[i .. "_addmacro"] then frame.rows[i .. "_addmacro"]:Hide() end
    if frame.rows[i .. "_macros"] then
      for m = 1, getn(frame.rows[i .. "_macros"]) do
        if frame.rows[i .. "_macros"][m] then frame.rows[i .. "_macros"][m]:Hide() end
      end
    end
  end

  ----------------------------------------------------------------------
  -- 3.  SECCIÓN "ESPACIOS DISPONIBLES EN BOLSAS"
  ----------------------------------------------------------------------
  -- A) Limpiar labels anteriores
  if frame.bagSlotLabels then
    for _, lbl in ipairs(frame.bagSlotLabels) do lbl:Hide() end
  end
  frame.bagSlotLabels = {}

  ----------------------------------------------------------------------
  -- B) Calcular espacios libres / totales por familia
  ----------------------------------------------------------------------
  local familyNames = {
    [0]  = { name = "Bolsa normal",      color = "|cffcccccc" },
    [1]  = { name = "Almas",             color = "|cffb13cff" },
    [2]  = { name = "Hierbas",           color = "|cff00ff00" },
    [4]  = { name = "Encantamiento",     color = "|cff66ccff" },
    [8]  = { name = "Ingeniería",        color = "|cffffa500" },
    [16] = { name = "Munición",          color = "|cffffff00" },
    [32] = { name = "Minería",           color = "|cffbbaa00" },
  }

  local slotTotals, slotLibres = {}, {}
  -- Contador de fragmentos y clase
  local _, englishClass = UnitClass("player")       -- "WARLOCK" si es brujo
  local soulShardCount  = 0                         -- total de fragmentos

  for bag = 0, 4 do
    local fam = 0
    if bag ~= 0 then
      local link = GetInventoryItemLink("player", bag + 19)
      if link then
        local id = tonumber(string.match(link, "item:(%d+):"))
        if id then
          local _, _, _, _, _, itemType = GetItemInfo(id)
          itemType = itemType or ""
          local tl = string.lower(itemType)
          if string.find(tl, "alma")       then fam = 1
          elseif string.find(tl, "hierba") then fam = 2
          elseif string.find(tl, "encant") then fam = 4
          elseif string.find(tl, "ingenier") then fam = 8
          elseif string.find(tl, "munici") then fam = 16
          elseif string.find(tl, "miner")  then fam = 32
          end
        end
      end
    end

    local numSlots = GetContainerNumSlots(bag)
    if numSlots and numSlots > 0 then
      slotTotals[fam] = (slotTotals[fam] or 0) + numSlots
      slotLibres[fam] = slotLibres[fam] or 0
      for slot = 1, numSlots do
		local link = GetContainerItemLink(bag, slot)
		if link then
		  local itemString = string.match(link, "item:(%d+):")
	      local itemId     = tonumber(itemString)

			-- 6265 = Fragmento de alma en Vanilla
		  if itemId == 6265 then
		    local _, itemCount = GetContainerItemInfo(bag, slot)
			soulShardCount = soulShardCount + (itemCount or 1)
		  end
		else
		  ------------------------------------------------------------------
		  --  Hueco vacío → cuenta como espacio libre de esta familia
		  ------------------------------------------------------------------
		  slotLibres[fam] = slotLibres[fam] + 1
	    end
	  end
    end
  end

  ----------------------------------------------------------------------
  -- C) Dibujar los labels (yOffset parte del nuevo padding)
  ----------------------------------------------------------------------
  local yOffset = ROW_START_Y - ((index - 1) * ROW_SPACING) - BAG_PADDING
  local lblIdx  = 1

  -- Leyenda principal
  local legend = frame.bagSlotLabels[lblIdx]
  if not legend then
    legend = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    frame.bagSlotLabels[lblIdx] = legend
  end
  legend:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, yOffset)
  legend:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
  legend:SetText("|cffffaa00--- Espacios disponibles en bolsas ---|r")
  legend:Show()

  yOffset = yOffset - 16
  lblIdx  = lblIdx + 1

  -- Bolsa normal primero
  if slotTotals[0] then
    local lbl = frame.bagSlotLabels[lblIdx] or
                frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    frame.bagSlotLabels[lblIdx] = lbl
    lbl:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, yOffset)
    lbl:SetFont("Fonts\\FRIZQT__.TTF", 12)
    lbl:SetText(string.format("%s%s: |cffffff00%d|r/%d|r",
                              familyNames[0].color, familyNames[0].name,
                              slotLibres[0], slotTotals[0]))
    lbl:Show()
    yOffset = yOffset - 16
    lblIdx  = lblIdx + 1
  end

  -- Resto de familias
  for fam, info in pairs(familyNames) do
    if fam ~= 0 and slotTotals[fam] then
      local lbl = frame.bagSlotLabels[lblIdx] or
                  frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
      frame.bagSlotLabels[lblIdx] = lbl
      lbl:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, yOffset)
      lbl:SetFont("Fonts\\FRIZQT__.TTF", 12)
      lbl:SetText(string.format("%s%s: |cffffff00%d|r/%d|r",
                                info.color, info.name,
                                slotLibres[fam], slotTotals[fam]))
      lbl:Show()
      yOffset = yOffset - 16
      lblIdx  = lblIdx + 1
    end
  end
  
  -- Si es brujo, muestra cuántos fragmentos lleva, aunque no haya soul bag
  if englishClass == "WARLOCK" and not slotTotals[1] then
    local lbl = frame.bagSlotLabels[lblIdx] or frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    frame.bagSlotLabels[lblIdx] = lbl
    lbl:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, yOffset)
    lbl:SetFont("Fonts\\FRIZQT__.TTF", 12)
    lbl:SetText(string.format("|cffb13cffFragmentos de alma:|r |cffffff00%d|r", soulShardCount))
    lbl:Show()
    yOffset = yOffset - 16
    lblIdx  = lblIdx + 1
  end

  -- Si no había ninguna bolsa equipada
  if lblIdx == 2 then
    local lbl = frame.bagSlotLabels[lblIdx] or
                frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    frame.bagSlotLabels[lblIdx] = lbl
    lbl:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, yOffset)
    lbl:SetText("|cffff8888No se detectaron bolsas equipadas.|r")
    lbl:Show()
    yOffset = yOffset - 16
    lblIdx  = lblIdx + 1
  end

  -- Línea divisoria inferior
  local divider = frame.bagSlotLabels[lblIdx] or
                  frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  frame.bagSlotLabels[lblIdx] = divider
  divider:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, yOffset)
  divider:SetFont("Fonts\\FRIZQT__.TTF", 10)
  divider:SetText("|cff555555----------------------------------------|r")
  divider:Show()

   ----------------------------------------------------------------------
  -- 4.  AJUSTAR ALTO DEL FRAME (crece o disminuye según el contenido)
  ----------------------------------------------------------------------
  local neededHeight = -yOffset + 40   -- 40 px de margen inferior
  local MIN_HEIGHT   = 240             -- alto mínimo por estética

  -- Fija la altura al mayor entre lo necesario y el mínimo.
  -- Esto permite que el marco se agrande y también se encoja.
  frame:SetHeight(math.max(neededHeight, MIN_HEIGHT))
end

-- Botón minimapa
local mini = CreateFrame("Button", "SkillTrackerMiniButton", Minimap)
mini:SetWidth(32)
mini:SetHeight(32)
mini:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 0, 0) -- Puedes ajustar a "CENTER" o lo que gustes

mini:SetNormalTexture("Interface\\AddOns\\SkillTracker\\icon.blp")  -- Aquí tu icono 32x32 con marco dorado
mini:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")

local tex = mini:GetNormalTexture()
if tex then
  tex:SetTexCoord(0, 1, 0, 1) -- Muestra el icono completo, sin recortar
end

mini:SetScript("OnUpdate", function()
  local tex = mini:GetNormalTexture()
  if tex then
    tex:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    this:SetScript("OnUpdate", nil)
  end
end)

mini:SetScript("OnClick", function()
  if frame:IsShown() then
    frame:Hide()
    SkillTrackerDB.visible = false
  else
    UpdateSkillRows()
    frame:Show()
    SkillTrackerDB.visible = true
  end
end)

mini:SetScript("OnEnter", function()
  GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
  GameTooltip:SetText("SkillTracker", 1, 1, 1)
  GameTooltip:AddLine("Click: mostrar/ocultar")
  GameTooltip:AddLine("Clic derecho: cambiar modo")
  GameTooltip:Show()
end)
mini:SetScript("OnLeave", function() GameTooltip:Hide() end)

frame:SetScript("OnMouseUp", function()
  if arg1 == "RightButton" then
    SkillTrackerDB.onlyProfessions = not SkillTrackerDB.onlyProfessions
    DEFAULT_CHAT_FRAME:AddMessage("|cffffcc00[SkillTracker]|r Modo: " ..
      (SkillTrackerDB.onlyProfessions and "Solo profesiones" or "Todas las habilidades"))
    UpdateSkillRows()
  end
end)

frame:RegisterEvent("BAG_UPDATE")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("SKILL_LINES_CHANGED")
frame:RegisterEvent("UNIT_INVENTORY_CHANGED")

frame:SetScript("OnEvent", function()
  -- if event == "UNIT_INVENTORY_CHANGED" and arg1 ~= "player" then return end
  UpdateSkillRows()
  if SkillTrackerDB.visible then
    frame:Show()
  end
end)

SLASH_SKILLTRACKER1 = "/skilltracker"
SlashCmdList["SKILLTRACKER"] = function()
  UpdateSkillRows()
  frame:Show()
  SkillTrackerDB.visible = true
end

LoadPosition()
if SkillTrackerDB.visible then
  UpdateSkillRows()
  frame:Show()
end

-- Editor de macro por profesión e índice
function SkillTracker_EditMacro(profession, index, isNew)
  if not SkillTrackerDB.macros[profession] then
    SkillTrackerDB.macros[profession] = {}
  end

  if SkillTrackerMacroEditor and SkillTrackerMacroEditor:IsShown() then
    SkillTrackerMacroEditor:Hide()
  end

  local f = CreateFrame("Frame", "SkillTrackerMacroEditor", UIParent)
  f:SetWidth(300)
  f:SetHeight(180)
  f:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
  f:SetBackdrop({
    bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 10,
    insets = { left = 3, right = 3, top = 3, bottom = 3 }
  })
  f:SetBackdropColor(0, 0, 0, 0.8)
  f:SetMovable(true)
  f:EnableMouse(true)
  f:RegisterForDrag("LeftButton")
  f:SetScript("OnDragStart", function() f:StartMoving() end)
  f:SetScript("OnDragStop", function() f:StopMovingOrSizing() end)

  local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  title:SetPoint("TOP", f, "TOP", 0, -10)
  title:SetText("Editar macro: " .. profession .. " #" .. index)

  local editBox = CreateFrame("EditBox", nil, f, "InputBoxTemplate")
  editBox:SetWidth(260)
  editBox:SetHeight(28)
  editBox:SetMultiLine(false)
  editBox:SetAutoFocus(true)
  editBox:SetPoint("TOP", f, "TOP", 0, -35)

  local descLabel = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  descLabel:SetPoint("TOPLEFT", editBox, "BOTTOMLEFT", 0, -10)
  descLabel:SetText("Descripción:")

  local descBox = CreateFrame("EditBox", nil, f, "InputBoxTemplate")
  descBox:SetWidth(260)
  descBox:SetHeight(28)
  descBox:SetMultiLine(false)
  descBox:SetAutoFocus(false)
  descBox:SetPoint("TOPLEFT", descLabel, "BOTTOMLEFT", 0, -5)
  descBox:SetMaxLetters(60)
  descBox:SetText("")

  local closeBtn = CreateFrame("Button", nil, f, "UIPanelCloseButton")
  closeBtn:SetPoint("TOPRIGHT", f, "TOPRIGHT", -5, -5)
  closeBtn:SetScript("OnClick", function()
    if isNew then
      local macro = SkillTrackerDB.macros[profession][index]
      if not macro or (not macro.skillIndex and (not macro.script or macro.script == "")) then
        tremove(SkillTrackerDB.macros[profession], index)
      end
      UpdateSkillRows()
    end
    f:Hide()
  end)

  -- Muestra el índice guardado o script y la descripción si existe
  local data = SkillTrackerDB.macros[profession][index]
  if data then
    if data.skillIndex then
      editBox:SetText(tostring(data.skillIndex))
    elseif data.script then
      editBox:SetText(data.script)
    end
    if data.desc then
      descBox:SetText(data.desc)
    end
  else
    editBox:SetText("")
    descBox:SetText("")
  end

  local help = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  help:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 10, 35)
  help:SetText("|cffffcc00Escribe el número de la receta en la ventana de la profesión (ej. 4),\no un script LUA personalizado si lo necesitas.\nAbre la ventana de profesión una vez, luego usa el botón de macro.")

  local saveBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
  saveBtn:SetWidth(80)
  saveBtn:SetHeight(20)
  saveBtn:SetPoint("BOTTOM", f, "BOTTOM", 0, 10)
  saveBtn:SetText("Guardar")
  saveBtn:SetScript("OnClick", function()
    local txt = editBox:GetText()
    local desc = descBox:GetText()
    local idx = tonumber(txt)
    if idx then
      SkillTrackerDB.macros[profession][index] = { skillIndex = idx, desc = desc }
    else
      SkillTrackerDB.macros[profession][index] = { script = txt, desc = desc }
    end
    f:Hide()
    UpdateSkillRows()
  end)
end

