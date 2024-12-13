module("luci.controller.base64", package.seeall)
function index()
entry({"admin","services","base64"}, template("base64"), _("Base64 D/E"), 7).leaf=true
end