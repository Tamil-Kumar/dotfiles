#Requires AutoHotkey v2.0

TrayTip("Ran")

SetTimer(() => MouseMove(1, 0, 0, "R"), 60000)
SetTimer(() => MouseMove(-1, 0, 0, "R"), 120000)