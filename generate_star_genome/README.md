# INSTALLATION

## INSTALL VIRTUALENVWRAPPER
```
pip install virtualenvwrapper --user
```

Ensure `.bashrc` contains the following lines:
```
export PATH=${HOME}/.local/bin:${PATH}
source ${HOME}/.local/bin/virtualenvwrapper.sh
```

Then logout/login. You should see some one-time messages from virtualenvwrapper.


## CREATE A VIRTUALENV FOR CWLTOOL
#### note EOS currently has `Python 3.4.6` installed, while cwltool requires `Python 3.5` and above. So the python2 stack must be used.

```
mkvirtualenv --python=/usr/bin/python2 p2
pip install --upgrade pip --no-cache-dir
pip install cwltool --no-cache-dir
```

#### Test installation
```
cwltool --version
```


## RUN WORKFLOWS
#### clone cwl files
```
git clone <git-repo>
```

#### run workflow to generate index files
```
mkdir run
cd run/
nohup cwltool --debug --tmpdir-prefix $(pwd)/tmp/ --cachedir $(pwd)/cache/ ~/rnaseq-cwl/generate_genome/etl.cwl ~/rnaseq-cwl/generate_genome/etl.yml &
```
