<?php
//------------------------------------------------------------------------------

define("GIB", 1048576);
define("MIB", 1024);


function format_sd($umount) {

	if($umount)
		@system("umount /dev/mmcblk0p1");

  @system("/usr/bin/mkfs.fat /dev/mmcblk0p1 > /dev/null");
  $fp = @popen("mount /dev/mmcblk0p1 /mnt/media 2>&1","r");
  $fr="";
  while(!feof($fp)) {
	  $line=@fread($fp,100);
	  $fr.=$line;
  }
  @pclose($fp);


	if(@strstr($fr, "does not exist")) {
		@system("echo 1 > /tmp/wifi_disk_status");
		show_popup_error("Format Fail");
	} else {
		$string_count = @strlen($fr);
		if($string_count == 0) {
			@system("echo 0 > /tmp/wifi_disk_status");
			show_popup_error("Format Success");
		} else {
			@system("echo 2 > /tmp/wifi_disk_status");
			show_popup_error("Format Fail");
		}
	}

	// exit;
}

function cal_unit($input,$to=0) {
	if($input >= GIB) {
		if($to==1) return round($input/GIB)."GB";
		else return round($input/GIB, 2)."GB";
	}
	else if($input >= MIB) {
	  	if($to==1) return round($input/MIB)."MB";
	  	else return round($input/MIB, 2)."MB";
	}
	else
		return ($input.KiB);
}

function do_format() {
	$fp = @fopen(WIFI_DISK_STATUS,"r");
	$fr = @fread($fp,1);
	@fclose($fp);

	if($fr == SD_CARD_INVALID_FS) {	// without umount
		format_sd('0');
	} else if($fr == WIFI_DISK_MOUNTED) {
		format_sd('1');
	}
}

