local AluraRanksViewer = {}

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
end

function AluraRanksViewer:OnRaidCheck(wndHandler, wndControl)
end

function AluraRanksViewer:OnRaidUncheck(wndHandler, wndControl)
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
  local wndGrid = self.wndMain:FindChild("Grid")
  wndGrid:DeleteAll()
  for _,row in ipairs(arData) do
    local nRow = wndGrid:AddRow("blah")
    wndGrid:SetCellText(nRow, 1, row[knNameColumn])
    wndGrid:SetCellText(nRow, 2, row[knRankColumn])
  end
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

function AluraRanksViewer:OnClose(wndHandler, wndControl)
  if self.wndMain and self.wndMain:IsValid() then
    self.wndMain:Destroy()
  end
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
