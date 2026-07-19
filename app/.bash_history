ps aux | grep php
pgrep php-fpm
exit
echo > /dev/tcp/127.0.0.1/9000
echo $?
ps aux
ls -la /var/run/php-fpm*
exit