function show_system($onlogin=NULL) {

	if($onlogin ==NULL && Verify_csrf($GLOBALS["token"])==0) {
		show_csrf_error($GLOBALS["error_msg"]["csrferror"]);
	}

//	print_r($GLOBALS["action"]);
	if($GLOBALS["action"] == "do_format")
	{
		do_format();
	}

	$fp = @popen("df | grep /dev/mmcblk0p1 | awk '{print $2, $4}'","r");
	$fr = @fread($fp,100);
	@pclose($fp);

	//print_r("SD Card Capacity: ".$fr);
	if($fr == NULL)	{
		$sd_capa = "Not Available";
		$sd_free = "Not Available";
//		$sd_capa = cal_unit("989184",0);
//		$sd_free = cal_unit("989184",0);
	}
	else {
		$cap=explode(' ',$fr);
		$sd_capa = cal_unit($cap[0],0);
		$sd_free = cal_unit($cap[1],0);
	}

//	Generation_csrf();
	echo "<html><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\"><title>".$GLOBALS["messages"]["model_title"]."</title> \n";
	echo "<script src='_fscrt/jquery-1.8.3.min.js' type='text/javascript'></script>\n";
	echo "<script src='_fscrt/f_system.js' type='text/javascript' ></script>\n";
	echo "<script type=\"text/JavaScript\">\n";
	echo "function ajax(url,target) { \n";
	echo "   if (window.XMLHttpRequest) { \n";
	echo "     req = new XMLHttpRequest(); \n";
	echo "     req.onreadystatechange = function() {ajaxDone(req);}; \n";
	echo "     req.open('GET', url, true); \n";
	echo "     if(navigator.appName =='Microsoft Internet Explorer') \n";
	echo "       req.setRequestHeader('Cookie',\"ksession=\"+getCookie(\"ksession\") ); \n";
	echo "     req.send(null); \n";
	echo "  } else if (window.ActiveXObject) { \n";
	echo "     req = new ActiveXObject('MSXML2.XMLHTTP'); \n";
	echo "     if (!req) { \n";
	echo "       req = new ActiveXObject('Microsoft.XMLHTTP'); \n";
	echo "     } \n";
	echo "     req.onreadystatechange = function() {ajaxDone(req);}; \n";
	echo "      req.open('GET', url, true); \n";
	echo "     req.setRequestHeader('Cookie',\"ksession=\"+getCookie(\"ksession\") ); \n";
	echo "     req.send(null); \n";
	echo "  } \n";
	echo "} \n";
	echo "function ajaxDone(req) { \n";
	echo "} \n";
	echo "function ajaxstart() { \n";
	echo "  var timestamp = Number(new Date()); \n";
	echo "  ajax('/sess.cgi?'+ timestamp ,null); \n";
	echo "} \n";
	echo "function start_session( ) { \n";
	echo "  setInterval('ajaxstart()', 3000); \n";
	echo "} \n";
	echo "function getCookie( name ) { \n";
	echo "  var nameOfCookie = name + \"=\"; \n";
	echo "  var x = 0; \n";
	echo "  while ( x <= document.cookie.length ) { \n";  
	echo "    var y = (x+nameOfCookie.length); \n";
	echo "    if ( document.cookie.substring( x, y ) == nameOfCookie ) {  \n";      
	echo "      if ( (endOfCookie=document.cookie.indexOf( \";\", y )) == -1 )  \n";        
	echo "        endOfCookie = document.cookie.length; \n";
	echo "      return unescape( document.cookie.substring( y, endOfCookie ) ); \n";        
	echo "    } \n";
	echo "    x = document.cookie.indexOf( \" \", x ) + 1; \n";  
	echo "    if ( x == 0 ) \n";
	echo "      break; \n";
	echo "  } \n";
	echo "  return \"\"; \n";
	echo "} \n";
	echo "window.onload=function () {\n";
	echo "  start_session(); \n";
	echo "}\n";
	echo "	$(document).keydown(function(e) {\n";
	echo "  var key = (e) ? e.keyCode : event.keyCode;\n";
	echo "  var t = document.activeElement;\n";
	echo "  if ((e.ctrlKey == true && (key == 78 || key == 82)) || key == 116 ) 	{\n"; // 116 F5 17 left control 82 R 78 N
	echo "    if (e) {\n";
	echo "      e.preventDefault();\n";
	echo "    } else {\n";
	echo "      event.keyCode = 0;\n";
	echo "      event.returnValue = false;\n";
	echo "    }\n";
	echo "  }\n";
	echo "  });\n";
	echo "</script>\n";
	echo "<style type=\"text/css\">.text_str{font-family:'HelveticaNeue-Light','Helvetica Neue Light','Helvetica Neue',Meiryo,Arial,Tahoma,Sans-serif;color:#50B6BF;}</style>\n";
	echo "</head>\n";
	echo "<body bgcolor=white text=black link=blue vlink=purple alink=red leftmargin=0 topmargin=20 background=\"_img/common_bg.jpg\" oncontextmenu=\"return false\" ondragstart=\"return false\" onselectstart=\" return false\"> \n";
	echo "<table border=0 bgcolor=white width=540 height=400 cellpadding=0 cellspacing=0 align=center>";
	echo "<input id=\"token\" type=\"hidden\" value=\"".$GLOBALS['__SESSION']['token']."\">\n";		
	echo "<tr><td width=10 height=20 valign=top align=left><img src=\"_img/left_round.jpg\"></td><td width=520 height=20>&nbsp;</td>";
	echo "<td width=10 height=20 valign=top align=right><img src=\"_img/right_top_round.jpg\"></td></tr><tr><td width=10 height=340></td>";
	echo "<td width=520 height=340 align=center valign=center><table border=0 width=300 height=112 cellpadding=0 cellspacing=0>";
	echo "<tr><td colspan=2 height=30 align=center class=text_str>SD Card</td></tr>";
	echo "<tr><td colspan=2 height=2 background=\"_img/separate_line.jpg\"><img src=\"_img/separate_line.jpg\"></td></tr>";
	echo "<tr><td colspan=2 height=10></td></tr><tr><td colspan=2 height=2 background=\"_img/separate_line.jpg\"><img src=\"_img/separate_line.jpg\"></td></tr>";
	echo "<tr><td width=200 bgcolor=#FAFFBD class=text_str>SD Capacity:</td>";
	echo "<td width=200 height=30 bgcolor=#FAFFBD class=text_str>".$sd_capa."</td></tr>";
	echo "<tr><td colspan=2 height=2 background=\"_img/separate_line.jpg\"><img src=\"_img/separate_line.jpg\"></td></tr><tr><td height=10> </td></tr>";
	echo "<tr><td bgcolor=#FAFFBD class=text_str>Free Capacity : </td><td width=200 height=30 bgcolor=#FAFFBD class=text_str>";
	echo $sd_free."</td></tr><tr><td colspan=2 height=2 background=\"_img/separate_line.jpg\"><img src=\"_img/separate_line.jpg\"></td></tr>";
	if($onlogin ==NULL) {
	echo "<tr><td colspan=2 height=10></td></tr><tr><td colspan=2 width=300 height=30 >";
		echo "<input type=image id=format_btn value=\"Format\" src=\"_img/format_btn.jpg\" align=\"left\" onclick=\"format_check();return false;\" class=text_str>"; 
		echo "<input type=image id=back_btn value=\"Back\" src=\"_img/back_btn.jpg\" align=\"right\" onclick=\"back();return false;\" class=text_str></td></tr>";
	}
	else {
	echo "<tr><td colspan=2 height=10></td></tr><tr><td colspan=2 width=300 height=30 align=center>";
		echo "<input type=image id=format_btn value=\"Format\" src=\"_img/format_btn.jpg\" align=\"center\" onclick=\"format_check();return false;\" class=text_str> ";
		echo "<A HREF=\"frame_main.cgi?back=storage\"><input type=image id=back_btn value=\"Back\" src=\"_img/back_btn.jpg\" align=\"right\" class=text_str></a></td></tr>"; 
		echo "<tr height=20></tr><tr><td colspan=2 height=30 align=center class=text_str><font color=red>".$GLOBALS["error_msg"]["invalidfs"]."</font></td></tr>";
	}
	echo "</table></td><td width=10 height=340></td></tr>";
	echo "<tr><td width=10 height=20 valign=bottom  align=left><img src=\"_img/left_down_round.jpg\"></td>";
	echo "<td width=520 height=20>&nbsp;</td><td width=10 height=20 valign=bottom  align=right><img src=\"_img/right_down_round.jpg\"></td></tr></table>";
?>
<?php
// => new
	show_footer();
	exit;
}

?>