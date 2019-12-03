wget -c http://libvirt.org/sources/libvirt-1.2.2-1.fc19.src.rpm
rpmbuild --rebuild libvirt-1.2.2-1.fc19.src.rpm
cp /home/fedor/rpmbuild/RPMS/x86_64/*.rpm .

