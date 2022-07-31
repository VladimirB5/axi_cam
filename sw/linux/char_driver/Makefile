ARCH := arm
obj-m := axi_cam.o
PWD := $(shell pwd)
export
default:
	$(MAKE) -C $(KERNEL) M=$(PWD) modules
clean:
	$(MAKE) -C $(KERNEL) M=$(PWD) clean
