#include <linux/version.h>
#include <linux/module.h>
#include <linux/vmalloc.h>
#include <linux/platform_device.h>
#include <linux/pm_runtime.h>
#include <linux/regulator/consumer.h>

#include <asm/io.h>

#if (LINUX_VERSION_CODE >= KERNEL_VERSION(3, 0, 0))
#include <linux/printk.h>
#include <linux/err.h>
#else
#include <config/printk.h>
#endif


extern int ssvdevice_init(void);
extern void ssvdevice_exit(void);

//#include <linux/rfkill-wlan.h>
extern int get_wifi_chip_type(void);
//extern int rockchip_wifi_power(int on);
//extern int rockchip_wifi_set_carddetect(int val);

int initWlan(void)
{
    int ret=0;
    printk(KERN_INFO "wlan.c initWlan\n");
    printk("\n");
    printk("=======================================================\n");
    printk("==== Launching Wi-Fi driver! (Powered by Rockchip) ====\n");
    printk("=======================================================\n");
    printk("SSV6x5x SDIO WiFi driver\n");

//    rockchip_wifi_power(1);
//    rockchip_wifi_set_carddetect(1);
    
    ret = ssvdevice_init();
    return ret;
}

void exitWlan(void)
{
    ssvdevice_exit();
    
//    rockchip_wifi_set_carddetect(0);
//    rockchip_wifi_power(0);
    return;
}

int generic_wifi_init_module(void)
{
	return initWlan();
}

void generic_wifi_exit_module(void)
{
	exitWlan();
}

EXPORT_SYMBOL(generic_wifi_init_module);
EXPORT_SYMBOL(generic_wifi_exit_module);

#ifdef CONFIG_SSV6X5X //CONFIG_SSV6XXX=y
late_initcall(generic_wifi_init_module);
#else //CONFIG_SSV6XXX=m or =n
module_init(generic_wifi_init_module);
#endif
module_exit(generic_wifi_exit_module);

MODULE_LICENSE("Dual BSD/GPL");
