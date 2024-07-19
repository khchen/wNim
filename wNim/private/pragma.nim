#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 Copyright (c) Chen Kai-Hung, Ward
#
#====================================================================

{.experimental.}

{.warning[LockLevel]: off.}

when compiles(block: {.warning[CastSizes]: off.}):
  {.warning[CastSizes]: off.}

when compiles(block: {.warning[BareExcept]: off.}):
  {.warning[BareExcept]: off.}

when defined(gcDestructors): {.push sinkInference: off.}
