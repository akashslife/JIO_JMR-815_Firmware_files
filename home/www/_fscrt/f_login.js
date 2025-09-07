function str_check(str) { 
  var valid = "_0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
  var invalid = "- ";
  var valid_cnt = 0;
  var c;
  if(str=='') { 
    return -2; 
  } 
  for(i=0; i<str.length; i++) { 
    c=str.charAt(i); 
    if(valid.indexOf(c) == -1) { 
      return -1; 
    } 
  } 
  for(i=0; i<str.length; i++) {
    c=str.charAt(i); 
    if(invalid.indexOf(c) == -1)  { 
      ++valid_cnt; 
    } 
  }
  if(!valid_cnt) 
    return -3; 
  return 0; 
}

function input_check() { 
  var resp = str_check(document.login.p_user.value);
    if( resp==-2 ) { 
      alert('Please enter the user ID ');
      document.login.p_user.focus();
      return false; 
    } 
  else if( resp==-1 ) { 
    alert('Invalid user ID '); 
    document.login.p_user.value=""; 
    document.login.p_user.focus();
    return false; 
  } 

  var res = str_check(document.login.p_pass.value);
    if( res==-2 ) { 
      alert('Please enter the password '); 
      document.login.p_pass.focus();
      return false; 
    } 
    else if( res==-1 ) { 
      alert('Invalid password '); 
      document.login.p_pass.value=""; 
      document.login.p_pass.focus();
      return false; 
    } 

  document.getElementById('login_btn').disabled = true; 
  document.login.submit();
  return true;    
}
