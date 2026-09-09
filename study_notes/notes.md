## 2.8 Terraform IOS-XE
### How to enable netconf on IOS-XE
config t
netconf-yang
### How to verify netconf enabled
ssh admin@10.0.0.251 -p 830 -s netconf