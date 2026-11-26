<?php
function getUserIP() {
    if (!empty($_SERVER['HTTP_X_FORWARDED_FOR'])) {
        $ip = $_SERVER['HTTP_X_FORWARDED_FOR'];
    } elseif (!empty($_SERVER['HTTP_CLIENT_IP'])) {
        $ip = $_SERVER['HTTP_CLIENT_IP'];
    } else {
        $ip = $_SERVER['REMOTE_ADDR'];
    }
    return $ip;
}

function getOS($userAgent) {
    $osArray = [
        'Windows' => 'Windows NT',
        'Mac' => 'Macintosh',
        'Linux' => 'Linux',
        'Android' => 'Android',
        'iOS' => 'iPhone|iPad'
    ];

    foreach ($osArray as $os => $pattern) {
        if (preg_match("/$pattern/i", $userAgent)) {
            return $os;
        }
    }
    return "Unknown OS";
}

function getBrowser($userAgent) {
    $browserArray = [
        'Chrome' => 'Chrome',
        'Firefox' => 'Firefox',
        'Edge' => 'Edg',
        'Safari' => 'Safari',
        'Opera' => 'Opera',
        'Internet Explorer' => 'MSIE|Trident'
    ];

    foreach ($browserArray as $browser => $pattern) {
        if (preg_match("/$pattern/i", $userAgent)) {
            return $browser;
        }
    }
    return "Unknown Browser";
}
?>

