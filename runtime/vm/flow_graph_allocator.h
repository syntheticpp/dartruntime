// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#ifndef VM_FLOW_GRAPH_ALLOCATOR_H_
#define VM_FLOW_GRAPH_ALLOCATOR_H_

#include "vm/growable_array.h"
#include "vm/intermediate_language.h"

namespace dart {

class AllocationFinger;
class FlowGraphBuilder;
class LiveRange;
class UseInterval;
class UsePosition;

class FlowGraphAllocator : public ValueObject {
 public:
  FlowGraphAllocator(const GrowableArray<BlockEntryInstr*>& block_order,
                     FlowGraphBuilder* builder);

  void AllocateRegisters();

  // Build live-in and live-out sets for each block.
  void AnalyzeLiveness();

 private:
  // Compute initial values for live-out, kill and live-in sets.
  void ComputeInitialSets();

  // Update live-out set for the given block: live-out should contain
  // all values that are live-in for block's successors.
  // Returns true if live-out set was changed.
  bool UpdateLiveOut(const BlockEntryInstr& instr);

  // Update live-in set for the given block: live-in should contain
  // all values that are live-out from the block and are not defined
  // by this block.
  // Returns true if live-in set was changed.
  bool UpdateLiveIn(const BlockEntryInstr& instr);

  // Perform fix-point iteration updating live-out and live-in sets
  // for blocks until they stop changing.
  void ComputeLiveInAndLiveOutSets();

  // Print results of liveness analysis.
  void DumpLiveness();

  // Visit blocks in the code generation order (reverse post order) and
  // linearly assign consequent lifetime positions to every instruction.
  // We assign position as follows:
  //
  //    2 * n     - even position corresponding to instruction's start;
  //
  //    2 * n + 1 - odd position corresponding to instruction's end;
  //
  // Having two positions per instruction allows us to capture non-trivial
  // shapes of use intervals: e.g. by placing a use at the start or the
  // end position we can distinguish between instructions that need value
  // at the register only at their start and those instructions that
  // need value in the register until the end of instruction's body.
  // Register allocator can perform splitting of live ranges at any position.
  // An implicit ParallelMove will be inserted by ConnectSplitSiblings where
  // required to resolve data flow between split siblings when allocation
  // is finished.
  // For specific examples see comments inside ProcessOneInstruction.
  // Additionally creates parallel moves at the joins' predecessors
  // that will be used for phi resolution.
  void NumberInstructions();
  Instruction* InstructionAt(intptr_t pos) const;
  bool IsBlockEntry(intptr_t pos) const;

  LiveRange* GetLiveRange(intptr_t vreg);

  // Visit instructions in the postorder and build live ranges for
  // all SSA values.
  void BuildLiveRanges();
  Instruction* ConnectOutgoingPhiMoves(BlockEntryInstr* block);
  void ProcessOneInstruction(BlockEntryInstr* block, Instruction* instr);
  void ConnectIncomingPhiMoves(BlockEntryInstr* block);
  void BlockLocation(Location loc, intptr_t pos);

  // Process live ranges sorted by their start and assign registers
  // to them
  void AllocateCPURegisters();
  void AdvanceActiveIntervals(const intptr_t start);

  // Connect split siblings over non-linear control flow edges.
  void ResolveControlFlow();
  void ConnectSplitSiblings(LiveRange* range,
                            BlockEntryInstr* source_block,
                            BlockEntryInstr* target_block);


  // Update location slot corresponding to the use with location allocated for
  // the use's live range.
  void ConvertUseTo(UsePosition* use, Location loc);
  void ConvertAllUses(LiveRange* range);

  // Add live range to the list of unallocated live ranges to be processed
  // by the allocator.
  void AddToUnallocated(LiveRange* range);
#ifdef DEBUG
  bool UnallocatedIsSorted();
#endif

  // Try to find a free register for an unallocated live range.
  bool AllocateFreeRegister(LiveRange* unallocated);

  // Try to find a register that can be used by a given live range.
  // If all registers are occupied consider evicting interference for
  // a register that is going to be used as far from the start of
  // the unallocated live range as possible.
  void AllocateAnyRegister(LiveRange* unallocated);

