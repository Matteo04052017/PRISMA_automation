<?php

$PROD = true;

if ($PROD) {
    
    /* PROD */

    $db_rdbms = "inaf_prisma";
    $db_name = 'inaf_prisma';
    $db_user = 'prisma';
    $db_pass = 'prismasecret';
    $db_host = '172.29.144.1';
    $db_port = '3306';

    date_default_timezone_set('UTC');

    define('_DB_NAME_', $db_name);
    define('_EXTLIB_', '/var/www/html/ext_lib/');
    define('_WEBROOTDIR_', '/var/www/html/');
    define('_IMGFILEURL_', 'http://34.77.178.151/img/');
    define('_FILEUPLADPATH_', '/var/www/html');
    
    define('_ENABLEWAREHOUSE_', false);

    define('_SMSMITTENTE_', '+39000000000');
    define('_SEVERNAMEC_', '34.77.178.151');
} else {
    
    /* PREPROD */

    $db_rdbms = "inaf_prisma";
    $db_name = 'inaf_prisma';
    $db_user = 'root';
    $db_pass = 'secret';
    $db_host = '172.29.144.1';
    $db_port = '3306';

    date_default_timezone_set('UTC');

    define('_DB_NAME_', $db_name);
    define('_EXTLIB_', '/var/www/inaf_prisma/ext_lib/');
    define('_WEBROOTDIR_', '/var/www/inaf_prisma/');
    define('_IMGFILEURL_', 'http://34.77.178.151/img/');
    define('_FILEUPLADPATH_', '/var/www/inaf_prisma/');
    define('_FILEEXPORTPATH_', '/var/www/inaf_prisma/export');
    
    define('_ENABLEWAREHOUSE_', false);

    define('_SMSMITTENTE_', '+39000000000');
    define('_SEVERNAMEC_', '34.77.178.151');
} 