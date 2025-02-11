module("luci.controller.netmon", package.seeall)
function index()
entry({"admin","status","netmon"}, template("netmon"), _("Network Monitor"), 7).leaf=true
end