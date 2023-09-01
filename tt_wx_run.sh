#添加格式化硬盘
addAutomkfs() {
#添加格式化硬盘脚本
echo -e 'sleep 1s;
choose=\x27ture\x27;
while [ $choose == \x27ture\x27 ] ;do
clear;
read -p "

=========================================================================================================

初次挂载硬盘、调整硬盘容量、更换硬盘后都要对硬盘进行重新分区及格式化，请按照提示
选择是否格式化,若多次初始化硬盘不成功，请重启系统或检查硬盘是否已经挂载！！！

1.不对硬盘进行格式化，请输入1

2.对硬盘进行格式化，请输入2

=========================================================================================================

请输入数字1-2：" formatchoose

if [[ ${formatchoose} == 1 || ${formatchoose} == \x27\x27 ]];then
sleep 1s;
choose=\x27false\x27;
sleep 1s;

elif [[ ${formatchoose} == 2 ]];then
sleep 1s;
echo "

硬盘正在格式化，请稍等。。。

"
sleep 1s;
if grep -qs \x27/dev/sda1\x27 /proc/mounts; then

#/dev/sda1被挂载，将判断/dev/sdb1是被挂载
sleep 1s;
if grep -qs \x27/dev/sdb1\x27 /proc/mounts; then
sleep 1s;
echo "

未发现可以被格式化的硬盘，10s后将自动返回格式化硬盘界面

"
sleep 10s;

#/dev/sdb1未被挂载，将进行格式化
else
echo "n

p

1

 

 

w

"|fdisk -u /dev/sdb;
mkfs.ext4 /dev/sdb1;
sleep 1s;
choose=\x27false\x27;
echo "

格式化完成，脚本将会在10s后继续执行，请稍等

"
sleep 10s;
fi
#/dev/sda1未被挂载，将进行格式化
else
echo "n

p

1

 

 

w

"|fdisk -u /dev/sda;
mkfs.ext4 /dev/sda1;
sleep 1s;
choose=\x27false\x27;
echo "

格式化完成，脚本将会在10s后继续执行，请稍等

"
sleep 10s;
fi

else
echo "

输入错误，5s后请重新选择，或按ctrl+c退出安装命令
";
sleep 5s;
fi
done
exit 0' > /usr/node/automkfs.sh
}

#添加自动挂载脚本
addAutoMount() {
echo -e '#!/bin/sh
#automount

function automount()
{
    mkdir /mnts;
    if grep -qs \x27/mnts\x27 /proc/mounts; then
        echo "/mnts is mounted"
    else
        mountsda
    fi
}

function mountsda()
{
    if grep -qs \x27/dev/sda1\x27 /proc/mounts; then
        echo "/dev/sda1 is mounted";
        mountsdb
     else 
        mount /dev/sda1 /mnts;
        if grep -qs \x27/mnts\x27 /proc/mounts; then
            echo "/mnts is mounted";
        else
            mountsdb
        fi
    fi
}

function mountsdb()
{
    if grep -qs \x27/dev/sdb1\x27 /proc/mounts; then
        echo "/dev/sdb1 is mounted";
        mountmmcblk0
    else 
        mount /dev/sdb1 /mnts;
        if grep -qs \x27/mnts\x27 /proc/mounts; then
            echo "/mnts is mounted";
        else
            mountmmcblk0
        fi
    fi
}

function mountmmcblk0()
{
    if grep -qs \x27/dev/mmcblk0p1\x27 /proc/mounts; then
        echo "/dev/mmcblk0p1 is mounted";
        mountmmcblk1
    else 
        mount /dev/mmcblk0p1 /mnts;
        if grep -qs \x27/mnts\x27 /proc/mounts; then
            echo "/mnts is mounted";
        else
            mountmmcblk1
        fi
    fi
}

function mountmmcblk1()
{
    if grep -qs \x27/dev/mmcblk1p1\x27 /proc/mounts; then
        echo "/dev/mmcblk1p1 is mounted";
        mountmmcblk2
    else
        mount /dev/mmcblk1p1 /mnts;
        if grep -qs \x27/mnts\x27 /proc/mounts; then
            echo "/mnts is mounted";
        else
            mountmmcblk2
        fi
    fi
}

function mountmmcblk2()
{
    if grep -qs \x27/dev/mmcblk1p2\x27 /proc/mounts; then
        echo "/dev/mmcblk1p2 is mounted";
        mountfail
    else 
        mount /dev/mmcblk2p1 /mnts;
        if grep -qs \x27/mnts\x27 /proc/mounts; then
            echo "/mnts is mounted";
        else
            mountfail
        fi
    fi
}

function mountfail()
{
    clear
    echo "

    ===========================================================================

    未找到合适的硬盘挂载到/mnts目录，请检查是否插入存储设备和存储设备是否格式化，
    10s后将自动结束挂载，挂载脚本所在目录：/usr/node下，可在脚本结束后手动执行。

    注意：此脚本只会按sda1>sdb1>mmcblk0p1>mmcblk1p1>mmcblk2p1的顺序挂载分区，
    若有其他分区，不会自动挂载

    ============================================================================

    "
    sleep 10s;
} 
automount
' > /usr/node/mount.sh
}

