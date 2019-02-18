open HolKernel boolLib liteLib simpLib Parse bossLib;

open bir_programTheory;
open bir_programSyntax;
open bir_valuesTheory;

open HolBACoreSimps;

open bir_exec_auxLib;
open bir_exec_envLib;
open bir_exec_expLib;

open optionSyntax;
open pairSyntax;
open numSyntax;

open listTheory;
open listSyntax;
open wordsLib;

open Redblackmap;

open bir_program_valid_stateTheory;


structure bir_exec_blockLib =
struct


(*
  val t = ``bir_exec_step ^prog_const ^state``;

  bir_exec_prog_step_conv var_eq_thm t
*)


  fun syntax_fns n d m = HolKernel.syntax_fns {n = n, dest = d, make = m} "bir_program"
  val syntax_fns1 = syntax_fns 1 HolKernel.dest_monop HolKernel.mk_monop;
  val syntax_fns2 = syntax_fns 2 HolKernel.dest_binop HolKernel.mk_binop;
  val syntax_fns3 = syntax_fns 3 HolKernel.dest_triop HolKernel.mk_triop;

  val (bir_get_program_block_info_by_label_tm,  mk_bir_get_program_block_info_by_label, dest_bir_get_program_block_info_by_label, is_bir_get_program_block_info_by_label)  = syntax_fns2 "bir_get_program_block_info_by_label";
  val (bir_exec_stmt_jmp_to_label_tm,  mk_bir_exec_stmt_jmp_to_label, dest_bir_exec_stmt_jmp_to_label, is_bir_exec_stmt_jmp_to_label)  = syntax_fns3 "bir_exec_stmt_jmp_to_label";
  val (bir_labels_of_program_tm,  mk_bir_labels_of_program, dest_bir_labels_of_program, is_bir_labels_of_program)  = syntax_fns1 "bir_labels_of_program";


  fun gen_block_thm_map prog_l_def labels_eq_thms =
    let
      val prog_l = (snd o dest_eq o concl) prog_l_def;
      val prog_l_const = (fst o dest_eq o concl) prog_l_def;
      val prog_const = (mk_BirProgram prog_l_const);

      val rep_gen_set_and_eval_conv =
                   (REWRITE_CONV [bir_labels_of_program_def]) THENC
                   (REPEATC ((SIMP_CONV list_ss []) THENC
                             ((fn t => if op=((dest_eq o concl) t) then raise UNCHANGED else t) o EVAL)
                            ));
      val label_set_thm = (REWRITE_CONV [prog_l_def] THENC (rep_gen_set_and_eval_conv)) ``bir_labels_of_program ^prog_const``;
      val valid_prog_thm =
        (
          (REWRITE_CONV [bir_is_valid_labels_def, label_set_thm]) THENC
          (SIMP_CONV list_ss (ALL_DISTINCT::labels_eq_thms))
        )
        ``bir_is_valid_labels ^prog_const``;
      val _ = if ((fn x => x <> T) o snd o dest_eq o concl) valid_prog_thm
              then raise ERR "gen_block_thm_map" "the input program is not valid" else ();

      (*
      val lt = List.nth(label_ts,10);
      *)
