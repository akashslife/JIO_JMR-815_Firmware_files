<?php
//------------------------------------------------------------------------------
require "./.include/fun_users.php";
load_users();
//------------------------------------------------------------------------------
if(isset($_COOKIE['ksession'])) session_id($_COOKIE['ksession']);
session_start();
if(isset($_SESSION)) 			$GLOBALS['__SESSION']=&$_SESSION;
elseif(isset($HTTP_SESSION_VARS))	$GLOBALS['__SESSION']=&$HTTP_SESSION_VARS;
else sd_logout(); //else logout();

//------------------------------------------------------------------------------
define("WIFI_DISK_STATUS", "/tmp/wifi_disk_status");
define("WIFI_DISK_MOUNTED", "0");
define("SD_CARD_NOT_EXIST", "1");
define("SD_CARD_INVALID_FS", "2");
define("WIFI_DISK_DISABLE", "3");
define("STORAGE_DISABLE", "4");

function sd_login() {

	if(isset($GLOBALS['__SESSION']["s_user"])) {
		if(!activate_user($GLOBALS['__SESSION']["s_user"],$GLOBALS['__SESSION']["s_pass"])) {
			sd_logout();
		}
		else {	// Check the status of SD Card after Login Success
				$fp = @fopen(WIFI_DISK_STATUS,"r");
				$fr = @fread($fp,1);
				@fclose($fp);

				if($fr == SD_CARD_NOT_EXIST)
					show_popup_error_with_url($GLOBALS["error_msg"]["withoutsd"]);
				else if($fr == SD_CARD_INVALID_FS) {
					require "./.include/fun_system.php";
					show_system("1"); //					show_popup_error_with_url($GLOBALS["error_msg"]["invalidfs"],);
				}
				else if($fr == WIFI_DISK_DISABLE)
					show_popup_error_with_url($GLOBALS["error_msg"]["wrongmode"]);
				else if($fr == STORAGE_DISABLE)
					show_popup_error_with_url($GLOBALS["error_msg"]["disablesd"]);

				if($GLOBALS['__SESSION']['token']=="0000000000") Generation_csrf();
				
		}
	} else {
		if(isset($GLOBALS['__POST']["p_pass"])) $p_pass=$GLOBALS['__POST']["p_pass"];
		else $p_pass="";
		
		if(isset($GLOBALS['__POST']["p_user"])) {
			// Check Login
			if(Verify_csrf($GLOBALS["token"])==0) {
				show_csrf_error($GLOBALS["error_msg"]["csrferror"]);
			}
			if(!activate_user(stripslashes($GLOBALS['__POST']["p_user"]), stripslashes($p_pass))) {
				show_popup_error($GLOBALS["error_msg"]["loginfail"]);
				//sd_logout();
			}
			else {	// Check the status of SD Card after Login Success
				$fp = @fopen(WIFI_DISK_STATUS,"r");
				$fr = @fread($fp,1);
				@fclose($fp);

				if($fr == SD_CARD_NOT_EXIST)
					show_popup_error_with_url($GLOBALS["error_msg"]["withoutsd"]);
				//else if($fr == SD_CARD_INVALID_FS)
				//	goto->format message in list page
				else if($fr == WIFI_DISK_DISABLE)
					show_popup_error_with_url($GLOBALS["error_msg"]["wrongmode"]);
				else if($fr == STORAGE_DISABLE)
					show_popup_error_with_url($GLOBALS["error_msg"]["disablesd"]);
			}
			return;
		} else {
/*
			{		
				Generation_csrf();

				echo "<html><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\"><title>".$GLOBALS["messages"]["model_title"]."</title> \n";
				echo "<script src='_fscrt/f_login.js' type='text/javascript' ></script>\n";
				echo "<script type=\"text/JavaScript\">\n";
//				echo "history.navigationMode = 'compatible'; \n"; 
//				echo "function noBack(){window.history.forward(0);}\n"; 
				echo "window.onload=function () {\n";
				echo "  document.login.p_user.focus(); }";
//				echo "  noBack(); }\n";
				echo "</script>\n";
				echo "<style type=\"text/css\">.text_str{font-family:'HelveticaNeue-Light','Helvetica Neue Light','Helvetica Neue',Meiryo,Arial,Tahoma,Sans-serif;color:#50B6BF;}</style>\n";
				echo "</head>\n";
				echo "<body bgcolor=white text=black link=blue vlink=purple alink=red leftmargin=0 topmargin=20 background=\"_img/common_bg.jpg\"> \n";
				echo "<table border=0 bgcolor=white width=540 height=400 cellpadding=0 cellspacing=0 align=center>";
				echo "<form name=login method=post action=\"storage.html\">";   
				echo "<input type=hidden name=action value=login> \n";
				echo "<input type=hidden name=token value=\"".$GLOBALS['__SESSION']['token']."\">\n";			
				echo "<tr><td width=10 height=20 valign=top align=left><img src=\"_img/left_round.jpg\"></td><td width=520 height=20>&nbsp;</td>";
				echo "<td width=10 height=20 valign=top align=right><img src=\"_img/right_top_round.jpg\"></td></tr><tr><td width=10 height=340></td>";
				echo "<td width=520 height=340 align=center valign=center><table border=0	width=340 height=112 cellpadding=0 cellspacing=0>";
				echo "<tr><td colspan=2 width=340 height=30 align=center class=text_str>Enter username and password to Storage</td></tr>";
				echo "<tr><td colspan=2 height=2 background=\"_img/separate_line.jpg\"><img src=\"_img/separate_line.jpg\"></td></tr>";
				echo "<tr><td colspan=2 height=10></td></tr><tr><td colspan=2 height=2 background=\"_img/separate_line.jpg\"><img src=\"_img/separate_line.jpg\"></td></tr>";
				echo "<tr><td width=100 bgcolor=#FAFFBD class=text_str>".$GLOBALS["messages"]["miscusername"].":</td>";
				echo "<td width=240 height=30 bgcolor=#FAFFBD><input type=text name=p_user size=28 class=text_str style=\"border: 0px;background-color:#FAFFBD;\"></td></tr>";
				echo "<tr><td colspan=2 height=2 background=\"_img/separate_line.jpg\"><img src=\"_img/separate_line.jpg\"></td></tr><tr><td height=10> </td></tr>";
				echo "<tr><td bgcolor=#FAFFBD class=text_str>".$GLOBALS["messages"]["miscpassword"]." : </td><td height=30 bgcolor=#FAFFBD>";
	      echo "<input type=password name=p_pass size=28  class=text_str style=\"border: 0px;background-color:#FAFFBD;\"></td></tr><tr><td colspan=2 height=2 background=\"_img/separate_line.jpg\"><img src=\"_img/separate_line.jpg\"></td></tr>";
				echo "<tr><td colspan=2 height=10></td></tr><tr><td colspan=2 width=300 height=30 align=center><input type=image id=login_btn value=\"Login\" src=\"_img/login_btn.jpg\" onclick=\"input_check();return false;\"></td></tr>";
				echo "</table></td><td width=10 height=340></td></tr></form><tr><td width=10 height=20 valign=bottom  align=left><img src=\"_img/left_down_round.jpg\"></td>";
				echo "<td width=520 height=20>&nbsp;</td><td width=10 height=20 valign=bottom  align=right><img src=\"_img/right_down_round.jpg\"></td></tr></table>";

				show_footer();
			}
*/
			{
			  echo "<html><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />\n";
			  echo "<meta http-equiv=\"Content-Script-Type\" content=\"text/javascript\" /><title></title> \n";
			  echo "<script type=\"text/javascript\"> \n";
			  echo "<!-- \n";
			  echo "function init_index() {\n";
			  echo "  document.location.href = \"frame_main.cgi\"; \n";
			  echo "}\n";
			  echo "--> \n";
			  echo "</script></head>\n";
			  echo "<body onload=\"JavaScript:init_index();\">  \n";
			  echo "</body></html>\n";
			}
			exit;
		}
	}
}
//------------------------------------------------------------------------------
function sd_logout() {
	if(Verify_csrf($GLOBALS["token"])==0) {
		show_csrf_error($GLOBALS["error_msg"]["csrferror"]);
	}
  @system("rm -rf /tmp/session/*");

	$GLOBALS['__SESSION']=array();
	session_destroy();

  echo "<html><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />\n";
  echo "<meta http-equiv=\"Content-Script-Type\" content=\"text/javascript\" /><title></title> \n";
  echo "<script type=\"text/javascript\"> \n";
  echo "<!-- \n";
  echo "function init_index() {\n";
  echo "  document.location.href = \"frame_main.cgi\"; \n";
  echo "}\n";
  echo "--> \n";
  echo "</script></head>\n";
  echo "<body onload=\"JavaScript:init_index();\">  \n";
  echo "</body></html>\n";
	exit;
}
//------------------------------------------------------------------------------
?>
