#include <asm/regdef.h>
#include <asm/asm.h>

#define CP0_INDEX	$0, 0
#define CP0_RANDOM	$1, 0
#define CP0_ENTRYLO0	$2, 0
#define CP0_ENTRYLO1	$3, 0
#define CP0_PAGEMASK	$5, 0
#define CP0_WIRED	$6, 0
#define CP0_ENTRYHI	$10, 0
#define CP0_STATUS	$12, 0
#define CORE_CTRL	$12, 2
#define CORE_STATUS	$12, 3
#define CORE_REIM	$12, 4
#define CP0_CAUSE	$13, 0
#define CP0_EBASE	$15, 1
#define CP0_CONFIG	$16, 0
#define CP0_CONFIG1	$16, 1
#define CP0_CONFIG7	$16, 7
#define PMON_CSR	$17, 7
#define PMON_HIGH	$17, 4
#define PMON_LC		$17, 5
#define PMON_RC		$17, 6
#define CP0_WATCHLo	$18, 0
#define CP0_WATCHHI	$19, 0
#define CP0_DESAVE	$31, 0

#define READY_FLAG 1
#define PMON_DEBUG 0
#define TLB_SAVE_RESTORE 1

	.data
	.global _regs_stack
_regs_stack:
	.align  5
	.space 64 * 4,0
	.global _tlb_entry_regs
_tlb_entry_regs:
	.align  5
	.space 32 * 3 * 4 + 32,0
	.global	_wait_flag
	.align  5
_wait_flag:
	.space 32,0
	.global	_ready_flag
	.align  5
_ready_flag:
	.space 32,0
	.text
	.global	save_goto
	.align	2
	.type	save_goto, @function
	.ent	save_goto, 0
save_goto:
	.set	push
	.set	noreorder
	.set	noat

	la	k0, _regs_stack

	/* s0-s7 */
	sw	s0, 0*4(k0)
	sw	s1, 1*4(k0)
	sw	s2, 2*4(k0)
	sw	s3, 3*4(k0)
	sw	s4, 4*4(k0)
	sw	s5, 5*4(k0)
	sw	s6, 6*4(k0)
	sw	s7, 7*4(k0)

	/* gp,sp,fp,ra */
	sw	gp, 8*4(k0)
	sw	sp, 9*4(k0)
	sw	fp, 10*4(k0)
	sw	ra, 11*4(k0)

	mfc0	k1, CP0_STATUS
	sw	k1, 12*4(k0)

	mfc0	k1, CP0_EBASE
	sw	k1, 13*4(k0)

	mfc0	k1, CP0_RANDOM
	sw	k1, 14*4(k0)

	mfc0	k1, CP0_PAGEMASK
	sw	k1, 15*4(k0)

	mfc0	k1, CP0_WIRED
	sw	k1, 16*4(k0)

	mfc0	k1, CP0_ENTRYHI
	sw	k1, 17*4(k0)

	mfc0	k1, CP0_CONFIG
	sw	k1, 18*4(k0)

	mfc0	k1, CP0_CONFIG7
	sw	k1, 19*4(k0)

	mfc0	k1, CP0_WATCHLo
	sw	k1, 20*4(k0)

	mfc0	k1, CP0_WATCHHI
	sw	k1, 21*4(k0)

	mfc0	k1, CP0_DESAVE
	sw	k1, 22*4(k0)

	mfc0	k1, PMON_CSR
	sw	k1, 23*4(k0)

	mfc0	k1, PMON_HIGH
	sw	k1, 24*4(k0)

	mfc0	k1, PMON_LC
	sw	k1, 25*4(k0)

	mfc0	k1, PMON_RC
	sw	k1, 26*4(k0)

	mfhi	k1
	sw	k1, 27*4(k0)
	mflo	k1
	sw	k1, 28*4(k0)

#if TLB_SAVE_RESTORE
	/* save tlb entry */
	li	t0, 32
	move	t1, zero
	la	v0, _tlb_entry_regs
1:
	mtc0	t1, CP0_INDEX
	nop
	nop
	nop
	nop

	tlbr
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop

	mfc0	s0, CP0_ENTRYHI
	sw	s0, 0(v0)

	mfc0	s1, CP0_ENTRYLO0
	sw	s1, 4(v0)

	mfc0	s2, CP0_ENTRYLO1
	sw	s2, 8(v0)

	addiu	v0, v0, 12

	slt	t2, t1, t0
	addiu	t1, t1, 1
	bne	t2, zero, 1b
	nop
#endif

	jr	a0
	nop

	.set	reorder
	.set	at
	.set	pop
	END(save_goto)

	.text
	.global	restore_goto
	.align	2
	.type	restore_goto, @function
	.ent	restore_goto, 0
restore_goto:
	.set	push
	.set	noreorder
	.set	noat

	la	k1, _regs_stack

	lw	k0, 15*4(k1)
	mtc0	k0, CP0_PAGEMASK

