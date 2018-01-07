local AluraRanksViewer = {}

function AluraRanksViewer:LoadMainWindow()
  if self.wndMain and self.wndMain:IsValid() then
    self.wndMain:Destroy()
  end
  self.wndMain = Apollo.LoadForm(self.xmlDoc, "Main", nil, self)
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
  -- Apollo.RegisterSlashCommand("arv", "LoadMainWindow", self)
end

local AluraRanksViewerInst = AluraRanksViewer:new()
AluraRanksViewerInst:Init()
