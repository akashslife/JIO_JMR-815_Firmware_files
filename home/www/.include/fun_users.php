<?php
//------------------------------------------------------------------------------
function load_users() {

	$uid =@system("uci get /etc/config/login_info.passwd.admin_id");
	$upass =@system("uci get /etc/config/login_info.passwd.admin_pw");

	$GLOBALS["users"]=array(
		array($uid,$upass,"/mnt/media","http://localhost",0,"",7,1),
	);
}
//------------------------------------------------------------------------------
function &find_user($user,$pass) {
	$cnt=count($GLOBALS["users"]);
	for($i=0;$i<$cnt;++$i) {
		if($user==$GLOBALS["users"][$i][0]) {
			if($pass==NULL || ($pass==$GLOBALS["users"][$i][1] &&
				$GLOBALS["users"][$i][7]))
			{
				return $GLOBALS["users"][$i];
			}
		}
	}
	
	return NULL;
}
//------------------------------------------------------------------------------
function activate_user($user,$pass) {
	$data=find_user($user,$pass);
	if($data==NULL) return false;
	
	// Set Login
	$GLOBALS['__SESSION']["s_user"]	= $data[0];
	$GLOBALS['__SESSION']["s_pass"]	= $data[1];
	$GLOBALS["home_dir"]	= $data[2];
	$GLOBALS["home_url"]	= $data[3];
	$GLOBALS["show_hidden"]	= $data[4];
	$GLOBALS["no_access"]	= $data[5];
	$GLOBALS["permissions"]	= $data[6];
	
	return true;
}

//------------------------------------------------------------------------------
?>