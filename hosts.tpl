[gfs_hosts]
%{ for ip in gfs_workers ~}
${ip}
%{ endfor ~}

[iscsi_hosts]
%{ for ip in iscsi_workers ~}
${ip}
%{ endfor ~}

[ansible_host]
localhost