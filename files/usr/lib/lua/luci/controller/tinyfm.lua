module("luci.controller.tinyfm", package.seeall)
function index()
entry({"admin","nas","tinyfm"}, template("tinyfm"), _("File Manager"), 47).leaf=true
end