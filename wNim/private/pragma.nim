#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2021 Ward
#
#====================================================================

{.experimental.}

{.warning[LockLevel]: off.}

when compiles(block: {.warning[CastSizes]: off.}):
  {.warning[CastSizes]: off.}

when compiles(block: {.warning[BareExcept]: off.}):
  {.warning[BareExcept]: off.}

when defined(gcDestructors): {.push sinkInference: off.}