#if TLB_SAVE_RESTORE
	/* write the tlb */
	li	t0, 32
	move	t1, zero
	la	v0, _tlb_entry_regs
4:
	mtc0	t1, CP0_INDEX
	nop

	lw	s0, 0(v0)
	mtc0	s0, CP0_ENTRYHI

	lw	s1, 4(v0)
	mtc0	s1, CP0_ENTRYLO0

	lw	s2, 8(v0)
	mtc0	s2, CP0_ENTRYLO1

	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	tlbwi

	addiu	v0, v0, 12

	slt	t2, t1, t0
	addiu	t1, t1, 1
	bne	t2, zero, 4b
	nop
#endif
	/* restroe the regs */
	lw	k0, 17*4(k1)
	mtc0	k0, CP0_ENTRYHI

	lw	k0, 16*4(k1)
	mtc0	k0, CP0_WIRED

	/* 15 is loaded before the tlb write */
	lw	k0, 14*4(k1)
	mtc0	k0, CP0_RANDOM

	lw	k0, 13*4(k1)
	mtc0	k0, CP0_EBASE

	lw	k0, 12*4(k1)
	mtc0	k0, CP0_STATUS

	lw	k0, 18*4(k1)
	mtc0	k0, CP0_CONFIG

	lw	k0, 19*4(k1)
	mtc0	k0, CP0_CONFIG7

	lw	k0, 20*4(k1)
	mtc0	k0, CP0_WATCHLo

	lw	k0, 21*4(k1)
	mtc0	k0, CP0_WATCHHI

	lw	k0, 22*4(k1)
	mtc0	k0, CP0_DESAVE

	lw	k0, 23*4(k1)
	mtc0	k0, PMON_CSR

	lw	k0, 24*4(k1)
	mtc0	k0, PMON_HIGH

	lw	k0, 25*4(k1)
	mtc0	k0, PMON_LC

	lw	k0, 26*4(k1)
	mtc0	k0, PMON_RC

	lw	k0, 27*4(k1)
	mthi	k0
	lw	k0, 28*4(k1)
	mtlo	k0

	la	t0, _regs_stack

	/* restore regs */
	lw	s0, 0*4(t0)
	lw	s1, 1*4(t0)
	lw	s2, 2*4(t0)
	lw	s3, 3*4(t0)
	lw	s4, 4*4(t0)
	lw	s5, 5*4(t0)
	lw	s6, 6*4(t0)
	lw	s7, 7*4(t0)

	lw	gp, 8*4(t0)
	lw	sp, 9*4(t0)
	lw	fp, 10*4(t0)
	lw	ra, 11*4(t0)

	jr	ra
	nop

	.set	reorder
	.set	at
	.set	pop
	END(restore_goto)

	.text
	.global	switch_cpu
	.align	2
	.type	switch_cpu, @function
	.ent	switch_cpu, 0
switch_cpu:
	.set	push
	.set	noreorder
	.set	noat

#if PMON_DEBUG

/*in debug this is the time for old core before flush cache */
	/*stop pmon*/
	mfc0	k0, $16, 7
	ori	k0, k0, 0x100
	xori	k0, k0, 0x100
	mtc0	k0, $16, 7

	la	k1, _regs_stack
	mfc0	k0, $17, 6
	sw	k0, 55*4(k1)

	/* clear pmon */
	mtc0    $0, $17, 4
	mtc0    $0, $17, 5
	mtc0    $0, $17, 6

	/* setup pmon */
	mfc0    t3, $16, 7
	li  t4, 0xffff0000
	and t3, t3, t4
	ori t3, t3, 0x500
	mtc0    t3, $16, 7

	/* before wait , we need flush cache */
	li	t0, 0x80000000
	addu	t1, t0, 0x7fe0
3:
	cache	0x1, 0(t0)	// Index_Writeback_Inv_D
	bne	t0, t1, 3b
	addiu	t0, t0, 32
	sync
#endif

/*this is the flash cache time if debug else it's the total time for old core*/
#if PMON_DEBUG
	/* stop pmon */
	mfc0	k0, $16, 7
	ori	k0, k0, 0x100
	xori	k0, k0, 0x100
	mtc0	k0, $16, 7

	la	k1, _regs_stack
	mfc0	k0, $17, 6
	sw	k0, 50*4(k1)
#endif

#if 1
	/* before wait , we need flush cache */
	li	t0, 0x80000000
	addu	t1, t0, 0x7fe0
3:
	cache	0x1, 0(t0)	// Index_Writeback_Inv_D
	bne	t0, t1, 3b
	addiu	t0, t0, 32
	sync
#endif
#ifdef SW_DEBUG
	jal flush_cache_all_1
	nop

	la  a0,0x12345678
	jal show_message
	nop
#endif
#if 1
/* wait for ready flag */
	la	k0, _wait_flag
	li	k1, 0x20000000
	add	k0, k0, k1
