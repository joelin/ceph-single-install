
set -x


mkdir -p ~/ceph-install/install-$(date +%Y%m%d%H%M%S) && cd $_

# offline
OFF_LINE=false

# version of CEPH and OS 
## jewel kraken
CEPH_VERSION=jewel
## el7(centos) rhel7(redhat)
OS_DISTRO=el7

# monitor IP 
MON_IP=192.168.80.100
# public network 
PUBLIC_NETWORK=192.168.80.0/24

#mirror of ceph download 
## aliyun  https://mirrors.aliyun.com/ceph
## ceph https://download.ceph.com
## 163 http://mirrors.163.com/ceph
## local http://localhost/ceph
BASE_URL=http://mirrors.163.com/ceph

#osd disk list
OSD_DISK=(/dev/sdb /dev/sdc /dev/sdd)



HOST=$(hostname -s)

if [[ $OFF_LINE ]]; then
  if [[ ! -f /etc/yum.repos.d/epel.repo ]] ; then
     echo "warn epel repo not found!!!"
  fi 
else 
#epel 
#required rpm 
 curl http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-9.noarch.rpm -o epel-release-7-9.noarch.rpm
 rpm -ivh epel-release-7-9.noarch.rpm

fi

#the repo for install ceph-deploy
cat <<EOF > /etc/yum.repos.d/ceph-deploy.repo
[ceph-deploy]
name=ceph-deploy 
baseurl=${BASE_URL}/rpm-${CEPH_VERSION}/${OS_DISTRO}/noarch
enabled=1
priority=0
gpgcheck=0
gpgkey=${BASE_URL}/keys/release.asc
EOF


# ceph-deploy conf for local repo
cat <<EOF > cephdeploy.conf
[ceph-local]
name=Ceph packages
baseurl=${BASE_URL}/rpm-${CEPH_VERSION}/${OS_DISTRO}/x86_64
enabled=1
priority=0
gpgcheck=0
gpgkey=${BASE_URL}/keys/release.asc
default=True
extra-repos = ceph-local
EOF


#update rpm
yum -y update && yum -y install ceph-deploy

#clean env
ceph_clean () {
ceph-deploy purge $HOST
ceph-deploy purgedata $HOST
ceph-deploy forgetkeys
}
ceph_clean

#init node
ceph-deploy new $HOST

#set repo
ceph-deploy repo ceph-local $HOST

#replace the ip addr for dev id when init
sed -i 's#mon_host.*#mon_host = '${MON_IP}'#' ceph.conf

#add conf for ceph
#osd
cat <<EOF >> ceph.conf
public_network = ${PUBLIC_NETWORK}
osd_journal_size = 1024
osd_pool_default_size = 2
osd_crush_chooseleaf_type = 0
EOF

# install node
ceph-deploy  install $HOST

#init monitor
ceph-deploy mon create-initial 

#install osd
for i in ${OSD_DISK[@]}
do 
  ceph-deploy osd prepare ${HOST}:${i}
  ceph-deploy osd activate ${HOST}:${i}1
done

#
ceph-deploy admin $HOST


sudo chmod +r /etc/ceph/ceph.client.admin.keyring