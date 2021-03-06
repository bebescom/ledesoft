#!/bin/sh

alias echo_date1='echo $(date +%Y/%m/%d\ %X)'
export KSROOT=/koolshare
source $KSROOT/scripts/base.sh
LOGFILE="/tmp/upload/qiandao_log.txt"
eval `dbus export autocheckin_`

gen_user_config() {
	echo_date1 "启动签到程序" >> $LOGFILE
	echo_date1 "生成签到Json文件" >> $LOGFILE
	sync_time=`date +%F_%T`
	time_show=`echo $sync_time`
	echo_date1 "请核对路由系统时间，路由系统现在时间为 $time_show " >> $LOGFILE
#	cat /dev/null > $KSROOT/autocheckin/account.ini
#	[ -f "$KSROOT/autocheckin/cookie.txt" ] && rm -rf $KSROOT/autocheckin/cookie.txt
#	[ ! -L "$KSROOT/bin/autocheckin" ] && ln -sf $KSROOT/autocheckin/autocheckin $KSROOT/bin
#	user_nu=`dbus list autocheckin_user_name_|wc -l`
#	for i in `seq $user_nu`
#	do
#		user_name=`dbus get autocheckin_user_name_$i`
#		user_cookie=`dbus get autocheckin_user_cookie_$i | base64_decode`
#		echo -e "\"${user_name}\"=`echo $user_cookie`" >> $KSROOT/autocheckin/cookie.txt
#	done
}

check_signdog(){
	if [ ! -s "$KSROOT/autocheckin/config.json" ]; then
		echo_date1 "------------------------------ Koolshare LEDE X64 签到狗3.0 -------------------------------" >> $LOGFILE
		echo_date1 "检测到你没有启动插件！关闭插件！" >> $LOGFILE
		dbus set autocheckin_enable="0"
		echo_date1 "------------------------------ Koolshare LEDE X64 签到狗3.0 -------------------------------" >> $LOGFILE
		echo XU6J03M6 >> $LOGFILE
		exit 1
	fi
}
random()
{
	min=$1
	max=$(($2-$min+1))
	num=$(date +%s%N)
	echo $(($num%$max+$min))
}

set_cru(){
	if [ "$autocheckin_enable" == "1" ]; then
		show=$(random 1 30)
		out=`echo "${show}m"`
		echo_date1 "添加签到定时任务，每天 $autocheckin_hour 点 $out 分自动签到..." >> $LOGFILE
		sed -i '/autocheckin/d' /etc/crontabs/root >/dev/null 2>&1
		echo "0 $autocheckin_hour * * * sleep $out && $KSROOT/scripts/autocheckin_config.sh 6 start" >> /etc/crontabs/root
	else
		echo_date1 "删除签到定时任务！" >> $LOGFILE
		sed -i '/autocheckin/d' /etc/crontabs/root >/dev/null 2>&1
	fi
}

creat_start_up(){
	[ ! -L "/etc/rc.d/S95autocheckin.sh" ] && ln -sf /koolshare/init.d/S95autocheckin.sh /etc/rc.d/S95autocheckin.sh
}

del_start_up(){
	rm -rf /etc/rc.d/S99autocheckin.sh >/dev/null 2>&1
}

save_config(){
	gen_user_config
#	set_cru
}

start_autocheckin(){
#	echo_date1 "立即开始签到..."
	cd $KSROOT/autocheckin && ./signdog >/dev/null 2>&1 &
}

stop_autocheckin(){
#	set_cru
#	del_start_up
	killall -9 signdog >/dev/null 2>&1
#	rm -rf $KSROOT/autocheckin/cookie.txt
}

case "$2" in
	start | 6)
	echo_date1 "------------------------------ Koolshare LEDE X64 签到狗3.0 -------------------------------" > $LOGFILE
	http_response "$1"
	echo_date1 "保存设置并立即签到！" >> $LOGFILE
	start_autocheckin >> $LOGFILE 2>&1
	echo_date1 "签到结束，请查看是否遗漏！" >> $LOGFILE
	echo_date1 "------------------------------ Koolshare LEDE X64 签到狗3.0 -------------------------------" >> $LOGFILE
	echo XU6J03M6 >> $LOGFILE	
	;;
	*)
	echo_date1 "------------------------------ Koolshare LEDE X64 签到狗3.0 -------------------------------" > $LOGFILE
	http_response "$1"
	if [ "$autocheckin_enable" == "1" ];then
		#echo_date1 "仅保存设置，签到将在你设定的时间进行..." >> $LOGFILE
		save_config >> $LOGFILE
		stop_autocheckin
		start_autocheckin
		creat_start_up
		echo_date1 "启动成功..." >> $LOGFILE
	else
		echo_date1 "关闭自动签到！" >> $LOGFILE
		stop_autocheckin >> $LOGFILE
		echo_date1 "关闭成功！" >> $LOGFILE
	fi
	echo_date1 "------------------------------ Koolshare LEDE X64 签到狗3.0 -------------------------------" >> $LOGFILE
	echo XU6J03M6 >> $LOGFILE
	;;
esac
