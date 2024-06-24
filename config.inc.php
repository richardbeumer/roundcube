<?php

$config = array();

// Generals
$config['db_dsnw'] = getenv('DB_DSNW');;
$config['temp_dir'] = '/tmp/';
$config['des_key'] = getenv('SECRET_KEY');
$config['cipher_method'] = 'AES-256-CBC';
$config['identities_level'] = 0;
$config['reply_all_mode'] = 1;

// List of active plugins (in plugins/ directory)
$config['plugins'] = array(
    'archive',
    'zipdownload',
    'markasjunk',
    'managesieve',
    'enigma',
    'carddav',
    'twofactor_gauthenticator'
);

$front = getenv('FRONT_ADDRESS') ? getenv('FRONT_ADDRESS') : 'front';
$imap  = getenv('IMAP_ADDRESS')  ? getenv('IMAP_ADDRESS')  : 'imap';

// Mail servers
$config['imap_host'] = 'tls://{{ FRONT_ADDRESS or "front" }}:10143';
$config['imap_conn_options'] = array(
  'ssl'         => array(
     'verify_peer'  => false,
     'verify_peer_name' => false,
     'allow_self_signed' => true,
   ),
);
$config['smtp_host'] = 'tls://{{ FRONT_ADDRESS or "front" }}:10025';
$config['smtp_user'] = '%u';
$config['smtp_pass'] = '%p';
$config['smtp_conn_options'] = array(
  'ssl'         => array(
     'verify_peer'  => false,
     'verify_peer_name' => false,
     'allow_self_signed' => true,
   ),
);

// Sieve script management
$config['managesieve_host'] = $imap;
$config['managesieve_usetls'] = false;

// Customization settings
$config['support_url'] = getenv('WEB_ADMIN') ? '../..' . getenv('WEB_ADMIN') : '';
$config['product_name'] = 'Mailu Webmail';

// skin name: folder from skins/
$config['skin'] = 'elastic';

// Enigma gpg plugin
$config['enigma_pgp_homedir'] = '/data/gpg';

// Set From header for DKIM signed message delivery reports
$config['mdn_use_from'] = true;
$config['mdn_use_from'] = true;