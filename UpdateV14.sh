wget https://github.com/Simo190/3dcoin_Masternode_Verify/releases/download/V1/3dcoin-cli
wget
chmod +x 3dcoind
chmod +x 3dcoin-cli
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
sleep 20
3dcoin-cli addnode 89.36.213.199:6695 onetry
watch 3dcoin-cli masternode status
