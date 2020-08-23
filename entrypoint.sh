#!/bin/sh

# check if bunkerized-phpmyadmin is already installed
if [ -f "/opt/phpmyadmin.installed" ] ; then
	exit 0
fi

# replace pattern in file
function replace_in_file() {
	# escape slashes
	pattern=$(echo "$2" | sed "s/\//\\\\\//g")
	replace=$(echo "$3" | sed "s/\//\\\\\//g")
	sed -i "s/$pattern/$replace/g" "$1"
}

# define default variables
PMA_DIRECTORY="${PMA_DIRECTORY-/}"
BLOWFISH_SECRET="${BLOWFISH_SECRET-random}"
if [ "$BLOWFISH_SECRET" = "random" ] ; then
	BLOWFISH_SECRET=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
fi
LOGIN_COOKIE_RECALL="${LOGIN_COOKIE_RECALL-false}"
LOGIN_COOKIE_VALIDITY="${LOGIN_COOKIE_VALIDITY-720}"
LOGIN_COOKIE_STORE="${LOGIN_COOKIE_STORE-0}"
LOGIN_COOKIE_DELETE_ALL="${LOGIN_COOKIE_DELETE_ALL-true}"
SEND_ERROR_REPORTS="${SEND_ERROR_REPORTS-never}"
ALLOW_THIRD_PARTY_FRAMING="${ALLOW_THIRD_PARTY_FRAMING-false}"
VERSION_CHECK="${VERSION_CHECK-false}"
ALLOW_USER_DROP_DATABASE="${ALLOW_USER_DROP_DATABASE-false}"
CONFIRM="${CONFIRM-true}"
ALLOW_ARBITRARY_SERVER="${ALLOW_ARBITRARY_SERVER-false}"
ARBITRARY_SERVER_REGEXP="${ARBITRARY_SERVER_REGEXP-}"
CAPTCHA_METHOD="${CAPTCHA_METHOD-invisible}"
CAPTCHA_LOGIN_PUBLIC_KEY="${CAPTCHA_LOGIN_PUBLIC_KEY-}"
CAPTCHA_LOGIN_PRIVATE_KEY="${CAPTCHA_LOGIN_PRIVATE_KEY-}"
CAPTCHA_SITE_VERIFY_URL="${CAPTCHA_SITE_VERIFY_URL-https://www.google.com/recaptcha/api/siteverify}"
SHOW_STATS="${SHOW_STATS-false}"
SHOW_SERVER_INFO="${SHOW_SERVER_INFO-false}"
SHOW_PHP_INFO="${SHOW_PHP_INFO-false}"
SHOW_GIT_REVISION="${SHOW_GIT_REVISION-false}"
USERPREFS_DISALLOW="${USERPREFS_DISALLOW-'VersionCheck', 'SendErrorReports', 'hide_db'}"
HIDE_PMA_VERSION="${HIDE_PMA_VERSION-yes}"
REMOVE_FILES="${REMOVE_FILES-*.md ChangeLog DCO LICENSE README RELEASE-DATE-* composer.json composer.lock config.sample.inc.php doc examples package.json yarn.lock}"
RESTRICT_PATHS="${RESTRICT_PATHS-yes}"
ZERO_CONF="${ZERO_CONF-false}"
PMA_NO_RELATION_DISABLE_WARNING="${PMA_NO_RELATION_DISABLE_WARNING-true}"
ALL_SERVERS_SSL="${ALL_SERVERS_SSL-false}"
ALL_SERVERS_HIDE_DB="${ALL_SERVERS_HIDE_DB-'^(information_schema|performance_schema)\$'}"
ALL_SERVERS_ALLOW_ROOT="${ALL_SERVERS_ALLOW_ROOT-true}"
ALL_SERVERS_ALLOW_NO_PASSWORD="${ALL_SERVERS_ALLOW_NO_PASSWORD-false}"

