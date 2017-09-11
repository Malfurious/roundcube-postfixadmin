#!/bin/sh

# Set attachment size and memory limit
sed -i -e "s/<UPLOAD_MAX_SIZE>/$UPLOAD_MAX_SIZE/g" /nginx/conf/nginx.conf /php/etc/php-fpm.conf \
       -e "s/<MEMORY_LIMIT>/$MEMORY_LIMIT/g" /php/etc/php-fpm.conf
	   
# Check Required Variables.
if [ -z ${ROUND_USER} ]; then
        echo "Roundcube MySQL Username not set!"
        exit 1
fi
if [ -z ${ROUND_PASS} ]; then
        echo "Roundcube MySQL Password not set!"
        exit 1
fi
if [ -z ${ROUND_DB} ]; then
        echo "Roundcube MySQL Database Name not set!"
        exit 1
fi
if [ -z ${MAIL_HOST} ]; then
        echo "Mail Hostname not set!"
        exit 1
fi
if [ -z ${MYSQL_HOST} ]; then
        echo "MySQL Hostname not set!"
        exit 1
fi
if [ -z ${POST_USER} ]; then
        echo "Postfixadmin MySQL Username not set!"
        exit 1
fi
if [ -z ${POST_PASS} ]; then
        echo "Postfixadmin MySQL Password not set!"
        exit 1
fi
if [ -z ${POST_DB} ]; then
        echo "Postfixadmin MySQL Database not set!"
        exit 1
fi

