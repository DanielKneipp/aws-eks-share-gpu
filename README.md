```
asdf plugin-add terraform https://github.com/asdf-community/asdf-hashicorp.git
asdf plugin-add pre-commit git@github.com:jonathanmorley/asdf-pre-commit.git
asdf plugin-add tflint https://github.com/skyzyx/asdf-tflint
asdf plugin add https://github.com/MetricMike/asdf-awscli.git

asdf install
pre-commit install
```

```
cd ami/
packer build .
cd ../
```

```
cd cluster/
terraform apply
cd ../
```

`terraform apply -refresh-only`

```
wget https://github.com/sl1pm4t/k2tf/releases/download/v0.6.3/k2tf_0.6.3_Linux_x86_64.tar.gz
tar zxvf k2tf_0.6.3_Linux_x86_64.tar.gz k2tf
sudo mv k2tf /usr/local/bin/
rm k2tf_0.6.3_Linux_x86_64.tar.gz

cd cluster/
cat aws-virtual-gpu-device-plugin.yaml | k2tf > aws-virtual-gpu-device-plugin.tf
cd ../app/
cat app.yaml | k2tf > app.tf
cd ../
```
