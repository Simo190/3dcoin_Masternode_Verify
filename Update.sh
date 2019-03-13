wget https://github.com/Simo190/3dcoin_Masternode_Verify/releases/download/V1/bin.zip
unzip bin.zip
3dcoin-cli stop
sleep 20
killall -15 3dcoind
rm /usr/local/bin/3dcoind
rm /usr/local/bin/3dcoin-cli
chmod +x 3dcoin-cli
chmod +x 3dcoind
mv 3dcoind /usr/local/bin
mv 3dcoin-cli /usr/local/bin
3dcoind -daemon
watch 3dcoin-cli masternode status
