#pragma once
#include "drivers/pinconf.hh"

namespace mdrivlib {
struct QSPIFlashConfig {
  PinConf io0{};
  PinConf io1{};
  PinConf io2{};
  PinConf io3{};
  PinConf clk{};
  PinConf cs{};

  uint32_t clock_division = 4;
  uint32_t IRQ_pri = 2;
  uint32_t IRQ_subpri = 2;

  uint32_t flash_size_bytes = 0x40000;

  enum AddressBits { AddrBits24 = 24, AddrBits32 = 32 };
  AddressBits flash_size_address_bits = AddrBits24;

  enum ChipID { IS25L, S25FLxxxL, W25Q128JV };
  ChipID chip_id = IS25L;

  enum IOMode { SingleSPI, DualSPI, QuadSPI };
  IOMode io_mode = QuadSPI;

  enum Bank { Bank1, Bank2 };
  Bank bank = Bank1;
};

} // namespace mdrivlib
