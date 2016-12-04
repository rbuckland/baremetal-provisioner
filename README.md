# baremetal-provisioner

This repo is notes and scripts for making and deploying baremetal OS's to machines. 
No VM's here :-*


## Manually Making Images

### Create a File with MBR and Partition(s)

How big is the MBR ? (where do the first partitions start)
(Answer is 1MiB)
```
rbuckland@chip:~/image-build$ sudo fdisk /dev/sda
[sudo] password for rbuckland: 

Welcome to fdisk (util-linux 2.27.1).
Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.


Command (m for help): p
Disk /dev/sda: 119.2 GiB, 128035676160 bytes, 250069680 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0x1169fa0e

Device     Boot     Start       End   Sectors   Size Id Type
/dev/sda1  *         2048 216709119 216707072 103.3G 83 Linux
/dev/sda2       216711166 250068991  33357826  15.9G  5 Extended
/dev/sda5       216711168 250068991  33357824  15.9G 82 Linux swap / Solaris

Command (m for help): q

```

`2048 units * 512 bytes = 1MiB`

* So we first set aside 1M
```
# dd if=/dev/zero of=disk.img count=1 bs=1MiB
1+0 records in  
1+0 records out  
1048576 bytes (1.0 MB) copied, 0.00177852 s, 590 MB/s  
```

* Then we can create a "bigger" disk .. and add it to the end. (400M for this example :-) )

```
# dd if=/dev/zero of=extra.img count=1 bs=400M
```

* Add those two together

```
# cat extra.img >> disk.img
```

* Create a Partition Map on the Image, with the right Partition Sizes 

```
rbuckland@chip:~/image-build$ fdisk disk.img

Welcome to fdisk (util-linux 2.27.1).
Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.

Device does not contain a recognized partition table.
Created a new DOS disklabel with disk identifier 0x31b61846.

Command (m for help): p
Disk disk.img: 401 MiB, 420478976 bytes, 821248 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0x31b61846

Command (m for help): n
Partition type
   p   primary (0 primary, 0 extended, 4 free)
   e   extended (container for logical partitions)
Select (default p): p
Partition number (1-4, default 1): 
First sector (2048-821247, default 2048): 2048
Last sector, +sectors or +size{K,M,G,T,P} (2048-821247, default 821247): 

Created a new partition 1 of type 'Linux' and of size 400 MiB.

Command (m for help): a
Selected partition 1
The bootable flag on partition 1 is enabled now.

Command (m for help): p
Disk disk.img: 401 MiB, 420478976 bytes, 821248 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0x31b61846

Device     Boot Start    End Sectors  Size Id Type
disk.img1   *     2048 821247  819200  400M 83 Linux

Command (m for help): w
The partition table has been altered.
Syncing disks.

rbuckland@chip:~/image-build$ file disk.img 
disk.img: DOS/MBR boot sector; partition 1 : ID=0x83, active, start-CHS (0x0,32,33), end-CHS (0x33,30,43), startsector 2048, 819200 sectors

```

* Make the partition, format it and then mount it.

  * First - register the partition in the image, using device mapper. (kpartx)
  
  ```
  rbuckland@chip:~/image-build$ sudo kpartx -a -v disk.img 
  add map loop0p1 (252:0): 0 819200 linear 7:0 2048
  ```

  * We now have a partition - format (`mkfs`) and `mount` it

  ```
  rbuckland@chip:~/image-build$ sudo mkfs.ext4 /dev/mapper/loop0p1 
  mke2fs 1.42.13 (17-May-2015)
  Discarding device blocks: done                            
  Creating filesystem with 409600 1k blocks and 102400 inodes
  Filesystem UUID: ef8debcd-6d85-48db-9acb-ebe154211c61
  Superblock backups stored on blocks: 
    8193, 24577, 40961, 57345, 73729, 204801, 221185, 401409

  Allocating group tables: done                            
  Writing inode tables: done                            
  Creating journal (8192 blocks): done
  Writing superblocks and filesystem accounting information: done 

  rbuckland@chip:~/image-build$ mkdir mount
  rbuckland@chip:~/image-build$ sudo mount /dev/mapper/loop0p1 mount
  ```
  
