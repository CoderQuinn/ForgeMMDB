//
//  ForgeMMDBBridge.c
//  ForgeMMDB
//
//  Created by MagicianQuinn on 2026/2/5.
//

#include "ForgeMMDBBridge.h"
#include <maxminddb.h>
#include <arpa/inet.h>
#include <string.h>

static MMDB_s g_db;
static int g_refcount = 0;

int forge_mmdb_open(const char *path)
{
    if (g_refcount++ > 0)
        return 0;

    int status = MMDB_open(path, MMDB_MODE_MMAP, &g_db);
    if (status != MMDB_SUCCESS) {
        g_refcount = 0;
        return status;
    }

    return 0;
}

void forge_mmdb_close(void)
{
    if (g_refcount <= 0)
        return;

    if (--g_refcount > 0)
        return;

    MMDB_close(&g_db);
    g_refcount = 0;
}

uint16_t forge_mmdb_country_ipv4(uint32_t ipv4_be)
{
    if (g_refcount <= 0)
        return 0;

    struct sockaddr_in sa = {0};
    sa.sin_family = AF_INET;
    sa.sin_addr.s_addr = ipv4_be;

    int err;
    MMDB_lookup_result_s result =
        MMDB_lookup_sockaddr(&g_db, (struct sockaddr *)&sa, &err);

    if (err != MMDB_SUCCESS || !result.found_entry)
        return 0;

    MMDB_entry_data_s data;
    if (MMDB_get_value(&result.entry, &data, "country", "iso_code", NULL) != MMDB_SUCCESS ||
        !data.has_data || data.data_size != 2)
        return 0;

    const unsigned char *s = (const unsigned char *)data.utf8_string;
    return ((uint16_t)s[0] << 8) | s[1];
}
