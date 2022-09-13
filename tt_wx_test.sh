StoragePath=$1

#部署甜糖服务
startTtnodesever() {
clear;
echo "

======================================================================================

正在启动/更新甜糖服务，请耐心等待

======================================================================================

";
docker rm -f ttnode  >/dev/null 2>&1 || echo 'remove ttnode container'
docker rm -f tiptime_wsv  >/dev/null 2>&1 || echo 'remove tiptime_wsv container'
docker rmi -f registry.cn-hangzhou.aliyuncs.com/tiptime/ttnode:latest  >/dev/null 2>&1 || echo 'remove tiptime/ttnode from ali'
docker rmi -f tiptime/ttnode:latest  >/dev/null 2>&1 || echo 'remove tiptime/ttnode from dockerhub'

docker run --privileged -d \
  -v $StoragePath:/mnt/data/ttnode \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /proc:/host/proc:ro \
  --name ttnode \
  --hostname ttnode \
  --net=host \
  --restart=always \
  registry.cn-hangzhou.aliyuncs.com/tiptime/ttnode:latest

sleep 10s;
echo "

======================================================================================

部署完成，请浏览器输入“ http://$(ip route get 1.2.3.4 | awk '{print $7}'):1024 ”进行二维码扫码绑定、业务选择选择等操作！！！

======================================================================================

";
}



#部署甜糖服务（高质量通道）
startHighTtnodesever() {
clear;
echo "

======================================================================================

正在启动/更新甜糖服务（高质量通道），请耐心等待

======================================================================================

";
docker rm -f ttnode  >/dev/null 2>&1 || echo 'remove ttnode container'
docker rm -f tiptime_wsv  >/dev/null 2>&1 || echo 'remove tiptime_wsv container'
docker rmi -f registry.cn-hangzhou.aliyuncs.com/tiptime/ttnode:latest  >/dev/null 2>&1 || echo 'remove tiptime/ttnode from ali'
docker rmi -f tiptime/ttnode:latest  >/dev/null 2>&1 || echo 'remove tiptime/ttnode from dockerhub'

docker run --privileged -d \
  -v $StoragePath:/mnt/data/ttnode \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /proc:/host/proc:ro \
  --name ttnode \
  --hostname ttnode \
  --net=host \
  -e mode=high \
  --restart=always \
  registry.cn-hangzhou.aliyuncs.com/tiptime/ttnode:latest

sleep 10s;
echo "

======================================================================================

部署完成，请浏览器输入“ http://$(ip route get 1.2.3.4 | awk '{print $7}'):1024 ”进行二维码扫码绑定、业务选择等操作！！！

======================================================================================

";
}



#部署网心容器魔方
startWxedgeSever() {
clear;
echo "

======================================================================================

正在部署/更新网心容器魔方，请耐心等待

======================================================================================

";
docker rm -f wxedge  >/dev/null 2>&1 || echo 'remove wxedge container'
docker rmi -f registry.hub.docker.com/onething1/wxedge:latest  >/dev/null 2>&1 || echo 'remove onething1/wxedge from dockerhub'

docker run \
--name=wxedge \
--restart=always \
--privileged \
--net=host \
--tmpfs /run \
--tmpfs /tmp \
-v $StoragePath/containerd:/var/lib/containerd \
-v $StoragePath:/storage:rw \
-d \
registry.hub.docker.com/onething1/wxedge

sleep 10s;
echo "

======================================================================================

部署完成，请浏览器输入“ http://$(ip route get 1.2.3.4 | awk '{print $7}'):18888 ”进行二维码扫码绑定、业务选择等操作！！！

======================================================================================

";
}


#开始前的说明
sleep 1s;
clear;
read -p "
======================================================================================

当前脚本只适用于安装甜糖服务/网心容器魔方

  请输入下列序号，进行相应操作

	1.部署/更新甜糖容器

	2.部署/更新甜糖容器（高质量通道，只适用于x86，详情请访问甜糖官网）
	
	3.清除甜糖缓存（适用于旧业务，不会删除绑定信息）

	4.删除甜糖容器

	5.部署/更新容器魔方容器

	6.清除容器魔方缓存(不会删除绑定信息，会删除所有缓存)

	7.删除容器魔方容器

	8.退出

======================================================================================


请选择相应的数字进行操作：" beforestart


if [[ ${beforestart} == 1 ]];then
sleep 1s;
if [ ! -d "$1" ];then
mkdir $1 
fi
sleep 1s;
startTtnodesever;

elif [[ ${beforestart} == 2 ]];then
sleep 1s;
if [ ! -d "$1" ];then
mkdir $1 
fi
sleep 1s;
startHighTtnodesever;

elif [[ ${beforestart} == 3 ]];then
sleep 1s;
echo '正在停止甜糖容器...';
docker stop ttnode >/dev/null 2>&1 || echo '容器不存在，不影响删除缓存' 
sleep 1s;
echo '删除缓存中...';
rm -rf $1/.yfnode/cache;
sleep 1s;
echo '正在启动甜糖容器...';
docker start ttnode >/dev/null 2>&1 || echo '容器不存在，不影响删除缓存' 

elif [[ ${beforestart} == 4 ]];then
sleep 1s;
docker rm -f ttnode >/dev/null 2>&1 || echo 'remove ttnode container'
docker rm -f tiptime_wsv >/dev/null 2>&1 || echo 'remove tiptime_wsv container'
docker rmi -f registry.cn-hangzhou.aliyuncs.com/tiptime/ttnode:latest >/dev/null 2>&1 || echo 'remove tiptime/ttnode from ali'
docker rmi -f tiptime/ttnode:latest >/dev/null 2>&1 || echo 'remove tiptime/ttnode from dockerhub'

elif [[ ${beforestart} == 5 ]];then
sleep 1s;
if [ ! -d "$1" ];then
mkdir $1 
fi
sleep 1s;
startWxedgeSever

elif [[ ${beforestart} == 6 ]];then
sleep 1s;
echo '正在停止容器魔方...';
docker stop wxedge >/dev/null 2>&1 || echo '容器不存在，不影响删除缓存' 
sleep 2s;
echo '删除缓存中...';
rm -rf $1/.onething_data/task;
sleep 2s;
echo '正在启动容器魔方...';
docker start wxedge >/dev/null 2>&1 || echo '容器不存在，不影响删除缓存' 

elif [[ ${beforestart} == 7 ]];then
sleep 1s;
docker rm -f wxedge >/dev/null 2>&1 || echo 'remove wxedge container'
docker rmi -f registry.hub.docker.com/onething1/wxedge:latest >/dev/null 2>&1 || echo 'remove onething1/wxedge from dockerhub'

else
echo "

退出安装脚本
";
sleep 5s;
fi





