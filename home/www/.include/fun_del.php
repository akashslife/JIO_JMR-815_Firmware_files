<?php
//------------------------------------------------------------------------------
function del_items($dir) {		// delete files/dirs

	if(Verify_csrf($GLOBALS["token"])==0) {
		show_csrf_error($GLOBALS["error_msg"]["csrferror"]);
	}	
	Generation_csrf();
	
	if(($GLOBALS["permissions"]&01)!=01) show_error($GLOBALS["error_msg"]["accessfunc"]);
	if(isset($GLOBALS['__POST']["selitems"])){
  	  $cnt=count($GLOBALS['__POST']["selitems"]);
  	  $m_list = 1;
  	} else if(isset($GLOBALS['__POST']["item"])) {
  	  $cnt=count($GLOBALS['__POST']["item"]);
  	  $m_list = 0;
 	}
	$err=false;
	
	// delete files & check for errors
	for($i=0;$i<$cnt;++$i) {
  	if($m_list == 1)
  		$items[$i] = stripslashes($GLOBALS['__POST']["selitems"][$i]);
  	else
  		$items[$i] = stripslashes($GLOBALS['__POST']["item"]);
		$abs = get_abs_item($dir,$items[$i]);

		if(!@file_exists($abs)) {
			$error[$i]=$GLOBALS["error_msg"]["itemexist"];
			$err=true;	continue;
		}
		if(!get_show_item($dir, $items[$i])) {
			$error[$i]=$GLOBALS["error_msg"]["accessitem"];
			$err=true;	continue;
		}
		
		// Delete
		$ok=remove($abs);
		
		if($ok===false) {
			$error[$i]=$GLOBALS["error_msg"]["delitem"];
			$err=true;	continue;
		}
		
		$error[$i]=NULL;
	}
	
	if($err) {			// there were errors
		$err_msg="";
		for($i=0;$i<$cnt;++$i) {
			if($error[$i]==NULL) continue;
			
			$err_msg .= $items[$i]." : ".$error[$i]."<BR>\n";
		}
		ajax_response($error); //show_error($err_msg);
	}
	else
		ajax_response("success"); //show_error("Delete success");	
}
//------------------------------------------------------------------------------
?>
