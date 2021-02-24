# RUN: julia -e "import Brutus; Brutus.lit(:emit_optimized)" --startup-file=no %s 2>&1 | FileCheck %s

function labels(N)
    @label start
    N += 1
    if N < 0
        @goto start
    end
    return N
end
###
# 1 ─      nothing::Nothing
# 3 2 ┄ %2 = φ (#1 => _2, #3 => %3)::Int64
#   │   %3 = Base.add_int(%2, 1)::Int64
# 4 │   %4 = Base.jlir.slt_int(%3, 0)::Bool
#   └──      goto #4 if not %4
# 5 3 ─      goto #2
# 7 4 ─      return %3
###
emit(labels, Int64)



# CHECK:   func @"Tuple{typeof(Main.labels), Int64}"(%arg0: !jlir<"typeof(Main.labels)">, %arg1: !jlir.Int64) -> !jlir.Int64 attributes {llvm.emit_c_interface} {
# CHECK-NEXT:     "jlir.goto"()[^bb1] : () -> ()
# CHECK-NEXT:   ^bb1:  // pred: ^bb0
# CHECK-NEXT:     "jlir.goto"(%arg1)[^bb2] : (!jlir.Int64) -> ()
# CHECK-NEXT:   ^bb2(%0: !jlir.Int64):  // 2 preds: ^bb1, ^bb3
# CHECK-NEXT:     %1 = "jlir.constant"() {value = #jlir<"1">} : () -> !jlir.Int64
# CHECK-NEXT:     %2 = "jlir.add_int"(%0, %1) : (!jlir.Int64, !jlir.Int64) -> !jlir.Int64
# CHECK-NEXT:     %3 = "jlir.constant"() {value = #jlir<"0">} : () -> !jlir.Int64
# CHECK-NEXT:     %4 = "jlir.slt_int"(%2, %3) : (!jlir.Int64, !jlir.Int64) -> !jlir.Bool
# CHECK-NEXT:     "jlir.gotoifnot"(%4)[^bb4, ^bb3] {operand_segment_sizes = dense<[1, 0, 0]> : vector<3xi32>} : (!jlir.Bool) -> ()
# CHECK-NEXT:   ^bb3:  // pred: ^bb2
# CHECK-NEXT:     "jlir.goto"(%2)[^bb2] : (!jlir.Int64) -> ()
# CHECK-NEXT:   ^bb4:  // pred: ^bb2
# CHECK-NEXT:     "jlir.return"(%2) : (!jlir.Int64) -> ()
# CHECK-NEXT:   }
# CHECK-NEXT: }

# CHECK: error: lowering to LLVM dialect failed
