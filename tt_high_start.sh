#开始前的说明
sleep 1s
clear;
echo "

======================================================================================
正在下载甜糖服务文件，请稍等。。。
======================================================================================

";

rm -rf ./ttnode-docker-high;
rm -f ./ttnode-docker-high.zip;
sleep 2s
wget https://gitee.com/zhang0510/ttnode_server/attach_files/1145514/download/ttnode-docker-high.zip
unzip ttnode-docker-high.zip


#选择安装甜糖服务的arm版本
sleep 1s;

chmod 755 ./ttnode-docker-high/ttnode/alpine/tt_run.sh;
./ttnode-docker-high/ttnode/alpine/tt_run.sh;


echo "

======================================================================================
正在清理缓存文件，请勿中断程序，脚本将在10s自动退出
======================================================================================

";
rm -rf ./ttnode-docker-high;
rm -f ./ttnode-docker-high.zip;
rm -f ./tt_high_start.sh;
sleep 10s;
echo "

======================================================================================

部署完成，请浏览器输入“ http://$(ip route get 1.2.3.4 | awk '{print $7}'):1024 ”进行二维

码扫码绑定、业务选择及高质量通道选择等操作！！！

======================================================================================

";
exit 0
