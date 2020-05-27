
WireToolSetup.setCategory("Input, Output/Glorified Banking")
WireToolSetup.open("gbcardreader", "Card Reader Controller", "glorifiedbanking_cardreader_controller", nil, "Card Reader Controller")

if CLIENT then
	language.Add("tool.wire_gbcardreader.name", i18n.GetPhrase("gbWireToolName"))
	language.Add("tool.wire_gbcardreader.desc", i18n.GetPhrase("gbWireToolDesc"))
	language.Add("tool.wire_gbcardreader.0", i18n.GetPhrase("gbWireToolStep1"))
	language.Add("tool.wire_gbcardreader.1", i18n.GetPhrase("gbWireToolStep2"))
end

WireToolSetup.BaseLang()
WireToolSetup.SetupMax(2)

TOOL.NoLeftOnClass = true
TOOL.ClientConVar = {
	model = "models/jaanus/wiretool/wiretool_siren.mdl"
}

WireToolSetup.SetupLinking(true)

function TOOL.BuildCPanel(panel)
	ModelPlug_AddToCPanel(panel, "Misc_Tools", "wire_gbcardreader", nil, 1)
end

WireToolSetup.close()
