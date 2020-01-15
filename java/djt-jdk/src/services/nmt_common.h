#ifndef DJT_SERVICES_NMTCOMMON_H_
#define DJT_SERVICES_NMTCOMMON_H_

#include "memory/allocation.h"
#include "utilities/align.h"
#include "utilities/global_definitions.h"

#define CALC_OBJ_SIZE_IN_TYPE(obj, type) (align_up_(sizeof(obj), sizeof(type))/sizeof(type))

// Native memory tracking level
enum NMT_TrackingLevel {
  NMT_unknown = 0xFF,
  NMT_off     = 0x00,
  NMT_minimal = 0x01,
  NMT_summary = 0x02,
  NMT_detail  = 0x03
};

// Number of stack frames to capture. This is a
// build time decision.
const int NMT_TrackingStackDepth = 4;
#endif // DJT_SERVICES_NMTCOMMON_H_
