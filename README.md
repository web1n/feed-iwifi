## feed-iwifi
OpenWrt 下的河北联通校园宽带拨号工具（使用网页认证协议）

### 如何编译
1. 修改 feeds.conf.default，最后一行添加 ```src-git iwifi https://github.com/web1n/feed-iwifi```
2. 刷新 feeds
```
./scripts/feeds update -a
./scripts/feeds install -a
```
3. 使用 ```make menuconfig``` 命令，在 LuCI-> Protocols 中选中 luci-proto-iwifi 软件包
4. 编译

### 使用方法
选中 OpenWrt 后台-> 接口-> 对应的接口-> 选择河北联通校园协议-> 填写宽带用户名密码后保存-> 等待登录成功

### License
Apache License
