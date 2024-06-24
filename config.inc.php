<?php

/* Local configuration for Roundcube Webmail */

// ----------------------------------
// IMAP
// ----------------------------------
// The IMAP host (and optionally port number) chosen to perform the log-in.
// Leave blank to show a textbox at login, give a list of hosts
// to display a pulldown menu or set one host as string.
// Enter hostname with prefix ssl:// to use Implicit TLS, or use
// prefix tls:// to use STARTTLS.
// If port number is omitted it will be set to 993 (for ssl://) or 143 otherwise.
// Supported replacement variables:
// %n - hostname ($_SERVER['SERVER_NAME'])
// %t - hostname without the first part
// %d - domain (http hostname $_SERVER['HTTP_HOST'] without the first part)
// %s - domain name after the '@' from e-mail address provided at login screen
// For example %n = mail.domain.tld, %t = domain.tld
// WARNING: After hostname change update of mail_host column in users table is
//          required to match old user data records with the new host.
$config['imap_host'] = 'front:10143';

// ----------------------------------
// SMTP
// ----------------------------------
// SMTP server host (and optional port number) for sending mails.
// Enter hostname with prefix ssl:// to use Implicit TLS, or use
// prefix tls:// to use STARTTLS.
// If port number is omitted it will be set to 465 (for ssl://) or 587 otherwise.
// Supported replacement variables:
// %h - user's IMAP hostname
// %n - hostname ($_SERVER['SERVER_NAME'])
// %t - hostname without the first part
// %d - domain (http hostname $_SERVER['HTTP_HOST'] without the first part)
// %z - IMAP domain (IMAP hostname without the first part)
// For example %n = mail.domain.tld, %t = domain.tld
// To specify different SMTP servers for different IMAP hosts provide an array
// of IMAP host (no prefix or port) and SMTP server e.g. ['imap.example.com' => 'smtp.example.net']
$config['smtp_host'] = 'front:10025';

// Generals
$config['db_dsnw'] = 'sqlite:////data/roundcube.db';

// We access the IMAP and SMTP servers locally with internal names, SSL
// will obviously fail but this sounds better than allowing insecure login
// from the outter world
$config['imap_conn_options'] = array (
  'ssl' => 
  array (
    'verify_peer' => false,
    'verify_peer_name' => false,
  ),
);

// SMTP socket context options
// See http://php.net/manual/en/context.ssl.php
// The example below enables server certificate validation, and
// requires 'smtp_timeout' to be non zero.
// $config['smtp_conn_options'] = [
//     'ssl' => [
//         'verify_peer'  => true,
//         'verify_depth' => 3,
//         'cafile'       => '/etc/openssl/certs/ca.crt',
//     ],
// ];
// Note: These can be also specified as an array of options indexed by hostname
$config['smtp_conn_options'] = array (
  'ssl' => 
  array (
    'verify_peer' => false,
    'verify_peer_name' => false,
  ),
);

// Customization settings
$config['support_url'] = '';

// Location of temporary saved files such as attachments and cache files
// must be writeable for the user who runs PHP process (Apache user if mod_php is being used)
$config['temp_dir'] = '/tmp/';

// This key is used for encrypting purposes, like storing of imap password
// in the session. For historical reasons it's called DES_key, but it's used
// with any configured cipher_method (see below).
// For the default cipher_method a required key length is 24 characters.
$config['des_key'] = false;

// Encryption algorithm. You can use any method supported by OpenSSL.
// Default is set for backward compatibility to DES-EDE3-CBC,
// but you can choose e.g. AES-256-CBC which we consider a better choice.
$config['cipher_method'] = 'AES-256-CBC';

// Name your service. This is displayed on the login screen and in the window title
$config['product_name'] = 'Mailu Webmail';

// Set From header for DKIM signed message delivery reports
$config['mdn_use_from'] = true;

// List of active plugins (in plugins/ directory)
$config['plugins'] = ['archive', 'zipdownload', 'markasjunk', 'managesieve', 'enigma', 'carddav', 'twofactor_gauthenticator'];

// Default behavior of Reply-All button:
// 0 - Reply-All always
// 1 - Reply-List if mailing list is detected
$config['reply_all_mode'] = 1;

// Sieve script management
$config['managesieve_host'] = 'imap';

$config['managesieve_conn_options'] = array (
  'ssl' => 
  array (
    'verify_peer' => false,
    'verify_peer_name' => false,
  ),
);

// Enigma gpg plugin
$config['enigma_pgp_homedir'] = '/data/gpg';

