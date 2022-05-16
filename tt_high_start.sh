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
docker rm -f ttnode;
sleep 2s
wget https://gitee.com/zhang0510/ttnode_server/attach_files/1061606/download/ttnode-docker-high.zip
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

安装完成，请输入reboot重启系统，系统重启后，输入/root/tt_info.sh(或docker logs ttnode)查看二维码

若未出现二维码，请等待1分钟左右，再次输入上述命令

======================================================================================

";
exit 0