#初始化alpine环境
startEvn() {
mkdir /usr/node
sleep 1s;
#添加格式化硬盘脚本
addAutomkfs

#添加自动挂载脚本
addAutoMount

chmod 777 -R /usr/node;

#修改软件源
echo '#/media/cdrom/apks
#http://mirrors.ustc.edu.cn/alpine/v3.15/main
#http://mirrors.ustc.edu.cn/alpine/v3.15/community
#http://mirrors.ustc.edu.cn/alpine/edge/main
#http://mirrors.ustc.edu.cn/alpine/edge/community
#http://mirrors.ustc.edu.cn/alpine/edge/testing
https://mirrors.ustc.edu.cn/alpine/latest-stable/main
https://mirrors.ustc.edu.cn/alpine/latest-stable/community' > /etc/apk/repositories


#关闭交换内存
swapoff -a

#安装相关应用
sleep 2s;
apk update;
sleep 2s;
apk add docker;
sleep 2s;
apk add lsblk;
sleep 2s;
rc-update add docker boot;
sleep 2s;
service docker start;
sleep 2s;
mkdir /mnts;
sleep 2s;
}



#部署甜糖服务
startTtnodeService() {
clear;
echo "

======================================================================================

正在启动/更新甜糖服务，请耐心等待

======================================================================================

";
#添加开机自动执行脚本
echo -e 'sleep 2s
swapoff -a
sleep 2s
/usr/node/mount.sh
sleep 5s
if [[ "$(docker inspect ttnode 2> /dev/null | grep \x27"Name": "/ttnode"\x27)" != "" ]];
then
docker restart $(docker ps -q)
else
docker run --privileged -d \
  -v /mnts/ttnode:/mnt/data/ttnode \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /proc:/host/proc:ro \
  --cap-add SYS_RAWIO \
  --device /dev/mem \
  --name ttnode \
  --hostname ttnode \
  --net=host \
  --restart=always \
  registry.cn-hangzhou.aliyuncs.com/tiptime/ttnode:latest
fi' > /etc/local.d/mount.start
chmod +x /etc/local.d/mount.start;
sleep 1s;
rc-update add local;

docker run --privileged -d \
  -v /mnts/ttnode:/mnt/data/ttnode \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /proc:/host/proc:ro \
  --cap-add SYS_RAWIO \
  --device /dev/mem \
  --name ttnode \
  --hostname ttnode \
  --net=host \
  --restart=always \
  registry.cn-hangzhou.aliyuncs.com/tiptime/ttnode:latest

sleep 10s;
echo "

======================================================================================

部署完成，请浏览器输入“ http://$(ip route get 1.2.3.4 | awk '{print $7}'):1024 ”进行二维码扫码绑定、业务选择及高质量通道选择等操作！！！

======================================================================================

";
exit 0;
}

