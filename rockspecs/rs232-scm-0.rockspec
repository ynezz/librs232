package = "rs232"
version = "scm-0"

source = {
  url = "https://github.com/moteus/librs232/archive/master.zip",
  dir = "librs232-master",
}

description = {
  summary    = "Serial port communication library",
  homepage   = "https://github.com/moteus/librs232",
  license    = "MIT/X11",
  maintainer = "Alexey Melnichuk",
  detailed   = [[
  This library based on`librs232` and provide OO API for `librs232`
  Also this libray has some bug fixes for `librs232`, but this is not official `librs232` library.
  ]],
}

dependencies = {
  "lua >= 5.1, < 5.4"
}

external_dependencies = {
}

build = {
  copy_directories = {'doc', 'bindings/lua/examples'},

  type = "builtin",

  platforms = {
    windows = { modules = {
      ['rs232.core'] = {
        sources = {
          'src/rs232.c',
          'src/rs232_windows.c',
          'bindings/lua/luars232.c',
        },
      }
    }},

    unix    = { modules = {
      ['rs232.core'] = {
        sources = {
          'src/rs232.c',
          'src/rs232_posix.c',
          'bindings/lua/luars232.c',
        },
      }
    }},

  },

  modules = {
    ['rs232.core'] = {
      incdirs   = { 'include' },
      defines   = { 'RS232_EXPORT' },
    },
    rs232 = 'bindings/lua/rs232.lua',
  }
}
