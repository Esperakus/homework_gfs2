[gfs_hosts]
%{ for hostname in gfs_workers ~}
${hostname}
%{ endfor ~}

[iscsi_hosts]
%{ for hostname in iscsi_workers ~}
${hostname}
%{ endfor ~}

[ansible_host]
localhost