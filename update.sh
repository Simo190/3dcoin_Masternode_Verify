wget https://github.com/ScaMar/3dcoin-masternode-unofficial/raw/master/3dcoin-linux.zip
unzip 3dcoin-linux.zip
3dcoin-cli stop
sleep 20
killall 3dcoind
rm /usr/local/bin/3dcoind
rm /usr/local/bin/3dcoin-cli
chmod +x 3dcoin-cli
chmod +x 3dcoind
mv 3dcoind /usr/local/bin
mv 3dcoin-cli /usr/local/bin
3dcoind -daemon
watch 3dcoin-cli masternode status