  // Assign selected non-free register to an unallocated live range and
  // evict any interference that can be evicted by splitting and spilling
  // parts of interfering live ranges.  Place non-spilled parts into
  // the list of unallocated ranges.
  void AssignNonFreeRegister(LiveRange* unallocated, Register reg);
  bool EvictIntersection(LiveRange* allocated, LiveRange* unallocated);
  void RemoveEvicted(Register reg, intptr_t first_evicted);

  // Find first intersection between unallocated live range and
  // live ranges currently allocated to the given register.
  intptr_t FirstIntersectionWithAllocated(Register reg,
                                          LiveRange* unallocated);

  bool UpdateFreeUntil(Register reg,
                       LiveRange* unallocated,
                       intptr_t* cur_free_until,
                       intptr_t* cur_blocked_at);

  // Split given live range in an optimal position between given positions.
  LiveRange* SplitBetween(LiveRange* range, intptr_t from, intptr_t to);

  // Find a spill slot that can be used by the given live range.
  intptr_t AllocateSpillSlotFor(LiveRange* range);

  // Allocate the given live range to a spill slot.
  void Spill(LiveRange* range);

  // Spill the given live range from the given position onwards.
  void SpillAfter(LiveRange* range, intptr_t from);

  // Spill the given live range from the given position until some
  // position preceeding the to position.
  void SpillBetween(LiveRange* range, intptr_t from, intptr_t to);

  MoveOperands* AddMoveAt(intptr_t pos, Location to, Location from);

  void PrintLiveRanges();

  // TODO(vegorov): this field is used only to call Bailout. Remove when
  // all bailouts are gone.
  FlowGraphBuilder* builder_;

  const GrowableArray<BlockEntryInstr*>& block_order_;
  const GrowableArray<BlockEntryInstr*>& postorder_;

  GrowableArray<Instruction*> instructions_;

  // Live-out sets for each block.  They contain indices of SSA values
  // that are live out from this block: that is values that were either
  // defined in this block or live into it and that are used in some
  // successor block.
  GrowableArray<BitVector*> live_out_;

  // Kill sets for each block.  They contain indices of SSA values that
  // are defined by this block.
  GrowableArray<BitVector*> kill_;

  // Live-in sets for each block.  They contain indices of SSA values
  // that are used by this block or its successors.
  GrowableArray<BitVector*> live_in_;

  // Number of virtual registers.  Currently equal to the number of
  // SSA values.
  const intptr_t vreg_count_;

  // LiveRanges corresponding to SSA values.
  GrowableArray<LiveRange*> live_ranges_;

  // Worklist for register allocator. Always maintained sorted according
  // to ShouldBeAllocatedBefore predicate.
  GrowableArray<LiveRange*> unallocated_;

  // Per register lists of allocated live ranges.  Contain only those
  // ranges that can be affected by future allocation decisions.
  // Those live ranges that end before the start of the current live range are
  // removed from the list and will not be affected.
  GrowableArray<LiveRange*> cpu_regs_[kNumberOfCpuRegisters];

  // List of used spill slots. Contain positions after which spill slots
  // become free and can be reused for allocation.
  GrowableArray<intptr_t> spill_slots_;

  bool blocked_cpu_regs_[kNumberOfCpuRegisters];

  DISALLOW_COPY_AND_ASSIGN(FlowGraphAllocator);
};


// UsePosition represents a single use of an SSA value by some instruction.
// It points to a location slot which either tells register allocator
// where instruction expects the value (if slot contains a fixed location) or
// asks register allocator to allocate storage (register or spill slot) for
// this use with certain properties (if slot contains an unallocated location).
class UsePosition : public ZoneAllocated {
 public:
  UsePosition(intptr_t pos, UsePosition* next, Location* location_slot)
      : pos_(pos), location_slot_(location_slot), next_(next) { }

  Location* location_slot() const { return location_slot_; }
  void set_location_slot(Location* location_slot) {
    location_slot_ = location_slot;
  }

  void set_next(UsePosition* next) { next_ = next; }
  UsePosition* next() const { return next_; }

  intptr_t pos() const { return pos_; }

  bool HasHint() const {
    return (location_slot() != NULL) && (location_slot()->IsRegister());
  }

  Location hint() const {
    ASSERT(HasHint());
    return *location_slot();
  }

 private:
  const intptr_t pos_;
  Location* location_slot_;
  UsePosition* next_;

