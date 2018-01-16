#=============================================================#
# Name:         Stunnel Auto Installer                        #
# Description:  Automatic install and setup stunnel           #
#               for Debian / ubuntu                           #
# Version:      1.0                                           #
#=============================================================#

if [[ "$USER" != 'root' ]]; then
	echo "Maaf, Silahkan login menggunakan root"
	exit
fi

#detail nama perusahaan
country=ID
state=JawaTengah
locality=Purwokerto
organization=GlobalSSH
organizationalunit=Provider
commonname=globalssh.net
email=admin@globalssh.net

#memeriksa port yang sedang berjalan

echo "-------------------- Stunnel Installer untuk debian dan ubuntu -------------------"
echo ""
echo "Mohon tunggu sebentar.. sedang memeriksa port yang berjalan"
sleep 2
openssh=444
dropbear1=80
dropbear2=443
squid1=3128
squid2=8080
if lsof -Pi :$openssh -sTCP:LISTEN -t >/dev/null ; then
	echo "Telah terdeteksi port $port sedang berjalan/aktif"
	sleep 2
	break
	clear
	echo "mohon untuk menonaktifkan/mematikan/merubah port $openssh"
	echo "jika sudah silakan mulai install dari awal"
elif lsof -Pi :$dropbear1 -sTCP:LISTEN -t >/dev/null ; then
	echo "Telah terdeteksi port $port sedang berjalan/aktif"
	sleep 2
	break
	clear
	echo "mohon untuk menonaktifkan/mematikan/merubah port $dropbear1"
	echo "jika sudah silakan mulai install dari awal"
if lsof -Pi :$dropbear2 -sTCP:LISTEN -t >/dev/null ; then
	echo "Telah terdeteksi port $port sedang berjalan/aktif"
	sleep 2
	break
	clear
	echo "mohon untuk menonaktifkan/mematikan/merubah port $dropbear2"
	echo "jika sudah silakan mulai install dari awal"
if lsof -Pi :$squid1 -sTCP:LISTEN -t >/dev/null ; then
	echo "Telah terdeteksi port $port sedang berjalan/aktif"
	sleep 2
	break
	clear
	echo "mohon untuk menonaktifkan/mematikan/merubah port $squid1"
	echo "jika sudah silakan mulai install dari awal"
if lsof -Pi :$squid2 -sTCP:LISTEN -t >/dev/null ; then
	echo "Telah terdeteksi port $port sedang berjalan/aktif"
	sleep 2
	break
	clear
	echo "mohon untuk menonaktifkan/mematikan/merubah port $squid2"
	echo "jika sudah silakan mulai install dari awal"
else
    echo ""
fi

#memeriksa paket dropbear

dpkg -s dropbear &> /dev/null

if [ $? -eq 0 ]; then
    echo ""
else
    echo "Mohon install dropbear terlebih dahulu"
	break
fi

#update repository
apt-get update
apt-get install stunnel4 -y
ip="ifconfig | awk -F':' '/inet addr/&&!/127.0.0.1/&&!/127.0.0.2/{split($2,_," ");print _[1]}'"
cat > /etc/stunnel/stunnel.conf <<-END
pid = /var/run/stunnel4.pid
cert = /etc/stunnel/stunnel.pem
client = no
socket = a:SO_REUSEADDR=1
socket = l:TCP_NODELAY=1
socket = r:TCP_NODELAY=1

[squid1]
accept = 8080
connect = $ip:8000
[squid2]
accept = 3128
connect = $ip:8000
[dropbear1]
accept = 443
connect = $ip:143
[dropbear2]
accept = 80
connect = $ip:143
[openssh]
accept = 444
connect = $ip:22
END

#membuat sertifikat
openssl genrsa -out key.pem 2048
openssl req -new -x509 -key key.pem -out cert.pem -days 1095 \
-subj "/C=$country/ST=$state/L=$locality/O=$organization/OU=$organizationalunit/CN=$commonname/emailAddress=$email"
cat key.pem cert.pem >> /etc/stunnel/stunnel.pem

#konfigurasi stunnel
sed -i 's/ENABLED=0/ENABLED=1/g' /etc/default/stunnel4
/etc/init.d/stunnel4 restart

#informasi
clear
	echo "------------------------- Informasi ------------------------"
	echo ""
	echo "Installer Stunnel4 Berhasil"
	echo ""
	echo "OpenSSH	: 444"
	echo "Dropbear	: 80 / 443"
	echo "Squid	: 3128 / 8080"
