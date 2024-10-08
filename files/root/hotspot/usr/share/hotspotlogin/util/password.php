<?php    
    
    /**
     * Get a RADIUS encrypted password from a plaintext password, shared secret, and request authenticator.
     * This method should generally not need to be called directly.
     *
     * @param string $password The plain text password
     * @param string $secret   The RADIUS shared secret
     * @param string $requestAuthenticator  16 byte request authenticator
     * @return string  The encrypted password
     */
    function getEncryptedPassword($password, $secret, $requestAuthenticator)
    {
        $encryptedPassword = '';
        $paddedPassword    = $password;
        if (0 != (strlen($password) % 16)) {
            $paddedPassword .= str_repeat(chr(0), (16 - strlen($password) % 16));
        }
        $previous = $requestAuthenticator;
        for ($i = 0; $i < (strlen($paddedPassword) / 16); ++$i) {
            $temp = md5($secret . $previous);
            $previous = '';
            for ($j = 0; $j <= 15; ++$j) {
                $value1 = ord(substr($paddedPassword, ($i * 16) + $j, 1));
                $value2 = hexdec(substr($temp, 2 * $j, 2));
                $xor_result = $value1 ^ $value2;
                $previous .= chr($xor_result);
            }
            $encryptedPassword .= $previous;
        }
        return $encryptedPassword;
    }
    
    function getEncryptedPasswordOther($password, $secret, $requestAuthenticator)
    {
        return chilli_response($password, $secret, $requestAuthenticator);
    }
    
    function getEncryptedPasswordPAP($password, $secret, $requestAuthenticator)
    {
        return chilli_response($password, $secret, $requestAuthenticator, $type="pap");
    }
    
    function getEncryptedPasswordMSCHAP($password, $secret, $requestAuthenticator, $username)
    {
        return chilli_response($password, $secret, $requestAuthenticator, "mschapv2", $username);
    }
    
    function chilli_response($password, $secret, $requestAuthenticator, $type="",  $username="")
    {
        $retval = "";
        $result = "";
        if(empty($type)){
            $result = exec("/usr/sbin/chilli_response $requestAuthenticator $secret $password", $retval);
        }else if($type=="pap"){
            $result = exec("/usr/sbin/chilli_response -pap $requestAuthenticator $secret $password", $retval);
        }else if($type=="mschapv2" && !empty($username)){
            $result = exec("/usr/sbin/chilli_response -nt $requestAuthenticator $secret $username $password", $retval);
        }
        
        return $result;
    }