#甜糖服务（二进制程序）
startOnlyTtnodeService() {
#下载甜糖程序
echo "

======================================================================================
正在下载甜糖服务文件，请稍等。。。
======================================================================================

";
sleep 2s;
rm -rf ./ttnode;
rm -f ./ttnode.zip;
rm -rf ./ttmanager.zip
rm -rf ./ttmanager
sleep 2s;
wget https://gitee.com/zhang0510/share/releases/download/v0.0.1/ttnode.zip
wget https://gitee.com/zhang0510/share/releases/download/amd64/ttmanager.zip

#文件存在则删除
if [ ! -f "/root/ttnode.zip" ];then
echo "甜糖文件下载失败，请检查网络后再次尝试，将返回上级菜单！"
sleep 10s
else
unzip ttnode.zip
unzip ./ttmanager.zip

#删除可能存在的旧文件
sleep 1s;
rm -rf /usr/node;

#移入甜糖所需文件
sleep 1s;
mv ./ttnode/node /usr/;
sleep 1s;
mv ./ttmanager /usr/node/
sleep 1s;
chmod 777 -R /usr/node;


#添加开机自动执行脚本
echo -e 'sleep 2s
swapoff -a
nohup /usr/node/run.sh -c /mnts/ttnode > /dev/null 2>&1 &
' > /etc/local.d/mount.start
chmod +x /etc/local.d/mount.start;
sleep 1s;
rc-update add local;


#初始化硬盘
/usr/node/automkfs.sh;


#关闭交换内存
swapoff -a

#安装相关应用
sleep 2s;
apk update;
sleep 2s;
apk add lsblk bash;
sleep 2s;
mkdir /mnts;
sleep 2s;
mkdir /mnts/ttnode;
sleep 2s;
echo "

======================================================================================

正在尝试挂载硬盘，请稍等。。。

======================================================================================

";
/usr/node/mount.sh;
sleep 1s;

#启动甜糖服务
clear;
echo "

======================================================================================

正在启动甜糖服务，请耐心等待

======================================================================================

";
/usr/node/ttmanager -g
sleep 2s;
nohup /usr/node/run.sh -t edsnode -c /mnts/ttnode > /dev/null 2>&1 &
sleep 5s;
echo "

======================================================================================

部署完成，请浏览器输入“ http://$(ip route get 1.2.3.4 | awk '{print $7}'):1024 ”进行二维码扫码绑定、业务选择及高质量通道选择等操作！！！

首次启动可能会自动更新甜糖程序导致程序未启动从而无法访问1024后台，可手动执行

命令nohup /usr/node/run.sh -t edsnode -c /mnts/ttnode > /dev/null 2>&1 &

请耐心等待脚本退出！！！

======================================================================================

";
sleep 20s;
exe_path="ttmanager"
main_id=$(pidof $exe_path)
if [ -n "$main_id" ]; then
   echo "$(date '+%Y-%m-%d %H:%M:%S') ttmanager进程存在" 2>&1 > /dev/null
else
   kill -9 $(pidof ksc-andromedae) 2>&1
   kill -9 $(pidof ksc-kepler) 2>&1
   kill -9 $(pidof yfnode) 2>&1
   nohup /usr/node/run.sh -c /mnts/ttnode > /dev/null 2>&1 &
fi
exit 0

 fi

}


#部署网心容器魔方
startWxedgeService() {
clear;
echo "

======================================================================================

正在部署/更新网心容器魔方，请耐心等待

======================================================================================

";
#添加开机自动执行脚本
echo -e 'sleep 2s
swapoff -a
sleep 2s
/usr/node/mount.sh
sleep 5s
if [[ "$(docker inspect wxedge 2> /dev/null | grep \x27"Name": "/wxedge"\x27)" != "" ]];
then
docker restart $(docker ps -q)
else
docker run \
--name=wxedge \
--restart=always \
--privileged \
--net=host \
--tmpfs /run \
--tmpfs /tmp \
-v /mnts/wxedge1:/storage:rw \
-d \
onething1/wxedge:latest
fi' > /etc/local.d/mount.start
chmod +x /etc/local.d/mount.start;
sleep 1s;
rc-update add local;


docker run \
--name=wxedge \
--restart=always \
--privileged \
--net=host \
--tmpfs /run \
--tmpfs /tmp \
-v /mnts/wxedge1:/storage:rw \
-d \
onething1/wxedge:latest

sleep 10s;
echo "

======================================================================================

部署完成，请浏览器输入“ http://$(ip route get 1.2.3.4 | awk '{print $7}'):18888 ”进行二维码扫码绑定、业务选择等操作！！！

======================================================================================

";
exit 0;
}

