{.used.}
when defined(vcc):
  {.link: "wWebViewVcc.res".}

elif defined(cpu64):
  when defined(tcc):
    {.link: "wWebViewTcc64.res".}

  else:
    {.link: "wWebView64.res".}

else:
  when defined(tcc):
    {.link: "wWebViewTcc32.res".}

  else:
    {.link: "wWebView32.res".}
