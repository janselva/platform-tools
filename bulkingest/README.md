# Bulk Ingest

The `ingest.sh` shell script is used to ingest data onto a PNDA cluster.

## Install
To install dependencies and configure the tool through secured KNOX gateway, run the `install` command with the KNOX Gateway URL

```
 ingest.sh install https://<knox FQDN>:<port>/gateway/<topology_name> <path_to_CA_root_certificate>
 e.g
 ingest.sh install https://knox.service.dc1.pnda.local:8443/gateway/pnda /root/pndaproject/pnda-cli/platform-certificates/pndaproject-ca.crt
```
For SSL certificate verification, enter the path to root CA certificate(This certificate can be retrieved from "pnda-cli/platform-certificates/pndaproject-ca.crt")

Please check with your cluster administrator for the correct IP address and port, as it may change in production deployments. 

## Upload

To upload file or directory onto a cluster, run the `upload` command with the dir/file name. 
You can use the `-f` flag to overwrite existing files, and `-t number of threads` for parallelism.
It prompts to enter username & password for Knox gateway authentication
 
```
ingest.sh upload localfile or local_directory
e.g
ingest.sh upload Readme.txt
ingest.sh upload -f -t 10 /user/data
```

Once the upload completes, verify whether the transferred files are stored in the `/user/pnda/PNDA_datasets/bulk/` folder in HDFS.

## Dependencies

The tool depends on the `hdfs` python pip package. The `install` command when run also sets up the package, as well as populating the cli config.

# Known bugs

- Sometime the files or nested directories are not overwritten for large folders. In such case rerun the upload command with -f switch.
- Appending a '/' slash at the end seem to have weird effect, in some case even overwriting the directory. To upload a directory just use its name as the argument.