  DISALLOW_COPY_AND_ASSIGN(UsePosition);
};


// UseInterval represents a holeless half open interval of liveness for a given
// SSA value: [start, end) in terms of lifetime positions that
// NumberInstructions assigns to instructions.  Register allocator has to keep
// a value live in the register or in a spill slot from start position and until
// the end position.  The interval can cover zero or more uses.
// Note: currently all uses of the same SSA value are linked together into a
// single list (and not split between UseIntervals).
class UseInterval : public ZoneAllocated {
 public:
  UseInterval(intptr_t start, intptr_t end, UseInterval* next)
      : start_(start),
        end_(end),
        next_(next) { }

  void Print();

  intptr_t start() const { return start_; }
  intptr_t end() const { return end_; }
  UseInterval* next() const { return next_; }

  bool Contains(intptr_t pos) const {
    return (start() <= pos) && (pos < end());
  }

  // Return the smallest position that is covered by both UseIntervals or
  // kIllegalPosition if intervals do not intersect.
  intptr_t Intersect(UseInterval* other);

 private:
  friend class LiveRange;

  intptr_t start_;
  intptr_t end_;
  UseInterval* next_;

  DISALLOW_COPY_AND_ASSIGN(UseInterval);
};


// AllocationFinger is used to keep track of currently active position
// for the register allocator and cache lookup results.
class AllocationFinger : public ValueObject {
 public:
  AllocationFinger()
      : first_pending_use_interval_(NULL),
        first_register_use_(NULL),
        first_register_beneficial_use_(NULL),
        first_hinted_use_(NULL) {
  }

  void Initialize(LiveRange* range);
  bool Advance(intptr_t start);

  UseInterval* first_pending_use_interval() const {
    return first_pending_use_interval_;
  }

  Location FirstHint();
  UsePosition* FirstRegisterUse(intptr_t after_pos);
  UsePosition* FirstRegisterBeneficialUse(intptr_t after_pos);

 private:
  UseInterval* first_pending_use_interval_;
  UsePosition* first_register_use_;
  UsePosition* first_register_beneficial_use_;
  UsePosition* first_hinted_use_;

  DISALLOW_COPY_AND_ASSIGN(AllocationFinger);
};


// LiveRange represents a sequence of UseIntervals for a given SSA value.
class LiveRange : public ZoneAllocated {
 public:
  explicit LiveRange(intptr_t vreg)
    : vreg_(vreg),
      assigned_location_(),
      uses_(NULL),
      first_use_interval_(NULL),
      last_use_interval_(NULL),
      next_sibling_(NULL),
      finger_() {
  }

  static LiveRange* MakeTemp(intptr_t pos, Location* location_slot);

  intptr_t vreg() const { return vreg_; }
  LiveRange* next_sibling() const { return next_sibling_; }
  UsePosition* first_use() const { return uses_; }
  void set_first_use(UsePosition* use) { uses_ = use; }
  UseInterval* first_use_interval() const { return first_use_interval_; }
  UseInterval* last_use_interval() const { return last_use_interval_; }
  Location assigned_location() const { return assigned_location_; }
  intptr_t Start() const { return first_use_interval()->start(); }
  intptr_t End() const { return last_use_interval()->end(); }

  AllocationFinger* finger() { return &finger_; }

  void set_assigned_location(Location location) {
    assigned_location_ = location;
  }

  void DefineAt(intptr_t pos);

  void AddUse(intptr_t pos, Location* location_slot);
  void AddUseInterval(intptr_t start, intptr_t end);

  void Print();

  void AssignLocation(UseInterval* use, Location loc);

  LiveRange* SplitAt(intptr_t pos);

  bool CanCover(intptr_t pos) const {
    return (Start() <= pos) && (pos < End());
  }

 private:
  LiveRange(intptr_t vreg,
            UsePosition* uses,
            UseInterval* first_use_interval,
            UseInterval* last_use_interval,
            LiveRange* next_sibling)
    : vreg_(vreg),
      assigned_location_(),
      uses_(uses),
      first_use_interval_(first_use_interval),
      last_use_interval_(last_use_interval),
      next_sibling_(next_sibling),
      finger_() {
  }

  const intptr_t vreg_;
  Location assigned_location_;

  UsePosition* uses_;
  UseInterval* first_use_interval_;
  UseInterval* last_use_interval_;

  LiveRange* next_sibling_;

  AllocationFinger finger_;

  DISALLOW_COPY_AND_ASSIGN(LiveRange);
};


}  // namespace dart

#endif  // VM_FLOW_GRAPH_ALLOCATOR_H_
