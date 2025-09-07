<?php
//------------------------------------------------------------------------------
function make_item($dir) {		// make new directory or file
	if(($GLOBALS["permissions"]&01)!=01) show_error($GLOBALS["error_msg"]["accessfunc"]);

	if(Verify_csrf($GLOBALS["token"])==0) {
		show_csrf_error($GLOBALS["error_msg"]["csrferror"]);
	}
	Generation_csrf();

	$mkname=$GLOBALS['__POST']["mkname"];
	$mktype=$GLOBALS['__POST']["mktype"];
	
	$mkname=preg_replace( '/^.+[\\\\\\/]/', '', stripslashes($mkname) ); //basename(stripslashes($mkname));
	if($mkname=="")  { 
		$ok=false;
		$err=$GLOBALS["error_msg"]["miscnoname"];
		ajax_response($err);
	}
	
	$new = get_abs_item($dir,$mkname);
	if(@file_exists($new))  { 
		$ok=false;
		$err=$GLOBALS["error_msg"]["itemdoesexist"];
		ajax_response($err);
	}
	
	if($mktype!="file") {
		$ok=@mkdir($new, 0777);
		$err=$GLOBALS["error_msg"]["createdir"];
	} else {
		$ok=@touch($new);
		$err=$GLOBALS["error_msg"]["createfile"];
	}
	if($ok==true)
		$err="success";
	
	ajax_response($err);
}
//------------------------------------------------------------------------------
?>