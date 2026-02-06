//
//  ForgeMMDBBridge.h
//  ForgeMMDB
//
//  Created by MagicianQuinn on 2026/2/5.
//

#ifndef ForgeMMDBBridge_h
#define ForgeMMDBBridge_h

#include <stdint.h>

// 0 = success, nonzero = MMDB_ error code
int forge_mmdb_open(const char *path);
void forge_mmdb_close(void);

/* return packed ISO alpha2 in BE order, 0 if not found */
uint16_t forge_mmdb_country_ipv4(uint32_t ipv4_be);

#endif /* ForgeMMDBBridge_h */
