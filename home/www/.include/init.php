<?php
//------------------------------------------------------------------------------
// Vars
if(isset($_SERVER)) {
	$GLOBALS['__GET']	=&$_GET;
	$GLOBALS['__POST']	=&$_POST;
	$GLOBALS['__SERVER']	=&$_SERVER;
	$GLOBALS['__FILES']	=&$_FILES;
} elseif(isset($HTTP_SERVER_VARS)) {
	$GLOBALS['__GET']	=&$HTTP_GET_VARS;
	$GLOBALS['__POST']	=&$HTTP_POST_VARS;
	$GLOBALS['__SERVER']	=&$HTTP_SERVER_VARS;
	$GLOBALS['__FILES']	=&$HTTP_POST_FILES;
} else {
	die("<B>ERROR: Your PHP version is too old</B><BR>".
	"You need at least PHP 4.0.0 preferably PHP 4.3.1 or higher.");
}

//------------------------------------------------------------------------------
// Get Action
if(isset($GLOBALS['__GET']["action"])) $GLOBALS["action"]=$GLOBALS['__GET']["action"];
else if(isset($GLOBALS['__POST']["action"])) $GLOBALS["action"]=$GLOBALS['__POST']["action"];
else $GLOBALS["action"]=""; //else $GLOBALS["action"]="list";
if($GLOBALS["action"]=="post" && isset($GLOBALS['__POST']["do_action"])) {
	$GLOBALS["action"]=$GLOBALS['__POST']["do_action"];
}
$GLOBALS["action"]=stripslashes($GLOBALS["action"]);

// Get Token
if(isset($GLOBALS['__GET']["token"])) $GLOBALS["token"]=$GLOBALS['__GET']["token"];
else if(isset($GLOBALS['__POST']["token"])) $GLOBALS["token"]=$GLOBALS['__POST']["token"];
else $GLOBALS["token"]="";

// Default Dir
if(isset($GLOBALS['__GET']["dir"])) $GLOBALS["dir"]=stripslashes($GLOBALS['__GET']["dir"]);
else if(isset($GLOBALS['__POST']["dir"])) $GLOBALS["dir"]=stripslashes($GLOBALS['__POST']["dir"]);
else $GLOBALS["dir"]="/";
if($GLOBALS["dir"]==".") $GLOBALS["dir"]=="";

// Get Item
if(isset($GLOBALS['__GET']["item"])) $GLOBALS["item"]=stripslashes($GLOBALS['__GET']["item"]);
else if(isset($GLOBALS['__POST']["item"])) $GLOBALS["item"]=stripslashes($GLOBALS['__POST']["item"]);
else $GLOBALS["item"]="";

// Get Sort
if(isset($GLOBALS['__GET']["order"])) $GLOBALS["order"]=stripslashes($GLOBALS['__GET']["order"]);
else $GLOBALS["order"]="name";
if($GLOBALS["order"]=="") $GLOBALS["order"]=="name";

// Get Sortorder (yes==up)
if(isset($GLOBALS['__GET']["srt"])) $GLOBALS["srt"]=stripslashes($GLOBALS['__GET']["srt"]);
else $GLOBALS["srt"]="yes";
if($GLOBALS["srt"]=="") $GLOBALS["srt"]=="yes";

//------------------------------------------------------------------------------
// Necessary files
ob_start(); // prevent unwanted output
require "./.config/conf.php";
if(isset($GLOBALS["lang"])) $GLOBALS["language"]=$GLOBALS["lang"];
require "./_lang/".$GLOBALS["language"].".php";
require "./_lang/".$GLOBALS["language"]."_mimes.php";
require "./.config/mimes.php";
require "./.include/fun_extra.php";
require "./.include/header.php";
require "./.include/error.php";
ob_end_clean(); // get rid of cached unwanted output

//------------------------------------------------------------------------------

if($GLOBALS["require_login"]) {	// LOGIN
	ob_start(); // prevent unwanted output
	require "./.include/login.php";
	ob_end_clean(); // get rid of cached unwanted output
	if($GLOBALS["action"]=="logout") {
		sd_logout(); //logout();
	} else {
		sd_login(); //login();
	}
}

//------------------------------------------------------------------------------
$abs_dir=get_abs_dir($GLOBALS["dir"]);
if(!@file_exists($GLOBALS["home_dir"])) {
	if($GLOBALS["require_login"]) {
		$extra="<A HREF=\"".make_link("logout",NULL,NULL)."\">".
			$GLOBALS["messages"]["btnlogout"]."</A>";
	} else $extra=NULL;
	show_error($GLOBALS["error_msg"]["home"],$extra);
}
if(!down_home($abs_dir)) show_error($GLOBALS["dir"]." : ".$GLOBALS["error_msg"]["abovehome"]);
if(!is_dir($abs_dir)) show_error($GLOBALS["dir"]." : ".$GLOBALS["error_msg"]["direxist"]);

//------------------------------------------------------------------------------
?>
