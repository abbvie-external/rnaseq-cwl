# rnaseq-cwl

### INSTALLATION
```
pip install virtualenvwrapper --user
```
ensure `.bashrc` ends with:
```
export PATH=${HOME}/.local/bin:${PATH}
source ${HOME}/.local/bin/virtualenvwrapper.sh
```
then logout/login

```
git clone <git repo>
```

### RUN
```
mkdir run
cd run/
cwltool --debug --tmpdir-prefix $(pwd)/tmp/ --cachedir $(pwd)/cache/ ~/rnaseq-cwl/star_align/transform.cwl ~/rnaseq-cwl/star_align/transform.yml
```

