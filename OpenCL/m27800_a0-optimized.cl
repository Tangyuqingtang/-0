/**
 * Author......: See docs/credits.txt
 * License.....: MIT
 */

//#define NEW_SIMD_CODE

#ifdef KERNEL_STATIC
#include "inc_vendor.h"
#include "inc_types.h"
#include "inc_platform.cl"
#include "inc_common.cl"
#include "inc_rp_optimized.h"
#include "inc_rp_optimized.cl"
#include "inc_simd.cl"
#endif

inline u32 Murmur32_Scramble(u32 k)
{
  k = (k * 0x16A88000) | ((k * 0xCC9E2D51) >> 17);
  return (k * 0x1B873593);
}

DECLSPEC u32 MurmurHash3(const u32 seed, const u32* data, const u32 size)
{
  u32 checksum = seed;

  const u32 nBlocks = (size / 4);
  if (size >= 4) //Hash blocks, sizes of 4
  {
    for (u32 i = 0; i < nBlocks; i++)
    {
      checksum ^= Murmur32_Scramble(data[i]);
      checksum = (checksum >> 19) | (checksum << 13); //rotateRight(checksum, 19)
      checksum = (checksum * 5) + 0xE6546B64;
    }
  }

  if (size % 4)
  {
    const u8* remainder = (u8*)(data + nBlocks);
    u32 val = 0;

    switch(size & 3) //Hash remaining bytes as size isn't always aligned by 4
    {
      case 3:
        val ^= (remainder[2] << 16);
      case 2:
        val ^= (remainder[1] << 8);
      case 1:
        val ^= remainder[0];
        checksum ^= Murmur32_Scramble(val);
      default:
        break;
    };
  }

  checksum ^= size;
  checksum ^= checksum >> 16;
  checksum *= 0x85EBCA6B;
  checksum ^= checksum >> 13;
  checksum *= 0xC2B2AE35;
  return checksum ^ (checksum >> 16);
}

KERNEL_FQ void m27800_m04 (KERN_ATTR_RULES ())
{
  /**
   * modifier
   */

  const u64 lid = get_local_id (0);

  /**
   * base
   */

  const u64 gid = get_global_id (0);

  if (gid >= gid_max) return;

  u32 pw_buf0[4];
  u32 pw_buf1[4];

  pw_buf0[0] = pws[gid].i[0];
  pw_buf0[1] = pws[gid].i[1];
  pw_buf0[2] = pws[gid].i[2];
  pw_buf0[3] = pws[gid].i[3];
  pw_buf1[0] = pws[gid].i[4];
  pw_buf1[1] = pws[gid].i[5];
  pw_buf1[2] = pws[gid].i[6];
  pw_buf1[3] = pws[gid].i[7];

  const u32 pw_len = pws[gid].pw_len & 63;

  /**
   * seed
   */

  const u32 seed = salt_bufs[SALT_POS].salt_buf[0];

  /**
   * loop
   */

  for (u32 il_pos = 0; il_pos < il_cnt; il_pos += VECT_SIZE)
  {
    u32x w[16] = { 0 };

    const u32x out_len = apply_rules_vect_optimized (pw_buf0, pw_buf1, pw_len, rules_buf, il_pos, w + 0, w + 4);

    u32x hash = MurmurHash3 (seed, w, out_len);

    const u32x r0 = hash;
    const u32x r1 = 0;
    const u32x r2 = 0;
    const u32x r3 = 0;

    COMPARE_M_SIMD (r0, r1, r2, r3);
  }
}

KERNEL_FQ void m27800_m08 (KERN_ATTR_RULES ())
{
}

KERNEL_FQ void m27800_m16 (KERN_ATTR_RULES ())
{
}

KERNEL_FQ void m27800_s04 (KERN_ATTR_RULES ())
{
  /**
   * modifier
   */

  const u64 lid = get_local_id (0);

  /**
   * base
   */

  const u64 gid = get_global_id (0);

  if (gid >= gid_max) return;

  u32 pw_buf0[4];
  u32 pw_buf1[4];

  pw_buf0[0] = pws[gid].i[0];
  pw_buf0[1] = pws[gid].i[1];
  pw_buf0[2] = pws[gid].i[2];
  pw_buf0[3] = pws[gid].i[3];
  pw_buf1[0] = pws[gid].i[4];
  pw_buf1[1] = pws[gid].i[5];
  pw_buf1[2] = pws[gid].i[6];
  pw_buf1[3] = pws[gid].i[7];

  const u32 pw_len = pws[gid].pw_len & 63;

  /**
   * digest
   */

  const u32 search[4] =
  {
    digests_buf[DIGESTS_OFFSET].digest_buf[DGST_R0],
    0,
    0,
    0
  };

  /**
   * seed
   */

  const u32 seed = salt_bufs[SALT_POS].salt_buf[0];

  /**
   * loop
   */

  for (u32 il_pos = 0; il_pos < il_cnt; il_pos += VECT_SIZE)
  {
    u32x w[16] = { 0 };

    const u32x out_len = apply_rules_vect_optimized (pw_buf0, pw_buf1, pw_len, rules_buf, il_pos, w + 0, w + 4);

    u32x hash = MurmurHash3 (seed, w, out_len);

    const u32x r0 = hash;
    const u32x r1 = 0;
    const u32x r2 = 0;
    const u32x r3 = 0;

    COMPARE_S_SIMD (r0, r1, r2, r3);
  }
}

KERNEL_FQ void m27800_s08 (KERN_ATTR_RULES ())
{
}

KERNEL_FQ void m27800_s16 (KERN_ATTR_RULES ())
{
}