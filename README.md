# ceph 单节点安装
ceph 的安装配置脚本，单节点虚拟机适合，目前只支持 centos，后面有空再加 debian 系。

## 准备centos环境

安装好centos系统，保证 base rpm 源配置好，如果无法访问互联网，则还需要配置内部的 epel 源。配置方法参考如下： 

https://mirrors.tuna.tsinghua.edu.cn/help/centos/
https://mirrors.tuna.tsinghua.edu.cn/help/epel/


## 修改centos.sh 
```
# offline 是否不能访问互联网，如果为true 则需要手动配置 epel 源，不会安装 epel 源
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
BASE_URL=http://mirrors.163.com/ceph

#osd disk list
OSD_DISK=(/dev/sdb /dev/sdc /dev/sdd)

```

## 执行脚本

> chmod +x cephInstall.sh

> ./cephInstall.sh