/*
 * start.S
 *
 * Entry point of the Voice Wakeup Module.
 * The firmware code are executed in the L2Cache.
 *
 * Copyright (C) 2006 Ingenic Semiconductor Inc.
 *
 */


	.globl	start

	.extern open
	.extern handler
	.extern close
	.extern cache_prefetch

	.extern set_handler
	.extern get_dma_address
	.extern ioctl
	.extern get_resource_addr
	.extern process_data
	.extern is_cpu_wakeup_by_dmic
	.extern set_sleep_buffer
	.extern get_sleep_process
	.extern set_dma_channel
	.extern voice_wakeup_enable
	.extern is_voice_wakeup_enabled

	.extern module_init
	.extern module_exit
start:
	.section .interface
	.word open
	.word handler
	.word close
	.word cache_prefetch
	.word set_handler
	.word get_dma_address
	.word ioctl
	.word get_resource_addr
	.word process_data
	.word is_cpu_wakeup_by_dmic
	.word set_sleep_buffer
	.word get_sleep_process
	.word set_dma_channel
	.word voice_wakeup_enable
	.word is_voice_wakeup_enabled

	.word module_init
	.word module_exit

