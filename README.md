# 3dcoin_Masternode_Verify
Simplify the check of the Masternode in VPS




## VPS

```
wget https://raw.githubusercontent.com/Simo190/LITEX-masternode-autoinstall/master/Upload_Ltx-control.sh && bash Upload_Ltx-control.sh
```



## Usage control script:

```
./3d_check.sh -[argument]

-a start 3dcoin service
-b stop 3dcoin service
-c checks Masternode Sync Status (mnsync status)
-d checks status Masternode (masternode status)
-e show 3dcoin.conf
-f getinfo
-g getblockcount
-h getpeerinfo
