# bunkerized-phpmyadmin

phpMyAdmin Docker image focused on security.

It's based based on [bunkerized-nginx](https://github.com/bunkerity/bunkerized-nginx) that adds many security features : automatic Let's Encrypt, ModSecurity, fail2ban, PHP hardening, HTTP headers ...

On top of that, bunkerized-phpmyadmin adds the following features :
- Choose a subdirectory of your choice to make it harder to find your phpMyAdmin (like https://your.server.com/hidden-directory-hard-to-guess)
- Hide the version number of phpMyAdmin
- Allow access to only the needed files (only css, js, php, ...)
- Delete unneeded files and folders (setup, doc, ...)
- Many security-related configs already set by default
- Easy to configure with environment variables
- Bring your own configuration for custom needs

# Table of contents

- [bunkerized-phpmyadmin](#bunkerized-phpmyadmin)
- [Table of contents](#table-of-contents)
- [Quickstart guide](#quickstart-guide)
  * [Basic usage](#basic-usage)
  * [HTTPS support](#https-support)
  * [More security](#more-security)
- [Environment variables](#environment-variables)
  * [Inherited from bunkerized-nginx](#inherited-from-bunkerized-nginx)
  * [Servers](#servers)
  * [All servers config](#all-servers-config)
  * [Security](#security)
  * [Information leak and privacy](#information-leak-and-privacy)
  * [Arbitrary servers](#arbitrary-servers)
  * [Cookie](#cookie)
  * [Configuration storage](#configuration-storage)
- [Custom configuration file](#custom-configuration-file)
- [TODO](#todo)

# Quickstart guide

## Basic usage

```shell
docker run -p 80:80 -e SERVER_1_host='mysql.server.com' bunkerity/bunkerized-phpmyadmin
```

It will listen on standard HTTP port and will handle connections to the server accessible from mysql.server.com (you can also use an IP address).

## HTTPS support

```shell
docker run -p 80:80 -p 443:443 -e AUTO_LETS_ENCRYPT=yes -e SERVER_NAME=phpmyadmin.mydomain.net -e REDIRECT_HTTP_TO_HTTPS=yes -e SERVER_1_host='mysql.server1.com' -e SERVER_2_host='mysql.server2.com' bunkerity/bunkerized-phpmyadmin
```

It will listen both standard HTTP and HTTPS ports and will handle connections to the servers accessible from mysql.server1.com and mysql.server2.com.

The following environment variables are inherited from [bunkerized-nginx](https://github.com/bunkerity/bunkerized-nginx) :
- `AUTO_LETS_ENCRYPT` : automatic Let's Encrypt certificate generation and renewal
- `SERVER_NAME` : your domain name (mandatory for Let's Encrypt)
- `REDIRECT_HTTP_TO_HTTPS` : all HTTP requests will be redirected to HTTPS

## More security

```shell
docker run -p 80:80 -p 443:443 -e AUTO_LETS_ENCRYPT=yes -e SERVER_NAME=phpmyadmin.mydomain.net -e REDIRECT_HTTP_TO_HTTPS=yes -e PMA_DIRECTORY=my-secret-directory CAPTCHA_LOGIN_PUBLIC_KEY=public-key-recaptcha-v3 CAPTCHA_LOGIN_PRIVATE_KEY=prviate-key-recaptcha-v3 -e SERVER_1_host='mysql.server.com' bunkerity/bunkerized-phpmyadmin
```

- `PMA_DIRECTORY` : choose a subdirectory where phpMyAdmin will be located (https://phpmyadmin.mydomain.net/my-secret-directory in this example)
- `CAPTCHA_LOGIN_PRIVATE_KEY` AND `CAPTCHA_LOGIN_PRIVATE_KEY` : the public and private keys given by Google to enable reCAPTCHA v3 on the login page

# Environment variables

## Inherited from bunkerized-nginx

All environment variables from [bunkerized-nginx](https://github.com/bunkerity/bunkerized-nginx) can be used. Feel free to do so.

## Servers

The following format is used to configure remote servers : SERVER_*index*_*config*=*value*. Here is an example :

```shell
docker run ... -e SERVER_1_host='mysql.server1.com' -e SERVER_2_host='mysql.server2.com' -e SERVER_2_port=1337 -e SERVER_3_host='mysql.server3.com' -e SERVER_3_AllowRoot=false ... bunkerity/bunkerized-phpmyadmin
```

This example will be translated to this PHP code inside the config.inc.php file :

```php
$cfg['Servers'][1]['host'] = 'mysql.server1.com';
$cfg['Servers'][2]['host'] = 'mysql.server2.com';
$cfg['Servers'][2]['port'] = 'mysql.server2.com';
$cfg['Servers'][3]['host'] = 'mysql.server3.com';
$cfg['Servers'][3]['AllowRoot'] = 'mysql.server3.com';
```

Every server connection settings listed in the documentation can be used (see https://docs.phpmyadmin.net/en/latest/config.html#server-connection-settings).

## All servers config

These settings will be applied to all of the servers defined by the `SERVER_\*` variables.

`HIDE_DB`  
PMA setting : [$cfg\['Servers'\]\[$i\]\['hide_db'\]](https://docs.phpmyadmin.net/fr/latest/config.html#cfg_Servers_hide_db)  
Values : *\<regex used to hide db\>*  
Default value : *^(information_schema|performance_schema)$*  
A regex used to hide some database from the list.

## Security

`PMA_DIRECTORY`  
Values : *\<any valid directory name\>*  
Default value :  
Use this variable to put phpMyAdmin inside a subdirectory (it will be accessible from http(s)://your.server.com/subdirectory). Can be usefull if your instance is accessible from Internet to avoid automatic scripts discovering your service.

`RESTRICT_PATHS`  
Values : *yes* | *no*  
Default value : *yes*  
If set to *yes*, clients won't be able to access files inside the following directories : libraries, locale, templates and vendor.

`MODSECURITY_CRS_EXCLUSIONS`  
Values : *yes* | *no*  
Default value : *yes*  
ModSecurity with OWASP Core Rule Set are enabled by default (inherited from bunkerity/bunkerized-nginx). If set to *yes*, will add some exclusions to CRS rules to avoid some false positives rules.

`CAPTCHA_LOGIN_PUBLIC_KEY`  
PMA setting : [$cfg\['CaptchaLoginPublicKey'\]](https://docs.phpmyadmin.net/en/latest/config.html#cfg_CaptchaLoginPublicKey)  
Values : *\<the reCAPTCHA v3 public key\>*  
Default value :  
Set your public key if you want to enable reCAPTCHA v3 protection on the login page.

`CAPTCHA_LOGIN_PRIVATE_KEY`  
PMA setting : [$cfg\['CaptchaLoginPublicKey'\]](https://docs.phpmyadmin.net/en/latest/config.html#cfg_CaptchaLoginPublicKey)  
Values : *\<the reCAPTCHA v3 private key\>*  
Default value :  
Set your private key if you want to enable reCAPTCHA v3 protection on the login page.

`CONFIRM`  
PMA setting : [$cfg\['Confirm'\]](https://docs.phpmyadmin.net/en/latest/config.html#cfg_Confirm)
Values : *true* | *false*  
Default value : *true*  
If set to *true*, users will be asked to confirm before deleting data.

`ALLOW_USER_DROP_DATABASE`  
PMA setting : [$cfg\['AllowUserDropDatabase'\]](https://docs.phpmyadmin.net/en/latest/config.html#cfg_AllowUserDropDatabase)  
Values : *true* | *false*  
Default value : *false*  
If set to *false*, users are not allowed to drop their databases within phpMyAdmin.

## Information leak and privacy

`HIDE_PMA_VERSION`  
Values : *yes* / *no*  
Default value : *yes*  
If set to *yes*, the version of phpMyAdmin will be set to 0.0.0. This is a 'hack' to prevent showing the real version to users. It hasn't been hardly tested yet to see if that breaks some features.

`REMOVE_FILES`  
Values : *\<list of files and directories to remove from phpMyAdmin separated with space\>*  
Default value : *setup \*.md ChangeLog DCO LICENSE README RELEASE-DATE-\* composer.json composer.lock config.sample.inc.php doc examples package.json setup yarn.lock*  
List of files and directories to remove inside the phpMyAdmin folder.

`SEND_ERROR_REPORTS`  
PMA setting : [$cfg\['SendErrorReports'\]](https://docs.phpmyadmin.net/en/latest/config.html#cfg_SendErrorReports)  
Values : *ask* | *always* | *never*  
Default value : *never*  
The default policy for sending error reports to the phpMyAdmin team.

`VERSION_CHECK`  
PMA setting : [$cfg\['VersionCheck'\]](https://docs.phpmyadmin.net/en/latest/config.html#cfg_VersionCheck)  
Values : *true* | *false*  
Default value : *false*  
If set to *true*, will tells users if there is an update of phpMyAdmin.

`SHOW_STATS`  
PMA setting : [$cfg\['ShowStats'\]](https://docs.phpmyadmin.net/en/latest/config.html#cfg_ShowStats)  
Values : *true* | *false*  
Default value : *false*  
If set to *true*, will show space usage and stats to the users.

`SHOW_SERVER_INFO`  
PMA setting : [$cfg\['ShowServerInfo'\]](https://docs.phpmyadmin.net/en/latest/config.html#cfg_ShowServerInfo)  
Values : *true* | *false*  
Default value : *false*  
If set to *true*, will show some information about the server to the users.

`SHOW_PHP_INFO`  
PMA setting : [$cfg\['ShowPhpInfo'\]](https://docs.phpmyadmin.net/en/latest/config.html#cfg_ShowPhpInfo)  
Values : *true* | *false*  
Default value : *false*  
If set to *true*, will show a phpinfo() to the users.

`SHOW_GIT_REVISION`  
PMA setting : [$cfg\['ShowGitRevision'\]](https://docs.phpmyadmin.net/en/latest/config.html#cfg_ShowGitRevision)  
Values : *true* | *false*  
Default value : *false*  
If set to *true*, will show the GIT revision to the users.

`USERPREFS_DISALLOW`  
PMA setting : [$cfg\['UserprefsDisallow'\]](https://docs.phpmyadmin.net/fr/latest/config.html#cfg_UserprefsDisallow)  
Values : *\<list of strings separated with ','\>*  
Default value : *'VersionCheck', 'SendErrorReports', 'hide_db'*  
List of settings that users can't override through the "settings" tab.

## Arbitrary servers

`ALLOW_ARBITRARY_SERVER`  
PMA setting : [$cfg\['AllowArbitraryServer'\]](https://docs.phpmyadmin.net/en/latest/config.html#cfg_AllowArbitraryServer)  
Values : *true* | *false*  
Default value : *false*  
If set to *true*, users can login to the servers of their choice. Use `ARBITRARY_SERVER_REGEXP` to restrict the authorized servers.

`ARBITRARY_SERVER_REGEXP`  
PMA setting : [$cfg\['ArbitraryServerRegexp'\]](https://docs.phpmyadmin.net/en/latest/config.html#cfg_ArbitraryServerRegexp)  
Values : *\<any valid regexp\>*  
Default value :  
When `ALLOW_ARBITRARY_SERVER` is set to *true*, you can restrict the servers that users can access.

## Cookie

`BLOWFISH_SECRET`  
PMA setting : [$cfg\['blowfish_secret'\]](https://docs.phpmyadmin.net/en/latest/config.html#cfg_blowfish_secret)  
Values : *\<32 characters\>* | random  
Default value : random  
The secret used to encrypt cookies, you can choose 32 chars or keep the default value *random* that will do it for you.

`LOGIN_COOKIE_RECALL`  
PMA setting : [$cfg\['LoginCookieRecall'\]](https://docs.phpmyadmin.net/en/latest/config.html#cfg_LoginCookieRecall)  
Values : *true* | *false*  
Default value : *false*  
If set to true, the previous login will appear on the connexion page.

`LOGIN_COOKIE_VALIDITY`  
PMA setting : [$cfg\['LoginCookieValidity'\]](https://docs.phpmyadmin.net/en/latest/config.html#cfg_LoginCookieValidity) 
Values : *\<any positive integer\>*  
Default value :  *3600*  
The number of seconds that a cookie is valid.

`LOGIN_COOKIE_STORE`  
PMA setting : [$cfg\['LoginCookieStore'\]](https://docs.phpmyadmin.net/en/latest/config.html#cfg_LoginCookieStore)  
Values : *0* | *\<any positive integer\>*  
Default value : *0*
The number of seconds to keep the cookie inside the browser. *0* means the cookie will only be kept for the current session.

`LOGIN_COOKIE_DELETE_ALL`  
PMA setting : [$cfg\['LoginCookieDeleteAll'\](https://docs.phpmyadmin.net/en/latest/config.html#cfg_LoginCookieDeleteAll)  
Values : *true* | *false*  
Default value : *true*  
Is set to *true*, logout from one server will also delete the cookies for the other servers.

## Configuration storage

`ZERO_CONF`  
PMA setting : [$cfg\['ZeroConf'\]](https://docs.phpmyadmin.net/en/latest/config.html#cfg_AuthLog)  
Values : *true* | *false*  
Default value : *false*  
If set to *true*, user will be able to create a configuration storage himself using an existing database.

`PMA_NO_RELATION_DISABLE_WARNING`  
PMA setting : [$cfg\['PmaNoRelation_DisableWarning'\]](https://docs.phpmyadmin.net/en/latest/config.html#cfg_PmaNoRelation_DisableWarning)  
Values : *true* | *false*  
Default value : *true*  
If set to *true*, warnings about configuration storage will not be printed.

# Custom configuration file

You can your own custom configuration file called *custom.config.inc.php* inside the PMA directory (/opt/phpmyadmin by default). The easiest way is to use a volume :

```shell
docker run ... -v /path/to/your/custom.config.inc.php:/opt/phpmyadmin/custom.config.inc.php ... bunkerity/bunkerized-phpmyadmin
```

Please note, if you set `PMA_DIRECTORY` you should adjust the destination path of the volume :

```shell
docker run ... -e PMA_DIRECTORY=hidden-pma ... -v /path/to/your/custom.config.inc.php:/opt/phpmyadmin/hidden-pma/custom.config.inc.php ... bunkerity/bunkerized-phpmyadmin
```

# TODO
- fail2ban on failed logins
- UserprefsDisallow remove quotes