startWxedgeService01() {
clear;
echo "

======================================================================================

正在部署/更新网心容器魔方，请耐心等待

======================================================================================

";
#添加开机自动执行脚本
echo -e 'sleep 2s
swapoff -a
sleep 2s
/usr/node/mount.sh
sleep 5s
if [[ "$(docker inspect wxedge 2> /dev/null | grep \x27"Name": "/wxedge"\x27)" != "" ]];
then
docker restart $(docker ps -q)
else
docker run \
--name=wxedge \
--restart=always \
--privileged \
--net=host \
--tmpfs /run \
--tmpfs /tmp \
-v /mnts/wxedge1:/storage:rw \
-d \
onething1/wxedge:2.4.3
fi' > /etc/local.d/mount.start
chmod +x /etc/local.d/mount.start;
sleep 1s;
rc-update add local;


docker run \
--name=wxedge \
--restart=always \
--privileged \
--net=host \
--tmpfs /run \
--tmpfs /tmp \
-v /mnts/wxedge1:/storage:rw \
-d \
onething1/wxedge:2.4.3

sleep 10s;
echo "

======================================================================================

部署完成，请浏览器输入“ http://$(ip route get 1.2.3.4 | awk '{print $7}'):18888 ”进行二维码扫码绑定、业务选择等操作！！！

======================================================================================

";
exit 0;
}

