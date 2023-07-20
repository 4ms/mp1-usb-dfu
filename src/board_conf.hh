#pragma once

// You must select your board:
//  Add the compilation flag:
//  -DBOARD_CONF_PATH="path/conf_file.hh"
//
//  Or put this at the top of main.cc:
//  #define BOARD_CONF_PATH "path/conf_file.hh"

#define HEADER_STRING_I(s) #s
#define HEADER_STRING(s) HEADER_STRING_I(s)

#if defined(BOARD_CONF_PATH)
#include HEADER_STRING(BOARD_CONF_PATH)

#elif defined(BOARD_CONF_OSD32)
#include "board_conf/osd32brk_conf.hh"

#elif defined(BOARD_CONF_DK2)
#include "board_conf/stm32disco_conf.hh"

#else
#include "board_conf/mmp11_conf.hh"
#warning "No board was selected. See src/board_conf.hh"
#endif