(*
      val index_find_step_conv =
        (fn x => REWRITE_CONV [Once INDEX_FIND_def] x) THENC
        (* take care of the condition alone *)
        (RATOR_CONV (RATOR_CONV (RAND_CONV (SIMP_CONV (std_ss++bir_TYPES_ss) (labels_eq_thms))))) THENC
        (* resolve the if-then-else *)
        (REWRITE_CONV []) THENC
        (* compute SUC *)
        (TRY_CONV (RATOR_CONV (RATOR_CONV (RAND_CONV (SIMP_CONV (arith_ss) [])))))
        ;

(*
dest_comb ``if a then b else c``
val test = (REPEATC (index_find_step_conv) term;

(REPEATC index_find_step_conv)
((snd o dest_eq o concl)((REWRITE_CONV [bir_get_program_block_info_by_label_def, prog_def]) (mk_bir_get_program_block_info_by_label (prog_const, lt))))

*)
bir_program_valid_stateTheory.bir_is_valid_program_def
bir_program_valid_stateTheory.bir_is_valid_labels_def
bir_program_valid_stateTheory.bir_get_program_block_info_by_label_valid_THM 


SIMP_CONV list_ss [] ``EL 23 ^(dest_BirProgram prog)``

      val block_by_label_conv =
        (REWRITE_CONV [bir_get_program_block_info_by_label_def, prog_def]) THENC
        (REPEATC index_find_step_conv);

      val block_l_thm_list =
           List.map (fn lt => (
                      (if ((!debug_trace) > 0) then (print "!") else ());
                      (lt, LIST_CONJ
                        [block_by_label_conv (mk_bir_get_program_block_info_by_label (prog_const, lt))
                         ,
                         labels_mem_conv (mk_mem (lt, mk_bir_labels_of_program prog_const))
                        ]
                    ))) labels;
*)


      val labels_mem_conv = SIMP_CONV (list_ss++WORD_ss++bir_TYPES_ss)
        [bir_program_labelsTheory.bir_labels_of_program_REWRS, prog_l_def];

      val prep_thm0 = (CONJUNCT2 bir_get_program_block_info_by_label_valid_THM);
      val prep_thm1 = MATCH_MP prep_thm0 (REWRITE_RULE [] valid_prog_thm);
      val prep_thm  = REWRITE_RULE [SIMP_CONV list_ss [prog_l_def] ``LENGTH ^prog_l_const``] prep_thm1;

      val (_,augm_block_lst) = List.foldl (fn (bl,(i,l)) => (i+1,(i,bl)::l)) (0,[]) ((fst o dest_list) prog_l);

(*
val i = 1;
val bl = snd(List.nth(augm_block_lst,i));
*)

      val block_l_thm_list =
           List.map (fn (i,bl) => (
             (if ((!debug_trace) > 0) then (print "!") else ());
             let
               val i_n = mk_numeral (Arbnum.fromInt i);
               val (lt,_,_)  = dest_bir_block bl;

               val thm1 = SPECL [lt, i_n, bl] prep_thm;

               val thm2 = CONV_RULE (RAND_CONV (EVAL)) thm1;
               val thm3 = (REWRITE_RULE [] thm2);

               val _ = if ((fn t => t <> T) o snd o dest_eq o concl) thm2
                       then (print_term ((concl) thm2);raise ERR "block_l_thm_list" "something went wrong")
                       else ();
(*
               val el_thm = EVAL ``EL ^i_n ^prog_l_const``;
               val thm2 = CONV_RULE (RAND_CONV (SIMP_CONV (arith_ss++bir_TYPES_ss) [el_thm])) thm1;
*)
             in
               (lt,
                CONJ
                  thm3
                  (EVAL (mk_mem (lt, mk_bir_labels_of_program prog_const)))
               )
             end
           )) augm_block_lst;
    in
      insertList (mkDict Term.compare, block_l_thm_list)
    end;




(*
for now, we're taking single steps, not whole blocks
*)
  fun bir_exec_prog_step_conv block_thm_map var_eq_thm =
    let
      val is_tm_fun = is_bir_exec_step;
      val check_tm_fun = (fn t => is_pair t andalso
                                  let
                                    val (ov, st) = dest_pair t;
                                  in
                                    (is_none ov orelse is_some ov) andalso
                                    (is_bir_state st)
                                  end);
      fun conv t =
        let
          (* prepare search for block *)
          val thm1 = (
                    (SIMP_CONV (std_ss++bir_TYPES_ss) [
                         bir_exec_step_def,
                         bir_get_current_statement_def,
                         bir_state_is_terminated_def,
                         bir_state_set_failed_def])
                   ) t;

          (* lookup the corresponding block thm *)
          val (_,l) = (dest_bir_get_program_block_info_by_label o
                       (GEN_find_subterm is_bir_get_program_block_info_by_label) o
                       snd o dest_eq o concl
                      ) thm1;
          val cur_lbl = (snd o dest_eq o concl o EVAL) l;
          val block_thm = Redblackmap.find(block_thm_map,cur_lbl);

          (* get block and current statement *)
          val thm1_1 = CONV_RULE (RAND_CONV (
                    (SIMP_CONV (list_ss++bir_TYPES_ss) [block_thm])
                   )) thm1;

          (* open statement effects *)
          val thm1_2 = CONV_RULE (RAND_CONV (
                    (REWRITE_CONV [
                         bir_exec_stmt_declare_def,
                         bir_exec_stmt_assign_def,
                         bir_exec_stmt_assert_def,
                         bir_exec_stmt_assume_def,
                         bir_exec_stmt_observe_def,
                         bir_exec_stmt_halt_def,
                         bir_exec_stmt_jmp_def,
                         bir_exec_stmt_cjmp_def,
                         bir_exec_stmtB_def,
                         bir_exec_stmtE_def,
                         bir_exec_stmt_def
                       ])
                   )) thm1_1;

          (* evaluate expressions (bir_eval_exp and bir_eval_label_exp) *)
          val thm1_3 = CONV_RULE (RAND_CONV (
                    (* evaluate the expressions *)
                    (bir_exec_exp_conv var_eq_thm) THENC
                    (* open the evaluation of label expressions *)
                    (* (additionally for cjmp: determine which branch to take) *)
                    (SIMP_CONV (std_ss++WORD_ss) [
                         bir_dest_bool_val_def,
                         bir_eval_label_exp_def]) THENC
                    (* evaluate the new label expressions *)
                    (bir_exec_exp_conv var_eq_thm) THENC
                    (* resolve cases *)
                    CASE_SIMP_CONV THENC
                    (* finally update the environment *)
                    (bir_exec_env_write_conv var_eq_thm)
                   )) thm1_2;

          (* control flow *)
          val thm_pre_pc_upd = thm1_3;
          val thm4 =
            (* try jmp_to_label *)
            let
              (* lookup the block thm for the jump target *)
              val (_,l,_) = (dest_bir_exec_stmt_jmp_to_label o
                             (GEN_find_subterm is_bir_exec_stmt_jmp_to_label) o
                             snd o dest_eq o concl
                            ) thm_pre_pc_upd;
              val cur_lbl = (snd o dest_eq o concl o EVAL) l;
              val block_thm_to = Redblackmap.find(block_thm_map,cur_lbl);

              (* compute program counter for the next block *)
              val thm2 = CONV_RULE (RAND_CONV (REWRITE_CONV [
                                block_thm_to,
                                bir_exec_stmt_jmp_to_label_def,
                                bir_block_pc_def])) thm_pre_pc_upd;

              (* cleanup bir_state_t record (for updated pc) *)
              val thm3 = CONV_RULE (RAND_CONV (SIMP_CONV (std_ss++bir_TYPES_ss) [])) thm2;
            in
              thm3
            end
            handle UNCHANGED =>
            (* if jmp_to_label is not present *)
            (* pc_next update and finalize *)
            CONV_RULE (RAND_CONV (SIMP_CONV (list_ss++bir_TYPES_ss)
               [LET_DEF, bir_pc_next_def, bir_state_is_terminated_def]
             )) thm_pre_pc_upd
            ;
        in
          thm4
        end;
    in
      GEN_selective_conv is_tm_fun check_tm_fun conv
    end;



end