#删除容器魔方缓存
deleteWxedgeTaskCache() {
clear;
choosedeletetask='ture';
while [ $choosedeletetask == 'ture' ] ;do
read -p "
======================================================================================

 请输入序号，删除对应业务的所有缓存

	1.B网盘
	2.CB*	
	3.CG*
	4.CX*
	5.CY
	6.CYK
	7.Z
	8.删除所有缓存
	9.退出

======================================================================================


请选择相应的数字进行操作：" deletecache

if [[ ${deletecache} == 1 ]];then
sleep 2s;
echo '删除缓存中...';
sleep 2s;
rm -rf /mnts/wxedge1/.onething_data/task/984017bcbfc37757a79ff41324d54008*;
echo '删除缓存完成，正在返回选项列表';
sleep 3s;

elif [[ ${deletecache} == 2 ]];then
sleep 2s;
echo '删除缓存中...';
sleep 2s;
rm -rf /mnts/wxedge1/.onething_data/task/5b442b259766008357b638af7d07d18a*;
echo '删除缓存完成，正在返回选项列表';
sleep 3s;

elif [[ ${deletecache} == 3 ]];then
sleep 2s;
echo '删除缓存中...';
sleep 2s;
rm -rf /mnts/wxedge1/.onething_data/task/bae5a079ee6d7ac69ea2ac8cec142662*;
echo '删除缓存完成，正在返回选项列表';
sleep 3s;

elif [[ ${deletecache} == 4 ]];then
sleep 2s;
echo '删除缓存中...';
sleep 2s;
rm -rf /mnts/wxedge1/.onething_data/task/e9b6850481e687306e41eb10b26e70bd*;
echo '删除缓存完成，正在返回选项列表';
sleep 3s;

elif [[ ${deletecache} == 5 ]];then
sleep 2s;
echo '删除缓存中...';
sleep 2s;
rm -rf /mnts/wxedge1/.onething_data/task/34341e4c1d629e9ea0336960a9f5d2a8*;
echo '删除缓存完成，正在返回选项列表';
sleep 3s;

elif [[ ${deletecache} == 6 ]];then
sleep 2s;
echo '删除缓存中...';
sleep 2s;
rm -rf /mnts/wxedge1/.onething_data/task/a040bc3e8db50b750167b22cf3e908fa*;
echo '删除缓存完成，正在返回选项列表';
sleep 3s;

elif [[ ${deletecache} == 7 ]];then
sleep 2s;
echo '删除缓存中...';
sleep 2s;
rm -rf /mnts/wxedge1/.onething_data/task/18e5e85d32df5a474f509aa86bcf0015*;
echo '删除缓存完成，正在返回选项列表';
sleep 3s;

elif [[ ${deletecache} == 8 ]];then
sleep 2s;
echo '删除缓存中...';
sleep 2s;
rm -rf /mnts/wxedge1/.onething_data/task/*;
echo '删除缓存完成，正在返回选项列表';
sleep 3s;

else
echo "

退出删除缓存
";
sleep 2s;
choosedeletetask='false';
fi
done
}

WxedgeService() {
#容器魔方相关
sleep 1s;
clear;
chooseWxedgeTask='ture';
while [ $chooseWxedgeTask == 'ture' ] ;do
read -p "
======================================================================================
更新时间：2023-6-22
当前脚本用于  “X86的alpine系统”  安装“网心容器魔方”，若选错了按Ctrl+C即可结束安装
缓存目录：/mnts/wxedge1（不支持自定义）
  请输入下列序号，进行相应操作
	
	1.一键部署网心容器魔方(最新版，智能业务，不支持自行选择业务)
	2.一键部署网心容器魔方(2.4.3版，支持自行选择业务)
	3.清除容器魔方缓存(不删除绑定信息)
	4.删除容器魔方容器
	5.更新容器魔方容器
	6.退出

======================================================================================


请选择相应的数字进行操作：" beforeWxedgeStart


if [[ ${beforeWxedgeStart} == 1 ]];then
sleep 1s;
startEvn
#初始化硬盘
/usr/node/automkfs.sh;
sleep 1s;
#挂载硬盘
echo "

======================================================================================

正在尝试挂载硬盘，请稍等。。。

======================================================================================

";
/usr/node/mount.sh;
sleep 2s;
startWxedgeService

elif [[ ${beforeWxedgeStart} == 2 ]];then
sleep 1s;
startEvn
#初始化硬盘
/usr/node/automkfs.sh;
sleep 1s;
#挂载硬盘
echo "

======================================================================================

正在尝试挂载硬盘，请稍等。。。

======================================================================================

";
/usr/node/mount.sh;
sleep 2s;
startWxedgeService01 

elif [[ ${beforeWxedgeStart} == 3 ]];then
sleep 1s;
echo '正在停止容器魔方...';
docker stop wxedge >/dev/null 2>&1 || echo '容器不存在，不影响删除缓存' 
sleep 2s;
echo '删除缓存中...';
deleteWxedgeTaskCache;
sleep 2s;
echo '正在启动容器魔方...';
docker start wxedge >/dev/null 2>&1 || echo '容器不存在，不影响删除缓存' 

elif [[ ${beforeWxedgeStart} == 4 ]];then
sleep 1s;
rm -rf /etc/local.d/mount.start;
docker rm -f wxedge >/dev/null 2>&1 || echo 'remove wxedge container'
docker rmi -f onething1/wxedge:latest >/dev/null 2>&1 || echo 'remove onething1/wxedge from dockerhub'
docker rmi -f onething1/wxedge:2.4.3 >/dev/null 2>&1 || echo 'remove onething1/wxedge from dockerhub'


elif [[ ${beforeWxedgeStart} == 5 ]];then
sleep 1s;
docker rm -f wxedge  >/dev/null 2>&1 || echo 'remove wxedge container'
docker rmi -f onething1/wxedge:latest  >/dev/null 2>&1 || echo 'remove onething1/wxedge from dockerhub'
docker rmi -f onething1/wxedge:2.4.3 >/dev/null 2>&1 || echo 'remove onething1/wxedge from dockerhub'
startWxedgeService

else
echo "

退出容器魔方安装脚本，将返回上级菜单！
";
sleep 5s;
chooseWxedgeTask='false';
fi
done
}



TtnodeService() {
#甜糖服务相关
sleep 1s;
clear;
chooseTtnodeTask='ture';
while [ $chooseTtnodeTask == 'ture' ] ;do
read -p "
======================================================================================
更新时间：2023-9-1
当前脚本用于  “X86的alpine系统”  安装“甜糖服务”，若选错了按Ctrl+C即可结束安装
缓存目录：/mnts/ttnode （不支持自定义）
  请输入下列序号，进行相应操作
	
	1.一键部署甜糖服务（docker，浏览器输入ip:1024进行业务选择）
	2.一键部署甜糖服务（二进制程序，浏览器输入ip:1024进行业务选择）
	3.删除甜糖容器
	4.删除甜糖（二进制程序）
	5.更新甜糖容器（非质量通道）
	6.退出

======================================================================================


请选择相应的数字进行操作：" beforeTtnodeStart


if [[ ${beforeTtnodeStart} == 1 ]];then
sleep 1s;
startEvn
#初始化硬盘
/usr/node/automkfs.sh;
sleep 1s;
#挂载硬盘
echo "

======================================================================================

正在尝试挂载硬盘，请稍等。。。

======================================================================================

";
/usr/node/mount.sh;
sleep 2s;
startTtnodeService

elif [[ ${beforeTtnodeStart} == 2 ]];then
startOnlyTtnodeService

elif [[ ${beforeTtnodeStart} == 3 ]];then
sleep 1s;
rm -rf /etc/local.d/mount.start;
docker rm -f ttnode >/dev/null 2>&1 || echo 'remove ttnode container'
docker rm -f tiptime_wsv >/dev/null 2>&1 || echo 'remove tiptime_wsv container'
docker rmi -f registry.cn-hangzhou.aliyuncs.com/tiptime/ttnode:latest >/dev/null 2>&1 || echo 'remove tiptime/ttnode from ali'
docker rmi -f registry.cn-hangzhou.aliyuncs.com/tiptime/ttnode-test:latest  >/dev/null 2>&1 || echo 'remove tiptime/ttnode from ali'
docker rmi -f tiptime/ttnode:latest >/dev/null 2>&1 || echo 'remove tiptime/ttnode from dockerhub'
docker rmi -f tiptime/ttnode-test:latest >/dev/null 2>&1 || echo 'remove tiptime/ttnode from dockerhub'

elif [[ ${beforeTtnodeStart} == 4 ]];then
echo '正在删除甜糖服务，请稍等';
/usr/node/ttmanager -uninstall
sleep 2s;
#删除相关文件
rm -rf /usr/node;
sleep 2s;

elif [[ ${beforeTtnodeStart} == 5 ]];then
sleep 1s;
docker rm -f ttnode  >/dev/null 2>&1 || echo 'remove ttnode container'
docker rm -f tiptime_wsv  >/dev/null 2>&1 || echo 'remove tiptime_wsv container'
docker rmi -f registry.cn-hangzhou.aliyuncs.com/tiptime/ttnode:latest  >/dev/null 2>&1 || echo 'remove tiptime/ttnode from ali'
docker rmi -f registry.cn-hangzhou.aliyuncs.com/tiptime/ttnode-test:latest  >/dev/null 2>&1 || echo 'remove tiptime/ttnode from ali'
docker rmi -f tiptime/ttnode:latest  >/dev/null 2>&1 || echo 'remove tiptime/ttnode from dockerhub'
docker rmi -f tiptime/ttnode-test:latest >/dev/null 2>&1 || echo 'remove tiptime/ttnode from dockerhub'
sleep 1s;
startTtnodeService

else
echo "

退出甜糖安装脚本，返回上级菜单
";
sleep 5s;
chooseTtnodeTask='false';
fi
done

}


#开始前的说明
sleep 1s;
clear;
choosetask='ture';
while [ $choosetask == 'ture' ] ;do
read -p "
======================================================================================
更新时间：2023-9-1
当前脚本只适用于  “X86的alpine系统”  安装甜糖服务/网心容器魔方，若选错了按Ctrl+C即可结束安装
 
  请输入下列序号，进行相应操作
	
	1.甜糖服务
	2.网心容器魔方
	3.硬盘分区并格式化（更换缓存盘后使用）
	4.退出

======================================================================================


请选择相应的数字进行操作：" beforestart


if [[ ${beforestart} == 1 ]];then
TtnodeService

elif [[ ${beforestart} == 2 ]];then
WxedgeService

elif [[ ${beforestart} == 3 ]];then
sleep 1s;
mkdir /usr/node
#添加格式化硬盘脚本
addAutomkfs

#添加自动挂载脚本
addAutoMount
chmod 777 -R /usr/node;

#初始化硬盘
/usr/node/automkfs.sh;
sleep 1s;
#挂载硬盘
echo "

======================================================================================

正在尝试挂载硬盘，请稍等。。。

======================================================================================

";
/usr/node/mount.sh;
sleep 2s;

else
echo "

退出安装脚本
";
sleep 5s;
choosetask='false';
fi
done







