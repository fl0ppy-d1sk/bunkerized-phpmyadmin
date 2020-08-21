<?php

declare(strict_types=1);

// secret used when auth method is cookie
$cfg['blowfish_secret'] = '%BLOWFISH_SECRET%';

// show or not the last login : true or false
$cfg['LoginCookieRecall'] = %LOGIN_COOKIE_RECALL%;

// cookie ttl in seconds
$cfg['LoginCookieValidity'] = %LOGIN_COOKIE_VALIDITY%;

// cookie storage time inside the browser : 0 (only for the current session) or more (in seconds)
$cfg['LoginCookieStore'] = %LOGIN_COOKIE_STORE%;

// delete all cookie for all servers if one logout occurs : true or false
$cfg['LoginCookieDeleteAll'] = %LOGIN_COOKIE_DELETE_ALL%;

// policy used for sending reports to PMA maintainers : 'ask', 'always' or 'never'
$cfg['SendErrorReports'] = %SEND_ERROR_REPORTS%;

// iframe policy : true, false or 'sameorigin'
$cfg['AllowThirdPartyFraming'] = %ALLOW_THIRD_PARTY_FRAMING%;

// check for new versions : true or false
$cfg['VersionCheck'] = %VERSION_CHECK%;

// prevent users drop their databases : true or false
$cfg['AllowUserDropDatabase'] = %ALLOW_USER_DROP_DATABASE%;

// ask users to confirm when they will lost data : true or false
$cfg['Confirm'] = %CONFIRM%;

// allow users to connect to arbitrary servers : true or false
$cfg['AllowArbitraryServer'] = %ALLOW_ARBITRARY_SERVER%;

// when arbitrary servers are enabled they must match this regexp
$cfg['ArbitraryServerRegexp'] = '%ARBITRARY_SERVER_REGEXP%';

// recaptcha method : checkbox or invisible
$cfg['CaptchaMethod'] = '%CAPTCHA_METHOD%';

// recaptcha public key
$cfg['CaptchaLoginPublicKey'] = '%CAPTCHA_LOGIN_PUBLIC_KEY%';

// recaptcha private key
$cfg['CaptchaLoginPrivateKey'] = '%CAPTCHA_LOGIN_PRIVATE_KEY%';

// recaptcha site verify url (should be https://www.google.com/recaptcha/api/siteverify)
$cfg['CaptchaSiteVerifyURL'] = '%CAPTCHA_SITE_VERIFY_URL%';

// show stats about disk usage : true or false
$cfg['ShowStats'] = %SHOW_STATS%;

// show info about the server : true or false
$cfg['ShowServerInfo'] = %SHOW_SERVER_INFO%;

// show info about PHP : true or false
$cfg['ShowPhpInfo'] = %SHOW_PHP_INFO%;

// show GIT revision : true or false
$cfg['ShowGitRevision'] = %SHOW_GIT_REVISION%;

%ALL_SERVERS%

?>
