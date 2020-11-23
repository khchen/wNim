{.used.}
when defined(vcc):
  {.link: "wNimVcc.res".}

elif defined(cpu64):
  when defined(tcc):
    {.link: "wNimTcc64.res".}

  else:
    {.link: "wNim64.res".}

else:
  when defined(tcc):
    {.link: "wNimTcc32.res".}

  else:
    {.link: "wNim32.res".}
