#pragma once
#include "drivers/i2c_conf.hh"
#include "drivers/leds.hh"
#include "drivers/norflash/qspi_flash_struct.hh"

namespace Board
{
using GPIO = mdrivlib::GPIO;
using PinNum = mdrivlib::PinNum;
using PinAF = mdrivlib::PinAF;
using LedActive = mdrivlib::LedActive;

using RedLED = mdrivlib::Led<GPIO::E, PinNum::_14, LedActive::Low>;
using GreenLED = mdrivlib::Led<GPIO::B, PinNum::_15, LedActive::Low>;
using BlueLED = mdrivlib::Led<GPIO::A, PinNum::_9, LedActive::Low>;

constexpr uint32_t ConsoleUART = UART7_BASE;
constexpr mdrivlib::PinConf UartRX{GPIO::B, PinNum::_3, PinAF::AF_13};
constexpr mdrivlib::PinConf UartTX{GPIO::B, PinNum::_4, PinAF::AF_13};

constexpr mdrivlib::QSPIFlashConfig qspi_flash_conf = {
	.io0 = {GPIO::F, PinNum::_8, PinAF::AF_10},
	.io1 = {GPIO::F, PinNum::_9, PinAF::AF_10},
	.io2 = {GPIO::F, PinNum::_7, PinAF::AF_9},
	.io3 = {GPIO::A, PinNum::_1, PinAF::AF_9},
	.clk = {GPIO::F, PinNum::_10, PinAF::AF_9},
	.cs = {GPIO::B, PinNum::_6, PinAF::AF_10},

	/* QSPI freq = QUADSPICLK /(1 + ClockPrescaler) = 266 MHz/(2+1) = 88 Mhz */
	.clock_division = 2,
	.IRQ_pri = 0,
	.IRQ_subpri = 0,

	.flash_size_bytes = 0x0100'0000,
	.flash_size_address_bits = mdrivlib::QSPIFlashConfig::AddrBits24,

	.chip_id = mdrivlib::QSPIFlashConfig::W25Q128JV,

	.io_mode = mdrivlib::QSPIFlashConfig::QuadSPI,

	.bank = mdrivlib::QSPIFlashConfig::Bank1,
};

} // namespace Board
