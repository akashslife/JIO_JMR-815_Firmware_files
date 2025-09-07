<?php
//------------------------------------------------------------------------------
function show_header($title) {			// header for html-page
	header("Expires: Mon, 26 Jul 1997 05:00:00 GMT");
	header("Last-Modified: " . gmdate("D, d M Y H:i:s") . " GMT");
	header("Cache-Control: no-cache, must-revalidate");
	header("Pragma: no-cache");
	header("Content-Type: text/html; charset=".$GLOBALS["charset"]);
	
	echo "<HTML lang=\"".$GLOBALS["language"]."\" dir=\"".$GLOBALS["text_dir"]."\">\n";
	echo "<HEAD>\n<meta http-equiv=\"Content-Type\" content=\"text/html; charset=".$GLOBALS["charset"]."\">\n";
	echo "</HEAD>\n<BODY><center>\n<table border=\"0\" width=\"100%\" cellspacing=\"0\" cellpadding=\"5\"><tbody>\n";
	echo "<tr><td class=\"title\">";
	if($GLOBALS["require_login"] && isset($GLOBALS['__SESSION']["s_user"])) echo "[".$GLOBALS['__SESSION']["s_user"]."] - ";
	echo $title."</td></tr></tbody></table>\n\n";
}

function show_footer() {			// footer for html-page
	echo "\n</BODY>\n</HTML>";
}

//------------------------------------------------------------------------------
?>
