local AluraRanksViewer = {
  arData = {},
  bRaidOnly = false,
  nVScrollPos = 0,
  nSortColumn = 0,
  bSortAscending = true,
}

local knColumns     = string.byte("R") - string.byte("A") + 1
local knNameColumn  = string.byte("A") - string.byte("A") + 1
local knRankColumn  = string.byte("R") - string.byte("A") + 1

function AluraRanksViewer:FindSystemChannel()
  for idx, channelCurrent in ipairs(ChatSystemLib.GetChannels()) do
    if channelCurrent:GetName() == "System" then
      self.system = channelCurrent:GetUniqueId()
    end
  end
end

function AluraRanksViewer:Print(message)
  if self.system then
    ChatSystemLib.PostOnChannel(self.system, message, "")
  else
    Print(message)
  end
end

function AluraRanksViewer:LoadMainWindow()
  if self.wndMain and self.wndMain:IsValid() then
    self.wndMain:Destroy()
  end
  self.wndMain = Apollo.LoadForm(self.xmlDoc, "Main", nil, self)
  self.wndMain:FindChild("Raid"):SetCheck(self.bRaidOnly)
  self:UpdateGrid()
end

function AluraRanksViewer:OnRaidCheck(wndHandler, wndControl)
  self.bRaidOnly = true
  self:UpdateGrid()
end

function AluraRanksViewer:OnRaidUncheck(wndHandler, wndControl)
  self.bRaidOnly = false
  self:UpdateGrid()
end

function AluraRanksViewer:OnImport(wndHandler, wndControl)
  local wndClipboard = self.wndMain:FindChild("Clipboard")
  wndClipboard:SetText("")
  wndClipboard:PasteTextFromClipboard()
  local strText = wndClipboard:GetText()
  if not strText then
    self:Print("Nothing to import")
    return
  end
  local arData = self:ParseCsv(strText)
  if not arData or #arData == 0 then
    self:Print("Failed to parse")
    return
  end
  self.arData = arData
  self:UpdateGrid()
end

function AluraRanksViewer:ParseCsv(strCsv)
  local arTable = {}
  for line in strCsv:gmatch("[^\r\n]+") do
    local arRow = {}
    for cell in line:gmatch("[^\t]+") do
      table.insert(arRow, cell)
    end
    if #arRow == knColumns then
      table.insert(arTable, arRow)
    end
  end
  return arTable
end

function AluraRanksViewer:UpdateGrid()
  local wndGrid = self.wndMain:FindChild("Grid")
  wndGrid:DeleteAll()
  if not self.arData then return end
  for _,arRow in ipairs(self.arData) do
    self:AddRow(wndGrid, arRow)
  end
  if self.nSortColumn > 0 then
    wndGrid:SetSortColumn(self.nSortColumn, self.bSortAscending)
  end
  wndGrid:SetVScrollPos(self.nVScrollPos)
end

function AluraRanksViewer:AddRow(wndGrid, arRow)
  local strName = arRow[knNameColumn]
  local strRank = arRow[knRankColumn]
  if self.bRaidOnly then
    --TODO
  end
  local nRow = wndGrid:AddRow("blah")
  wndGrid:SetCellText(nRow, 1, strName)
  wndGrid:SetCellText(nRow, 2, strRank)
  wndGrid:SetCellSortText(nRow, 2, strRank..strName)
end

function AluraRanksViewer:OnMouseButtonUp(wndHandler, wndControl)
  local wndGrid = self.wndMain:FindChild("Grid")
  self.nSortColumn = wndGrid:GetSortColumn()
  self.bSortAscending = wndGrid:IsSortAscending()
end

function AluraRanksViewer:OnMouseWheel(wndHandler, wndControl)
  local wndGrid = self.wndMain:FindChild("Grid")
  self.nVScrollPos = wndGrid:GetVScrollPos()
end

function AluraRanksViewer:OnClose(wndHandler, wndControl)
  if self.wndMain and self.wndMain:IsValid() then
    self.wndMain:Destroy()
  end
end

function AluraRanksViewer:OnSave(eLevel)
  if eLevel ~= GameLib.CodeEnumAddonSaveLevel.Realm then return nil end
  return {
    arData = self.arData,
    bRaidOnly = self.bRaidOnly,
    nSortColumn = self.nSortColumn,
    bSortAscending = self.bSortAscending,
    nVScrollPos = self.nVScrollPos,
  }
end

function AluraRanksViewer:OnRestore(eLevel, tSave)
  if eLevel ~= GameLib.CodeEnumAddonSaveLevel.Realm then return end
  self.arData = tSave.arData
  self.bRaidOnly = tSave.bRaidOnly
  self.nSortColumn = tSave.nSortColumn
  self.bSortAscending = tSave.bSortAscending
  self.nVScrollPos = tSave.nVScrollPos
end

function AluraRanksViewer:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function AluraRanksViewer:Init()
  Apollo.RegisterAddon(self)
end

function AluraRanksViewer:OnLoad()
  self.xmlDoc = XmlDoc.CreateFromFile("AluraRanksViewer.xml")
  self.xmlDoc:RegisterCallback("OnDocumentReady", self)
end

function AluraRanksViewer:OnDocumentReady()
  if not self.xmlDoc then return end
  if not self.xmlDoc:IsLoaded() then return end
  Apollo.RegisterSlashCommand("arv", "LoadMainWindow", self)
  self:FindSystemChannel()
end

local AluraRanksViewerInst = AluraRanksViewer:new()
AluraRanksViewerInst:Init()
