<?php
/*
 *********************************************************************************************************
 * daloRADIUS - RADIUS Web Platform
 * Copyright (C) 2007 - Liran Tal <liran@enginx.com> All Rights Reserved.
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
 *
 *********************************************************************************************************
 *
 * Authors:     Liran Tal <liran@enginx.com>
 *
 * daloRADIUS edition - fixed up variable definition through-out the code
 * as well as parted the code for the sake of modularity and ability to
 * to support templates and languages easier.
 * Copyright (C) Enginx and Liran Tal 2007, 2008
 *
 *********************************************************************************************************
 */

if ($reply == 'Your maximum never usage time has been reached') {
echo "<center><div class='notice'>Voucher anda sudah kadaluarsa";
}
else if ($reply) {
echo "<center><div class='notice'>$reply";
}
else {
echo "<center><div class='notice'>$h1Failed";
}

echo "</div>";
echo "</div></div>";