wait_wait_ready:
	lw	k1, 0(k0)
	nop
	beq	k1, zero ,wait_wait_ready
	nop
	sw  zero, 0(k0)
#endif
#ifdef SW_DEBUG
	la  a0,0x12345677
	jal show_message
	nop
#endif
#if READY_FLAG
/* after flush cache ,we set ready flag */
	la	k0, _ready_flag
	li	k1, 0x20000000
	add	k0, k0, k1
#ifdef SW_DEBUG
	lw     a0, 0(k0)
	jal show_message
	nop
#endif
	li	k1, 1
	sw	k1, 0(k0)
#endif
loopwait:
	wait			// cpu0/1 wait is closed
	b loopwait
	nop
	/* ------------------cpu switch end --------------------------*/

	.set	reorder
	.set	at
	.set	pop
	END(switch_cpu)

#define SR_CU1		0x20000000	/* Mark CP1 as usable */
#define SR_CU0		0x10000000	/* Mark CP0 as usable */

	.global	_start_secondary
	.type	_start_secondary, @function
	.align	2
	.extern restore_goto
	.ent	_start_secondary, 0
	.section .start_secondary,"ax",@progbits
_start_secondary:
	.set	push
	.set	noat
	.set	noreorder
#ifdef SW_DEBUG
	la t0,0x10000
aaaaa:
	addiu  t0,-1
	bne    t0,zero,aaaaa
	nop
#endif

	/* tell old cpu i'm up uncache write*/
	la	t0, _wait_flag
	li	t1, 0x20000000
	add	t0, t0, t1
	li	t1, 1
	sw	t1, 0(t0)

	/* Init cache */
	mtc0	zero, $28, 0	//  CP0_TAGLO
	mtc0	zero, $28, 1	// CP0_DATALO

	/* first ,cache only three line */
	la	t0, Init_cache
	addu	t1, t0, 0x60
1:
	cache	0x8, 0(t0)
	cache   0x8, 4096(t0)
	cache   0x8, 8192(t0)
	cache   0x8, 12288(t0)
	cache   0x8, 16384(t0)
	cache   0x8, 20480(t0)
	cache   0x8, 24576(t0)
	cache   0x8, 28672(t0)

	bne	t0, t1, 1b
	addiu	t0, t0, 32

	/* set cache */
	mfc0	v0, CP0_CONFIG
	ori	v0, v0, 3
	mtc0	v0, CP0_CONFIG
Init_cache:
	lui	t0, 0x8000	// KSEG0
	addu	t1, t0, 0x7fe0
1:
	/* cache_clear_a_line */
	cache	0x8, 0(t0)	// Index_Store_Tag_I
//	cache	0x9, 0(t0)	// Index_Store_Tag_D //if the core is wakeup from keep reset ,we don't need flush Dcache
	bne	t0, t1, 1b
	addiu	t0, t0, 32

	/* flush tlb */
	li	t0, 32
	move	t1, zero
	mtc0	zero, $5,0	//PageMask
	mtc0	zero, $2, 0	//Lo0
	mtc0	zero, $3, 0	//Lo1
4:
	mtc0	t1, $0,0	//Index
	sll	t3, t1, 13
	mtc0	t3, $10,0	//H

	nop
	nop
	nop
	nop
	tlbwi
	slt	t4, t1, t0
	addiu	t1, t1, 1
	bne	t4, zero, 4b
	nop
	sync
	nop

	/* call clk_disable functions close cpu power*/
	mfc0	v0, CP0_EBASE
	andi	v0, v0,0x3ff   //v0 is the cpu No.

	mfc0	v1, CORE_CTRL

//	la	t7, 0xb0000004
//	lw	t6, 0(t7)

	beqz	v0, 1f
	nop

	ori	v1, 0x1		// keep reset cpu0
//	lui	t5, 0x8000	// power down cpu0
//	or	t6, t6, t5
	b	2f
	nop
1:

	ori	v1, 0x2		//keep reset cpu1
//	lui	t5, 0x4000	// power down cpu1
//	or	t6, t6, t5

2:
	nop

/* wait for ready flag */
	la	k0, _ready_flag
	li	k1, 0x20000000
	add	k0, k0, k1
wait_ready:
	lw	k1, 0(k0)
	beq	k1, zero ,wait_ready
	nop
	sw	zero, 0(k0)

#if PMON_DEBUG
	/* clear pmon */
	mtc0	$0, $17, 4
	mtc0	$0, $17, 5
	mtc0	$0, $17, 6

	/* setup pmon */
	mfc0	t3, $16, 7
	li	t4, 0xffff0000
	and	t3, t3, t4
	ori	t3, t3, 0x500
	mtc0	t3, $16, 7
#endif
	mtc0	v1, CORE_CTRL
//	sw	t6, 0(t7)
#ifdef SW_DEBUG
	la  a0,0x12345676
	jal show_message
	nop
#endif
	la	k0,restore_goto
	jr	k0
	nop

	.set	reorder
	.set	at
	.set	pop
	END(_start_secondary)
