[gfs_hosts]
%{ for hostname in gfs_worker_hostname ~}
${hostname}
%{ endfor ~}

[iscsi_hosts]
%{ for hostname in iscsi_worker_hostname ~}
${hostname}
%{ endfor ~}

[ansible_host]
localhost