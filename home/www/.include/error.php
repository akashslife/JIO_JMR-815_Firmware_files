<?php
//------------------------------------------------------------------------------
function show_error($error,$extra=NULL) {		// show error-message
	echo "<html><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\"><title>".$GLOBALS["messages"]["model_title"]."</title> \n";
  echo "<meta http-equiv=\"refresh\" content=\"3;url=storage.html\" /> \n";
	echo "<script type=\"text/JavaScript\">\n";
	echo "function list_view() { \n";
	echo "location.href='storage.html';\n";
	echo "} \n";
	echo "</script>\n";
	echo "</head>\n";
	echo "<body bgcolor=white text=black link=blue vlink=purple alink=red leftmargin=0 topmargin=20 background=\"_img/common_bg.jpg\"> \n";
	echo "<table border=0 bgcolor=white width=540 height=200 cellpadding=0 cellspacing=0 align=center>";
	echo "<tr><td width=10 height=20 valign=top align=left><img src=\"_img/left_round.jpg\"></td><td width=520 height=20>&nbsp;</td>";
	echo "<td width=10 height=20 valign=top align=right><img src=\"_img/right_top_round.jpg\"></td></tr><tr><td width=10 height=160></td>";
	echo "<td width=520 height=160 align=center valign=center><table border=0 width=300 height=16 cellpadding=0 cellspacing=0>";
	echo "<tr><td colspan=2 height=30 align=center></td></tr>";
	echo "<tr><CENTER><BR>".$error."<BR><BR>";
	if($extra!=NULL) echo " - ".$extra;
	echo "<BR><BR><A HREF=\"javascript:list_view()\">".$GLOBALS["error_msg"]["back"]."</A></CENTER></tr>\n";
	echo "</table></td><td width=10 height=160></td></tr><tr><td width=10 height=20 valign=bottom  align=left><img src=\"_img/left_down_round.jpg\"></td>";
	echo "<td width=520 height=20>&nbsp;</td><td width=10 height=20 valign=bottom  align=right><img src=\"_img/right_down_round.jpg\"></td></tr></table>";

	show_footer();
	exit;
}
//------------------------------------------------------------------------------
function show_popup_error($error, $extra=NULL) {
	echo "<html><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\"><title>".$GLOBALS["messages"]["model_title"]."</title> \n";
	echo "<script type=\"text/JavaScript\">\n";
	echo "alert('$error'); ";
	echo "location.href='storage.html';\n";
	echo "</script></head><body></body><html> \n";
	exit;
}
//------------------------------------------------------------------------------
function show_csrf_error($error, $extra=NULL) {
	echo "<html><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\"><title>".$GLOBALS["messages"]["model_title"]."</title> \n";
	echo "<script type=\"text/JavaScript\">\n";
	echo "alert('$error'); ";
	echo "</script></head><body></body><html> \n";
	exit;
}

//------------------------------------------------------------------------------
function show_popup_error_with_url($error, $url=NULL) {
	if($url==NULL) {
		$url = 'frame_main.cgi?back=storage';
	}
	echo "<html><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\"><title>".$GLOBALS["messages"]["model_title"]."</title> \n";
	echo "<script type=\"text/JavaScript\">\n";
	echo "alert('$error'); ";
	echo "location.href='".$url."';\n";
	echo "</script></head><body></body><html> \n";
	exit;
}
//------------------------------------------------------------------------------
?>