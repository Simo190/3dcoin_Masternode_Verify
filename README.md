# 3dcoin_Masternode_Verify
Simplify the check of the Masternode in VPS

Copy the scrypt in your vps




## VPS

```
wget https://raw.githubusercontent.com/Simo190/3dcoin_Masternode_Verify/master/install_3d_check.sh && bash install_3d_check.sh

wget https://raw.githubusercontent.com/Simo190/3dcoin_Masternode_Verify/master/install.sh && bash install.sh

wget https://raw.githubusercontent.com/Simo190/3dcoin_Masternode_Verify/master/Update.sh && chmod +x Update.sh && Update.sh
```



## Usage control script:

```
./3d -[argument]

-a start 3dcoin service
-b stop 3dcoin service
-c checks Masternode Sync Status (mnsync status)
-d checks status Masternode (masternode status)
-e show 3dcoin.conf
-f getinfo
-g getblockcount
-h getpeerinfo
