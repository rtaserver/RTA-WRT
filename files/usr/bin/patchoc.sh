#!/bin/bash

# patch openclash
STATUS="/usr/lib/lua/luci/view/openclash/status.htm"
DEV="/usr/lib/lua/luci/view/openclash/developer.htm"
MYIP="/usr/lib/lua/luci/view/openclash/myip.htm"
IMG="/luci-static/resources/openclash/img"
CLIENT="/usr/lib/lua/luci/model/cbi/openclash/client.lua"
CONT="/usr/lib/lua/luci/controller/openclash.lua"

[ -f "/www/${IMG}/logo.png" ] && sed -i "s#https://ftp.jaist.ac.jp/pub/sourceforge.jp/storage/g/o/op/openclash/<%=RELEASE_BRANCH%>/img/logo.png#$IMG/logo.png#g" $STATUS
[ -f "/www/${IMG}/meta.png" ] && sed -i "s#https://ftp.jaist.ac.jp/pub/sourceforge.jp/storage/g/o/op/openclash/<%=RELEASE_BRANCH%>/img/meta.png#$IMG/meta.png#g" $STATUS
[ -f "/www/${IMG}/Wiki.svg" ] && sed -i "s#https://img.shields.io/badge/Wiki--lightgrey?logo=GitBook&style=social#$IMG/Wiki.svg#g" $STATUS
[ -f "/www/${IMG}/Tutorials.svg" ] && sed -i "s#https://img.shields.io/badge/Tutorials--lightgrey?logo=Wikipedia&style=social#$IMG/Tutorials.svg#g" $STATUS
[ -f "/www/${IMG}/Star.svg" ] && sed -i "s#https://img.shields.io/badge/Star--lightgrey?logo=github&style=social#$IMG/Star.svg#g" $STATUS
[ -f "/www/${IMG}/Telegram.svg" ] && sed -i "s#https://img.shields.io/badge/Telegram--lightgrey?logo=Telegram&style=social#$IMG/Telegram.svg#g" $STATUS
[ -f "/www/${IMG}/Sponsor.svg" ] && sed -i "s#https://img.shields.io/badge/Sponsor--lightgrey?logo=ko-fi&style=social#$IMG/Sponsor.svg#g" $STATUS

if ! grep -qE "\-\- s:section|\-\-s:section" $CLIENT
then
	sed -i "s#s:section#-- s:section#g" $CLIENT
	mv $MYIP $MYIP.bak
	cat << 'EOF' > $MYIP
<!DOCTYPE html>
<html>
</html>
EOF
fi

if grep -q 'githubusercontent.com' $DEV
then
	sed -i 's#translate("Credits")#translate("")#g' $CLIENT
	mv $DEV $DEV.bak
	cat << 'EOF' > $DEV
<style>
.developer_ {
  text-align: justify;
  text-align-last: justify;
}
</style>
<fieldset class="cbi-section">
    <div class="developer_">
        <table width="100%"><tr><td>
        <span id="_Dreamacro"><%:Dreamacro%></span>
        <span id="_vernesong"><%:Vernesong%></span>
        <span id="_frainzy1477"><%:Frainzy1477%></span>
        <span id="_SukkaW"><%:SukkaW%></span>
        <span id="_lhie1_dev"><%:lhie1_dev%></span>
        <span id="_ConnersHua_dev"><%:ConnersHua_dev%></span>
        <span id="_haishanh"><%:Haishanh%></span>
        <span id="_MaxMind"><%:MaxMind%></span>
        <span id="_FQrabbit"><%:FQrabbit%></span>
        <span id="_Alecthw"><%:Alecthw%></span>
        <span id="_Tindy_X"><%:Tindy_X%></span>
        <span id="_lmc999"><%:lmc999%></span>
        <span id="_dlercloud"><%:Dlercloud%></span>
        <span id="_immortalwrt"><%:Immortalwrt%></span>
        <span id="_MetaCubeX"><%:MetaCubeX%></span>
        </td></tr></table>
    </div>
</fieldset>
EOF
fi

if ! grep -q "Config Editor" $CONT && [ -f "/www/tinyfm/tinyfm.php" ]; then
    sed -i '87 i\	entry({"admin", "services", "openclash", "editor"}, template("openclash/editor"),_("Config Editor"), 90).leaf = true' $CONT
    cat << EOF > /usr/lib/lua/luci/view/openclash/editor.htm
<%+header%>
<div class="cbi-map">
<iframe id="editor" style="width: 100%; min-height: 100vh; border: none; border-radius: 2px;"></iframe>
</div>
<script type="text/javascript">
document.getElementById("editor").src = "http://" + window.location.hostname + "/tinyfm/tinyfm.php?p=etc/openclash";
</script>
<%+footer%>
EOF
elif grep -q "Config Editor" $CONT && [ ! -f "/www/tinyfm/tinyfm.php" ]; then
	sed -i '/Config Editor/d' $CONT
fi
echo "done."
