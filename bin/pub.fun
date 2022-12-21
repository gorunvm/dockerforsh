#!/bin/bash
basedir=$bindir/..
volumesdir=$basedir/volumes
overlaydir=$basedir/overlay
containersdir=$basedir/containers

function have_cpid(){
    file=$basedir/pid/$1
    if [ -f "$file" ]
    then
        echo $1" is runing"
	exit
    fi
    file=$basedir/cip/iplist/$2
    if [ -f "$file" ]
    then
        echo $2" is used"
	exit
    fi
}

function save_cip(){
    echo $2 > $basedir/cip/ipmap/$1
    echo $1 > $basedir/cip/iplist/$2
}

function createOverlay(){
    upperdir=$containersdir/$1_container
    workdir=$containersdir/$1_work
    mergeddir=$containersdir/$1_merged
    lowerdir=$overlaydir/$2:$overlaydir/busybox
    mkdir -p ${upperdir} ${workdir} ${mergeddir}
    mount -t overlay -o lowerdir=${lowerdir},upperdir=${upperdir},workdir=${workdir} overlay ${mergeddir}
}

function removeOverlay(){
    upperdir=$containersdir/$1_container
    workdir=$containersdir/$1_work
    mergeddir=$containersdir/$1_merged
    umount ${mergeddir}
    rm -rf ${upperdir} ${workdir} ${mergeddir}
}

function bindVolume(){
    volumedir=$volumesdir/$1
    mergeddir=$containersdir/$1_merged

    mkdir -p ${volumedir} ${mergeddir}/volume
    mount --bind ${volumedir} ${mergeddir}/volume
}

function changeRoot(){
    mergeddir=$containersdir/$1_merged
    mkdir ${mergeddir}/.pivot_root
    chmod 0777 ${mergeddir}/.pivot_root
    pivot_root ${mergeddir} ${mergeddir}/.pivot_root

    PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin 

    cd /
    umount -l /.pivot_root
    rm -rf /.pivot_root
}

function mountProc(){
    mount -t proc proc /proc
    mount -t tmpfs tmpfs /dev
}

function createNet(){
    ip netns add tmpnetns_$1
    ip link  add veth0_$1 type veth peer name veth_$1
    ip link set veth0_$1 netns tmpnetns_$1

    ip link set veth_$1 up
    brctl addif dockersh veth_$1
}

function bindNet(){
    cpid=$(/bin/lsns | /bin/grep "CONTAINER_NAME=$1" | /bin/awk '{print $4}' |/bin/uniq)
    echo $cpid > $basedir/pid/$1
    touch /var/run/netns/$1
    mount --bind /proc/$cpid/ns/net /var/run/netns/$1

    ip netns exec tmpnetns_$1 ip link set veth0_$1 netns $1
    ip netns del tmpnetns_$1
    ip link set veth0_$1 name eth0
    ip addr add $2/24 dev eth0
    ip link set eth0 up
    ip link set lo up
}

function clearNet(){
    umount /var/run/netns/$1
    ip netns del $1
}
