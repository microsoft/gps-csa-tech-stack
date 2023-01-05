
sudo sed -i 's/#   StrictHostKeyChecking ask/StrictHostKeyChecking no/g' /etc/ssh/ssh_config

sudo rpm -Uvh https://packages.microsoft.com/config/centos/7/packages-microsoft-prod.rpm

sudo yum install msopenjdk-11 -y

#sudo update-java-alternatives --set msopenjdk-11-amd64

#/usr/lib/jvm/msopenjdk-11/bin/java

curl -O https://dlcdn.apache.org/hadoop/common/hadoop-3.3.4/hadoop-3.3.4.tar.gz

tar -xzvf hadoop-3.3.4.tar.gz

mv hadoop-3.3.4 /usr/local/hadoop

