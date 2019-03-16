wget https://github.com/ScaMar/3dcoin/releases/download/v0.14.4.2/3dcoin-v0.14.4.2-x86_64-pc-linux-gnu.zip
unzip 3dcoin-v0.14.4.2-x86_64-pc-linux-gnu.zip
3dcoin-cli stop
sleep 30
killall -15 3dcoind
rm /usr/local/bin/3dcoind
rm /usr/local/bin/3dcoin-cli
chmod +x 3dcoin-cli
chmod +x 3dcoind
mv 3dcoind /usr/local/bin
mv 3dcoin-cli /usr/local/bin
3dcoind -daemon
sleep 20
3dcoin-cli addnode 89.36.213.199:6695 onetry
3dcoin-cli -version
sleep 5
watch 3dcoin-cli masternode status
