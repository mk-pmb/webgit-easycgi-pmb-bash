<?php # -*- coding: utf-8, tab-width: 2 -*-

http_response_code(500);
header('Content-Type: text/plain; charset=UTF-8');

$cfg = [
#=== Config starts here ===#
# For descriptions of the available settings, please refer to cfg.defaults.rc.

  'share_sh_path' => 'webgit-easycgi-pmb/../../share.sh',






#=== Config ends here ===#
];

# Anyone considering to extend this to full CGI capabilities, have a look at
# https://github.com/mk-pmb/phutility-160816-pmb/blob/master/web/cgi-emu.php

function env_export_dict($dict, $prefix='') {
  foreach ($dict as $key => $val) {
    if (is_array($val)) { $val = implode("\n", $val); }
    putenv("$prefix$key=$val");
  }
}
env_export_dict($_SERVER);
env_export_dict($cfg, 'wg_');

$cgi_cmd = 'bash ' . escapeshellarg($cfg['share_sh_path']) . ' 2>&1';
exec($cgi_cmd, $output, $retval);

$val = explode(' ', (string)@$output[0], 3);
$code = ((($retval === 0)
  && (count($val) === 3)
  && ($val[0] === 'Status:')
  && (bool)$val[2]
  ) ? (int)$val[1] : 0);

if ($code >= 100) {
  http_response_code($code);
  while (list(, $val) = each($output)) {
    $val = trim($val);
    if (!$val) { break; }
    header($val);
  }
} else {
  echo "CGI error, exit value: $retval, details:\n";
}
while (list(, $val) = each($output)) { echo "$val\n"; }