DOMAIN=${MAIL_HOST#*.}
DBHOST=${MYSQL_HOST}
DBUSER=${POST_USER}
DBNAME=${POST_DB}
DBPASS=${POST_PASS}
SMTPHOST=${MAIL_HOST}
DISABLE_INSTALLER=${DISABLE_INSTALLER:-false}
ENABLE_IMAPS=${ENABLE_IMAPS:-true}
ENABLE_SMTPS=${ENABLE_SMTPS:-true}

# Configure Emoticons Plugin
mv /roundcube/plugins/emoticons/config.inc.php.dist /roundcube/plugins/emoticons/config.inc.php
export EMOT="\$config['emoticons_display'] = true;"
sed -i "/\$config\['emoticons_display'\]/c $EMOT" /roundcube/plugins/emoticons/config.inc.php

# Configure persistent login
export PERS="\$rcmail_config['ifpl_use_auth_tokens'] = true;"
sed -i "/\$rcmail_config\['ifpl_use_auth_tokens'\]/c $PERS" /roundcube/plugins/persistent_login/config.inc.php

# Configure managesieve
mv /roundcube/plugins/managesieve/config.inc.php.dist /roundcube/plugins/managesieve/config.inc.php
export SIVPORT="\$config['managesieve_port'] = 4190;"
export SIVHOST="\$config['managesieve_host'] = '${MAIL_HOST}';"
export SIVTLS="\$config['managesieve_usetls'] = true;"
sed -i "/\$config\['managesieve_port'\]/c $SIVPORT" /roundcube/plugins/managesieve/config.inc.php
sed -i "/\$config\['managesieve_host'\]/c $SIVHOST" /roundcube/plugins/managesieve/config.inc.php
sed -i "/\$config\['managesieve_usetls'\]/c $SIVTLS" /roundcube/plugins/managesieve/config.inc.php

# Create smarty cache folder
mkdir -p /postfixadmin/templates_c

# Configure Encryption Method
if [ -z ${PASS_CRYPT} ]; then
		echo "No Password encryption set, using SHA512-CRYPT by default."
		export PASS_CRYPT_LC="sha512-crypt"
		export PASS_CRYPT_UC="SHA512-CRYPT"
		export ENCRYPTION="dovecot:SHA512-CRYPT"
else
		echo "Using password encryption: ${PASS_CRYPT} "
		export PASS_CRYPT_LC="sha512-crypt"
		export PASS_CRYPT_UC=$(echo $PASS_CRYPT_LC | awk '{print toupper($0)}')
		export ENCRYPTION="dovecot:$PASS_CRYPT_UC"
fi

# Enabling or Disabling Installer depending on variable.
if [ ${DISABLE_INSTALLER} == "true" ]; then
        export INST="\$config['enable_installer'] = false;"
        sed -i "/roundcubemail';/a $INST" /roundcube/config/config.inc.php
        echo "Disabling Installer."
elif [ ${DISABLE_INSTALLER} == "false" ]; then
        export INST="\$config['enable_installer'] = true;"
        sed -i "/roundcubemail';/a $INST" /roundcube/config/config.inc.php
        echo "Enabling Installer."
fi

# Configure MIME Types
echo "Configuring MIME Types..."
export MIME="\$config['mime_types'] = '/nginx/conf/mime.types';"
sed -i "/roundcubemail';/a $MIME" /roundcube/config/config.inc.php
echo "MIME Types Configured!"

# Configure MySQL Connection.
echo "Configuring MySQL Connection..."
export SQL="\$config['db_dsnw'] = 'mysql://${ROUND_USER}:${ROUND_PASS}@${MYSQL_HOST}/${ROUND_DB}';"
sed -i "/roundcubemail';/c $SQL" /roundcube/config/config.inc.php
echo "MySQL Connection Configured!"

# Configure Mailserver Connection.
echo "Configuring Mailserver Connection."
if [ ${ENABLE_IMAPS} == "true" ]; then
        export IMAPS="\$config['default_host'] = 'imaps://${MAIL_HOST}';"
        sed -i "/\$config\['default_host'\]/c $IMAPS" /roundcube/config/config.inc.php
        export PRT="\$config['default_port'] = 993;"
		if grep -q "993" /roundcube/config/config.inc.php; then
				echo "Default Port already Set!"
		else
				sed -i "/imaps:\/\/${MAIL_HOST}/a $PRT" /roundcube/config/config.inc.php
		fi
        echo "IMAPS Enabled, and Server Set!"
elif [ ${ENABLE_IMAPS} == "false" ]; then
        export IMAP="\$config['default_host'] = '${MAIL_HOST}';"
        sed -i "/\$config\['default_host'\]/c $IMAP" /roundcube/config/config.inc.php
        export PRT="\$config['default_port'] = 143;"
		if grep -q "143" /roundcube/config/config.inc.php; then
				echo "Default Port already Set!"
		else
				sed -i "/ssl:\/\/${MAIL_HOST}/a $PRT" /roundcube/config/config.inc.php
		fi
        echo "IMAPS Disabled, and Server Set!"
fi
if [ ${ENABLE_SMTPS} == "true" ]; then
        export SMTPS="\$config['smtp_server'] = 'tls://${MAIL_HOST}';"
        export SMTPSPRT="\$config['smtp_port'] = 587;"
        sed -i "/\$config\['smtp_server'\]/c $SMTPS" /roundcube/config/config.inc.php
        sed -i "/\$config\['smtp_port'\]/c $SMTPSPRT" /roundcube/config/config.inc.php
        echo "SMTPS Enabled, and Server Set!"
elif [ ${ENABLE_SMTPS} == "false" ]; then
        export SMTP="\$config['smtp_server'] = '${MAIL_HOST}';"
        sed -i "/\$config\['smtp_server'\]/c $SMTP" /roundcube/config/config.inc.php
        echo "SMTPS Disabled, and Server Set!"
fi

# Configure Password/Postfixadmin plugin
echo "Configuring password plugin with Postfixadmin information."
export POST="\$config['password_db_dsn'] = 'mysql://${POST_USER}:${POST_PASS}@${MYSQL_HOST}/${POST_DB}';"
export POSTCMD="\$config['password_query'] = 'UPDATE mailbox SET password=%P WHERE username=%u LIMIT 1';"
export PASSALG="\$config['password_algorithm'] = '${PASS_CRYPT_LC}';"
export PASSPRE="\$config['password_algorithm_prefix'] = '{${PASS_CRYPT_UC}}';"
sed -i "/\$config\['password_db_dsn'\]/c $POST" /roundcube/plugins/password/config.inc.php
sed -i "/\$config\['password_query'\]/c $POSTCMD" /roundcube/plugins/password/config.inc.php
sed -i "/\$config\['password_algorithm'\]/c $PASSALG" /roundcube/plugins/password/config.inc.php
sed -i "/\$config\['password_algorithm_prefix'\]/c $PASSPRE" /roundcube/plugins/password/config.inc.php
echo "Password plugin Configured."

# Configure Enigma GPG
export GPGHOME="\$config['enigma_pgp_homedir'] = '/enigma';"
sed -i "/\$config\['enigma_pgp_homedir'\]/c $GPGHOME" /roundcube/plugins/enigma/config.inc.php

# Fix permissions
chown -R $UID:$GID /roundcube /etc/s6.d /nginx /php /var/log /enigma /postfixadmin

# Configure Listening Ports if changed.
if [ -z ${POSTFIX_PORT} ]; then
	echo "Postfix WebGUI Port not Specified, using default of 8080."
else
	echo "Postfix WebGUI Port Specified as ${POSTFIX_PORT}, configuring as such."
	sed -i "s/8080/${POSTFIX_PORT}/g" /nginx/sites-enabled/postfixadmin.conf
	echo "Postfix WebGUI Port configured!"
fi
if [ -z ${ROUNDCUBE_PORT} ]; then
	echo "Roundcube WebGUI Port not Specified, using default of 8888."
else
	echo "Roundcube WebGUI Port Specified as ${ROUNDCUBE_PORT}, configuring as such."
	sed -i "s/8888/${ROUNDCUBE_PORT}/g" /nginx/sites-enabled/roundcube.conf
	echo "Roundcube WebGUI Port configured!"
fi

# Local postfixadmin configuration file
cat > /postfixadmin/config.local.php <<EOF
<?php
\$CONF['configured'] = true;
\$CONF['database_type'] = 'mysqli';
\$CONF['database_host'] = '${DBHOST}';
\$CONF['database_user'] = '${DBUSER}';
\$CONF['database_password'] = '${DBPASS}';
\$CONF['database_name'] = '${DBNAME}';
\$CONF['encrypt'] = '${ENCRYPTION}';
\$CONF['dovecotpw'] = "/usr/bin/doveadm pw";
\$CONF['smtp_server'] = '${SMTPHOST}';
\$CONF['domain_path'] = 'YES';
\$CONF['domain_in_mailbox'] = 'NO';
\$CONF['fetchmail'] = 'YES';
\$CONF['sendmail'] = 'YES';
\$CONF['admin_email'] = 'postfixadmin@${DOMAIN}';
\$CONF['footer_text'] = 'Return to ${DOMAIN}';
\$CONF['footer_link'] = 'http://${DOMAIN}';
\$CONF['default_aliases'] = array (
  'abuse'      => 'abuse@${DOMAIN}',
  'hostmaster' => 'hostmaster@${DOMAIN}',
  'postmaster' => 'postmaster@${DOMAIN}',
  'webmaster'  => 'webmaster@${DOMAIN}'
);
\$CONF['quota'] = 'YES';
\$CONF['domain_quota'] = 'YES';
\$CONF['quota_multiplier'] = '1024000';
\$CONF['used_quotas'] = 'YES';
\$CONF['new_quota_table'] = 'YES';
\$CONF['aliases'] = '0';
\$CONF['mailboxes'] = '0';
\$CONF['maxquota'] = '0';
\$CONF['domain_quota_default'] = '500';
?>
EOF

echo "Server is now started."
echo "Roundcube is listening on port: ${ROUNDCUBE_PORT} & Postfixadmin is listening on port: ${POSTFIX_PORT}"
# RUN !
exec su-exec $UID:$GID /bin/s6-svscan /etc/s6.d
