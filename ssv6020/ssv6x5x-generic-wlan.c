/*
 * Platform-neutral module entry. The card is powered and enumerated on its
 * SDIO bus before the module loads (a board GPIO, the host's card detect),
 * so there is no platform hook to call here; Allwinner's version drove its
 * sunxi WLAN power and MMC rescan helpers.
 */
#include <linux/module.h>

extern int ssvdevice_init(void);
extern void ssvdevice_exit(void);

static int generic_wifi_init_module(void)
{
	return ssvdevice_init();
}

static void generic_wifi_exit_module(void)
{
	ssvdevice_exit();
}

module_init(generic_wifi_init_module);
module_exit(generic_wifi_exit_module);
MODULE_LICENSE("Dual BSD/GPL");
