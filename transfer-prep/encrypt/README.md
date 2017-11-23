# main.nf #

Nexftlow pipeline for encrypting a list of files.

To run on a local machine and resume if something has failed do it like this:

```bash
nextflow -log nextflow.log run -w /global5/scratch/gerrit/test-nxf/work/ -c /home/gerrit/code/bioinftk/transfer-prep/encrypt/nextflow.config /home/gerrit/code/bioinftk/transfer-prep/encrypt/main.nf -profile standard -resume
```

Currently the submission to the CBIO cluster do not work. Something to do with the key loading and running GPG. Things just stalls. 


In `nextflow.config` to change when running on your own data

* `file_list` = path the file containing paths of all files to be encrypted
* `key` = the GPG key file
* `key_phrase` = the GPG key phrase
* `out` = output directory that will contain the individual encrypted files
*`project_name ` = just a base name to give to your run to distinguis it from other runs. Useful on cluster.
* In the `standard` profile `process.cpu` = the number of threads to spawn on local machine



