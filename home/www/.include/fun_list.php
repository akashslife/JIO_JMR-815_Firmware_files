<?php
define("MAX_LIST", 30);
define("GIB", 1048576);
define("MIB", 1024);


//------------------------------------------------------------------------------
function trim_str($str,$from,$len)
{
    return preg_replace('#^(?:[\x00-\x7F]|[\xC0-\xFF][\x80-\xBF]+){0,'. $from .'}'.'((?:[\x00-\x7F]|[\xC0-\xFF][\x80-\xBF]+){0,'. $len .'}).*#s','$1', $str);
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

//------------------------------------------------------------------------------
function make_list($_list1, $_list2) {		// make list of files
	$list = array();

	if($GLOBALS["srt"]=="yes") {
		$list1 = $_list1;
		$list2 = $_list2;
	} else {
		$list1 = $_list2;
		$list2 = $_list1;
	}
	
	if(is_array($list1)) {
		while (list($key, $val) = each($list1)) {
			$list[$key] = $val;
		}
	}
	
	if(is_array($list2)) {
		while (list($key, $val) = each($list2)) {
			$list[$key] = $val;
		}
	}
	
	return $list;
}
//------------------------------------------------------------------------------
function make_tables($dir, &$dir_list, &$file_list, &$tot_file_size, &$num_items)
{
	
	$tot_file_size = $num_items = 0;
	
	// Open directory
	$handle = @opendir(get_abs_dir($dir));
	if($handle===false) show_error($dir.": ".$GLOBALS["error_msg"]["opendir"]);
	
	// Read directory
	while(($new_item = readdir($handle))!==false) {
		$abs_new_item = get_abs_item($dir, $new_item);
		
		if(!@file_exists($abs_new_item)) show_error($dir.": ".$GLOBALS["error_msg"]["readdir"]);
		if(!get_show_item($dir, $new_item)) continue;
		
		$new_file_size = getfilesize($abs_new_item);
		$tot_file_size += $new_file_size;
		$num_items++;
		
		if(get_is_dir($dir, $new_item)) {
			if($GLOBALS["order"]=="mod") {
				$dir_list[$new_item] =
					@filemtime($abs_new_item);
			} else {	// order == "size", "type" or "name"
				$dir_list[$new_item] = $new_item;
			}
		} else {
			if($GLOBALS["order"]=="size") {
				$file_list[$new_item] = $new_file_size;
			} elseif($GLOBALS["order"]=="mod") {
				$file_list[$new_item] =
					@filemtime($abs_new_item);
			} elseif($GLOBALS["order"]=="type") {
				$file_list[$new_item] =
					get_mime_type($dir, $new_item, "type");
			} else {	// order == "name"
				$file_list[$new_item] = $new_item;
			}
		}
	}
	closedir($handle);
	
	
	// sort
	if(is_array($dir_list)) {
		if($GLOBALS["order"]=="mod") {
			if($GLOBALS["srt"]=="yes") arsort($dir_list);
			else asort($dir_list);
		} else {	// order == "size", "type" or "name"
			if($GLOBALS["srt"]=="yes") ksort($dir_list);
			else krsort($dir_list);
		}
	}
	
	// sort
	if(is_array($file_list)) {
		if($GLOBALS["order"]=="mod") {
			if($GLOBALS["srt"]=="yes") arsort($file_list);
			else asort($file_list);
		} elseif($GLOBALS["order"]=="size" || $GLOBALS["order"]=="type") {
			if($GLOBALS["srt"]=="yes") asort($file_list);
			else arsort($file_list);
		} else {	// order == "name"
			if($GLOBALS["srt"]=="yes") ksort($file_list);
			else krsort($file_list);
		}
	}
}
//------------------------------------------------------------------------------
function make_filter_tables($dir, &$dir_list, &$file_list, &$tot_file_size, &$num_items,$file_filter)
{	
	
	// Open directory
	$handle = @opendir(get_abs_dir($dir));
	if($handle===false) show_error($dir.": ".$GLOBALS["error_msg"]["opendir"]);
	
	// Read directory
	while(($new_item = readdir($handle))!==false) {
		$abs_new_item = get_abs_item($dir, $new_item);
		
		if(!@file_exists($abs_new_item)) show_error($dir.": ".$GLOBALS["error_msg"]["readdir"]);
		if(!get_show_item($dir, $new_item)) continue;
		
		if(get_is_dir($dir, $new_item)) {
		  if($file_filter!=NULL && $file_filter!=0) {
		if($dir=='/')
	        make_filter_tables($dir.$new_item, $dir_list, $file_list, $tot_file_size, $num_items, $file_filter);
		else
 	        make_filter_tables($dir.'/'.$new_item, $dir_list, $file_list, $tot_file_size, $num_items, $file_filter);
      }else {
        $new_file_size = getfilesize($abs_new_item);
        $tot_file_size += $new_file_size;
        $num_items++;


				$dir_list[$dir.'/'.$new_item] =  $new_item;
				$dir_list[$dir.'/'.$new_item] = array(
          "name"	=> $new_item,				
          "size"	=> $new_file_size,
        	"date"	=> @filemtime($abs_new_item),
          "type"	=> get_mime_type($dir, $new_item, "type"),
        	"path"	=> $dir,
        );
      }
		} else {

		  if($new_item =="." || $new_item=="..") {
        continue;
		  }
//filter
      $needle = strrpos($new_item, ".") + 1;
      $ext = substr($new_item, $needle);
      if((($file_filter=="1") && (@preg_match('/^doc|txt|ppt|xls|pdf$/i',$ext)))
      || (($file_filter=="4") && (@preg_match('/^jpg|bmp|png|gif|jpeg$/i',$ext)))
      || (($file_filter=="2") && (@preg_match('/^mp3|wav$/i',$ext)))
      || (($file_filter=="3") && (@preg_match('/^avi|mp4|rmvb|mov|mpg|f4v|flv|3gp|wmv$/i',$ext)))
      || (($file_filter=="5") && (@preg_match('/^rar|zip$/i',$ext)))) {
      
    		$new_file_size = getfilesize($abs_new_item);
    		$tot_file_size += $new_file_size;
    		$num_items++;

				$file_list[$dir.'/'.$new_item] =  $new_item;
				$file_list[$dir.'/'.$new_item] = array(
          "name"	=> $new_item,				
          "size"	=> $new_file_size,
        	"date"	=> @filemtime($abs_new_item),
          "type"	=> get_mime_type($dir, $new_item, "type"),
        	"path"	=> $dir,
        );
 			}
 			else if($file_filter==0 || $file_filter==NULL)
 			{
    		$new_file_size = getfilesize($abs_new_item);
    		$tot_file_size += $new_file_size;
    		$num_items++;

				$file_list[$dir.'/'.$new_item] =  $new_item;
				$file_list[$dir.'/'.$new_item] = array(
          "name"	=> $new_item,				
          "size"	=> $new_file_size,
        	"date"	=> @filemtime($abs_new_item),
          "type"	=> get_mime_type($dir, $new_item, "type"),
        	"path"	=> $dir,
        );
 			}
		}
	}
	closedir($handle);

}

//------------------------------------------------------------------------------
function make_search_tables($dir, &$dir_list, &$file_list, &$tot_file_size, &$num_items,$searchname)
{
	
	// Open directory
	$handle = @opendir(get_abs_dir($dir));
	if($handle===false) show_error($dir.": ".$GLOBALS["error_msg"]["opendir"]);
	
	// Read directory
	while(($new_item = readdir($handle))!==false) {
		$abs_new_item = get_abs_item($dir, $new_item);
		
		if(!@file_exists($abs_new_item)) show_error($dir.": ".$GLOBALS["error_msg"]["readdir"]);
		if(!get_show_item($dir, $new_item)) continue;
		
		if(get_is_dir($dir, $new_item)) {
        make_search_tables($dir.'/'.$new_item, $dir_list, $file_list, $tot_file_size, $num_items, $searchname);
		} else {

		  if($new_item =="." || $new_item=="..") {
        continue;
		  }
 //     $ext = strtolower($new_item);
      $matchname = '*'.$searchname.'*';
      $pat="^".str_replace("?",".",str_replace("*",".*",str_replace(".","\.",$matchname)))."$";
      if(@eregi($pat,$new_item)) 
//      $pat="*".$searchname."*";
//      foreach(glob($pat) as $new_item) 
      {
    		$new_file_size = getfilesize($abs_new_item);
    		$tot_file_size += $new_file_size;
    		$num_items++;

				$file_list[$dir.'/'.$new_item] =  $new_item;
				$file_list[$dir.'/'.$new_item] = array(
          "name"	=> $new_item,				
          "size"	=> $new_file_size,
        	"date"	=> @filemtime($abs_new_item),
          "type"	=> get_mime_type($dir, $new_item, "type"),
        	"path"	=> $dir,
        );
 			}
		}
	}
	closedir($handle);

}

//------------------------------------------------------------------------------

function print_listtable($dir, $list, $allow, $filter, $num_items, $page_items) {	// print table of files
	if(!is_array($list)) return;

  $start_items=$page_items*MAX_LIST;
  $stop_items=($page_items+1)*MAX_LIST;

  for($i=0; $i<$num_items; $i++) {
    list($items,$subary) = each($list);
    if($i < $start_items)
     continue;
    if($i >= $stop_items)
     break;     
	  
	  while ( list($key, $val) = each($subary) ) { 
        if($key=="name") $item = $val;
        else if($key=="size") $item_size = $val;
        else if($key=="date") $item_date = $val;
        else if($key=="type") $item_type = $val;
        else if($key=="path") $item_path = $val;
    } 

		// link to dir / file
		$abs_item=get_abs_item($item_path,$item);

	echo "<thead>\n";
//checkbox	
	echo "<tr><td width=40 class=odd_even><INPUT TYPE=\"checkbox\" name=\"selitems[]\" value=\"";
  if($filter =='0') echo htmlspecialchars($item)."\" onclick=\"javascript:Toggle(this);\"></td>\n";
	else echo $item_path."/".htmlspecialchars($item)."\" onclick=\"javascript:Toggle(this);\"></td>\n";
// Icon + Link
	echo "<TD width=400 nowrap class=odd_even>";
	echo "<IMG border=\"0\" width=\"16\" height=\"16\" ";
	echo "align=\"ABSMIDDLE\" src=\"_img/".get_mime_type($dir, $item, "img")."\" ALT=\"\">&nbsp;";

	if(get_is_dir($dir, $item)) {
	  if($dir=="/")
    	    echo "<a class=\"rename\" HREF=\"javascript:current_list('".$dir.$item."',0,0);\" title=\"".$item."\">";
	  else
    	    echo "<a class=\"rename\" HREF=\"javascript:current_list('".$dir."/".$item."',0,0);\" title=\"".$item."\">";

		$s_item=$item;
		$ne_item=trim_str($s_item, 0, 46);
		if($ne_item  !==$s_item)
			$s_item=trim_str($s_item, 0, 43)."...";

  	echo htmlspecialchars($s_item)."</A></TD>\n";	// ...$extra...
 	}
 	else
 	{
	 	if($dir=="/") $dir_str=$dir;
	 	else $dir_str=$dir."/";

    echo "<span class='icon'><label>".$item_path."</label><pre class='file_name'>".$item."</pre><a class=\"rename\" href='javascript:;' title=\"".$item."\">";
		$s_item=$item;
		$ne_item=trim_str($s_item, 0, 46);
		if($ne_item  !==$s_item)
			$s_item=trim_str($s_item, 0, 43)."...";
		
    echo htmlspecialchars($s_item)."</A></span></TD>\n";	// ...$extra...
 	}
 	//option	
	echo "<td width=120 class=odd_even>\n<TABLE><tr>\n";

	// DOWNLOAD
	if(get_is_file($item_path,$item)) {
		if($allow) {
//			echo "<TD><A HREF=\"".make_link("download",$item_path,$item)."\">";
			echo "<TD><A HREF=\"javascript:download_file('".$item_path."','".$item."');\">";
			echo "<IMG border=\"0\" width=\"16\" height=\"16\" align=\"ABSMIDDLE\" ";
			echo "src=\"_img/_download.gif\" ALT=\"".$GLOBALS["messages"]["downlink"];
			echo "\" TITLE=\"".$GLOBALS["messages"]["downlink"]."\"></A></TD>\n";
		} else if(!$allow) {
			echo "<TD><IMG border=\"0\" width=\"16\" height=\"16\" align=\"ABSMIDDLE\" ";
			echo "src=\"_img/_download_.gif\" ALT=\"".$GLOBALS["messages"]["downlink"];
			echo "\" TITLE=\"".$GLOBALS["messages"]["downlink"]."\"></TD>\n";
		}
	} else {
		echo "<TD><IMG border=\"0\" width=\"16\" height=\"16\" align=\"ABSMIDDLE\" ";
		echo "src=\"_img/_.gif\" ALT=\"\"></TD>\n";
	}
	// Rename
	echo "<TD><A HREF=# onclick=\"Rename_file('".$item_path."','".$item."');return false\"><IMG border=\"0\" width=\"16\" height=\"16\" ";
	echo "align=\"ABSMIDDLE\" src=\"_img/_rename.gif\" ALT=\"".$GLOBALS["messages"]["renamelink"];
	echo "\" TITLE=\"".$GLOBALS["messages"]["renamelink"]."\"></A></TD>\n";
	
	// Delete
	if(get_is_file($item_path,$item)) {
  	echo "<TD><A HREF=# onclick=\"Delete_item('".$item_path."','".$item."',0);\"><IMG border=\"0\" width=\"16\" height=\"16\" ";
  	echo "align=\"ABSMIDDLE\" src=\"_img/_delete.gif\" ALT=\"".$GLOBALS["messages"]["dellink"];
  	echo "\" TITLE=\"".$GLOBALS["messages"]["dellink"]."\"></A></TD>\n";
  }
  else
  {
  	echo "<TD><A HREF=# onclick=\"Delete_item('".$item_path."','".$item."',1);\"><IMG border=\"0\" width=\"16\" height=\"16\" ";
  	echo "align=\"ABSMIDDLE\" src=\"_img/_delete.gif\" ALT=\"".$GLOBALS["messages"]["dellink"];
  	echo "\" TITLE=\"".$GLOBALS["messages"]["dellink"]."\"></A></TD>\n";
  }
	echo "</tr></TABLE>\n</td>";
//size
	if(get_is_dir($dir, $item)) echo "<td width=100 nowrap class=odd_even>-</td>\n";
	else echo "<td width=100 nowrap class=odd_even>".parse_file_size($item_size)."</td>\n";
//add date
	if($GLOBALS["action"]=="list") {
	  if($filter =='0')
    	echo "<td width=200 nowrap class=odd_even>".parse_file_date($item_date)."</td>\n";
    else {
	  	echo "<td width=200 nowrap class=odd_even title=\"".$item_path."\">";
  	$needle=strrpos($item_path,"/");
    $path_item = substr($item_path, $needle);
		$ne_item=trim_str($path_item, 0, 16);
		if($ne_item  !==$path_item)		
  		$path_item=trim_str($path_item, 0,	13)."...";
  	echo htmlspecialchars($path_item)."</td>\n";
   	}
 	}
	else if($GLOBALS["action"]=="search") {
  	echo "<td width=200 class=odd_even>";
  	$needle=strrpos($item_path,"/");
    $path_item = substr($item_path, $needle);
		$ne_item=trim_str($path_item, 0, 16);
		if($ne_item  !==$path_item)		
  		$path_item=trim_str($path_item, 0,	13)."...";

  	echo htmlspecialchars($path_item)."</td>\n";
  }
	echo "</tr>	\n";
	echo "</thead>\n";

	}
}
//------------------------------------------------------------------------------
// MAIN FUNCTION
function list_dir($dir) {			// list directory contents

	$allow=($GLOBALS["permissions"]&01)==01;
	$admin=((($GLOBALS["permissions"]&04)==04) || (($GLOBALS["permissions"]&02)==02));

	if($GLOBALS["action"]!=""  && $GLOBALS["action"]!='login') {
  		if(Verify_csrf($GLOBALS["token"])==0) {
  			show_csrf_error($GLOBALS["error_msg"]["csrferror"]);
  		}
	}

	$dir_up = dirname($dir);
	if($dir_up==".") $dir_up = "";
	$show_dir = preg_replace( '/^.+[\\\\\\/]/', '', $dir ); //basename($dir);
	if(!get_show_item($dir_up,$show_dir)) show_error($dir." : ".$GLOBALS["error_msg"]["accessdir"]);
	
	$tot_file_size = $num_items = 0;
  if(($GLOBALS["action"]!="search") && ($GLOBALS["action"]!="list")) $GLOBALS["action"]="list";
  if($GLOBALS["action"]=="list")
  {
  	if(isset($GLOBALS['__POST']["filter"])) $file_filter = stripslashes($GLOBALS['__POST']["filter"]);
  	else $file_filter="0";
	$searchitem="";
   	make_filter_tables($dir, $dir_list, $file_list, $tot_file_size, $num_items ,$file_filter);
 	}
 	else if($GLOBALS["action"]=="search")
 	{
  	if(isset($GLOBALS['__POST']["searchitem"])) {
  		$searchitem=stripslashes($GLOBALS['__POST']["searchitem"]);
 		}
 		$file_filter="0";
    make_search_tables ($dir, $dir_list, $file_list, $tot_file_size, $num_items ,$searchitem); 
 	}

	if(isset($GLOBALS['__POST']["page"])) $page_items = stripslashes($GLOBALS['__POST']["page"]);
	else 	$page_items="0";

	$s_dir=$dir;		if(strlen($s_dir)>50) $s_dir="...".substr($s_dir,-47);

//<--
	
	echo "<html><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\">";
	echo "<meta http-equiv=\"X-UA-Compatible\" content=\"IE=9; IE=8; IE=7; IE=EDGE,chrome=1\">\n";
	echo "<title>".$GLOBALS["messages"]["model_title"]."</title> \n";
	echo "<script src='_fscrt/jquery-1.8.3.min.js' type='text/javascript'></script>\n";
	echo "<link rel=stylesheet type='text/css' href='_fscrt/storage.css'> \n";
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
	echo "</script>\n";
	echo "</head>\n";
	echo "<body  style=\"overflow:hidden\" oncontextmenu=\"return false\" ondragstart=\"return false\" onselectstart=\" return false\">\n";

	echo "<div style=\"height:60px;background-image:url('../image/mainTop/top_background.jpg');\">\n"; 
	echo "<div style=\"position:relative;top:10px;\" align=center valign=middle><img src=\"../image/mainTop/top_logo.jpg\" border=0></div>";
	echo "<div style=\"position:relative;top:-25px;\"valign=middle><A HREF=\"javascript:current_list('".$dir."',".$file_filter.",".$page_items.");\"><button id=\"btn_refresh\" style=\"position:relative;\">Refresh</button></a></div>\n";
	echo "<div style=\"position:relative;top:-54px;right:130px;\"valign=middle><A HREF=\"frame_main.cgi?back=storage\"><button id=\"btn_back\" style=\"position:relative;float:right;\">Back WebCM</button></a></div>\n";
	echo "<div style=\"position:relative;top:-54px;right:-120px;\"valign=middle><a HREF=\"javascript:log_out();\"><button id=\"log_out\" style=\"position:relative;float:right;\">Log-out</button></a></div>\n";
	echo "</div>\n";

	echo "<div style=\"width:18%;height:90%-60px;postion:absolute;float:left;background:#eee;\">\n";
	echo "<div id=\"filter_div\" style=\"height:90%-60px;margin-top:8px;\">\n";

	if($file_filter =='0') {
  	echo "<a class=\"filter_sel\" title=\"All Files\" HREF=\"javascript:current_list('/',0,0);\">";
		echo "<img alt=\"all\" class=\"all\" src=\"_img/default.gif\" style=\"border:0px;\"/><span id=\"file_cate_text\">All Files</span></a>\n";
	}else {
	  echo "<a class=\"filter\" title=\"All Files\" HREF=\"javascript:current_list('/',0,0);\">";
		echo "<img alt=\"all\" class=\"all_gray\" src=\"_img/default.gif\" style=\"border:0px;\"/><span id=\"file_cate_text\">All Files</span></a>\n";
	}

	if($file_filter =='1') 	{
  	echo "<a class=\"filter_sel\" title=\"All Documents\" HREF=\"javascript:current_list('/',1,0);\">";
  	echo "<img alt=\"doc\" class=\"doc\" src=\"_img/default.gif\" style=\"border:0px;\"/><span id=\"file_cate_text\">Document</span></a>\n";
 	}
	else {
		echo "<a class=\"filter\" title=\"All Documents\" HREF=\"javascript:current_list('/',1,0);\">";
		echo "<img alt=\"doc\" class=\"doc_gray\" src=\"_img/default.gif\" style=\"border:0px;\"/><span id=\"file_cate_text\">Document</span></a>\n";
	}

	if($file_filter =='2') 	{
	  echo "<a class=\"filter_sel\" title=\"All Audios\" HREF=\"javascript:current_list('/',2,0);\">";
	  echo "<img alt=\"audio\" class=\"au\" src=\"_img/default.gif\" style=\"border:0px;\"/><span id=\"file_cate_text\">Audio</span></a>\n";
  }
 	else {
	  echo "<a class=\"filter\" title=\"All Audios\" HREF=\"javascript:current_list('/',2,0);\">";
		echo "<img alt=\"audio\" class=\"au_gray\" src=\"_img/default.gif\" style=\"border:0px;\"/><span id=\"file_cate_text\">Audio</span></a>\n";
	}

	if($file_filter =='3') 	{
  	echo "<a class=\"filter_sel\" title=\"All Videos\" HREF=\"javascript:current_list('/',3,0);\">";
  	echo "<img alt=\"video\" class=\"mv\" src=\"_img/default.gif\" style=\"border:0px;\"/><span id=\"file_cate_text\">Video</span></a>\n";
  }
  else {
	  echo "<a class=\"filter\" title=\"All Videos\" HREF=\"javascript:current_list('/',3,0);\">";
		echo "<img alt=\"video\" class=\"mv_gray\" src=\"_img/default.gif\" style=\"border:0px;\"/><span id=\"file_cate_text\">Video</span></a>\n";
	}

	if($file_filter =='4') 	{
  	echo "<a class=\"filter_sel\" title=\"All Images\" HREF=\"javascript:current_list('/',4,0);\">";
		echo "<img alt=\"image\" class=\"img\" src=\"_img/default.gif\" style=\"border:0px;\"/><span id=\"file_cate_text\">Image</span></a>\n";
 	}
 	else {
	  echo "<a class=\"filter\" title=\"All Images\" HREF=\"javascript:current_list('/',4,0);\">";
		echo "<img alt=\"image\" class=\"img_gray\" src=\"_img/default.gif\" style=\"border:0px;\"/><span id=\"file_cate_text\">Image</span></a>\n";
	}

	if($file_filter =='5') 	{
  	echo "<a class=\"filter\" title=\"All Packages\" HREF=\"javascript:current_list('/',5,0);\">";
		echo "<img alt=\"zip\" class=\"zip\" src=\"_img/default.gif\" style=\"border:0px;\"/><span id=\"file_cate_text\">Package</span></a>\n";
 	}
 	else {
	  echo "<a class=\"filter\" title=\"All Packages\" HREF=\"javascript:current_list('/',5,0);\">";
		echo "<img alt=\"zip\" class=\"zip_gray\" src=\"_img/default.gif\" style=\"border:0px;\"/><span id=\"file_cate_text\">Package</span></a>\n";
	}
	echo "<hr>\n";
	echo "<a HREF=\"javascript:sd_set();\"><button id=\"sd_set\" >System</button></a>\n";
	echo "&nbsp;&nbsp;&nbsp;<a HREF=\"help.html#index2\" target=\"_blank\"><button>help</button></a>\n";
	echo "<div id='list'></div>\n";

	echo "</div>\n";
	echo "</div>\n";

	echo "<div style=\"position: relative;margin-left:0px;margin-top:-30px;width:82%;height:90%-60px;border:0px solid red;float:right;\">\n";
	echo "<span id=\"browser_tips\" style=\"font-size:12px;margin-left:30px;color:red;display:none;\">Tips:&nbsp; For better performance,we recommend using <b>Chrome /Firefox / Safari / 	IE10+</b></span>";
	echo "<div>\n";

	$fp = @popen("df | grep /dev/mmcblk0p1 | awk '{print $2, $4}'","r");
	$fr = @fread($fp,100);
	@pclose($fp);

	if($fr == NULL)	{
		$sd_capa = " - ";
		$sd_free = " - ";
	}
	else {
		$cap=explode(' ',$fr);
		$sd_capa = cal_unit($cap[0],0);
		$sd_free = cal_unit($cap[1],0);
	}


//	if($GLOBALS['WIFI_HOST']=='1')
	echo " <a class=\"upload_btn\">Upload</a>\n";

	echo "<a class=\"new_folder\">New Folder</a>\n";
	echo "<input name=curr_path id=curr_path type=hidden value='".$dir."' />\n";
	echo "<form id=\"form_search\" style=\"display:inline-block;*display:inline;zoom:1;\"><input name=dir type=hidden value='".$dir."'><input name=searchitem id=\"search\" type=\"search\" value='".$searchitem ."' onkeydown =\"javascript:if(event.keyCode==13)search_file(this.value, 0);\" title=\"please input filename you want to search\" results=5  placeholder=\"search filename..\" /></form>\n";
	echo "<span class=\"free_space\"><b><font color=blue> ".$sd_free."</font></b> free of<b><font color=blue> ".$sd_capa."</font></b></span>\n";
	echo "</div>\n";
	if($GLOBALS["action"]=="search") {
	echo "<div id=\"cpath\">[ ".$searchitem." :: ".$dir." ]</div>\n";
	}else {
  	if($file_filter =='0') {
  	  if($dir=='/' || $dir=='')
        	echo "<div id=\"cpath\">All Files</div>\n";
  	  else
      		echo "<div id=\"cpath\"><a HREF=\"javascript:current_list('".dirname($dir)."',0,0);\"><button_s id=\"btn_updir\" style=\"position:relative;float:left;\">Up dir</button_s></a>&nbsp;&nbsp;&nbsp;..".$dir."</div>\n";
  	} else
  	  echo "<div id=\"cpath\">All Files</div>\n";
	}
	echo "<FORM name=\"selform\" id=\"selform\" method=\"POST\" action=\"storage.html\">\n";
	echo "<input type=hidden name=action value=delete>\n";
	echo "<input name=token id=\"token\" type=\"hidden\" value=\"".$GLOBALS['__SESSION']['token']."\">\n";		
	echo "<input type=hidden name=dir value='".$dir."'>\n";
	echo "<div style=\"width:100%;height:30;float:left;\">\n";
	echo "<table style=\"width:100%\" border=\"0\" cellspacing=\"0\" cellpadding=\"0\" class=\"fu_list\" >\n";
	echo "<thead>\n";
	echo "<tr><td id=\"idcheck\" width=40><input type=\"checkbox\" name=toggleAllC id=\"cbAll\" onclick=\"javascript:ToggleAll(this);\"/> </td>\n";

	echo "<td id=\"idTitle\" width=400 nowrap>Name</td>\n";
	echo "<td id=\"idOp\" width=120 nowrap>&nbsp;&nbsp;Actions&nbsp;";
	// Delete
	echo "<A HREF=# onclick=\"Delete_lists();\"><IMG border=\"0\" width=\"16\" height=\"16\" ";
	echo "align=\"ABSMIDDLE\" src=\"_img/_deleteall.gif\" ALT=\"".$GLOBALS["messages"]["dellink"];
	echo "\" TITLE=\"".$GLOBALS["messages"]["delalllink"]."\"></A>\n";
	echo "</td>";
 	echo "<td id=\"idSize\" width=100 nowrap>Size</td>\n";

	if($GLOBALS["action"]=="list") {
	  if($file_filter =='0')
  	  echo "<td id=\"idAddtime\" width=200 nowrap>Modified</td>\n";
  	else
  	  echo "<td id=\"idAddtime\" width=200 nowrap>Directory</td>\n";
	} 
	else if($GLOBALS["action"]=="search")
  	echo "<td id=\"idSize\" width=200 nowrap>Directory</td>\n";
	

	echo "</tr>\n";
	echo "</thead>\n";
	echo "</table></div>\n";
	echo "<div id=ie9_div class='table_div'>\n";
	echo "<table style=\"margin-top:0px;\" border=\"0\" cellspacing=\"0\" cellpadding=\"0\" class=\"fu_list\" id=\"idTable\">\n";
	echo "<tbody id=\"tb_body\">\n";
	// make & print Table using lists

	print_listtable($dir, make_list($dir_list, $file_list), $allow, $file_filter, $num_items, $page_items);

	echo "</tbody>\n";
	echo "</table>\n";
	echo "</div></form>\n";
	echo "</div>\n";
	echo "<div style=\"clear:both;width:100%;height:40px;background:#ddd;\">\n";
	echo "<input name=curr_cmd id=curr_cmd type=hidden value='".$GLOBALS["action"]."' />\n";
	echo "<input name=curr_fil id=curr_fil type=hidden value='".$file_filter."' />\n";
	echo "<div id=\"page_href\">\n";
	$page = ceil($num_items/MAX_LIST);
	for($i=1; $i<=$page;$i++) {
	if($i==$page_items+1) 	echo "<span>".$i."</span>\n"; 
	else echo "<a>".$i."</a>\n"; }
	echo "</div>\n";
	echo "</div>\n";

//	if($GLOBALS['WIFI_HOST']=='1')	
	echo "<script src='_fscrt/f_list.js' type='text/javascript' ></script>\n";
//	else
//	echo "<script src='_fscrt/f_lists.js' type='text/javascript' ></script>\n";
	echo "</body>\n";
}
//------------------------------------------------------------------------------
?>
