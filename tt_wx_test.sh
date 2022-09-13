#!/bin/sh -e
#部署甜糖服务
startTtnodesever() {
clear;
echo "

======================================================================================

正在启动/更新甜糖服务，请耐心等待

======================================================================================

";
docker rm -f ttnode >& /dev/null || echo 'remove ttnode container'
docker rm -f tiptime_wsv >& /dev/null || echo 'remove tiptime_wsv container'
docker rmi -f registry.cn-hangzhou.aliyuncs.com/tiptime/ttnode:latest >& /dev/null || echo 'remove tiptime/ttnode from ali'
docker rmi -f tiptime/ttnode:latest >& /dev/null || echo 'remove tiptime/ttnode from dockerhub'

docker run --privileged -d \
  -v $1:/mnt/data/ttnode \
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

部署完成，请浏览器输入“ http://$(ip route get 1.2.3.4 | awk '{print $7}'):1024 ”进行二维码扫码绑定、业务选择及高质量通道选择等操作！！！

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
docker rm -f wxedge >& /dev/null || echo 'remove ttnode container'
docker rmi -f registry.hub.docker.com/onething1/wxedge:latest >& /dev/null || echo 'remove tiptime/ttnode from dockerhub'


docker run \
--name=wxedge \
--restart=always \
--privileged \
--net=host \
--tmpfs /run \
--tmpfs /tmp \
-v $1/containerd:/var/lib/containerd \
-v $1:/storage:rw \
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
	
	2.清除甜糖缓存（适用于旧业务，不会删除绑定信息）

	3.删除甜糖容器

	4.部署/更新容器魔方容器

	5.清除容器魔方缓存(不会删除绑定信息，会删除所有缓存)

	6.删除容器魔方容器

	7.退出

======================================================================================


请选择相应的数字进行操作：" beforestart


if [[ ${beforestart} == 1 ]];then
sleep 1s;
startTtnodesever

elif [[ ${beforestart} == 2 ]];then
sleep 1s;
docker stop ttnode
sleep 1s;
rm -rf $1/.yfnode/cache;
sleep 1s;
docker start ttnode
elif [[ ${beforestart} == 3 ]];then
sleep 1s;
docker rm -f ttnode ||  echo 'remove ttnode container'
docker rm -f tiptime_wsv ||  echo 'remove tiptime_wsv container'
docker rmi -f registry.cn-hangzhou.aliyuncs.com/tiptime/ttnode:latest || echo 'remove tiptime/ttnode from ali'
docker rmi -f tiptime/ttnode:latest || echo 'remove tiptime/ttnode from dockerhub'

elif [[ ${beforestart} == 4 ]];then
startWxedgeSever

elif [[ ${beforestart} == 5 ]];then
sleep 1s;
docker stop wxedge
sleep 1s;
rm -rf $1/.onething_data/task;
sleep 1s;
docker start wxedge

elif [[ ${beforestart} == 6 ]];then
sleep 1s;
docker rm -f wxedge || echo 'remove ttnode container'
docker rmi -f registry.hub.docker.com/onething1/wxedge:latest || echo 'remove tiptime/ttnode from dockerhub'

else
echo "

退出安装脚本
";
sleep 5s;
fi


