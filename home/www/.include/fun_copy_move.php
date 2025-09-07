<?php
//------------------------------------------------------------------------------
function rename_items($dir) {		// rename

	if(Verify_csrf($GLOBALS["token"])==0) {
		show_csrf_error($GLOBALS["error_msg"]["csrferror"]);
	}	
	Generation_csrf();
	if(($GLOBALS["permissions"]&01)!=01) show_error($GLOBALS["error_msg"]["accessfunc"]);
	// rename
	$err=true;

	$tmp = stripslashes($GLOBALS['__POST']["old_name"]);
	$new = preg_replace( '/^.+[\\\\\\/]/', '', stripslashes($GLOBALS['__POST']["new_name"]) );
	$abs_item = get_abs_item($dir,$tmp);
	$abs_new_item = get_abs_item($dir,$new);
	$items = $tmp;

	// Check
	if($new=="") {
		$error= $GLOBALS["error_msg"]["miscnoname"];
		$err=false;	
	}
	if(!@file_exists($abs_item)) {
		$error= $GLOBALS["error_msg"]["itemexist"];
		$err=false;	
	}
	if(!get_show_item($dir, $tmp)) {
		$error= $GLOBALS["error_msg"]["accessitem"];
		$err=false;	
	}
	if(@file_exists($abs_new_item)) {
		$error= $GLOBALS["error_msg"]["targetdoesexist"];
		$err=false;	
	}
	if($err ===false) ajax_response($error);
	else $ok=@rename($abs_item,$abs_new_item);
	
	if($ok===true) {
		$error="success";
		$err=true;	
	}
	else
	{
		$error=$GLOBALS["error_msg"]["renameitem"];
		$err=true;	
	}
	ajax_response($error);
}
//------------------------------------------------------------------------------
?>