# move to the right directory
mkdir /opt/phpmyadmin
if [ "$PMA_DIRECTORY" = "/" ] ; then
	mv /opt/phpmyadmin-files/* /opt/phpmyadmin/
else
	mv /opt/phpmyadmin-files /opt/phpmyadmin/$PMA_DIRECTORY
fi
cp /opt/config.inc.php /opt/phpmyadmin/$PMA_DIRECTORY
chown -R root:nginx /opt/phpmyadmin
chmod -R 750 /opt/phpmyadmin

# replace variables
replace_in_file "/opt/phpmyadmin/${PMA_DIRECTORY}/config.inc.php" "%BLOWFISH_SECRET%" "$BLOWFISH_SECRET"
replace_in_file "/opt/phpmyadmin/${PMA_DIRECTORY}/config.inc.php" "%LOGIN_COOKIE_RECALL%" "$LOGIN_COOKIE_RECALL"
replace_in_file "/opt/phpmyadmin/${PMA_DIRECTORY}/config.inc.php" "%LOGIN_COOKIE_VALIDITY%" "$LOGIN_COOKIE_VALIDITY"
replace_in_file "/opt/phpmyadmin/${PMA_DIRECTORY}/config.inc.php" "%LOGIN_COOKIE_STORE%" "$LOGIN_COOKIE_STORE"
replace_in_file "/opt/phpmyadmin/${PMA_DIRECTORY}/config.inc.php" "%LOGIN_COOKIE_DELETE_ALL%" "$LOGIN_COOKIE_DELETE_ALL"
replace_in_file "/opt/phpmyadmin/${PMA_DIRECTORY}/config.inc.php" "%SEND_ERROR_REPORTS%" "$SEND_ERROR_REPORTS"
replace_in_file "/opt/phpmyadmin/${PMA_DIRECTORY}/config.inc.php" "%ALLOW_THIRD_PARTY_FRAMING%" "$ALLOW_THIRD_PARTY_FRAMING"
replace_in_file "/opt/phpmyadmin/${PMA_DIRECTORY}/config.inc.php" "%VERSION_CHECK%" "$VERSION_CHECK"
replace_in_file "/opt/phpmyadmin/${PMA_DIRECTORY}/config.inc.php" "%ALLOW_USER_DROP_DATABASE%" "$ALLOW_USER_DROP_DATABASE"
replace_in_file "/opt/phpmyadmin/${PMA_DIRECTORY}/config.inc.php" "%CONFIRM%" "$CONFIRM"
replace_in_file "/opt/phpmyadmin/${PMA_DIRECTORY}/config.inc.php" "%ALLOW_ARBITRARY_SERVER%" "$ALLOW_ARBITRARY_SERVER"
replace_in_file "/opt/phpmyadmin/${PMA_DIRECTORY}/config.inc.php" "%ARBITRARY_SERVER_REGEXP%" "$ARBITRARY_SERVER_REGEXP"
replace_in_file "/opt/phpmyadmin/${PMA_DIRECTORY}/config.inc.php" "%CAPTCHA_METHOD%" "$CAPTCHA_METHOD"
replace_in_file "/opt/phpmyadmin/${PMA_DIRECTORY}/config.inc.php" "%CAPTCHA_LOGIN_PUBLIC_KEY%" "$CAPTCHA_LOGIN_PUBLIC_KEY"
replace_in_file "/opt/phpmyadmin/${PMA_DIRECTORY}/config.inc.php" "%CAPTCHA_LOGIN_PRIVATE_KEY%" "$CAPTCHA_LOGIN_PRIVATE_KEY"
replace_in_file "/opt/phpmyadmin/${PMA_DIRECTORY}/config.inc.php" "%CAPTCHA_SITE_VERIFY_URL%" "$CAPTCHA_SITE_VERIFY_URL"
replace_in_file "/opt/phpmyadmin/${PMA_DIRECTORY}/config.inc.php" "%SHOW_STATS%" "$SHOW_STATS"
replace_in_file "/opt/phpmyadmin/${PMA_DIRECTORY}/config.inc.php" "%SHOW_SERVER_INFO%" "$SHOW_SERVER_INFO"
replace_in_file "/opt/phpmyadmin/${PMA_DIRECTORY}/config.inc.php" "%SHOW_PHP_INFO%" "$SHOW_PHP_INFO"
replace_in_file "/opt/phpmyadmin/${PMA_DIRECTORY}/config.inc.php" "%SHOW_GIT_REVISION%" "$SHOW_GIT_REVISION"
replace_in_file "/opt/phpmyadmin/${PMA_DIRECTORY}/config.inc.php" "%USERPREFS_DISALLOW%" "$USERPREFS_DISALLOW"

# include custom servers
for i in $(env | grep "^SERVERS_" | cut -d '_' -f 2 | sort -u) ; do
	ALL_SERVERS="${ALL_SERVERS}\$cfg['Servers'][$i]['ssl'] = ${ALL_SERVERS_SSL};\n"
	ALL_SERVERS="${ALL_SERVERS}\$cfg['Servers'][$i]['hide_db'] = ${ALL_SERVERS_HIDE_DB};\n"
	ALL_SERVERS="${ALL_SERVERS}\$cfg['Servers'][$i]['AllowRoot'] = ${ALL_SERVERS_ALLOW_ROOT};\n"
	ALL_SERVERS="${ALL_SERVERS}\$cfg['Servers'][$i]['AllowNoPassword'] = ${ALL_SERVERS_ALLOW_NO_PASSWORD};\n"
done
for var in $(env) ; do
	#echo "$var"
	var_name=$(echo "$var" | cut -d '=' -f 1 | cut -d '_' -f 1)
	if [ "$var_name" = "SERVERS" ] ; then
		index=$(echo "$var" | cut -d '=' -f 1 | cut -d '_' -f 2)
		param=$(echo "$var" | cut -d '=' -f 1 | cut -d '_' -f 3)
		value=$(echo "$var" | cut -d '=' -f 2)
		ALL_SERVERS="${ALL_SERVERS}\$cfg['Servers'][${index}]['${param}'] = $value;\n"
	fi
done
replace_in_file "/opt/phpmyadmin/${PMA_DIRECTORY}/config.inc.php" "%ALL_SERVERS%" "$ALL_SERVERS"

# the hackish way to hide the real version of PMA
if [ "$HIDE_PMA_VERSION" = "yes" ] ; then
	replace_in_file "/opt/phpmyadmin/${PMA_DIRECTORY}/libraries/classes/Config.php" "$PMA_VERSION" "0.0.0"
	for theme in $(ls /opt/phpmyadmin/${PMA_DIRECTORY}/themes | grep -v "dot.gif") ; do
		replace_in_file "/opt/phpmyadmin/${PMA_DIRECTORY}/themes/${theme}/theme.json" "5.0" "0.0"
	done
fi

# remove files from PMA directory
if [ -n "$REMOVE_FILES" ] ; then
	current_dir=$(pwd)
	cd /opt/phpmyadmin/${PMA_DIRECTORY}
	rm -rf $REMOVE_FILES
	cd $current_dir
fi

# include custom nginx configuration if we decided to restrict some paths
if [ "$RESTRICT_PATHS" = "yes" ] ; then
	cp /opt/pma.conf /custom-server-confs/pma.conf
	replace_pma_directory="$PMA_DIRECTORY"
	if [ "$(echo $PMA_DIRECTORY | head -c 1)" != "/" ] ; then
		replace_pma_directory="/${replace_pma_directory}"
	fi
	if [ "$(echo $PMA_DIRECTORY | tail -c 1)" != "/" ] ; then
		replace_pma_directory="${replace_pma_directory}/"
	fi
	replace_in_file "/custom-server-confs/pma.conf" "%PMA_DIRECTORY%" "$replace_pma_directory"
fi

# we're done
echo "installed" > /opt/phpmyadmin.installed
exit 0
