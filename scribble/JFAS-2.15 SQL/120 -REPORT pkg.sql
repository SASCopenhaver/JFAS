create or replace PACKAGE      report
AS
   TYPE np_action_type IS VARRAY (3) OF VARCHAR2 (50);

   TYPE np_action_obj_type IS RECORD (
      action_desc         VARCHAR2 (50),
      effective_date      VARCHAR2 (10),
      from_date           VARCHAR2 (10),
      through_date        VARCHAR2 (10),
      completion_date     VARCHAR2 (10),
      final_date      VARCHAR2 (10),
      mod_purpose         VARCHAR2 (200),
      mod_issue_date      VARCHAR2 (10),
      case_num            NUMBER,
      next_option_year    NUMBER,
      action_date         DATE,
      next_action_date    DATE,
      est_cost_date       DATE
   );

   TYPE vst_rec IS RECORD (
      region_desc            VARCHAR2 (25),
      aapp_num               NUMBER,
      contractor_name        VARCHAR2 (50),
      report_date            DATE,
      contract_num           VARCHAR2 (50),
      center_name            VARCHAR2 (80),
      cnt_date_start         DATE,
      cnt_date_end           DATE,
      vst_slots              NUMBER,
      vst_cum_fund           NUMBER,
      fop_pre_py             NUMBER,
      vst_obligation_date    DATE,
      unused_vst_fund        NUMBER,
      vst_obligation         NUMBER,
      vst_minium             NUMBER,
      vst_supple             NUMBER,
      vst_unspent_fund       NUMBER,
      days_remaining         NUMBER,
      vst_remaining_credit   NUMBER,
      vst_total_credit       NUMBER,
      vst_excess_fund        NUMBER,
      vst_base_allocation    NUMBER,
      vst_net_allocation     NUMBER,
      prg_date_start         DATE,
      vst_prorated          NUMBER,
      form_version          NUMBER
   );

   np_action   np_action_type
      := np_action_type ('New Contract Award',
                         'Option Year Extension',
                         'No Further Actions'
                        );

   FUNCTION fun_get_fiscal_plan_npa (p_aapp_num IN NUMBER)
      RETURN np_action_obj_type;

   FUNCTION fun_get_fiscal_plan_efa (
      p_aapp_num        IN   NUMBER,
      p_cost_cat_code   IN   VARCHAR2,
      p_program_year    IN   NUMBER,
      p_column          IN   CHAR
   )
      RETURN NUMBER;

   FUNCTION fun_get_depletion_date (p_date IN DATE)
      RETURN DATE;

   FUNCTION fun_get_next_depletion_date (p_date IN DATE)
      RETURN DATE;

   FUNCTION fun_get_next_date_in_effect
      RETURN DATE;

   PROCEDURE prc_get_fiscal_plan_rpt (
      p_aapp_num              NUMBER,
      p_recordset       OUT   sys_refcursor,
      p_recordset_est   OUT   sys_refcursor,
      p_recordset_fit   OUT   sys_refcursor,
      p_recordset_c     OUT   sys_refcursor
   );

   PROCEDURE prc_get_est_cost_rpt (
      p_aapp_num          NUMBER,
      p_recordset   OUT   sys_refcursor
   );

   PROCEDURE prc_get_fop_vst_rpt (
      p_aapp_num             NUMBER,
      p_program_year         NUMBER,
      p_recordset      OUT   sys_refcursor
   );

   PROCEDURE prc_get_fop_ccc_rpt (
      p_aapp_num                 NUMBER,
      p_program_year             NUMBER,
      p_recordset_data     OUT   sys_refcursor,
      p_recordset_status   OUT   sys_refcursor
   );

   PROCEDURE prc_get_future_new_rpt (
      p_aapp_num          NUMBER,
      p_recordset   OUT   sys_refcursor
   );

   PROCEDURE prc_get_funew_workload_rpt (
      p_aapp_num          NUMBER,
      p_recordset   OUT   sys_refcursor
   );

   PROCEDURE prc_get_bar_fundingoff_rpt (
      p_fundingofficeno   IN       NUMBER,
      p_recordset         OUT      sys_refcursor
   );

   /*PROCEDURE prc_get_fprint_contr_ti_rpt (
      p_aapp                  IN       NUMBER,
      p_fundingofficeno       IN       NUMBER,
      p_agreement_type_code   IN       CHAR,
      p_start_date            IN       VARCHAR2,
      p_end_date              IN       VARCHAR2,
      p_recordset             OUT      sys_refcursor
   );

   PROCEDURE prc_get_fprint_contr_da_rpt (
      p_aapp   IN       varchar2,
      p_recordset   OUT      sys_refcursor
   );
   */
   PROCEDURE prc_get_ccc_ba_tra_rpt (
      p_fund_office_no   IN       NUMBER,
      p_recordset_ops    OUT      sys_refcursor,
      p_recordset_cra    OUT      sys_refcursor
   );

   -- get aapps, centers for program operating plan detail
   PROCEDURE prc_get_progop_detail_list_rpt (
      p_in                  IN       NUMBER,
      p_recordset_aapps     OUT      sys_refcursor,
      p_recordset_centers   OUT      sys_refcursor
   );

   -- get program operating plan detail data
   PROCEDURE prc_get_progop_detail_data_rpt (
      p_py                  IN       NUMBER,
      p_aapp                IN       NUMBER,
      p_center              IN       NUMBER,
      p_fundofficenum       IN       NUMBER,
      p_dol_region          IN       NUMBER,
      p_recordset_progrop   OUT      sys_refcursor
   );

   -- get FOP CCC Budget report data
   PROCEDURE prc_get_fop_ccc_bud_rpt (
      p_py                    IN       NUMBER,
      p_aapp                  IN       NUMBER,
      p_center                IN       NUMBER,
      p_fundofficenum         IN       NUMBER,
      p_dol_region            IN       NUMBER,
      p_recordset_fopcccbud   OUT      sys_refcursor
   );

   -- get Budget Authority requirements by AAPP report data
   PROCEDURE prc_get_bud_auth_aapp_rpt (
      p_status                   IN       VARCHAR,
      p_fundofficenum            IN       NUMBER,
      p_recordset_budauth_aapp   OUT      sys_refcursor
   );

   -- get Program Year Initial CCC Budget
   PROCEDURE prc_get_ccc_py_worksheet_rpt (
      p_fundingofficenum            IN       NUMBER,
      p_py                          IN       NUMBER,
      p_recordset_cccpy_worksheet   OUT      sys_refcursor,
      p_recordset_ccc_percent       OUT      sys_refcursor
   );

   -- OA/CTS Annualized Workload/Cost under current contacts
   PROCEDURE prc_get_oa_cts_annualized_rpt (
      p_fundingofficenum   IN       NUMBER,
      p_date_asof          IN       DATE,
      p_oa_cts_recordset   OUT      sys_refcursor
   );

   -- Budget Status Report
   PROCEDURE prc_get_budget_status_rpt (
      p_fundingofficenum          IN       NUMBER,
      p_budget_status_recordset   OUT      sys_refcursor
   );
   
   FUNCTION fun_np_action_obj_case_num (p_aapp_num IN NUMBER)
      RETURN NUMBER;
   
   FUNCTION fun_np_action_obj_com_date (p_aapp_num IN NUMBER)
      RETURN DATE;
   
   FUNCTION fun_np_action_obj_next_date (p_aapp_num IN NUMBER)
      RETURN DATE;
   
   FUNCTION fun_np_action_obj_action_date (p_aapp_num IN NUMBER)
      RETURN DATE;
   
   -- Footprint Transaction Discrepancy Report
  
   PROCEDURE prc_get_outyear_rpt (
      p_serv_type             IN      VARCHAR,
      p_fund_off              IN      NUMBER,
      p_outyear_recordset   OUT     sys_refcursor
   );
   
   PROCEDURE prc_get_workload_change_rpt (
      p_recordset    OUT      sys_refcursor
   );
   
END report;

/

create or replace PACKAGE BODY      report
AS
   FUNCTION fun_get_fiscal_plan_npa (p_aapp_num IN NUMBER)
      RETURN np_action_obj_type
   AS
      v_num                   NUMBER;
      v_effective_date        VARCHAR2 (10);
      v_through_date          VARCHAR2 (10);
      v_completion_date       VARCHAR2 (10);
      v_years_base            NUMBER             := 0;
      v_years_option          NUMBER             := 0;
      v_cur_contract_year     NUMBER;
      np_action_obj           np_action_obj_type;
      v_date                  DATE;
      v_next_option_year      NUMBER;
      v_depletion_date        DATE;
      v_next_depletion_date   DATE;
      v_next_date_in_effect   DATE;
      v_next_py               NUMBER := utility.fun_getcurrntprogram_year + 1;
      v_final_date            DATE;
   BEGIN
      SELECT years_base, years_option,
             contract.fun_getcurrntcontract_year (aapp_num),
             report.fun_get_depletion_date (trunc(to_date(sysdate), 'DDD')),
             report.fun_get_next_depletion_date (trunc(to_date(sysdate), 'DDD')),
             report.fun_get_next_date_in_effect,
             CASE
                WHEN contract.fun_getcurrntcontract_year (aapp_num) >=
                                                                    years_base
                   THEN LEAST (  contract.fun_getcurrntcontract_year (aapp_num)
                               + 1,
                               years_base + years_option
                              )
                ELSE years_option
             END CASE
        INTO v_years_base, v_years_option,
             v_cur_contract_year,
             v_depletion_date,
             v_next_depletion_date,
             v_next_date_in_effect,
             v_next_option_year
        FROM aapp
       WHERE aapp_num = p_aapp_num;

      v_final_date :=
         contract.fun_getaappdate (p_aapp_num,
                                   v_years_base + v_years_option,
                                   'E'
                                  );

      CASE
         WHEN v_cur_contract_year = 0
         THEN
            v_num := 1;
            v_effective_date :=
               TO_CHAR (contract.fun_getaappdate (p_aapp_num, 1, 'S'),
                        'mm/dd/yyyy'
                       );
            v_through_date :=
               TO_CHAR (contract.fun_getaappdate (p_aapp_num,
                                                  v_years_base,
                                                  'E'
                                                 ),
                        'mm/dd/yyyy'
                       );
         WHEN v_cur_contract_year <= v_years_base AND v_years_option > 0
         THEN
            v_num := 2;
            v_effective_date :=
               TO_CHAR (contract.fun_getaappdate (p_aapp_num,
                                                  v_years_base + 1,
                                                  'S'
                                                 ),
                        'mm/dd/yyyy'
                       );
            v_through_date :=
               TO_CHAR (contract.fun_getaappdate (p_aapp_num,
                                                  v_years_base + 1,
                                                  'E'
                                                 ),
                        'mm/dd/yyyy'
                       );
            v_completion_date :=
               TO_CHAR (contract.fun_getaappdate (p_aapp_num,
                                                  v_years_base,
                                                  'E'
                                                 ),
                        'mm/dd/yyyy'
                       );
         WHEN     v_cur_contract_year > v_years_base
              AND v_cur_contract_year < v_years_base + v_years_option
         THEN
            v_num := 2;
            v_effective_date :=
               TO_CHAR (contract.fun_getaappdate (p_aapp_num,
                                                  v_cur_contract_year + 1,
                                                  'S'
                                                 ),
                        'mm/dd/yyyy'
                       );
            v_through_date :=
               TO_CHAR (contract.fun_getaappdate (p_aapp_num,
                                                  v_cur_contract_year + 1,
                                                  'E'
                                                 ),
                        'mm/dd/yyyy'
                       );
            v_completion_date :=
               TO_CHAR (contract.fun_getaappdate (p_aapp_num,
                                                  v_cur_contract_year,
                                                  'E'
                                                 ),
                        'mm/dd/yyyy'
                       );
         WHEN v_cur_contract_year <= v_years_base AND v_years_option = 0
         THEN
            v_num := 3;
            v_through_date :=
               TO_CHAR (contract.fun_getaappdate (p_aapp_num,
                                                  v_years_base
                                                  + v_years_option,
                                                  'E'
                                                 ),
                        'mm/dd/yyyy'
                       );
            v_completion_date :=
               TO_CHAR (contract.fun_getaappdate (p_aapp_num,
                                                  v_years_base
                                                  + v_years_option,
                                                  'E'
                                                 ),
                        'mm/dd/yyyy'
                       );
         WHEN     v_cur_contract_year > v_years_base
              AND v_cur_contract_year = v_years_base + v_years_option
         THEN
            v_num := 3;
            v_through_date :=
               TO_CHAR (contract.fun_getaappdate (p_aapp_num,
                                                  v_years_base
                                                  + v_years_option,
                                                  'E'
                                                 ),
                        'mm/dd/yyyy'
                       );
            v_completion_date :=
               TO_CHAR (contract.fun_getaappdate (p_aapp_num,
                                                  v_years_base
                                                  + v_years_option,
                                                  'E'
                                                 ),
                        'mm/dd/yyyy'
                       );
         WHEN v_cur_contract_year = 999
         THEN
            v_num := 3;
            v_through_date :=
               TO_CHAR (contract.fun_getaappdate (p_aapp_num,
                                                  v_years_base
                                                  + v_years_option,
                                                  'E'
                                                 ),
                        'mm/dd/yyyy'
                       );
            v_completion_date :=
               TO_CHAR (contract.fun_getaappdate (p_aapp_num,
                                                  v_years_base
                                                  + v_years_option,
                                                  'E'
                                                 ),
                        'mm/dd/yyyy'
                       );
      END CASE;

      np_action_obj.action_desc := np_action (v_num);
      np_action_obj.effective_date := v_effective_date;
      np_action_obj.from_date :=
         TO_CHAR (contract.fun_getaappdate (p_aapp_num, 1, 'S'), 'mm/dd/yyyy');
      np_action_obj.through_date := v_through_date;
      np_action_obj.final_date := TO_CHAR (v_final_date, 'mm/dd/yyyy');
      np_action_obj.completion_date := v_completion_date;
      np_action_obj.action_date :=
           LEAST (v_depletion_date, TO_DATE (v_completion_date, 'mm/dd/yyyy'));
      /*
      SELECT a
        INTO
        FROM (SELECT a, RANK () OVER (ORDER BY a) AS RANK
                FROM (SELECT v_depletion_date AS a
                        FROM DUAL
                      UNION
                      SELECT TO_DATE (v_completion_date, 'mm/dd/yyyy')
                        FROM DUAL
                      UNION
                      SELECT v_next_depletion_date
                        FROM DUAL
                      UNION
                      SELECT contract.fun_getaappdate (p_aapp_num,
                                                       v_next_option_year,
                                                       'E'
                                                      )
                        FROM DUAL))
       WHERE RANK = 2;
       */
      np_action_obj.next_option_year := v_next_option_year;

      /*************************************************
      For Mod Purpose and Recommended Mod Issue Date
      *************************************************/
      CASE
         /*************************************************
         SCENARIO 1:  Final contract end date has already occurred OR final end date occurs on/before current depletion date. Example: REPORT DATE = 5/1/2008; FINAL CONTRACT END DATE = 3/31/2008.
         *************************************************/
      WHEN    v_num = 3 AND v_cur_contract_year = 999
           OR v_final_date <= v_depletion_date
         THEN
            np_action_obj.mod_purpose :=
                         'No further ECP/funding mod scheduled at this time.';
            np_action_obj.mod_issue_date := 'NA';
            np_action_obj.case_num := 1;
         /*************************************************
         SCENARIO 2: Final contract end date is after current depletion date: Example: REPORT DATE = 9/1/2007; FINAL CONTRACT END DATE = 12/31/2007.
         *************************************************/
      WHEN v_num = 3 AND v_final_date > v_depletion_date
         THEN
            SELECT LEAST (v_next_depletion_date, v_final_date)
              INTO v_date
              FROM DUAL;

            np_action_obj.mod_purpose :=
                  'Incremental funding only, for costs from '
               || TO_CHAR (v_depletion_date + 1, 'mm/dd/yyyy')
               || ' through '
               || TO_CHAR (v_date, 'mm/dd/yyyy')
               || '.';
            np_action_obj.mod_issue_date :=
                                 TO_CHAR (v_next_date_in_effect, 'mm/dd/yyyy');
            np_action_obj.case_num := 2;
            np_action_obj.est_cost_date :=
                                     TO_DATE (v_completion_date, 'mm/dd/yyyy');
            np_action_obj.next_action_date := v_date;
         /*************************************************
         SCENARIO 3:   Next option year starts before next date_in_effect.  Example: REPORT DATE = 2/1/2008; NEXT OPTION START DATE = 3/1/2008.
         *************************************************/
      WHEN     v_num = 2
           AND contract.fun_getaappdate (p_aapp_num, v_next_option_year, 'S') <
                                                         v_next_date_in_effect
         THEN
            SELECT LEAST (v_depletion_date,
                          contract.fun_getaappdate (p_aapp_num,
                                                    v_next_option_year,
                                                    'E'
                                                   )
                         )
              INTO v_date
              FROM DUAL;

            np_action_obj.mod_purpose :=
                  'Option extension for '
               || TO_CHAR (contract.fun_getaappdate (p_aapp_num,
                                                     v_next_option_year,
                                                     'S'
                                                    ),
                           'mm/dd/yyyy'
                          )
               || ' through '
               || TO_CHAR (contract.fun_getaappdate (p_aapp_num,
                                                     v_next_option_year,
                                                     'E'
                                                    ),
                           'mm/dd/yyyy'
                          )
               || ' and contract funding for costs from '
               || TO_CHAR (contract.fun_getaappdate (p_aapp_num,
                                                     v_next_option_year,
                                                     'S'
                                                    ),
                           'mm/dd/yyyy'
                          )
               || ' through '
               || TO_CHAR (v_date, 'mm/dd/yyyy');
            np_action_obj.mod_issue_date :=
               TO_CHAR (contract.fun_getaappdate (p_aapp_num,
                                                  v_next_option_year,
                                                  'S'
                                                 ),
                        'mm/dd/yyyy'
                       );
            np_action_obj.case_num := 3;
            np_action_obj.est_cost_date :=
                contract.fun_getaappdate (p_aapp_num, v_next_option_year, 'E');
            np_action_obj.next_action_date := v_date;
         /*************************************************
         SCENARIO 4:   Next option year starts on/after next date_in_effect AND on/before next depletion date.   Example: REPORT DATE = 9/1/2007; NEXT OPTION START DATE = 11/1/2007.
         *************************************************/
      WHEN     v_num = 2
           AND contract.fun_getaappdate (p_aapp_num, v_next_option_year, 'S') >=
                                                         v_next_date_in_effect
           AND TO_DATE (v_completion_date, 'mm/dd/yyyy') <= v_depletion_date
         THEN
            SELECT LEAST (v_next_depletion_date,
                          contract.fun_getaappdate (p_aapp_num,
                                                    v_next_option_year,
                                                    'E'
                                                   )
                         )
              INTO v_date
              FROM DUAL;

            np_action_obj.mod_purpose :=
                  'Option extension for '
               || TO_CHAR (contract.fun_getaappdate (p_aapp_num,
                                                     v_next_option_year,
                                                     'S'
                                                    ),
                           'mm/dd/yyyy'
                          )
               || ' through '
               || TO_CHAR (contract.fun_getaappdate (p_aapp_num,
                                                     v_next_option_year,
                                                     'E'
                                                    ),
                           'mm/dd/yyyy'
                          )
               || ' and contract funding for costs from '
               || TO_CHAR (contract.fun_getaappdate (p_aapp_num,
                                                     v_next_option_year,
                                                     'S'
                                                    ),
                           'mm/dd/yyyy'
                          )
               || ' through '
               || TO_CHAR (v_date, 'mm/dd/yyyy');
            np_action_obj.mod_issue_date :=
               TO_CHAR (contract.fun_getaappdate (p_aapp_num,
                                                  v_next_option_year,
                                                  'S'
                                                 ),
                        'mm/dd/yyyy'
                       );
            np_action_obj.case_num := 4;
            np_action_obj.est_cost_date :=
                contract.fun_getaappdate (p_aapp_num, v_next_option_year, 'E');
            np_action_obj.next_action_date := v_date;
         /*************************************************
         SCENARIO 5:  Next option year starts after current depletion date.  Example: REPORT DATE = 9/1/2007; NEXT OPTION START DATE = 12/1/2007.
         *************************************************/
      WHEN     v_num = 2
           AND TO_DATE (v_completion_date, 'mm/dd/yyyy') > v_depletion_date
         THEN
            SELECT LEAST (v_next_depletion_date,
                          TO_DATE (v_completion_date, 'mm/dd/yyyy')
                         )
              INTO v_date
              FROM DUAL;

            np_action_obj.mod_purpose :=
                  'Incremental funding only, for costs from '
               || TO_CHAR (v_depletion_date + 1, 'mm/dd/yyyy')
               || ' through '
               || TO_CHAR (v_date, 'mm/dd/yyyy')
               || '.';
            np_action_obj.mod_issue_date :=
                                 TO_CHAR (v_next_date_in_effect, 'mm/dd/yyyy');
            np_action_obj.case_num := 5;
            np_action_obj.est_cost_date :=
                                     TO_DATE (v_completion_date, 'mm/dd/yyyy');
            np_action_obj.next_action_date := v_date;
         /*************************************************
         SCENARIO 6:   New contract starts at a later date which is on / before next depletion date.  Example: REPORT DATE = 2/1/2008; New Contract Starts 4/1/2008.
         *************************************************/
      WHEN     v_num = 1
           AND v_cur_contract_year = 0
           AND contract.fun_getaappdate (p_aapp_num, 1, 'S') <=
                                                         v_next_depletion_date
         THEN
            SELECT LEAST (report.fun_get_depletion_date (date_start),
                          contract.fun_getaappdate (aapp_num, years_base, 'E')
                         )
              INTO v_date
              FROM aapp
             WHERE aapp_num = p_aapp_num;

            np_action_obj.mod_purpose :=
                  'New contract award for initial base period of '
               || TO_CHAR (contract.fun_getaappdate (p_aapp_num, 1, 'S'),
                           'mm/dd/yyyy'
                          )
               || ' through '
               || TO_CHAR (contract.fun_getaappdate (p_aapp_num,
                                                     v_years_base,
                                                     'E'
                                                    ),
                           'mm/dd/yyyy'
                          )
               || ' and contract funding for costs from '
               || TO_CHAR (contract.fun_getaappdate (p_aapp_num, 1, 'S'),
                           'mm/dd/yyyy'
                          )
               || ' through '
               || TO_CHAR (v_date, 'mm/dd/yyyy')
               || '.';
            np_action_obj.mod_issue_date :=
               TO_CHAR (contract.fun_getaappdate (p_aapp_num, 1, 'S'),
                        'mm/dd/yyyy'
                       );
            np_action_obj.case_num := 6;
            np_action_obj.est_cost_date :=
                      contract.fun_getaappdate (p_aapp_num, v_years_base, 'E');
            np_action_obj.next_action_date := v_date;
         /*************************************************
         SCENARIO 7:   New contract starts at a later date which is on/after the second date_in_effect in the NEXT PY (October 1) .  Example: REPORT DATE = 2/1/2008; New Contract Starts 7/1/2008.
         *************************************************/
      WHEN     v_num = 1
           AND v_cur_contract_year = 0
           AND contract.fun_getaappdate (p_aapp_num, 1, 'S') >
                                                         v_next_depletion_date
         THEN
            np_action_obj.mod_purpose :=
                       'NA. Please refer to the new contract profile report.';
            np_action_obj.mod_issue_date := 'NA';
            np_action_obj.case_num := 7;
      END CASE;

      RETURN np_action_obj;
   END fun_get_fiscal_plan_npa;

   FUNCTION fun_get_fiscal_plan_efa (
      p_aapp_num        IN   NUMBER,
      p_cost_cat_code   IN   VARCHAR2,
      p_program_year    IN   NUMBER,
      p_column          IN   CHAR
   )
      RETURN NUMBER
   AS
      v_amount              NUMBER                            := 0;
      v_amount1             NUMBER;
      v_year_mod            NUMBER;
      v_date1               NUMBER;
      v_date2               NUMBER;
      v_contract_year       aapp_yearend.contract_year%TYPE;
      v_cost_cat_id         lu_cost_cat.cost_cat_id%TYPE;
      v_curr_cont_year      NUMBER
                          := contract.fun_getcurrntcontract_year (p_aapp_num);
      v_contract_end_date   DATE;
      v_py_s_date           DATE
                             := utility.fun_get_py_date (p_program_year, 'S');
      v_py_e_date           DATE
                             := utility.fun_get_py_date (p_program_year, 'E');
      v_date_y              DATE;
      v_date_z              DATE;
      np_action_obj         report.np_action_obj_type;
      v_budget_input_type   CHAR;
      v_years_base          NUMBER;
      v_years_option        NUMBER;
   BEGIN
      np_action_obj := report.fun_get_fiscal_plan_npa (p_aapp_num);

      SELECT cost_cat_id
        INTO v_cost_cat_id
        FROM lu_cost_cat
       WHERE cost_cat_code = p_cost_cat_code;

      SELECT date_end, budget_input_type, years_base,
             years_option
        INTO v_contract_end_date, v_budget_input_type, v_years_base,
             v_years_option
        FROM aapp
       WHERE aapp_num = p_aapp_num;

      CASE
         WHEN v_curr_cont_year > 0 AND v_budget_input_type != 'A'
         THEN
            v_amount := NULL;
         WHEN     (np_action_obj.case_num = 1 OR np_action_obj.case_num = 7)
              AND (p_column = 'C' OR p_column = 'F')
         THEN
            v_amount := NULL;
         WHEN    p_cost_cat_code = 'B1'
              OR p_cost_cat_code = 'B2'
              OR p_cost_cat_code = 'B3'
              OR p_cost_cat_code = 'B4'
              OR p_cost_cat_code = 'D'
              OR p_column = 'H'
         THEN
            --estimate and funding
            SELECT NVL (SUM (a.amount), 0)
              INTO v_amount
              FROM fop a
             WHERE a.aapp_num = p_aapp_num
               AND a.py <= p_program_year
               AND a.cost_cat_id = v_cost_cat_id;
         WHEN    p_cost_cat_code = 'A'
              OR p_cost_cat_code = 'C1'
              OR p_cost_cat_code = 'C2'
              OR p_cost_cat_code = 'S'
         THEN
            --column A p_date = completion date
            IF p_column = 'A'
            THEN
               BEGIN
                  SELECT MAX (contract_year)
                    INTO v_contract_year
                    FROM aapp_yearend
                   WHERE aapp_num = p_aapp_num
                     AND date_end <=
                            TO_DATE (np_action_obj.completion_date,
                                     'mm/dd/yyyy'
                                    );
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     v_contract_year := -1;
               END;

               v_amount :=
                  contract.fun_getcumulativeamount (p_aapp_num,
                                                    v_cost_cat_id,
                                                    v_contract_year
                                                   );

               IF np_action_obj.case_num = 6
               THEN
                  v_amount := NULL;
               END IF;
            --column C p_date = completion date
            ELSIF p_column = 'C'
            THEN
               SELECT NVL (MAX (contract_year), -1)
                 INTO v_contract_year
                 FROM aapp_yearend
                WHERE aapp_num = p_aapp_num
                  AND date_end <=
                         TO_DATE (np_action_obj.completion_date, 'mm/dd/yyyy');

               CASE
                  WHEN np_action_obj.case_num = 2
                       OR np_action_obj.case_num = 5
                  THEN
                     v_amount :=
                        contract.fun_getcumulativeamount (p_aapp_num,
                                                          v_cost_cat_id,
                                                          v_contract_year
                                                         );
                  WHEN np_action_obj.case_num = 3
                       OR np_action_obj.case_num = 4
                  THEN
                     v_amount :=
                        contract.fun_getcumulativeamount (p_aapp_num,
                                                          v_cost_cat_id,
                                                          v_contract_year + 1
                                                         );
                  WHEN np_action_obj.case_num = 6
                  THEN
                     SELECT years_base
                       INTO v_contract_year
                       FROM aapp
                      WHERE aapp_num = p_aapp_num;

                     v_amount :=
                        contract.fun_getcumulativeamount (p_aapp_num,
                                                          v_cost_cat_id,
                                                          v_contract_year
                                                         );

                     IF v_amount = 0
                     THEN
                        FOR idx IN 1 .. v_contract_year
                        LOOP
                           SELECT contract.fun_getaappbudgetest
                                                     (p_aapp_num,
                                                      idx,
                                                      contract_budget_item_id,
                                                      contract_type_code
                                                     )
                             INTO v_amount1
                             FROM i_contract_budget_item
                            WHERE contract_type_code = p_cost_cat_code
                              AND budget_item_code = 'TI';

                           v_amount := v_amount + NVL (v_amount1, 0);
                        END LOOP;
                     END IF;
               END CASE;
            --column D p_date = action date
            ELSIF p_column = 'D'
            THEN
               /****************************************
               A better formula (except for B3) would be as follows: Cumulative ECP thru prior contract year + ECP for current contract year X (DEPLETION DATE ? END DATE OF PRIOR CONTRACT YEAR / (END DATE OF CURRENT CONTRACT YEAR ? END DATE OF PRIOR CONTRACT YEAR).
               ****************************************/
               --Check if you are in base year
               BEGIN
                  SELECT a.contract_year
                    INTO v_contract_year
                    FROM aapp_yearend a, aapp b
                   WHERE a.aapp_num = p_aapp_num
                     AND np_action_obj.action_date <= a.date_end
                     AND np_action_obj.action_date >= b.date_start
                     AND a.aapp_num = b.aapp_num
                     --AND b.years_base >= a.contract_year
                     AND ROWNUM < 2;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     v_contract_year := 0;
               END;

               IF v_contract_year != 0
               THEN
                  v_amount :=
                     contract.fun_getcumulativeamount (p_aapp_num,
                                                       v_cost_cat_id,
                                                       v_contract_year - 1
                                                      );
                  v_amount1 :=
                     contract.fun_getestcostprototalamount (p_aapp_num,
                                                            v_cost_cat_id,
                                                            v_contract_year
                                                           );
                  v_amount :=
                       v_amount
                     +   v_amount1
                       * (  (  datediff
                                  ('dd',
                                   contract.fun_getaappdate (p_aapp_num,
                                                             v_contract_year,
                                                             'S'
                                                            ),
                                   np_action_obj.action_date
                                  )
                             + 1
                            )
                          / contract.fun_getcontractyeardays (p_aapp_num,
                                                              v_contract_year
                                                             )
                         );
               ELSIF v_curr_cont_year > v_years_base + v_years_option
               THEN
                  BEGIN
                     SELECT MAX (contract_year)
                       INTO v_contract_year
                       FROM aapp_yearend
                      WHERE aapp_num = p_aapp_num
                        AND date_end <=
                               TO_DATE (np_action_obj.completion_date,
                                        'mm/dd/yyyy'
                                       );
                  EXCEPTION
                     WHEN NO_DATA_FOUND
                     THEN
                        v_contract_year := -1;
                  END;

                  v_amount :=
                     contract.fun_getcumulativeamount (p_aapp_num,
                                                       v_cost_cat_id,
                                                       v_contract_year
                                                      );

                  IF np_action_obj.case_num = 6
                  THEN
                     v_amount := NULL;
                  END IF;
               END IF;
            --column F p_date = next_action date
            ELSIF p_column = 'F'
            THEN
               /****************************************
               A better formula (except for B3) would be as follows: Cumulative ECP thru prior contract year + ECP for current contract year X (DEPLETION DATE ? END DATE OF PRIOR CONTRACT YEAR / (END DATE OF CURRENT CONTRACT YEAR ? END DATE OF PRIOR CONTRACT YEAR).
               ****************************************/
               --Check if you are in base year
               BEGIN
                  SELECT a.contract_year
                    INTO v_contract_year
                    FROM aapp_yearend a, aapp b
                   WHERE a.aapp_num = p_aapp_num
                     AND np_action_obj.next_action_date < a.date_end
                     AND np_action_obj.next_action_date >= b.date_start
                     AND a.aapp_num = b.aapp_num
                     AND b.years_base >= a.contract_year
                     AND ROWNUM < 2;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     v_contract_year := 0;
               END;

               --In base year
               IF v_contract_year != 0
               THEN
                  v_amount :=
                     contract.fun_getcumulativeamount (p_aapp_num,
                                                       v_cost_cat_id,
                                                       v_contract_year - 1
                                                      );
                  v_amount1 :=
                     contract.fun_getestcostprototalamount (p_aapp_num,
                                                            v_cost_cat_id,
                                                            v_contract_year
                                                           );

                  IF     np_action_obj.case_num = 6
                     AND v_amount = 0
                     AND v_amount1 = 0
                  THEN
                     FOR idx IN 1 .. v_contract_year - 1
                     LOOP
                        SELECT contract.fun_getaappbudgetest
                                                     (p_aapp_num,
                                                      idx,
                                                      contract_budget_item_id,
                                                      contract_type_code
                                                     )
                          INTO v_amount1
                          FROM i_contract_budget_item
                         WHERE contract_type_code = p_cost_cat_code
                           AND budget_item_code = 'TI';

                        v_amount := v_amount + NVL (v_amount1, 0);
                     END LOOP;

                     SELECT NVL
                               (contract.fun_getaappbudgetest
                                                     (p_aapp_num,
                                                      v_contract_year,
                                                      contract_budget_item_id,
                                                      contract_type_code
                                                     ),
                                0
                               )
                       INTO v_amount1
                       FROM i_contract_budget_item
                      WHERE contract_type_code = p_cost_cat_code
                        AND budget_item_code = 'TI';
                  END IF;

                  v_amount :=
                       v_amount
                     +   v_amount1
                       * (  (  datediff
                                  ('dd',
                                   contract.fun_getaappdate (p_aapp_num,
                                                             v_contract_year,
                                                             'S'
                                                            ),
                                   np_action_obj.next_action_date
                                  )
                             + 1
                            )
                          / contract.fun_getcontractyeardays (p_aapp_num,
                                                              v_contract_year
                                                             )
                         );
               --In Option Year
               ELSE
                  CASE
                     WHEN    np_action_obj.case_num = 2
                          OR np_action_obj.case_num = 5
                     THEN
                        v_year_mod := v_curr_cont_year - 1;
                     ELSE
                        v_year_mod := v_curr_cont_year;
                  END CASE;

                  v_amount :=
                     contract.fun_getcumulativeamount (p_aapp_num,
                                                       v_cost_cat_id,
                                                       v_year_mod
                                                      );
                  v_amount1 :=
                     contract.fun_getestcostprototalamount (p_aapp_num,
                                                            v_cost_cat_id,
                                                            v_year_mod + 1
                                                           );
                  v_amount :=
                       v_amount
                     +   v_amount1
                       * (  datediff
                                 ('dd',
                                  contract.fun_getaappdate (p_aapp_num,
                                                            v_year_mod,
                                                            'E'
                                                           ),
                                  np_action_obj.next_action_date
                                 )
                          / contract.fun_getcontractyeardays
                                                           (p_aapp_num,
                                                              v_year_mod
                                                            + 1
                                                           )
                         );
               END IF;
            END IF;
         /* b3 NO LONGER PRO-RATED - JUST USE FULL FOP AMOUNT thru current PY
         WHEN p_cost_cat_code = 'B3'
         THEN
            SELECT NVL (SUM (a.amount), 0)
              INTO v_amount
              FROM fop a
             WHERE a.aapp_num = p_aapp_num
               AND a.py < p_program_year
               AND a.cost_cat_id = v_cost_cat_id;

            SELECT NVL (SUM (a.amount), 0)
              INTO v_amount1
              FROM fop a
             WHERE a.aapp_num = p_aapp_num
               AND a.py = p_program_year
               AND a.cost_cat_id = v_cost_cat_id;

            v_date2 :=
                 datediff
                         ('DD',
                          GREATEST (v_py_s_date,
                                    utility.fun_cnt_date (p_aapp_num, 0, 'S')
                                   ),                                 --date y
                          LEAST (TO_DATE (np_action_obj.final_date,
                                          'mm/dd/yyyy'
                                         ),
                                 v_py_e_date
                                )                                     --date x
                         )
               + 1;

            SELECT DECODE (v_date2, 0, 1, v_date2)
              INTO v_date2
              FROM DUAL;

            --estimate
            IF p_column = 'A'
            THEN
               v_date1 :=
                    datediff ('DD',
                              GREATEST (v_py_s_date,
                                        utility.fun_cnt_date (p_aapp_num,
                                                              0,
                                                              'S'
                                                             )
                                       ),
                              TO_DATE (np_action_obj.completion_date,
                                       'mm/dd/yyyy'
                                      )
                             )
                  + 1;
            ELSIF p_column = 'C'
            THEN
               v_date1 :=
                    datediff ('DD',
                              GREATEST (v_py_s_date,
                                        utility.fun_cnt_date (p_aapp_num,
                                                              0,
                                                              'S'
                                                             )
                                       ),
                              np_action_obj.est_cost_date
                             )
                  + 1;
            --column D p_date = action date
            ELSIF p_column = 'D'
            THEN
               v_date1 :=
                    datediff ('DD',
                              GREATEST (v_py_s_date,
                                        utility.fun_cnt_date (p_aapp_num,
                                                              0,
                                                              'S'
                                                             )
                                       ),
                              np_action_obj.action_date
                             )
                  + 1;
            --column F p_date = next_action date
            ELSIF p_column = 'F'
            THEN
               v_date1 :=
                    datediff ('DD',
                              GREATEST (v_py_s_date,
                                        utility.fun_cnt_date (p_aapp_num,
                                                              0,
                                                              'S'
                                                             )
                                       ),
                              np_action_obj.next_action_date
                             )
                  + 1;
            END IF;

            v_amount :=
                 v_amount
               + NVL (ROUND (NVL (v_amount1, 0) * v_date1 / v_date2), 0);
      */
      END CASE;

      IF v_amount = 0 AND p_cost_cat_code = 'S'
      THEN
         SELECT NVL (SUM (a.amount), 0)
           INTO v_amount
           FROM fop a
          WHERE a.aapp_num = p_aapp_num
            AND a.py <= p_program_year
            AND a.cost_cat_id = v_cost_cat_id;
      END IF;

      IF    (np_action_obj.case_num = 7 AND p_column != 'H')
         OR (np_action_obj.case_num = 6
             AND (p_column = 'A' OR p_column = 'D')
            )
      THEN
         v_amount := NULL;
      ELSIF v_amount != NULL
      THEN
         v_amount := ROUND (v_amount);
      END IF;

      RETURN v_amount;
   END fun_get_fiscal_plan_efa;

   FUNCTION fun_get_depletion_date (p_date IN DATE)
      RETURN DATE
   AS
      v_date   DATE;
      v_isleapyear VARCHAR(1);
      v_year   NUMBER;
      v_monthdate VARCHAR(5);
   BEGIN
      /*
      SELECT a.date_depletion
        INTO v_date
        FROM omb_depletion_date a
       WHERE p_date BETWEEN a.date_in_effect
                        AND (SELECT date_in_effect - 1
                               FROM omb_depletion_date
                              WHERE date_in_effect > a.date_in_effect
                                AND ROWNUM < 2);
      */
      select  to_number(to_char(p_date,'yyyy')), to_char(p_date,'mm/dd') into v_year, v_monthdate from dual;
      
      select decode(mod(v_year+1,4),0,decode(mod(v_year+1,400),0,'Y',decode(mod(v_year+1,100),0,'N','Y') ),'N')
      into v_isleapyear
      from dual;
      
      select    case when v_monthdate between '07/01' and '09/30' then to_date('11/30/'||to_char(v_year),'mm/dd/yyyy')
                     when v_monthdate between '10/01' and '12/31' and v_isleapyear='N' then to_date('02/28/'||to_char(v_year+1),'mm/dd/yyyy')
                     when v_monthdate between '10/01' and '12/31' and v_isleapyear='Y' then to_date('02/29/'||to_char(v_year+1),'mm/dd/yyyy')
                     when v_monthdate between '01/01' and '03/31' then to_date('04/30/'||to_char(v_year),'mm/dd/yyyy')
                     when v_monthdate between '04/01' and '06/30' then to_date('06/30/'||to_char(v_year),'mm/dd/yyyy')
                end into v_date
      from      dual;       
      
      RETURN v_date;
   END fun_get_depletion_date;

   FUNCTION fun_get_next_depletion_date (p_date IN DATE)
      RETURN DATE
   AS
      v_date   DATE;
      v_isleapyear VARCHAR(1);
      v_year   NUMBER;
      v_monthdate VARCHAR(5);
   BEGIN
      /*
      SELECT date_depletion
        INTO v_date
        FROM omb_depletion_date
       WHERE report.fun_get_depletion_date (p_date) < date_depletion
         AND ROWNUM < 2;
      */
      select  to_number(to_char(p_date,'yyyy')), to_char(p_date,'mm/dd') into v_year, v_monthdate from dual;
      
      select decode(mod(v_year+1,4),0,decode(mod(v_year+1,400),0,'Y',decode(mod(v_year+1,100),0,'N','Y') ),'N')
      into v_isleapyear
      from dual;
      
      select    case when v_monthdate between '07/01' and '09/30' and v_isleapyear='N' then to_date('02/28/'||to_char(v_year+1),'mm/dd/yyyy')
                     when v_monthdate between '07/01' and '09/30' and v_isleapyear='Y' then to_date('02/29/'||to_char(v_year+1),'mm/dd/yyyy')
                     when v_monthdate between '10/01' and '12/31' then to_date('04/30/'||to_char(v_year+1),'mm/dd/yyyy')
                     when v_monthdate between '01/01' and '03/31' then to_date('06/30/'||to_char(v_year),'mm/dd/yyyy')
                     when v_monthdate between '04/01' and '06/30' then to_date('11/30/'||to_char(v_year),'mm/dd/yyyy')
                end into v_date
      from      dual;             

      RETURN v_date;
   END fun_get_next_depletion_date;

   FUNCTION fun_get_next_date_in_effect
      RETURN DATE
   AS
      v_date   DATE;
      v_year   NUMBER;
      v_monthdate VARCHAR(5);
   BEGIN
      /*
      SELECT date_in_effect
        INTO v_date
        FROM omb_depletion_date
       WHERE date_in_effect > trunc(to_date(sysdate), 'DDD') AND ROWNUM < 2;
      */
      select  to_number(to_char(sysdate,'yyyy')), to_char(sysdate,'mm/dd') into v_year, v_monthdate from dual;
      
      select    case when v_monthdate between '07/01' and '09/30' then to_date('10/01/'||to_char(v_year),'mm/dd/yyyy')
             when v_monthdate between '10/01' and '12/31' then to_date('01/01/'||to_char(v_year+1),'mm/dd/yyyy')
             when v_monthdate between '01/01' and '03/31' then to_date('04/01/'||to_char(v_year),'mm/dd/yyyy')
             when v_monthdate between '04/01' and '06/30' then to_date('07/01/'||to_char(v_year),'mm/dd/yyyy')
            end into v_date
      from      dual;         
      RETURN v_date;
   END fun_get_next_date_in_effect;

--Procedure
   PROCEDURE prc_get_fiscal_plan_rpt (
      p_aapp_num              NUMBER,
      p_recordset       OUT   sys_refcursor,
      p_recordset_est   OUT   sys_refcursor,
      p_recordset_fit   OUT   sys_refcursor,
      p_recordset_c     OUT   sys_refcursor
   )
   IS
      np_action_obj    report.np_action_obj_type;
      v_program_year   NUMBER         := utility.fun_getcurrntprogram_year
                                                                          ();
      v_doc_count      NUMBER;
      v_doc_num        VARCHAR2 (100);
   BEGIN
      np_action_obj := report.fun_get_fiscal_plan_npa (p_aapp_num);

      BEGIN
         SELECT COUNT (DISTINCT doc_num) AS rnum
           INTO v_doc_count
           FROM footprint_ncfms --updated for NCFMS
          WHERE aapp_num = p_aapp_num AND oblig != 0;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            v_doc_count := 0;
            v_doc_num := 'None';
      END;

      IF v_doc_count > 1
      THEN
         v_doc_num := 'Multiple';
      ELSIF v_doc_count = 1
      THEN
         SELECT DISTINCT doc_num
                    INTO v_doc_num
                    FROM footprint_ncfms --updated for NCFMS
                   WHERE aapp_num = p_aapp_num AND oblig != 0;
      END IF;

      OPEN p_recordset FOR
         SELECT v_program_year AS program_year,
                utility.fun_get_region_desc (a.aapp_num) AS region_desc,
                a.aapp_num,
                utility.fun_get_contractor_name
                                               (a.aapp_num)
                                                           AS contractor_name,
                utility.fun_get_center_name (a.aapp_num) AS center_name,
                a.contract_num, v_doc_num AS doc_number,
                aapp_program_activity (a.aapp_num, 'S') AS program_service,
                a.venue, np_action_obj.action_desc AS action_desc,
                np_action_obj.effective_date AS effective_date,
                np_action_obj.from_date AS from_date,
                np_action_obj.through_date AS through_date,
                np_action_obj.final_date AS final_date,
                np_action_obj.completion_date AS completion_date,
                np_action_obj.action_date AS action_date,
                np_action_obj.mod_purpose AS mod_purpose,
                np_action_obj.mod_issue_date AS mod_issue_date,
                np_action_obj.case_num AS case_num,
                CASE
                   WHEN a.date_start <= trunc(to_date(sysdate), 'DDD')
                   AND a.budget_input_type != 'A'
                      THEN 'Award Package needed. Please contact National Office.'
                   ELSE ''
                END AS users_note
           FROM aapp a
          WHERE a.aapp_num = p_aapp_num;
      -- removed "'B3', '2/'," from decode set below (no longer pro-rating B3)
      OPEN p_recordset_est FOR
         SELECT   'E' AS TYPE, cost_cat_code, cost_cat_desc,
                  DECODE (cost_cat_code,
                          'A', '1/',
                          'C1', '1/',
                          'C2', '1/',
                          ''
                         ) AS note,
                  
                  --(a)
                  CASE
                     WHEN np_action_obj.case_num = 6
                        THEN report.fun_get_fiscal_plan_efa
                                                   (p_aapp_num,
                                                    cost_cat_code,
                                                    v_program_year,
                                                    'A'
                                                   )
                     ELSE NVL
                             (report.fun_get_fiscal_plan_efa (p_aapp_num,
                                                              cost_cat_code,
                                                              v_program_year,
                                                              'A'
                                                             ),
                              0
                             )
                  END AS amount,
                  
                  --(b)
                  CASE
                     WHEN np_action_obj.case_num = 6
                        THEN report.fun_get_fiscal_plan_efa
                                          (p_aapp_num,
                                           cost_cat_code,
                                           v_program_year,
                                           'C'
                                          )
                     ELSE   report.fun_get_fiscal_plan_efa (p_aapp_num,
                                                            cost_cat_code,
                                                            v_program_year,
                                                            'C'
                                                           )
                          - report.fun_get_fiscal_plan_efa (p_aapp_num,
                                                            cost_cat_code,
                                                            v_program_year,
                                                            'A'
                                                           )
                  END AS est_cost_change,
                  
                  --(c)
                  report.fun_get_fiscal_plan_efa
                                       (p_aapp_num,
                                        cost_cat_code,
                                        v_program_year,
                                        'C'
                                       ) AS new_est_cost_total
             FROM lu_cost_cat
            WHERE cost_cat_p_id IS NULL
         ORDER BY cost_cat_code;

      OPEN p_recordset_fit FOR
         --(d)
         SELECT   'F' AS TYPE, cost_cat_code, cost_cat_desc, 1 AS sort_by,
                  CASE
                     WHEN np_action_obj.case_num = 6
                        THEN report.fun_get_fiscal_plan_efa
                                                   (p_aapp_num,
                                                    cost_cat_code,
                                                    v_program_year,
                                                    'D'
                                                   )
                     ELSE NVL
                             (report.fun_get_fiscal_plan_efa (p_aapp_num,
                                                              cost_cat_code,
                                                              v_program_year,
                                                              'D'
                                                             ),
                              0
                             )
                  END AS amount
             FROM lu_cost_cat
            WHERE cost_cat_p_id IS NULL
         UNION
         --(e)
         SELECT   'M' AS TYPE, cost_cat_code, cost_cat_desc, 2 AS sort_by,
                  CASE
                     WHEN np_action_obj.case_num = 6
                        THEN report.fun_get_fiscal_plan_efa (p_aapp_num,
                                                             cost_cat_code,
                                                             v_program_year,
                                                             'F'
                                                            )
                     ELSE   report.fun_get_fiscal_plan_efa (p_aapp_num,
                                                            cost_cat_code,
                                                            v_program_year,
                                                            'F'
                                                           )
                          - report.fun_get_fiscal_plan_efa (p_aapp_num,
                                                            cost_cat_code,
                                                            v_program_year,
                                                            'D'
                                                           )
                  END
             FROM lu_cost_cat
            WHERE cost_cat_p_id IS NULL
         UNION
         --(f)
         SELECT   'D' AS TYPE, cost_cat_code, cost_cat_desc, 3 AS sort_by,
                  report.fun_get_fiscal_plan_efa (p_aapp_num,
                                                  cost_cat_code,
                                                  v_program_year,
                                                  'F'
                                                 )
             FROM lu_cost_cat
            WHERE cost_cat_p_id IS NULL
         UNION
         --(h)
         SELECT   'T' AS TYPE, cost_cat_code, cost_cat_desc, 4 AS sort_by,
                  NVL (report.fun_get_fiscal_plan_efa (p_aapp_num,
                                                       cost_cat_code,
                                                       v_program_year,
                                                       'H'
                                                      ),
                       0
                      )
             FROM lu_cost_cat
            WHERE cost_cat_p_id IS NULL
         ORDER BY cost_cat_code, sort_by;

      OPEN p_recordset_c FOR
         SELECT   1 AS row1, 1 AS col, 'Operation Funds' AS CATEGORY,
                  'A' AS TYPE,
                  SUM
                     (report.fun_get_fiscal_plan_efa (p_aapp_num,
                                                      cost_cat_code,
                                                      v_program_year,
                                                      'H'
                                                     )
                     ) AS amount
             FROM lu_cost_cat
            WHERE cost_cat_p_id IS NULL AND cost_cat_code != 'B1'
         UNION
         SELECT   2 AS row1, 1 AS col, 'Cnst/Rehab/Acquisition' AS CATEGORY,
                  'A' AS TYPE,
                  SUM
                     (report.fun_get_fiscal_plan_efa (p_aapp_num,
                                                      cost_cat_code,
                                                      v_program_year,
                                                      'D'
                                                     )
                     ) AS amount
             FROM lu_cost_cat
            WHERE cost_cat_p_id IS NULL AND cost_cat_code = 'B1'
         UNION
         
         -- updated for NCFMS
         SELECT   1 AS row1, 2 AS col, 'Operation Funds' AS CATEGORY,
                  'B' AS TYPE, NVL (SUM (a.oblig), 0) AS amount
             FROM footprint_ncfms a
            WHERE a.aapp_num = p_aapp_num
              AND a.APPROP_EXP_PY < v_program_year
              AND upper(a.fund_cat) = 'OPS'
         UNION
         SELECT   2 AS row1, 2 AS col, 'Cnst/Rehab/Acquisition' AS CATEGORY,
                  'B' AS TYPE, NVL (SUM (a.oblig), 0) AS amount
             FROM footprint_ncfms a
            WHERE a.aapp_num = p_aapp_num
              AND a.APPROP_EXP_PY < v_program_year
              AND upper(a.fund_cat) = 'CRA'
         UNION
         SELECT   1 AS row1, 4 AS col, 'Operation Funds' AS CATEGORY,
                  'D' AS TYPE, NVL (SUM (a.oblig), 0) AS amount
             FROM footprint_ncfms a
            WHERE a.aapp_num = p_aapp_num
              AND a.APPROP_EXP_PY >= v_program_year
              AND upper(a.fund_cat) = 'OPS'
         UNION
         SELECT   2 AS row1, 4 AS col, 'Cnst/Rehab/Acquisition' AS CATEGORY,
                  'D' AS TYPE, NVL (SUM (a.oblig), 0) AS amount
             FROM footprint_ncfms a
            WHERE a.aapp_num = p_aapp_num
              AND a.APPROP_EXP_PY >= v_program_year
              AND upper(a.fund_cat) = 'CRA'
              
         /* legacy - DOLAR$ footprint
         SELECT   1 AS row1, 2 AS col, 'Operation Funds' AS CATEGORY,
                  'B' AS TYPE, NVL (SUM (a.oblig), 0) AS amount
             FROM footprint a, rcc_code b
            WHERE a.aapp_num = p_aapp_num
              AND a.rcc_org = b.rcc_org
              AND a.rcc_fund = b.rcc_fund
              AND a.fy = b.fy
              AND b.last_oblig_py < v_program_year
              AND b.ops_cra = 'OPS'
         UNION
         SELECT   2 AS row1, 2 AS col, 'Cnst/Rehab/Acquisition' AS CATEGORY,
                  'B' AS TYPE, NVL (SUM (a.oblig), 0) AS amount
             FROM footprint a, rcc_code b
            WHERE a.aapp_num = p_aapp_num
              AND a.rcc_org = b.rcc_org
              AND a.rcc_fund = b.rcc_fund
              AND a.fy = b.fy
              AND b.last_oblig_py < v_program_year
              AND b.ops_cra = 'CRA'
         UNION
         SELECT   1 AS row1, 4 AS col, 'Operation Funds' AS CATEGORY,
                  'D' AS TYPE, NVL (SUM (a.oblig), 0) AS amount
             FROM footprint a, rcc_code b
            WHERE a.aapp_num = p_aapp_num
              AND a.rcc_org = b.rcc_org
              AND a.rcc_fund = b.rcc_fund
              AND a.fy = b.fy
              AND b.last_oblig_py >= v_program_year
              AND b.ops_cra = 'OPS'
         UNION
         SELECT   2 AS row1, 4 AS col, 'Cnst/Rehab/Acquisition' AS CATEGORY,
                  'D' AS TYPE, NVL (SUM (a.oblig), 0) AS amount
             FROM footprint a, rcc_code b
            WHERE a.aapp_num = p_aapp_num
              AND a.rcc_org = b.rcc_org
              AND a.rcc_fund = b.rcc_fund
              AND a.fy = b.fy
              AND b.last_oblig_py >= v_program_year
              AND b.ops_cra = 'CRA'
         */
         ORDER BY row1, col;
   END prc_get_fiscal_plan_rpt;

   PROCEDURE prc_get_est_cost_rpt (
      p_aapp_num          NUMBER,
      p_recordset   OUT   sys_refcursor
   )
   IS
   BEGIN
      OPEN p_recordset FOR
         SELECT utility.fun_get_contractor_name
                                               (p_aapp_num)
                                                          AS contractor_name,
                utility.fun_get_region_desc (p_aapp_num) AS region_desc,
                aapp_num, contract_num,
                utility.fun_get_center_name (p_aapp_num) AS center_name,
                venue, aapp_program_activity (aapp_num) AS program_service,
                DECODE (contract_status_id,
                        1, 'Active Record',
                        'Inactive Record'
                       ) AS status,
                funding_office_num
           FROM aapp
          WHERE aapp_num = p_aapp_num;
   END prc_get_est_cost_rpt;

   PROCEDURE prc_get_fop_vst_rpt (
      p_aapp_num             NUMBER,
      p_program_year         NUMBER,
      p_recordset      OUT   sys_refcursor
   )
   IS
      v_type      NUMBER;
      v_vst_rec   fop_batch.vst_rec;
   BEGIN
      SELECT COUNT (1)
        INTO v_type
        FROM vst_report_history
       WHERE aapp_num = p_aapp_num AND py = p_program_year;

      IF v_type = 0
      THEN
         v_vst_rec := fop_batch.fun_vstrec (p_aapp_num, p_program_year);

         OPEN p_recordset FOR
            SELECT utility.fun_get_region_desc (p_aapp_num) AS region_desc,
                   utility.fun_get_contractor_name
                                               (p_aapp_num)
                                                          AS contractor_name,
                   a.contract_num,
                   utility.fun_get_center_name (p_aapp_num) AS center_name,
                   v_vst_rec.aapp_num AS aapp_num,
                   v_vst_rec.calculated_date AS calculated_date,
                   v_vst_rec.status AS status,
                   v_vst_rec.rpt_type AS rpt_type,
                   v_vst_rec.good_report_date AS good_report_date,
                   v_vst_rec.pre_vst_rpt_date AS pre_vst_rpt_date,
                   v_vst_rec.vst_rpt_date AS vst_rpt_date,
                   v_vst_rec.pre_fms_amount AS pre_fms_amount,
                   v_vst_rec.fms_amount AS fms_amount,
                   v_vst_rec.pre_fopamount AS pre_fopamount,
                   v_vst_rec.fopamount AS fopamount,
                   v_vst_rec.vst_slots AS vst_slots,
                   v_vst_rec.pre_vst_slots AS pre_vst_slots,
                   v_vst_rec.pre_py AS pre_py, v_vst_rec.py AS py,
                   v_vst_rec.prg_date_start AS prg_date_start,
                   v_vst_rec.next_prg_date_start AS next_prg_date_start,
                   v_vst_rec.cnt_date_start AS cnt_date_start,
                   v_vst_rec.pre_cnt_date_end AS pre_cnt_date_end,
                   v_vst_rec.cnt_date_end AS cnt_date_end,
                   v_vst_rec.pre_aapp_num AS pre_aapp_num,
                   v_vst_rec.pre_uncommit_vst AS pre_uncommit_vst,
                   v_vst_rec.uncommit_vst AS uncommit_vst,
                   v_vst_rec.total_uncommit_vst AS total_uncommit_vst,
                   v_vst_rec.credit AS credit,
                   v_vst_rec.pre_credit AS pre_credit,
                   v_vst_rec.pre_final_obligation AS pre_final_obligation,
                   v_vst_rec.est_total_vst_find AS est_total_vst_find,
                   v_vst_rec.est_cum_obligation AS est_cum_obligation,
                   v_vst_rec.allowance AS allowance,
                   v_vst_rec.base_allowance AS base_allowance,
                   v_vst_rec.vst_supple AS vst_supple,
                   v_vst_rec.vst_minium AS vst_minium,
                   v_vst_rec.excess_vst AS excess_vst,
                   v_vst_rec.vst_amount AS vst_amount,
                   v_type AS history_rec,
                   v_vst_rec.vst_prorated AS vst_prorated,
                   v_vst_rec.form_version AS form_version
              FROM aapp a
             WHERE a.aapp_num = p_aapp_num;
      ELSE
         OPEN p_recordset FOR
            SELECT utility.fun_get_region_desc (p_aapp_num) AS region_desc,
                   utility.fun_get_contractor_name
                                               (p_aapp_num)
                                                          AS contractor_name,
                   a.contract_num,
                   utility.fun_get_center_name (p_aapp_num) AS center_name,
                   f.aapp_num, f.calculated_date, f.status, f.rpt_type,
                   f.good_report_date, f.pre_vst_rpt_date, f.vst_rpt_date,
                   f.pre_fms_amount, f.fms_amount, f.pre_fopamount,
                   f.fopamount, f.vst_slots, f.pre_vst_slots, f.pre_py, f.py,
                   f.prg_date_start, f.next_prg_date_start, f.cnt_date_start,
                   f.pre_cnt_date_end, f.cnt_date_end, f.pre_aapp_num,
                   f.pre_uncommit_vst, f.uncommit_vst, f.total_uncommit_vst,
                   f.credit, f.pre_credit, f.pre_final_obligation,
                   f.est_total_vst_find, f.est_cum_obligation, f.allowance,
                   f.base_allowance, f.vst_supple, f.vst_minium,
                   f.excess_vst, f.vst_amount, v_type AS history_rec,
                   f.vst_prorated,f.form_version
              FROM aapp a, vst_report_history f
             WHERE a.aapp_num = p_aapp_num
               AND a.aapp_num = f.aapp_num
               AND f.py = p_program_year;
      END IF;
   END prc_get_fop_vst_rpt;

   PROCEDURE prc_get_fop_ccc_rpt (
      p_aapp_num                 NUMBER,
      p_program_year             NUMBER,
      p_recordset_data     OUT   sys_refcursor,
      p_recordset_status   OUT   sys_refcursor
   )
   IS
      v_fed_rate      NUMBER
                     := utility.fun_get_fep_pers_inflat_rate (p_program_year);
      v_omb_rate      NUMBER
         := utility.fun_get_omb_inflat_rate
                                    (utility.fun_get_py_date (p_program_year,
                                                              'S'
                                                             )
                                    );
      v_omb_b3_rate   NUMBER
         := utility.fun_get_omb_inflat_rate
                                    (utility.fun_get_py_date (p_program_year,
                                                              'S'
                                                             ),
                                     'B3'
                                    );
      v_type          NUMBER                           := 0;
      
      v_pre_py        NUMBER                           := p_program_year - 1;
      py_prorate_factor  NUMBER := utility.fun_get_py_prorate_factor(p_program_year);
      v_ccc_comment   ccc_worksheet.ccc_comment%TYPE;
   BEGIN
/****************************************
      If there is no record in worksheet table, then calculate it.
****************************************/
      SELECT COUNT (1)
        INTO v_type
        FROM ccc_worksheet_data
       WHERE aapp_num = p_aapp_num AND program_year = p_program_year;

      IF v_type = 0
      THEN
         OPEN p_recordset_data FOR
            SELECT   a.ccc_wscc_id, a.cost_cat_id, a.cost_cat_code,
                     a.cost_cat_desc, a.base_edit, a.base_subtotal,
                     a.default_amount, a.sort_order, p_aapp_num AS aapp_num,
                     p_program_year AS program_year, pd_expense,base_subtotal_nopd, next_py_edit,
                     DECODE
                        (a.default_amount,
                         1, fop_batch.fun_fopcccworksheetamount
                                                              (p_aapp_num,
                                                               v_pre_py,
                                                               a.cost_cat_id,
                                                               a.cost_cat_code,
                                                               a.ccc_wscc_id
                                                              ),
                         NULL
                        ) AS amount_py_base,
                     fop_batch.fun_get_fop_ccc_rpt_pro_budget
                                       (p_aapp_num,
                                        p_program_year,
                                        a.ccc_wscc_id,
                                        a.cost_cat_id,
                                        a.cost_cat_code
                                       ) AS amount_py_inflated,
                     NULL AS amount_py_proposed, NULL AS amount_dol_adjusted,
                     NULL AS amount_final
                FROM lu_ccc_worksheet_cost_cat a
                WHERE
                    (
                    CASE
                    WHEN p_program_year <=2008 AND py08_back = 1 THEN 1
                    WHEN p_program_year >=2009 AND py09_forward = 1 THEN 1
                    ELSE 0
                    END
                    ) = 1
            ORDER BY a.sort_order;
      ELSE
         OPEN p_recordset_data FOR
            SELECT   a.ccc_wscc_id, a.cost_cat_id, a.cost_cat_code,
                     a.cost_cat_desc, a.base_edit, a.base_subtotal,
                     a.default_amount, a.sort_order, p_aapp_num AS aapp_num,
                     p_program_year AS program_year, b.amount_py_base,
                     b.amount_py_inflated, b.amount_py_proposed,
                     b.amount_dol_adjusted, b.amount_final, pd_expense, base_subtotal_nopd, next_py_edit
                FROM lu_ccc_worksheet_cost_cat a LEFT OUTER JOIN ccc_worksheet_data b
                     ON a.ccc_wscc_id = b.ccc_wscc_id
                   AND b.aapp_num = p_aapp_num
                   AND b.program_year = p_program_year
                WHERE
                    (
                    CASE
                    WHEN p_program_year <=2008 AND py08_back = 1 THEN 1
                    WHEN p_program_year >=2009 AND py09_forward = 1 THEN 1
                    ELSE 0
                    END
                    ) = 1
            ORDER BY a.sort_order;
      END IF;

      BEGIN
         SELECT ccc_comment
           INTO v_ccc_comment
           FROM ccc_worksheet
          WHERE aapp_num = p_aapp_num AND program_year = p_program_year;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            v_ccc_comment := '';
      END;

      OPEN p_recordset_status FOR
         SELECT   v_fed_rate AS fed_rate, v_omb_rate AS omb_rate,
                  v_omb_b3_rate AS omb_b3_rate, a.worksheet_status_id,
                  a.worksheet_status_desc,
                  DECODE (b.worksheet_status_id, NULL, 0, 1) AS checked,
                  v_ccc_comment AS ccc_comment,
                  py_prorate_factor as prorate_factor
             FROM lu_worksheet_status a LEFT OUTER JOIN ccc_worksheet b
                  ON a.worksheet_status_id = b.worksheet_status_id
                AND b.aapp_num = p_aapp_num
                AND b.program_year = p_program_year
         ORDER BY a.worksheet_status_id;
   END prc_get_fop_ccc_rpt;

   PROCEDURE prc_get_future_new_rpt (
      p_aapp_num          NUMBER,
      p_recordset   OUT   sys_refcursor
   )
   IS
      v_pred_aapp_num              aapp.aapp_num%TYPE;
      v_type_of_contract           VARCHAR2 (50) := 'Cost Plus Base/Incentive Fee';
      v_smb_setaside_desc          lu_smb_setaside.smb_setaside_desc%TYPE;
      v_pred_contract_num          aapp.contract_num%TYPE;
      v_pred_total_cnt_year        aapp.years_base%TYPE                  := 0;
      v_pred_cnt_date_start        DATE;
      v_pred_cnt_date_end          DATE;
      v_pred_cnt_last_year_days    NUMBER;
      v_pred_cnt_whole_year_days   NUMBER;
      v_pred_cnt_days_percent      NUMBER;
   BEGIN
      SELECT NVL (pred_aapp_num, 0)
        INTO v_pred_aapp_num
        FROM aapp
       WHERE aapp_num = p_aapp_num;

      /*
      SELECT DECODE (COUNT (contract_type_code),
                     0, '',
                     'Cost Plus Base/Incentive Fee'
                    )
        INTO v_type_of_contract
        FROM aapp_bi_fees
       WHERE aapp_num = p_aapp_num;
      */

      SELECT DECODE (a.smb_setaside_id, NULL, 'none', b.smb_setaside_desc)
        INTO v_smb_setaside_desc
        FROM aapp a, lu_smb_setaside b
       WHERE a.smb_setaside_id = b.smb_setaside_id(+)
             AND a.aapp_num = p_aapp_num;

      IF v_pred_aapp_num != 0
      THEN
         SELECT contract_num, NVL ((years_base + years_option), 0)
           INTO v_pred_contract_num, v_pred_total_cnt_year
           FROM aapp
          WHERE aapp_num = v_pred_aapp_num;

         v_pred_cnt_date_start :=
            utility.fun_cnt_date (v_pred_aapp_num, v_pred_total_cnt_year, 'S');
         v_pred_cnt_date_end :=
            utility.fun_cnt_date (v_pred_aapp_num, v_pred_total_cnt_year, 'E');
         v_pred_cnt_last_year_days :=
                datediff ('DD', v_pred_cnt_date_start, v_pred_cnt_date_end)
                + 1;

         IF v_pred_cnt_last_year_days = 366
         THEN
            v_pred_cnt_days_percent := 100;
         ELSE
            v_pred_cnt_days_percent :=
                           ROUND (v_pred_cnt_last_year_days / 365 * 1000)
                           / 10;
         END IF;

         v_pred_cnt_whole_year_days :=
            datediff ('DD',
                      v_pred_cnt_date_start,
                      dateadd ('yy', 1, v_pred_cnt_date_start)
                     );
      END IF;

      OPEN p_recordset FOR
         SELECT utility.fun_get_region_desc (p_aapp_num) AS region_desc,
                a.aapp_num,
                aapp_program_activity (a.aapp_num) AS program_service,
                v_type_of_contract AS type_of_contract,
                v_smb_setaside_desc AS set_aside,
                utility.fun_cnt_date (a.aapp_num,
                                      1,
                                      'S'
                                     ) AS base_year_date_start,
                utility.fun_cnt_date (a.aapp_num,
                                      a.years_base,
                                      'E'
                                     ) AS base_year_date_end,
                years_option,
                utility.fun_get_contractor_name
                                          (v_pred_aapp_num)
                                                           AS contractor_name,
                v_pred_contract_num AS contract_num,
                utility.fun_cnt_date
                                 (v_pred_aapp_num,
                                  v_pred_total_cnt_year,
                                  'E'
                                 ) AS pred_cnt_date_end,
                v_pred_cnt_last_year_days AS pred_cnt_days,
                v_pred_cnt_whole_year_days AS pred_whole_days,
                v_pred_cnt_days_percent AS full_year_percent,
                v_pred_aapp_num AS pred_aapp_num
           FROM aapp a
          WHERE a.aapp_num = p_aapp_num;
   END prc_get_future_new_rpt;

   PROCEDURE prc_get_funew_workload_rpt (
      p_aapp_num          NUMBER,
      p_recordset   OUT   sys_refcursor
   )
   IS
      v_pred_aapp_num   aapp.aapp_num%TYPE;
   BEGIN
      SELECT NVL (pred_aapp_num, 0)
        INTO v_pred_aapp_num
        FROM aapp
       WHERE aapp_num = p_aapp_num;

      OPEN p_recordset FOR
         SELECT   0 AS contractyear, aapp_yearend.date_end AS yearenddate,
                  aapp_workload.workload_type_code AS workloadtypecode,
                  lu_workload_type.workload_type_desc AS workloadtypedesc,
                  VALUE, VALUE AS workloadvalue, vst_slots AS vstslots,
                  lu_workload_type.contract_type_code AS contracttypecode,
                  lu_workload_type.sort_order AS sortorder
             FROM aapp, aapp_workload, aapp_yearend, lu_workload_type
            WHERE aapp.aapp_num = aapp_workload.aapp_num
              AND aapp_workload.aapp_num = v_pred_aapp_num
              AND aapp_workload.workload_type_code =
                                           lu_workload_type.workload_type_code
              AND aapp_workload.contract_year = aapp_yearend.contract_year
              AND aapp_workload.aapp_num = aapp_yearend.aapp_num
              AND aapp_workload.contract_year =
                                           (SELECT MAX (contract_year)
                                              FROM aapp_workload
                                             WHERE aapp_num = v_pred_aapp_num)
         UNION
         SELECT   aapp_workload.contract_year AS contractyear,
                  aapp_yearend.date_end AS yearenddate,
                  aapp_workload.workload_type_code AS workloadtypecode,
                  lu_workload_type.workload_type_desc AS workloadtypedesc,
                  VALUE, VALUE AS workloadvalue, vst_slots AS vstslots,
                  lu_workload_type.contract_type_code AS contracttypecode,
                  lu_workload_type.sort_order AS sortorder
             FROM aapp, aapp_workload, aapp_yearend, lu_workload_type
            WHERE aapp.aapp_num = aapp_workload.aapp_num
              AND aapp_workload.aapp_num = p_aapp_num
              AND aapp_workload.workload_type_code =
                                           lu_workload_type.workload_type_code
              AND aapp_workload.contract_year = aapp_yearend.contract_year
              AND aapp_workload.aapp_num = aapp_yearend.aapp_num
         ORDER BY contractyear, sortorder;
   END prc_get_funew_workload_rpt;

   -- procedure for Budget Authority Requirements by funding office
   PROCEDURE prc_get_bar_fundingoff_rpt (
      p_fundingofficeno   IN       NUMBER,
      p_recordset         OUT      sys_refcursor
   )
   IS
      v_current_py   NUMBER;
   BEGIN
      SELECT utility.fun_getcurrntprogram_year
        INTO v_current_py
        FROM DUAL;

      OPEN p_recordset FOR
         SELECT          /*+rule*/
                DISTINCT a.funding_office_num,
                         (select max(fop_num)
                             from fop
                             where funding_office_num = a.funding_office_num and
                                   py = v_current_py)
                         as max_fop_num,
                         v_current_py AS py,
                         (SUM (x.ops_funds) - SUM (c.ops_expire_funds)
                         ) ops_funds,
                         (SUM (y.cra_funds) - SUM (d.cra_expire_funds)
                         ) cra_funds
                    FROM aapp a,
                         (SELECT   f1.aapp_num,
                                   NVL (SUM (f1.amount), 0) AS ops_funds
                              FROM fop f1
                             WHERE f1.cost_cat_id != 2
                          GROUP BY f1.aapp_num) x,
                         (SELECT   f2.aapp_num,
                                   NVL (SUM (f2.amount), 0) cra_funds
                              FROM fop f2
                             WHERE f2.cost_cat_id = 2
                          GROUP BY f2.aapp_num) y,
                         (SELECT   f3.aapp_num,
                                   MAX (f3.fop_num) AS ops_fop_num
                              FROM fop f3
                             WHERE f3.py = v_current_py
                                   AND f3.cost_cat_id != 2
                          GROUP BY f3.aapp_num) e,
                         (SELECT   f4.aapp_num,
                                   MAX (f4.fop_num) AS cra_fop_num
                              FROM fop f4
                             WHERE f4.py = v_current_py AND f4.cost_cat_id = 2
                          GROUP BY f4.aapp_num) g,
                         
                         (SELECT   fpn.aapp_num,
                                   NVL (SUM (oblig), 0) AS ops_expire_funds
                              FROM footprint_ncfms fpn
                             WHERE UPPER (fpn.fund_cat) = 'OPS'
                               AND FPN.APPROP_EXP_PY < v_current_py
                          GROUP BY fpn.aapp_num) c,
                          
                         (SELECT   fpn.aapp_num,
                                   NVL (SUM (oblig), 0) cra_expire_funds
                              FROM footprint_ncfms fpn
                             WHERE UPPER (fpn.fund_cat) = 'CRA'
                               AND FPN.APPROP_EXP_PY < v_current_py
                          GROUP BY fpn.aapp_num) d
                          
                          /* legacy - DOLAR$ footprint
                          (SELECT   fp.aapp_num,
                                   NVL (SUM (oblig), 0) AS ops_expire_funds
                              FROM footprint fp, rcc_code r
                             WHERE fp.rcc_fund = r.rcc_fund
                               AND fp.rcc_org = r.rcc_org
                               AND fp.fy = r.fy
                               AND UPPER (r.ops_cra) = 'OPS'
                               AND r.last_oblig_py < v_current_py
                          GROUP BY fp.aapp_num) c,
                          
                         (SELECT   fp.aapp_num,
                                   NVL (SUM (oblig), 0) cra_expire_funds
                              FROM footprint fp, rcc_code r
                             WHERE fp.rcc_fund = r.rcc_fund
                               AND fp.rcc_org = r.rcc_org
                               AND fp.fy = r.fy
                               AND UPPER (r.ops_cra) = 'CRA'
                               AND r.last_oblig_py < v_current_py
                          GROUP BY fp.aapp_num) d
                          */
                          
                   WHERE a.contract_status_id = 1
                     AND a.aapp_num = x.aapp_num(+)
                     AND a.aapp_num = y.aapp_num(+)
                     AND a.aapp_num = e.aapp_num(+)
                     AND a.aapp_num = g.aapp_num(+)
                     AND a.aapp_num = c.aapp_num(+)
                     AND a.aapp_num = d.aapp_num(+)
                     AND (       p_fundingofficeno > 0
                             AND a.funding_office_num = p_fundingofficeno
                          OR     p_fundingofficeno = 0
                             AND a.funding_office_num in (1,2,3,4,5,6,20,25)
                         )
                GROUP BY a.funding_office_num;
   END prc_get_bar_fundingoff_rpt;

   

   -- CCC BA Transfer Requirements Report
   -- CCC BA Transfer Requirements Report
   PROCEDURE prc_get_ccc_ba_tra_rpt (
      p_fund_office_no   IN       NUMBER,
      p_recordset_ops    OUT      sys_refcursor,
      p_recordset_cra    OUT      sys_refcursor
   )
   IS
      v_current_py   NUMBER;
      v_quarter_no   NUMBER;
   BEGIN
      -- get current program year
      SELECT utility.fun_getcurrntprogram_year_ccc
        INTO v_current_py
        FROM DUAL;

      -- get current quarter num
      SELECT utility.fun_get_quarter (SYSDATE, 'P')
        INTO v_quarter_no
        FROM DUAL;

      -- get cost category:  A
      OPEN p_recordset_ops FOR
         SELECT   l.cost_cat_code,
                     l.cost_cat_desc
                  || ' (Incl Program Direction)' AS cost_cat_desc,
                  a.a_mount, p.transfer_percent
             FROM lu_cost_cat l,
                  ba_transfer_percent p,
                  (SELECT 'A' AS cost_cat_code,
                          NVL (SUM (f.amount), 0) AS a_mount
                     FROM aapp a, fop f
                    WHERE a.aapp_num = f.aapp_num
                      AND a.agreement_type_code = 'CC'
                      AND f.py = v_current_py
                      AND a.funding_office_num = p_fund_office_no
                      AND f.cost_cat_id >= 10
                      AND f.cost_cat_id <= 38) a
            WHERE l.cost_cat_code = a.cost_cat_code
              AND l.cost_cat_id = p.cost_cat_id
              AND p.quarter = v_quarter_no
         -- get cost category:  B2
         UNION
         SELECT   l.cost_cat_code, l.cost_cat_desc, b2.a_mount,
                  p.transfer_percent
             FROM lu_cost_cat l,
                  ba_transfer_percent p,
                  (SELECT 'B2' AS cost_cat_code,
                          NVL (SUM (f.amount), 0) AS a_mount
                     FROM aapp a, fop f
                    WHERE a.aapp_num = f.aapp_num
                      AND a.agreement_type_code = 'CC'
                      AND f.py = v_current_py
                      AND a.funding_office_num = p_fund_office_no
                      AND f.cost_cat_id = 3) b2
            WHERE l.cost_cat_code = b2.cost_cat_code
              AND l.cost_cat_id = p.cost_cat_id
              AND p.quarter = v_quarter_no
         -- get cost category:  B3
         UNION
         SELECT   l.cost_cat_code, l.cost_cat_desc, b3.a_mount,
                  p.transfer_percent
             FROM lu_cost_cat l,
                  ba_transfer_percent p,
                  (SELECT 'B3' AS cost_cat_code,
                          NVL (SUM (f.amount), 0) AS a_mount
                     FROM aapp a, fop f
                    WHERE a.aapp_num = f.aapp_num
                      AND a.agreement_type_code = 'CC'
                      AND f.py = v_current_py
                      AND a.funding_office_num = p_fund_office_no
                      AND f.cost_cat_id = 4) b3
            WHERE l.cost_cat_code = b3.cost_cat_code
              AND l.cost_cat_id = p.cost_cat_id
              AND p.quarter = v_quarter_no
         -- get cost category:  B4
         UNION
         SELECT   l.cost_cat_code, l.cost_cat_desc, b4.a_mount,
                  p.transfer_percent
             FROM lu_cost_cat l,
                  ba_transfer_percent p,
                  (SELECT 'B4' AS cost_cat_code,
                          NVL (SUM (f.amount), 0) AS a_mount
                     FROM aapp a, fop f
                    WHERE a.aapp_num = f.aapp_num
                      AND a.agreement_type_code = 'CC'
                      AND f.py = v_current_py
                      AND a.funding_office_num = p_fund_office_no
                      AND f.cost_cat_id = 5) b4
            WHERE l.cost_cat_code = b4.cost_cat_code
              AND l.cost_cat_id = p.cost_cat_id
              AND p.quarter = v_quarter_no
         -- get cost category: C1
         UNION
         SELECT   l.cost_cat_code, l.cost_cat_desc, c1.a_mount,
                  p.transfer_percent
             FROM lu_cost_cat l,
                  ba_transfer_percent p,
                  (SELECT 'C1' AS cost_cat_code,
                          NVL (SUM (f.amount), 0) AS a_mount
                     FROM aapp a, fop f
                    WHERE a.aapp_num = f.aapp_num
                      AND a.agreement_type_code = 'CC'
                      AND f.py = v_current_py
                      AND a.funding_office_num = p_fund_office_no
                      AND f.cost_cat_id = 6) c1
            WHERE l.cost_cat_code = c1.cost_cat_code
              AND l.cost_cat_id = p.cost_cat_id
              AND p.quarter = v_quarter_no
         -- get cost category: C2
         UNION
         SELECT   l.cost_cat_code, l.cost_cat_desc, c2.a_mount,
                  p.transfer_percent
             FROM lu_cost_cat l,
                  ba_transfer_percent p,
                  (SELECT 'C2' AS cost_cat_code,
                          NVL (SUM (f.amount), 0) AS a_mount
                     FROM aapp a, fop f
                    WHERE a.aapp_num = f.aapp_num
                      AND a.agreement_type_code = 'CC'
                      AND f.py = v_current_py
                      AND a.funding_office_num = p_fund_office_no
                      AND f.cost_cat_id = 7) c2
            WHERE l.cost_cat_code = c2.cost_cat_code
              AND l.cost_cat_id = p.cost_cat_id
              AND p.quarter = v_quarter_no
         -- get cost category: D
         UNION
         SELECT   l.cost_cat_code, l.cost_cat_desc, d.a_mount,
                  p.transfer_percent
             FROM lu_cost_cat l,
                  ba_transfer_percent p,
                  (SELECT 'D' AS cost_cat_code,
                          NVL (SUM (f.amount), 0) AS a_mount
                     FROM aapp a, fop f
                    WHERE a.aapp_num = f.aapp_num
                      AND a.agreement_type_code = 'CC'
                      AND f.py = v_current_py
                      AND a.funding_office_num = p_fund_office_no
                      AND f.cost_cat_id = 8) d
            WHERE l.cost_cat_code = d.cost_cat_code
              AND l.cost_cat_id = p.cost_cat_id
              AND p.quarter = v_quarter_no
         -- get cost category: S
         UNION
         SELECT   l.cost_cat_code, l.cost_cat_desc, s.a_mount,
                  p.transfer_percent
             FROM lu_cost_cat l,
                  ba_transfer_percent p,
                  (SELECT 'S' AS cost_cat_code,
                          NVL (SUM (f.amount), 0) AS a_mount
                     FROM aapp a, fop f
                    WHERE a.aapp_num = f.aapp_num
                      AND a.agreement_type_code = 'CC'
                      AND f.py = v_current_py
                      AND a.funding_office_num = p_fund_office_no
                      AND f.cost_cat_id = 9) s
            WHERE l.cost_cat_code = s.cost_cat_code
              AND l.cost_cat_id = p.cost_cat_id
              AND p.quarter = v_quarter_no
         ORDER BY 1;

      -- get CRA
      OPEN p_recordset_cra FOR
         SELECT   'A', c_py.a_mount, p.transfer_percent
             FROM ba_transfer_percent p,
                  (SELECT NVL (SUM (f.amount), 0) AS a_mount
                     FROM aapp a, fop f
                    WHERE a.aapp_num = f.aapp_num
                      AND a.agreement_type_code = 'CC'
                      AND f.py_cra_budget = v_current_py
                      AND a.funding_office_num = p_fund_office_no
                      AND f.cost_cat_id = 2) c_py
            WHERE p.cost_cat_id = 2 AND p.quarter = v_quarter_no
         UNION
         SELECT   'B', p_py.a_mount, p.transfer_percent
             FROM ba_transfer_percent p,
                  (SELECT NVL (SUM (f.amount), 0) AS a_mount
                     FROM aapp a, fop f
                    WHERE a.aapp_num = f.aapp_num
                      AND a.agreement_type_code = 'CC'
                      AND f.py_cra_budget = v_current_py - 1
                      AND a.funding_office_num = p_fund_office_no
                      AND f.cost_cat_id = 2) p_py
            WHERE p.cost_cat_id = 2 AND p.quarter = v_quarter_no
         UNION
         SELECT   'C', b_py.a_mount, p.transfer_percent
             FROM ba_transfer_percent p,
                  (SELECT NVL (SUM (f.amount), 0) AS a_mount
                     FROM aapp a, fop f
                    WHERE a.aapp_num = f.aapp_num
                      AND a.agreement_type_code = 'CC'
                      AND f.py_cra_budget = v_current_py - 2
                      AND a.funding_office_num = p_fund_office_no
                      AND f.cost_cat_id = 2) b_py
            WHERE p.cost_cat_id = 2 AND p.quarter = v_quarter_no
         ORDER BY 1 DESC;
   END prc_get_ccc_ba_tra_rpt;

   -- get aapps, centers for program operating plan detail
   PROCEDURE prc_get_progop_detail_list_rpt (
      p_in                  IN       NUMBER,
      p_recordset_aapps     OUT      sys_refcursor,
      p_recordset_centers   OUT      sys_refcursor
   )
   IS
   BEGIN
      -- get aapps
      OPEN p_recordset_aapps FOR
         SELECT   aapp_num, a.center_id
             FROM aapp a, lu_funding_office l
            WHERE a.funding_office_num = l.funding_office_num
              AND l.office_type = 'FED'
         ORDER BY a.aapp_num;

      -- get centers
      OPEN p_recordset_centers FOR
         SELECT   a.aapp_num, c.center_name, a.center_id
             FROM aapp a, center c, lu_funding_office l
            WHERE a.center_id = c.center_id
              AND a.funding_office_num = l.funding_office_num
              AND l.office_type = 'FED'
         ORDER BY c.center_name;
   END prc_get_progop_detail_list_rpt;

   -- get program operating plan detail data
   PROCEDURE prc_get_progop_detail_data_rpt (
      p_py                  IN       NUMBER,
      p_aapp                IN       NUMBER,
      p_center              IN       NUMBER,
      p_fundofficenum       IN       NUMBER,
      p_dol_region          IN       NUMBER,
      p_recordset_progrop   OUT      sys_refcursor
   )
   IS
   BEGIN
      IF p_aapp > 0
      THEN                                             -- if p_aapp passed in
         OPEN p_recordset_progrop FOR
            -- get all OPS data
            SELECT   a.aapp_num AS aapp_num, c.center_name AS center_name,
                     a.funding_office_num AS fundingoffnum,
                     o.funding_office_desc funding_office_desc,
                     CASE
                        WHEN INSTR (x.cost_cat_code,
                                    'A '
                                   ) > 0
                           THEN 'A'
                        ELSE cost_cat_code
                     END AS cost_category_code,
                     CASE
                        WHEN INSTR (x.cost_cat_code,
                                    'A '
                                   ) > 0
                           THEN REPLACE (x.cost_cat_code, 'A ', '')
                        ELSE ''
                     END AS cost_subcategory_id,
                     CASE
                        WHEN INSTR (x.cost_cat_code, 'A ') >
                                                           0
                           THEN 'Center Operations'
                        ELSE cost_cat_desc
                     END AS cost_cat_desc,
                     CASE
                        WHEN INSTR (x.cost_cat_code,
                                    'A ') > 0
                           THEN x.cost_cat_desc
                        ELSE ''
                     END AS cost_subcategory,
                     x.py_cra_budget AS py_cra_budget, x.py AS py,
                     x.amount AS amount, x.fop_num AS fop_num,
                     x.date_executed AS date_executed,
                     x.fop_description AS fop_description
                FROM aapp a,
                     center c,
                     lu_funding_office o,
                     (SELECT   f.aapp_num, l.cost_cat_code, l.cost_cat_desc,
                               f.py_cra_budget, f.py, f.amount, f.fop_num,
                               f.date_executed, f.fop_description
                          FROM fop f, lu_cost_cat l
                         WHERE f.cost_cat_id = l.cost_cat_id
                           AND f.py = p_py
                           AND f.cost_cat_id != 2
                      GROUP BY f.aapp_num,
                               l.cost_cat_code,
                               l.cost_cat_desc,
                               f.py_cra_budget,
                               f.amount,
                               f.py,
                               f.amount,
                               f.fop_num,
                               f.date_executed,
                               f.fop_description) x
               WHERE a.aapp_num = x.aapp_num
                 AND a.center_id = c.center_id
                 AND a.funding_office_num = o.funding_office_num
                 AND a.agreement_type_code = 'CC'
                 AND o.office_type = 'FED'
                 AND a.aapp_num = p_aapp
            UNION
            -- get B1 information
            SELECT   a.aapp_num AS aapp_num, c.center_name AS center_name,
                     a.funding_office_num AS fundingoffnum,
                     o.funding_office_desc AS funding_office_desc,
                     CASE
                        WHEN INSTR (y.cost_cat_code,
                                    'A '
                                   ) > 0
                           THEN 'A'
                        ELSE cost_cat_code
                     END AS cost_category_code,
                     CASE
                        WHEN INSTR (y.cost_cat_code,
                                    'A '
                                   ) > 0
                           THEN REPLACE (y.cost_cat_code, 'A ', '')
                        ELSE ''
                     END AS cost_subcategory_id,
                     CASE
                        WHEN INSTR (y.cost_cat_code, 'A ') >
                                                           0
                           THEN 'Center Operations'
                        ELSE cost_cat_desc
                     END AS cost_cat_desc,
                     CASE
                        WHEN INSTR (y.cost_cat_code,
                                    'A ') > 0
                           THEN y.cost_cat_desc
                        ELSE ''
                     END AS cost_subcategory,
                     y.py_cra_budget AS py_cra_budget, y.py AS py,
                     y.amount AS amount, y.fop_num,
                     y.date_executed AS date_executed,
                     y.fop_description AS fop_description
                FROM aapp a,
                     center c,
                     lu_funding_office o,
                     (SELECT   f.aapp_num, l.cost_cat_code, l.cost_cat_desc,
                               f.py_cra_budget, f.py, f.amount, f.fop_num,
                               f.date_executed, f.fop_description
                          FROM fop f, lu_cost_cat l
                         WHERE f.cost_cat_id = l.cost_cat_id
                           AND (   f.py_cra_budget = p_py
                                OR f.py_cra_budget = p_py - 1
                                OR f.py_cra_budget = p_py - 2
                               )
                           AND f.cost_cat_id = 2
                      GROUP BY f.aapp_num,
                               l.cost_cat_code,
                               l.cost_cat_desc,
                               f.py_cra_budget,
                               f.amount,
                               f.py,
                               f.amount,
                               f.fop_num,
                               f.date_executed,
                               f.fop_description) y
               WHERE a.aapp_num = y.aapp_num
                 AND a.center_id = c.center_id
                 AND a.funding_office_num = o.funding_office_num
                 AND a.agreement_type_code = 'CC'
                 AND o.office_type = 'FED'
                 AND a.aapp_num = p_aapp
            ORDER BY aapp_num,
                     cost_subcategory_id,
                     funding_office_desc,
                     center_name,
                     cost_category_code,
                     cost_cat_desc,
                     py,
                     fop_num;
      ELSE                                      --- if other parameters passed
         OPEN p_recordset_progrop FOR
            SELECT   a.aapp_num AS aapp_num, c.center_name AS center_name,
                     a.funding_office_num AS fundingoffnum,
                     o.funding_office_desc funding_office_desc,
                     CASE
                        WHEN INSTR (x.cost_cat_code,
                                    'A '
                                   ) > 0
                           THEN 'A'
                        ELSE cost_cat_code
                     END AS cost_category_code,
                     CASE
                        WHEN INSTR (x.cost_cat_code,
                                    'A '
                                   ) > 0
                           THEN REPLACE (x.cost_cat_code, 'A ', '')
                        ELSE ''
                     END AS cost_subcategory_id,
                     CASE
                        WHEN INSTR (x.cost_cat_code, 'A ') >
                                                           0
                           THEN 'Center Operations'
                        ELSE cost_cat_desc
                     END AS cost_cat_desc,
                     CASE
                        WHEN INSTR (x.cost_cat_code,
                                    'A ') > 0
                           THEN x.cost_cat_desc
                        ELSE ''
                     END AS cost_subcategory,
                     x.py_cra_budget AS py_cra_budget, x.py AS py,
                     x.amount AS amount, x.fop_num AS fop_num,
                     x.date_executed AS date_executed,
                     x.fop_description AS fop_description
                FROM aapp a,
                     center c,
                     lu_funding_office o,
                     lu_state s,
                     (SELECT   f.aapp_num, l.cost_cat_code, l.cost_cat_desc,
                               f.py_cra_budget, f.py, f.amount, f.fop_num,
                               f.date_executed, f.fop_description
                          FROM fop f, lu_cost_cat l
                         WHERE f.cost_cat_id = l.cost_cat_id
                           AND f.py = p_py
                           AND f.cost_cat_id != 2
                      GROUP BY f.aapp_num,
                               l.cost_cat_code,
                               l.cost_cat_desc,
                               f.py_cra_budget,
                               f.amount,
                               f.py,
                               f.amount,
                               f.fop_num,
                               f.date_executed,
                               f.fop_description) x
               WHERE a.aapp_num = x.aapp_num
                 AND a.center_id = c.center_id
                 AND a.funding_office_num = o.funding_office_num
                 AND a.agreement_type_code = 'CC'
                 AND o.office_type = 'FED'
                 AND a.state_abbr = s.state_abbr
                 AND (       p_fundofficenum > 0
                         AND a.funding_office_num = p_fundofficenum
                      OR p_fundofficenum = 0 AND o.office_type = 'FED'
                     )
                 AND (   p_dol_region > 0 AND s.region_num = p_dol_region
                      OR p_dol_region = 0 AND s.region_num <= 6
                     )
            UNION
            -- get B1 information
            SELECT   a.aapp_num AS aapp_num, c.center_name AS center_name,
                     a.funding_office_num AS fundingoffnum,
                     o.funding_office_desc AS funding_office_desc,
                     CASE
                        WHEN INSTR (y.cost_cat_code,
                                    'A '
                                   ) > 0
                           THEN 'A'
                        ELSE cost_cat_code
                     END AS cost_category_code,
                     CASE
                        WHEN INSTR (y.cost_cat_code,
                                    'A '
                                   ) > 0
                           THEN REPLACE (y.cost_cat_code, 'A ', '')
                        ELSE ''
                     END AS cost_subcategory_id,
                     CASE
                        WHEN INSTR (y.cost_cat_code, 'A ') >
                                                           0
                           THEN 'Center Operations'
                        ELSE cost_cat_desc
                     END AS cost_cat_desc,
                     CASE
                        WHEN INSTR (y.cost_cat_code,
                                    'A ') > 0
                           THEN y.cost_cat_desc
                        ELSE ''
                     END AS cost_subcategory,
                     y.py_cra_budget AS py_cra_budget, y.py AS py,
                     y.amount AS amount, y.fop_num,
                     y.date_executed AS date_executed,
                     y.fop_description AS fop_description
                FROM aapp a,
                     center c,
                     lu_funding_office o,
                     lu_state s,
                     (SELECT   f.aapp_num, l.cost_cat_code, l.cost_cat_desc,
                               f.py_cra_budget, f.py, f.amount, f.fop_num,
                               f.date_executed, f.fop_description
                          FROM fop f, lu_cost_cat l
                         WHERE f.cost_cat_id = l.cost_cat_id
                           AND (   f.py_cra_budget = p_py
                                OR f.py_cra_budget = p_py - 1
                                OR f.py_cra_budget = p_py - 2
                               )
                           AND f.cost_cat_id = 2
                      GROUP BY f.aapp_num,
                               l.cost_cat_code,
                               l.cost_cat_desc,
                               f.py_cra_budget,
                               f.amount,
                               f.py,
                               f.amount,
                               f.fop_num,
                               f.date_executed,
                               f.fop_description) y
               WHERE a.aapp_num = y.aapp_num
                 AND a.center_id = c.center_id
                 AND a.funding_office_num = o.funding_office_num
                 AND a.agreement_type_code = 'CC'
                 AND o.office_type = 'FED'
                 AND a.state_abbr = s.state_abbr
                 AND (       p_fundofficenum > 0
                         AND a.funding_office_num = p_fundofficenum
                      OR p_fundofficenum = 0 AND o.office_type = 'FED'
                     )
                 AND (   p_dol_region > 0 AND s.region_num = p_dol_region
                      OR p_dol_region = 0 AND s.region_num <= 6
                     )
            ORDER BY aapp_num,
                     cost_subcategory_id,
                     funding_office_desc,
                     center_name,
                     cost_category_code,
                     cost_cat_desc,
                     py,
                     fop_num;
      END IF;
   END prc_get_progop_detail_data_rpt;

   -- get FOP CCC Budget report data
   PROCEDURE prc_get_fop_ccc_bud_rpt (
      p_py                    IN       NUMBER,
      p_aapp                  IN       NUMBER,
      p_center                IN       NUMBER,
      p_fundofficenum         IN       NUMBER,
      p_dol_region            IN       NUMBER,
      p_recordset_fopcccbud   OUT      sys_refcursor
   )
   IS
      v_aapp   NUMBER;
   BEGIN
      v_aapp := 0;

      IF p_aapp != 0
      THEN
         v_aapp := p_aapp;
      ELSIF p_center != 0
      THEN
         v_aapp := p_center;
      END IF;

      IF v_aapp > 0
      THEN                                              -- if p_aapp passed in
         OPEN p_recordset_fopcccbud FOR
            SELECT   a.aapp_num AS aapp_num, c.center_name AS center_name,
                     a.funding_office_num AS fundingoffnum,
                     o.funding_office_desc fundingofficedesc,
                     l.cost_cat_code, l.cost_cat_desc, x.amount AS amount,
                     p_py AS py
                FROM aapp a,
                     center c,
                     lu_funding_office o,
                     lu_cost_cat l,
                     (SELECT   f.aapp_num, f.cost_cat_id,
                               NVL (SUM (f.amount), 0) AS amount
                          FROM fop f
                         WHERE f.py = p_py AND f.cost_cat_id != 2
                      GROUP BY f.aapp_num, f.cost_cat_id) x
               WHERE a.aapp_num = x.aapp_num
                 AND a.center_id = c.center_id
                 AND a.funding_office_num = o.funding_office_num
                 AND l.cost_cat_id = x.cost_cat_id
                 AND a.agreement_type_code = 'CC'
                 AND o.office_type = 'FED'
                 AND a.aapp_num = v_aapp
            UNION
            -- get B1 current py information
            SELECT   a.aapp_num AS aapp_num, c.center_name AS center_name,
                     a.funding_office_num AS fundingoffnum,
                     o.funding_office_desc fundingofficedesc, l.cost_cat_code,
                     l.cost_cat_desc, y.amount AS amount, p_py AS py
                FROM aapp a,
                     center c,
                     lu_funding_office o,
                     lu_cost_cat l,
                     (SELECT   f.aapp_num, f.cost_cat_id,
                               NVL (SUM (f.amount), 0) AS amount
                          FROM fop f
                         WHERE py_cra_budget = p_py AND f.cost_cat_id = 2
                      GROUP BY f.aapp_num, f.cost_cat_id) y
               WHERE a.aapp_num = y.aapp_num
                 AND a.center_id = c.center_id
                 AND a.funding_office_num = o.funding_office_num
                 AND l.cost_cat_id = y.cost_cat_id
                 AND a.agreement_type_code = 'CC'
                 AND o.office_type = 'FED'
                 AND a.aapp_num = v_aapp
            UNION
            -- get B1 previous py information
            SELECT   a.aapp_num AS aapp_num, c.center_name AS center_name,
                     a.funding_office_num AS fundingoffnum,
                     o.funding_office_desc fundingofficedesc, l.cost_cat_code,
                     l.cost_cat_desc, z.amount AS amount, p_py - 1 AS py
                FROM aapp a,
                     center c,
                     lu_funding_office o,
                     lu_cost_cat l,
                     (SELECT   f.aapp_num, f.cost_cat_id,
                               NVL (SUM (f.amount), 0) AS amount
                          FROM fop f
                         WHERE py_cra_budget = p_py - 1 AND f.cost_cat_id = 2
                      GROUP BY f.aapp_num, f.cost_cat_id) z
               WHERE a.aapp_num = z.aapp_num
                 AND a.center_id = c.center_id
                 AND a.funding_office_num = o.funding_office_num
                 AND l.cost_cat_id = z.cost_cat_id
                 AND a.agreement_type_code = 'CC'
                 AND o.office_type = 'FED'
                 AND a.aapp_num = v_aapp
            UNION
            -- get B1 previous two py information
            SELECT   a.aapp_num AS aapp_num, c.center_name AS center_name,
                     a.funding_office_num AS fundingoffnum,
                     o.funding_office_desc fundingofficedesc, l.cost_cat_code,
                     l.cost_cat_desc, w.amount AS amount, p_py - 2 AS py
                FROM aapp a,
                     center c,
                     lu_funding_office o,
                     lu_cost_cat l,
                     (SELECT   f.aapp_num, f.cost_cat_id,
                               NVL (SUM (f.amount), 0) AS amount
                          FROM fop f
                         WHERE py_cra_budget = p_py - 2 AND f.cost_cat_id = 2
                      GROUP BY f.aapp_num, f.cost_cat_id) w
               WHERE a.aapp_num = w.aapp_num
                 AND a.center_id = c.center_id
                 AND a.funding_office_num = o.funding_office_num
                 AND l.cost_cat_id = w.cost_cat_id
                 AND a.agreement_type_code = 'CC'
                 AND o.office_type = 'FED'
                 AND a.aapp_num = v_aapp
            ORDER BY 1, 5, 8;
      ELSE
         OPEN p_recordset_fopcccbud FOR
            -- get OPS data
            SELECT   a.aapp_num AS aapp_num, c.center_name AS center_name,
                     a.funding_office_num AS fundingoffnum,
                     o.funding_office_desc fundingofficedesc,
                     l.cost_cat_code, l.cost_cat_desc, x.amount AS amount,
                     p_py AS py
                FROM aapp a,
                     center c,
                     lu_funding_office o,
                     lu_cost_cat l,
                     lu_state s,
                     (SELECT   f.aapp_num, f.cost_cat_id,
                               NVL (SUM (f.amount), 0) AS amount
                          FROM fop f
                         WHERE f.py = p_py AND f.cost_cat_id != 2
                      GROUP BY f.aapp_num, f.cost_cat_id) x
               WHERE a.aapp_num = x.aapp_num
                 AND a.center_id = c.center_id
                 AND a.funding_office_num = o.funding_office_num
                 AND l.cost_cat_id = x.cost_cat_id
                 AND a.agreement_type_code = 'CC'
                 AND o.office_type = 'FED'
                 AND a.state_abbr = s.state_abbr
                 AND (       p_fundofficenum > 0
                         AND a.funding_office_num = p_fundofficenum
                      OR p_fundofficenum = 0 AND o.office_type = 'FED'
                     )
                 AND (   p_dol_region > 0 AND s.region_num = p_dol_region
                      OR p_dol_region = 0 AND s.region_num <= 6
                     )
            GROUP BY a.aapp_num,
                     c.center_name,
                     a.funding_office_num,
                     o.funding_office_desc,
                     l.cost_cat_code,
                     l.cost_cat_desc,
                     x.amount
            UNION
            -- get CRA data (Current PY)
            SELECT   a.aapp_num AS aapp_num, c.center_name AS center_name,
                     a.funding_office_num AS fundingoffnum,
                     o.funding_office_desc fundingofficedesc, l.cost_cat_code,
                     l.cost_cat_desc, y.amount AS amount, p_py AS py
                FROM aapp a,
                     center c,
                     lu_funding_office o,
                     lu_cost_cat l,
                     lu_state s,
                     (SELECT   f.aapp_num, f.cost_cat_id,
                               NVL (SUM (f.amount), 0) AS amount
                          FROM fop f
                         WHERE py_cra_budget = p_py AND f.cost_cat_id = 2
                      GROUP BY f.aapp_num, f.cost_cat_id) y
               WHERE a.aapp_num = y.aapp_num
                 AND a.center_id = c.center_id
                 AND a.funding_office_num = o.funding_office_num
                 AND l.cost_cat_id = y.cost_cat_id
                 AND a.agreement_type_code = 'CC'
                 AND o.office_type = 'FED'
                 AND a.state_abbr = s.state_abbr
                 AND (       p_fundofficenum > 0
                         AND a.funding_office_num = p_fundofficenum
                      OR p_fundofficenum = 0 AND o.office_type = 'FED'
                     )
                 AND (   p_dol_region > 0 AND s.region_num = p_dol_region
                      OR p_dol_region = 0 AND s.region_num <= 6
                     )
            GROUP BY a.aapp_num,
                     c.center_name,
                     a.funding_office_num,
                     o.funding_office_desc,
                     l.cost_cat_code,
                     l.cost_cat_desc,
                     y.amount
            UNION
            -- get CRA data (Previous PY)
            SELECT   a.aapp_num AS aapp_num, c.center_name AS center_name,
                     a.funding_office_num AS fundingoffnum,
                     o.funding_office_desc fundingofficedesc, l.cost_cat_code,
                     l.cost_cat_desc, z.amount AS amount, p_py - 1 AS py
                FROM aapp a,
                     center c,
                     lu_funding_office o,
                     lu_cost_cat l,
                     lu_state s,
                     (SELECT   f.aapp_num, f.cost_cat_id,
                               NVL (SUM (f.amount), 0) AS amount
                          FROM fop f
                         WHERE py_cra_budget = p_py - 1 AND f.cost_cat_id = 2
                      GROUP BY f.aapp_num, f.cost_cat_id) z
               WHERE a.aapp_num = z.aapp_num
                 AND a.center_id = c.center_id
                 AND a.funding_office_num = o.funding_office_num
                 AND l.cost_cat_id = z.cost_cat_id
                 AND a.agreement_type_code = 'CC'
                 AND o.office_type = 'FED'
                 AND a.state_abbr = s.state_abbr
                 AND (       p_fundofficenum > 0
                         AND a.funding_office_num = p_fundofficenum
                      OR p_fundofficenum = 0 AND o.office_type = 'FED'
                     )
                 AND (   p_dol_region > 0 AND s.region_num = p_dol_region
                      OR p_dol_region = 0 AND s.region_num <= 6
                     )
            GROUP BY a.aapp_num,
                     c.center_name,
                     a.funding_office_num,
                     o.funding_office_desc,
                     l.cost_cat_code,
                     l.cost_cat_desc,
                     z.amount
            UNION
            -- get CRA data (Previou two PY)
            SELECT   a.aapp_num AS aapp_num, c.center_name AS center_name,
                     a.funding_office_num AS fundingoffnum,
                     o.funding_office_desc fundingofficedesc, l.cost_cat_code,
                     l.cost_cat_desc, w.amount AS amount, p_py - 2 AS py
                FROM aapp a,
                     center c,
                     lu_funding_office o,
                     lu_cost_cat l,
                     lu_state s,
                     (SELECT   f.aapp_num, f.cost_cat_id,
                               NVL (SUM (f.amount), 0) AS amount
                          FROM fop f
                         WHERE py_cra_budget = p_py - 2 AND f.cost_cat_id = 2
                      GROUP BY f.aapp_num, f.cost_cat_id) w
               WHERE a.aapp_num = w.aapp_num
                 AND a.center_id = c.center_id
                 AND a.funding_office_num = o.funding_office_num
                 AND l.cost_cat_id = w.cost_cat_id
                 AND a.agreement_type_code = 'CC'
                 AND o.office_type = 'FED'
                 AND a.state_abbr = s.state_abbr
                 AND (       p_fundofficenum > 0
                         AND a.funding_office_num = p_fundofficenum
                      OR p_fundofficenum = 0 AND o.office_type = 'FED'
                     )
                 AND (   p_dol_region > 0 AND s.region_num = p_dol_region
                      OR p_dol_region = 0 AND s.region_num <= 6
                     )
            GROUP BY a.aapp_num,
                     c.center_name,
                     a.funding_office_num,
                     o.funding_office_desc,
                     l.cost_cat_code,
                     l.cost_cat_desc,
                     w.amount
            ORDER BY 1, 5, 8;
      END IF;
   END prc_get_fop_ccc_bud_rpt;

   -- get Budget Authority requirements by AAPP report data
   PROCEDURE prc_get_bud_auth_aapp_rpt (
      p_status                   IN       VARCHAR,
      p_fundofficenum            IN       NUMBER,
      p_recordset_budauth_aapp   OUT      sys_refcursor
   )
   IS
      v_current_py   NUMBER;
   BEGIN
      -- get current program year
      SELECT utility.fun_getcurrntprogram_year
        INTO v_current_py
        FROM DUAL;

      --get  all aapps for agreement type is not CC
      OPEN p_recordset_budauth_aapp FOR
         SELECT /*rule*/ DISTINCT a.aapp_num AS aappnum,
                          aapp_program_activity
                                               (a.aapp_num)
                                                           AS programactivity,
                          a.venue AS venue,
                          a.contract_status_id AS contract_status_i,
                          cr.center_name AS center_name,
                          c.contractor_name AS contractorname,
                          a.contract_num AS contractnumber,
                          a.date_start AS datestart, y.date_end AS dateend,
                          NVL
                             (funding_cumm_ops.fundingcummops,
                              0
                             ) AS fundingcummops,
                          NVL
                             (funding_cumm_cra.fundingcummcra,
                              0
                             ) AS fundingcummcra,
                          (  NVL (funding_cumm_ops.fundingcummops, 0)
                           + NVL (funding_cumm_cra.fundingcummcra, 0)
                          ) AS fundingcummtotal,
                          NVL
                             (funding_expired_ops.fundingexpiredops,
                              0
                             ) AS fundingexpiredops,
                          NVL
                             (funding_expired_cra.fundingexpiredcra,
                              0
                             ) AS fundingexpiredcra,
                          (  NVL (funding_expired_ops.fundingexpiredops, 0)
                           + NVL (funding_expired_cra.fundingexpiredcra, 0)
                          ) AS fundingexpiredtotal,
                          (  NVL (funding_cumm_ops.fundingcummops, 0)
                           - NVL (funding_expired_ops.fundingexpiredops, 0)
                          ) AS fundingactiveops,
                          (  NVL (funding_cumm_cra.fundingcummcra, 0)
                           - NVL (funding_expired_cra.fundingexpiredcra, 0)
                          ) AS fundingactivecra,
                          (  NVL (funding_cumm_ops.fundingcummops, 0)
                           + NVL (funding_cumm_cra.fundingcummcra, 0)
                           - NVL (funding_expired_ops.fundingexpiredops, 0)
                           - NVL (funding_expired_cra.fundingexpiredcra, 0)
                          ) AS fundingactivetotal,
                          
                          -- note ops
                          CASE
                             WHEN   NVL
                                       (funding_cumm_ops.fundingcummops,
                                        0
                                       )
                                  - NVL
                                       (funding_expired_ops.fundingexpiredops,
                                        0
                                       ) < 0
                                THEN '1/'
                             ELSE NULL
                          END AS noteops,
                          
                          -- note cra
                          CASE
                             WHEN   NVL
                                       (funding_cumm_cra.fundingcummcra,
                                        0
                                       )
                                  - NVL
                                       (funding_expired_cra.fundingexpiredcra,
                                        0
                                       ) < 0
                                THEN '2/'
                             ELSE NULL
                          END AS notecra,
                          a.funding_office_num
                    FROM aapp a,
                         contractor c,
                         center cr,
                         (SELECT   yr.aapp_num, MAX (yr.date_end) AS date_end
                              FROM aapp_yearend yr
                          GROUP BY yr.aapp_num) y,
                         
                         -- funding cumm ops
                         (SELECT   f.aapp_num,
                                   NVL (SUM (amount), 0) AS fundingcummops
                              FROM fop f
                             WHERE f.cost_cat_id != 2
                          GROUP BY f.aapp_num) funding_cumm_ops,
                         
                         -- funding cumm cra
                         (SELECT   f.aapp_num,
                                   NVL (SUM (amount), 0) AS fundingcummcra
                              FROM fop f
                             WHERE f.cost_cat_id = 2
                          GROUP BY f.aapp_num) funding_cumm_cra,
                         
                         -- expired OPS funding (updated for NCFMS)
                         (SELECT   b.aapp_num,
                                   NVL (SUM (oblig), 0) AS fundingexpiredops
                              FROM footprint_ncfms fpn, aapp b
                             WHERE fpn.aapp_num = b.aapp_num
                               AND UPPER (fpn.fund_cat) = 'OPS'
                               AND fpn.approp_exp_py < v_current_py
                          GROUP BY b.aapp_num) funding_expired_ops,
                          
                         
                         -- expired CRA funding (unpdated for NCFMS)
                         (SELECT   b.aapp_num,
                                   NVL (SUM (oblig), 0) AS fundingexpiredcra
                              FROM footprint_ncfms fpn, aapp b
                             WHERE fpn.aapp_num = b.aapp_num
                               AND UPPER (fpn.fund_cat) = 'CRA'
                               AND fpn.approp_exp_py < v_current_py
                          GROUP BY b.aapp_num) funding_expired_cra
                        
                          
                   WHERE a.contractor_id = c.contractor_id(+)
                     AND a.center_id = cr.center_id(+)
                     AND agreement_type_code != 'CC'
                     AND a.aapp_num = funding_cumm_ops.aapp_num(+)
                     AND a.aapp_num = funding_cumm_cra.aapp_num(+)
                     AND a.aapp_num = funding_expired_ops.aapp_num(+)
                     AND a.aapp_num = funding_expired_cra.aapp_num(+)
                     AND a.aapp_num = y.aapp_num(+)
                     AND a.funding_office_num = p_fundofficenum
                     AND (   (p_status = '0' AND a.contract_status_id = 0)
                          OR (p_status = '1' AND a.contract_status_id = 1)
                          OR (    p_status = 'all'
                              AND (   a.contract_status_id = 1
                                   OR a.contract_status_id = 0
                                  )
                             )
                         )
         UNION
         -- get all AAPPs are  CC type
         SELECT /*rule*/ DISTINCT a.aapp_num AS aappnum,
                          aapp_program_activity
                                               (a.aapp_num)
                                                           AS programactivity,
                          a.venue, a.contract_status_id, cr.center_name,
                          c.contractor_name, a.contract_num,
                          a.date_start AS datestart, y1.date_end AS dateend,
                          NVL (funding_cumm_ops1.fundingcummops, 0),
                          NVL (funding_cumm_cra1.fundingcummcra, 0),
                            NVL
                               (funding_cumm_ops1.fundingcummops,
                                0
                               )
                          + NVL (funding_cumm_cra1.fundingcummcra, 0)
                                                          AS fundingcummtotal,
                          NVL (funding_expired_ops1.fundingexpiredops, 0),
                          NVL (funding_expired_cra1.fundingexpiredcra, 0),
                            NVL
                               (funding_expired_ops1.fundingexpiredops,
                                0
                               )
                          + NVL (funding_expired_cra1.fundingexpiredcra, 0)
                                                       AS fundingexpiredtotal,
                            NVL
                               (funding_cumm_ops1.fundingcummops,
                                0
                               )
                          - NVL (funding_expired_ops1.fundingexpiredops, 0)
                                                          AS fundingactiveops,
                            NVL
                               (funding_cumm_cra1.fundingcummcra,
                                0
                               )
                          - NVL (funding_expired_cra1.fundingexpiredcra, 0)
                                                          AS fundingactivecra,
                            (  NVL (funding_cumm_ops1.fundingcummops, 0)
                             + NVL (funding_cumm_cra1.fundingcummcra, 0)
                            )
                          - (  NVL (funding_expired_ops1.fundingexpiredops, 0)
                             + NVL (funding_expired_cra1.fundingexpiredcra, 0)
                            ) AS fundingactivetotal,
                          
                          -- note ops
                          CASE
                             WHEN   NVL
                                       (funding_cumm_ops1.fundingcummops,
                                        0
                                       )
                                  - NVL
                                       (funding_expired_ops1.fundingexpiredops,
                                        0
                                       ) < 0
                                THEN '1/'
                             ELSE NULL
                          END AS noteops,
                          
                          -- note cra
                          CASE
                             WHEN   NVL
                                       (funding_cumm_cra1.fundingcummcra,
                                        0
                                       )
                                  - NVL
                                       (funding_expired_cra1.fundingexpiredcra,
                                        0
                                       ) < 0
                                THEN '2/'
                             ELSE NULL
                          END AS notecra,
                          a.funding_office_num
                    FROM aapp a,
                         contractor c,
                         center cr,
                         (SELECT   yr.aapp_num, MAX (yr.date_end) AS date_end
                              FROM aapp_yearend yr
                          GROUP BY yr.aapp_num) y1,
                         
                         -- funding cumm ops
                         (SELECT   f.aapp_num,
                                   NVL (SUM (amount), 0) AS fundingcummops
                              FROM fop f
                             WHERE f.cost_cat_id != 2 AND f.py = v_current_py
                          GROUP BY f.aapp_num) funding_cumm_ops1,
                         
                         -- funding cumm cra
                         (SELECT   f.aapp_num,
                                   NVL (SUM (amount), 0) AS fundingcummcra
                              FROM fop f
                             WHERE f.cost_cat_id = 2
                               AND (   f.py_cra_budget = v_current_py
                                    OR f.py_cra_budget = v_current_py - 1
                                    OR f.py_cra_budget = v_current_py - 2
                                   )
                          GROUP BY f.aapp_num) funding_cumm_cra1,
                         
                         -- expired OPS funding                          
                          (SELECT   b.aapp_num,
                                   NVL (SUM (oblig), 0) AS fundingexpiredops
                              FROM footprint_ncfms fpn, aapp b
                             WHERE fpn.aapp_num = b.aapp_num
                               AND UPPER (fpn.fund_cat) = 'OPS'
                               AND fpn.approp_exp_py < v_current_py
                          GROUP BY b.aapp_num) funding_expired_ops1,
                         
                         -- expired CRA funding                          
                          (SELECT   b.aapp_num,
                                   NVL (SUM (oblig), 0) AS fundingexpiredcra
                              FROM footprint_ncfms fpn, aapp b
                             WHERE fpn.aapp_num = b.aapp_num
                               AND UPPER (fpn.fund_cat) = 'CRA'
                               AND fpn.approp_exp_py < v_current_py
                          GROUP BY b.aapp_num) funding_expired_cra1
                          
                   WHERE a.contractor_id = c.contractor_id(+)
                     AND a.center_id = cr.center_id(+)
                     AND agreement_type_code = 'CC'
                     AND a.aapp_num = funding_cumm_ops1.aapp_num(+)
                     AND a.aapp_num = funding_cumm_cra1.aapp_num(+)
                     AND a.aapp_num = funding_expired_ops1.aapp_num(+)
                     AND a.aapp_num = funding_expired_cra1.aapp_num(+)
                     AND a.aapp_num = y1.aapp_num(+)
                     AND a.funding_office_num = p_fundofficenum
                     AND (   (p_status = '0' AND a.contract_status_id = 0)
                          OR (p_status = '1' AND a.contract_status_id = 1)
                          OR (    p_status = 'all'
                              AND (   a.contract_status_id = 1
                                   OR a.contract_status_id = 0
                                  )
                             )
                         )
                ORDER BY 1;
   END prc_get_bud_auth_aapp_rpt;

   -- get Program Year Initial CCC Budget
   PROCEDURE prc_get_ccc_py_worksheet_rpt (
      p_fundingofficenum            IN       NUMBER,
      p_py                          IN       NUMBER,
      p_recordset_cccpy_worksheet   OUT      sys_refcursor,
      p_recordset_ccc_percent       OUT      sys_refcursor
   )
   IS
   BEGIN
      OPEN p_recordset_cccpy_worksheet FOR
         SELECT   a.cost_cat_desc, a.cost_cat_code, a.cost_cat_id,
                  a.base_subtotal, a.sort_order,
                  NVL (SUM (amount_py_proposed), 0) AS proposed,
                  NVL (SUM (b.amount_dol_adjusted), 0) AS dol_adjusted,
                  NVL (SUM (b.amount_final), 0) AS amount_final
             FROM lu_ccc_worksheet_cost_cat a LEFT OUTER JOIN ccc_worksheet_data b
                  ON a.ccc_wscc_id = b.ccc_wscc_id
                AND b.program_year = p_py
                AND b.aapp_num IN (
                              SELECT ap.aapp_num
                                FROM aapp ap
                               WHERE ap.funding_office_num =
                                                            p_fundingofficenum)
            WHERE
                (
                CASE
                WHEN p_py <=2008 AND py08_back = 1 THEN 1
                WHEN p_py >=2009 AND py09_forward = 1 THEN 1
                ELSE 0
                END
                ) = 1
         GROUP BY a.cost_cat_desc,
                  a.cost_cat_code,
                  a.cost_cat_id,
                  a.base_subtotal,
                  a.sort_order
         ORDER BY a.sort_order;

      OPEN p_recordset_ccc_percent FOR
         SELECT   p.cost_cat_id, p.transfer_percent
             FROM ba_transfer_percent p
            WHERE p.quarter = 1 AND p.TYPE = 'CCC'
         ORDER BY p.cost_cat_id;
   END prc_get_ccc_py_worksheet_rpt;

   -- get OA/CTS annualized workload/Cost under current contracts
   PROCEDURE prc_get_oa_cts_annualized_rpt (
      p_fundingofficenum   IN       NUMBER,
      p_date_asof          IN       DATE,
      p_oa_cts_recordset   OUT      sys_refcursor
   )
   IS
      v_current_ccc_py   NUMBER;
   BEGIN
      -- get current CCC program year
      SELECT utility.fun_getcurrntprogram_year_ccc
        INTO v_current_ccc_py
        FROM DUAL;

      OPEN p_oa_cts_recordset FOR
         SELECT   a.funding_office_num AS funding_office_num, a.aapp_num,
                  a.contract_num, pr_activity.prog_acti AS programactivity,
                  c.contractor_name, a.date_start,
                  ADD_MONTHS (d.minyearenddate, -12) + 1 AS minyearenddate,
                  d.date_end AS enddate,
                  contract.fun_getannualized (a.aapp_num,
                                              d.contract_year,
                                              ar.arrvs
                                             ) AS arrvs,
                  contract.fun_getannualized (a.aapp_num,
                                              d.contract_year,
                                              gr.grads
                                             ) AS grads,
                  contract.fun_getannualized (a.aapp_num,
                                              d.contract_year,
                                              fe.fes
                                             ) AS fes,
                  contract.fun_getannualized
                     (a.aapp_num,
                      d.contract_year,
                      (SELECT contract.fun_getestcostprototalamount
                                                              (a.aapp_num,
                                                               6,
                                                               d.contract_year
                                                              )
                         FROM DUAL)
                     ) AS oa_funds,
                  contract.fun_getannualized
                     (a.aapp_num,
                      d.contract_year,
                      (SELECT contract.fun_getestcostprototalamount
                                                              (a.aapp_num,
                                                               7,
                                                               d.contract_year
                                                              )
                         FROM DUAL)
                     ) AS cts_funds
             FROM aapp a,
                  contractor c,
                  (SELECT b.aapp_num, minyearenddate, b.contract_year,
                          b.date_end
                     FROM (SELECT   y.aapp_num, y.date_end, y.contract_year,
                                    MIN (y.date_end) OVER (PARTITION BY y.aapp_num)
                                                               minyearenddate
                               FROM aapp_yearend y
                              WHERE y.date_end >= p_date_asof
                           GROUP BY y.aapp_num, y.date_end, y.contract_year) b
                    WHERE b.date_end = minyearenddate) d,
                  (SELECT   w.aapp_num, w.contract_year, w.VALUE AS arrvs
                       FROM aapp_workload w
                      WHERE w.workload_type_code = 'AR'
                   GROUP BY w.aapp_num, w.contract_year, w.VALUE) ar,
                  (SELECT   w.aapp_num, w.contract_year, w.VALUE AS grads
                       FROM aapp_workload w
                      WHERE w.workload_type_code = 'GR'
                   GROUP BY w.aapp_num, w.contract_year, w.VALUE) gr,
                  (SELECT   w.aapp_num, w.contract_year, w.VALUE AS fes
                       FROM aapp_workload w
                      WHERE w.workload_type_code = 'FE'
                   GROUP BY w.aapp_num, w.contract_year, w.VALUE) fe,
                  (SELECT a1.aapp_num,
                          CASE
                             WHEN a1.center_id IS NOT NULL
                                THEN    ctr.center_name
                                     || ': '
                                     || aapp_program_activity (a1.aapp_num)
                             ELSE aapp_program_activity (a1.aapp_num)
                          END prog_acti
                     FROM aapp a1, center ctr
                    WHERE a1.center_id = ctr.center_id(+)) pr_activity
            WHERE a.funding_office_num = p_fundingofficenum
              AND a.aapp_num = d.aapp_num
              AND a.contractor_id = c.contractor_id(+)
              AND d.aapp_num = ar.aapp_num
              AND d.aapp_num = gr.aapp_num
              AND d.aapp_num = fe.aapp_num
              AND d.contract_year = ar.contract_year
              AND d.contract_year = gr.contract_year
              AND d.contract_year = fe.contract_year
              AND a.aapp_num = pr_activity.aapp_num
              AND a.contract_status_id = 1
              AND a.date_start <= p_date_asof
              AND (ar.arrvs != 0 OR gr.grads != 0 OR fe.fes != 0)
         -- get CCC information
         UNION
         SELECT   s.region_num AS funding_office_num, a.aapp_num,
                  a.contract_num, pr_activity.prog_acti AS programactivity,
                  c.contractor_name, NULL AS date_start,
                  NULL AS minyearenddate, NULL AS enddate,
                  NVL (ar.arrvs, 0) AS arrvs, NVL (gr.grads, 0) AS grads,
                  fe.fes AS fes, NVL (oa_funds.oa_funds, 0) AS oa_funds,
                  NVL (cts_funds.cts_funds, 0) AS cts_funds
             FROM aapp a,
                  contractor c,
                  lu_state s,
                  (SELECT   f.aapp_num, SUM (f.amount) AS oa_funds
                       FROM aapp a, fop f
                      WHERE a.aapp_num = f.aapp_num
                        AND a.agreement_type_code = 'CC'
                        AND a.contract_status_id = 1
                        AND f.py = v_current_ccc_py
                        AND f.cost_cat_id = 6
                   GROUP BY f.aapp_num) oa_funds,
                  (SELECT   f.aapp_num, SUM (f.amount) AS cts_funds
                       FROM aapp a, fop f
                      WHERE f.aapp_num = a.aapp_num(+)
                        AND a.agreement_type_code = 'CC'
                        AND a.contract_status_id = 1
                        AND f.py = v_current_ccc_py
                        AND f.cost_cat_id = 7
                   GROUP BY f.aapp_num) cts_funds,
                  (SELECT   w.aapp_num, w.contract_year, w.VALUE AS arrvs
                       FROM aapp_workload w
                      WHERE w.workload_type_code = 'AR'
                   GROUP BY w.aapp_num, w.contract_year, w.VALUE) ar,
                  (SELECT   w.aapp_num, w.contract_year, w.VALUE AS grads
                       FROM aapp_workload w
                      WHERE w.workload_type_code = 'GR'
                   GROUP BY w.aapp_num, w.contract_year, w.VALUE) gr,
                  (SELECT   w.aapp_num, w.contract_year, w.VALUE AS fes
                       FROM aapp_workload w
                      WHERE w.workload_type_code = 'FE'
                   GROUP BY w.aapp_num, w.contract_year, w.VALUE) fe,
                  (SELECT a1.aapp_num,
                          CASE
                             WHEN a1.center_id IS NOT NULL
                                THEN    ctr.center_name
                                     || ': '
                                     || aapp_program_activity (a1.aapp_num)
                             ELSE aapp_program_activity (a1.aapp_num)
                          END prog_acti
                     FROM aapp a1, center ctr
                    WHERE a1.center_id = ctr.center_id(+)) pr_activity
            WHERE a.contractor_id = c.contractor_id
              AND a.aapp_num = ar.aapp_num
              AND a.aapp_num = gr.aapp_num
              AND a.aapp_num = fe.aapp_num
              AND a.aapp_num = pr_activity.aapp_num
              AND a.aapp_num = oa_funds.aapp_num
              AND oa_funds.aapp_num = cts_funds.aapp_num(+)
              AND a.state_abbr = s.state_abbr
              AND s.region_num = p_fundingofficenum
              AND (ar.arrvs != 0 OR gr.grads != 0 OR fe.fes != 0)
         ORDER BY funding_office_num, contractor_name;
   END prc_get_oa_cts_annualized_rpt;

   -- Budget Status Report
   PROCEDURE prc_get_budget_status_rpt (
      p_fundingofficenum          IN       NUMBER,
      p_budget_status_recordset   OUT      sys_refcursor
   )
   IS
      v_current_py   NUMBER;
   BEGIN
      -- get current program year
      SELECT utility.fun_getcurrntprogram_year
        INTO v_current_py
        FROM DUAL;

      OPEN p_budget_status_recordset FOR
         SELECT /*rule*/ DISTINCT a.aapp_num AS aappnum,
                          
                          -- information about aapp
                          pr_activity.prog_acti AS programactivity,
                          a.venue AS venue,
                          a.contract_status_id AS contract_status_id,
                          c.contractor_name AS contractorname,
                          a.contract_num AS contractnumber,
                          a.date_start AS datestart, y.date_end AS dateend,
                          
                          -- Approved cummlulative funds
                          NVL
                             (funding_cumm_ops.fundingcummops,
                              0
                             ) AS fundingcummops,
                          NVL
                             (funding_cumm_cra.fundingcummcra,
                              0
                             ) AS fundingcummcra,
                            NVL
                               (funding_cumm_ops.fundingcummops,
                                0
                               )
                          + NVL (funding_cumm_cra.fundingcummcra, 0)
                                                          AS fundingcummtotal,
                          
                          -- Obligation from expired account
                          NVL
                             (funding_expired_ops.fundingexpiredops,
                              0
                             ) AS fundingexpiredops,
                          NVL
                             (funding_expired_cra.fundingexpiredcra,
                              0
                             ) AS fundingexpiredcra,
                            NVL
                               (funding_expired_ops.fundingexpiredops,
                                0
                               )
                          + NVL (funding_expired_cra.fundingexpiredcra, 0)
                                                       AS fundingexpiredtotal,
                          
                            -- arrproved for status of active funds
                            NVL
                               (funding_cumm_ops.fundingcummops,
                                0
                               )
                          - NVL (funding_expired_ops.fundingexpiredops, 0)
                                                          AS fundingactiveops,
                            NVL
                               (funding_cumm_cra.fundingcummcra,
                                0
                               )
                          - NVL (funding_expired_cra.fundingexpiredcra, 0)
                                                          AS fundingactivecra,
                          
                          --nvl(funding_cumm_ops.fundingcummops,0) + nvl(funding_cumm_cra.fundingcummcra,0)- nvl(funding_expired_ops.fundingexpiredops,0) + nvl(funding_expired_cra.fundingexpiredcra,0) AS fundingactivetotal,

                          -- current obligation for status of active funds
                          NVL
                             (current_oblg_ops.currentoblgops,
                              0
                             ) AS currentoblgops,
                          NVL
                             (current_oblg_cra.currentoblgcra,
                              0
                             ) AS currentoblgcra,
                          
                          -- as % for status of active funds
                          -- as % for status of active funds
                          CASE
                             WHEN   NVL
                                       (funding_cumm_ops.fundingcummops,
                                        0
                                       )
                                  - NVL
                                       (funding_expired_ops.fundingexpiredops,
                                        0
                                       ) != 0
                                THEN NVL
                                       (ROUND
                                           (  current_oblg_ops.currentoblgops
                                            / (  NVL
                                                    (funding_cumm_ops.fundingcummops,
                                                     0
                                                    )
                                               - NVL
                                                    (funding_expired_ops.fundingexpiredops,
                                                     0
                                                    )
                                              )
                                            * 100
                                           ),
                                        0
                                       )
                             ELSE 0
                          END AS actfundspercentops,
                          CASE
                             WHEN   NVL
                                       (funding_cumm_cra.fundingcummcra,
                                        0
                                       )
                                  - NVL
                                       (funding_expired_cra.fundingexpiredcra,
                                        0
                                       ) != 0
                                THEN NVL
                                       (ROUND
                                           (  current_oblg_cra.currentoblgcra
                                            / (  NVL
                                                    (funding_cumm_cra.fundingcummcra,
                                                     0
                                                    )
                                               - NVL
                                                    (funding_expired_cra.fundingexpiredcra,
                                                     0
                                                    )
                                              )
                                            * 100
                                           ),
                                        0
                                       )
                             ELSE 0
                          END AS actfundspercentcra,
                          
                            -- remaingin balancing
                            NVL
                               (funding_cumm_ops.fundingcummops,
                                0
                               )
                          - NVL (funding_expired_ops.fundingexpiredops, 0)
                          - NVL (current_oblg_ops.currentoblgops, 0)
                                                       AS remainingbalanceops,
                            NVL
                               (funding_cumm_cra.fundingcummcra,
                                0
                               )
                          - NVL (funding_expired_cra.fundingexpiredcra, 0)
                          - NVL (current_oblg_cra.currentoblgcra, 0)
                                                       AS remainingbalancecra,
                          
                            -- unspent pbligaiton
                            NVL
                               (funding_expired_ops.fundingexpiredops,
                                0
                               )
                          - NVL (funding_expired_ops.fundingexpiredcostops, 0)
                                                         AS unspentexpiredops,
                            NVL
                               (funding_expired_cra.fundingexpiredcra,
                                0
                               )
                          - NVL (funding_expired_cra.fundingexpiredcostcra, 0)
                                                         AS unspentexpiredcra,
                            NVL
                               (current_oblg_ops.currentoblgops,
                                0
                               )
                          - NVL (current_oblg_ops.fundingcurrentcostops, 0)
                                                          AS unspentactiveops,
                            NVL
                               (current_oblg_cra.currentoblgcra,
                                0
                               )
                          - NVL (current_oblg_cra.fundingcurrentcostcra, 0)
                                                          AS unspentactivecra,
                          a.funding_office_num
                    FROM aapp a,
                         contractor c,
                         (SELECT a1.aapp_num,
                                 CASE
                                    WHEN a1.center_id IS NOT NULL
                                       THEN    ctr.center_name
                                            || ': '
                                            || aapp_program_activity
                                                                  (a1.aapp_num)
                                    ELSE aapp_program_activity (a1.aapp_num)
                                 END prog_acti
                            FROM aapp a1, center ctr
                           WHERE a1.center_id = ctr.center_id(+)) pr_activity,
                         (SELECT   yr.aapp_num, MAX (yr.date_end) AS date_end
                              FROM aapp_yearend yr
                          GROUP BY yr.aapp_num) y,
                         
                         -- funding cumm ops
                         (SELECT   f.aapp_num,
                                   NVL (SUM (amount), 0) AS fundingcummops
                              FROM fop f
                             WHERE f.cost_cat_id != 2
                          GROUP BY f.aapp_num) funding_cumm_ops,
                         
                         -- funding cumm cra
                         (SELECT   f.aapp_num,
                                   NVL (SUM (amount), 0) AS fundingcummcra
                              FROM fop f
                             WHERE f.cost_cat_id = 2
                          GROUP BY f.aapp_num) funding_cumm_cra,
                         
                         -- expired OPS funding (updated for NCFMS)
                         (SELECT   fpn.aapp_num,
                                   NVL (SUM (oblig), 0) AS fundingexpiredops,
                                   NVL (SUM (COST),
                                        0
                                       ) AS fundingexpiredcostops
                              FROM footprint_ncfms fpn
                             WHERE UPPER (fpn.fund_cat) = 'OPS'
                               AND FPN.APPROP_EXP_PY < v_current_py
                          GROUP BY fpn.aapp_num) funding_expired_ops,
                         
                         -- expired CRA funding (updated for NCFMS)
                         (SELECT   fpn.aapp_num,
                                   NVL (SUM (oblig), 0) AS fundingexpiredcra,
                                   NVL (SUM (COST),
                                        0
                                       ) AS fundingexpiredcostcra
                              FROM footprint_ncfms fpn
                             WHERE UPPER (fpn.fund_cat) = 'CRA'
                               AND FPN.APPROP_EXP_PY < v_current_py
                          GROUP BY fpn.aapp_num) funding_expired_cra,
                         
                         -- current obligation of OPS funding (updated for NCFMS)
                         (SELECT   fpn.aapp_num,
                                   NVL (SUM (oblig), 0) AS currentoblgops,
                                   NVL (SUM (COST),
                                        0
                                       ) AS fundingcurrentcostops
                              FROM footprint_ncfms fpn
                             WHERE UPPER (fpn.fund_cat) = 'OPS'
                               AND FPN.APPROP_EXP_PY >= v_current_py
                          GROUP BY fpn.aapp_num) current_oblg_ops,
                         
                         -- current obligation of CRA funding (updated for NCFMS)
                         (SELECT   fpn.aapp_num,
                                   NVL (SUM (oblig), 0) AS currentoblgcra,
                                   NVL (SUM (COST),
                                        0
                                       ) AS fundingcurrentcostcra
                              FROM footprint_ncfms fpn
                             WHERE UPPER (fpn.fund_cat) = 'CRA'
                               AND FPN.APPROP_EXP_PY >= v_current_py
                          GROUP BY fpn.aapp_num) current_oblg_cra
                         
                         /* legacy = DOLAR$ footprint
                         -- expired OPS funding
                         (SELECT   fp.aapp_num,
                                   NVL (SUM (oblig), 0) AS fundingexpiredops,
                                   NVL (SUM (COST),
                                        0
                                       ) AS fundingexpiredcostops
                              FROM footprint fp, rcc_code r
                             WHERE fp.rcc_fund = r.rcc_fund
                               AND fp.rcc_org = r.rcc_org
                               AND fp.fy = r.fy
                               AND UPPER (r.ops_cra) = 'OPS'
                               AND r.last_oblig_py < v_current_py
                          GROUP BY fp.aapp_num) funding_expired_ops,
                         
                         -- expired CRA funding
                         (SELECT   fp.aapp_num,
                                   NVL (SUM (oblig), 0) AS fundingexpiredcra,
                                   NVL (SUM (COST),
                                        0
                                       ) AS fundingexpiredcostcra
                              FROM footprint fp, rcc_code r
                             WHERE fp.rcc_fund = r.rcc_fund
                               AND fp.rcc_org = r.rcc_org
                               AND fp.fy = r.fy
                               AND UPPER (r.ops_cra) = 'CRA'
                               AND r.last_oblig_py < v_current_py
                          GROUP BY fp.aapp_num) funding_expired_cra,
                         
                         -- current obligation of OPS funding
                         (SELECT   fp.aapp_num,
                                   NVL (SUM (oblig), 0) AS currentoblgops,
                                   NVL (SUM (COST),
                                        0
                                       ) AS fundingcurrentcostops
                              FROM footprint fp, rcc_code r
                             WHERE fp.rcc_fund = r.rcc_fund
                               AND fp.rcc_org = r.rcc_org
                               AND fp.fy = r.fy
                               AND UPPER (r.ops_cra) = 'OPS'
                               AND r.last_oblig_py >= v_current_py
                          GROUP BY fp.aapp_num) current_oblg_ops,
                         
                         -- current obligation of CRA funding
                         (SELECT   fp.aapp_num,
                                   NVL (SUM (oblig), 0) AS currentoblgcra,
                                   NVL (SUM (COST),
                                        0
                                       ) AS fundingcurrentcostcra
                              FROM footprint fp, rcc_code r
                             WHERE fp.rcc_fund = r.rcc_fund
                               AND fp.rcc_org = r.rcc_org
                               AND fp.fy = r.fy
                               AND UPPER (r.ops_cra) = 'CRA'
                               AND r.last_oblig_py >= v_current_py
                          GROUP BY fp.aapp_num) current_oblg_cra
                          */
                   WHERE a.contractor_id = c.contractor_id(+)
                     AND a.aapp_num = pr_activity.aapp_num
                     AND agreement_type_code != 'CC'
                     AND a.contract_status_id = 1
                     AND a.aapp_num = funding_cumm_ops.aapp_num(+)
                     AND a.aapp_num = funding_cumm_cra.aapp_num(+)
                     AND a.aapp_num = funding_expired_ops.aapp_num(+)
                     AND a.aapp_num = funding_expired_cra.aapp_num(+)
                     AND a.aapp_num = current_oblg_ops.aapp_num(+)
                     AND a.aapp_num = current_oblg_cra.aapp_num(+)
                     AND a.aapp_num = y.aapp_num(+)
                     AND a.funding_office_num = p_fundingofficenum
                ORDER BY funding_office_num, contractorname;
   END prc_get_budget_status_rpt;

/**********************************
Function for debug
**********************************/
   FUNCTION fun_np_action_obj_case_num (p_aapp_num IN NUMBER)
      RETURN NUMBER
   AS
   BEGIN
      RETURN report.fun_get_fiscal_plan_npa (p_aapp_num).case_num;
   END fun_np_action_obj_case_num;

   FUNCTION fun_np_action_obj_com_date (p_aapp_num IN NUMBER)
      RETURN DATE
   AS
   BEGIN
      RETURN report.fun_get_fiscal_plan_npa (p_aapp_num).completion_date;
   END fun_np_action_obj_com_date;

   FUNCTION fun_np_action_obj_next_date (p_aapp_num IN NUMBER)
      RETURN DATE
   AS
   BEGIN
      RETURN report.fun_get_fiscal_plan_npa (p_aapp_num).next_action_date;
   END fun_np_action_obj_next_date;

   FUNCTION fun_np_action_obj_action_date (p_aapp_num IN NUMBER)
      RETURN DATE
   AS
   BEGIN
      RETURN report.fun_get_fiscal_plan_npa (p_aapp_num).action_date;
   END fun_np_action_obj_action_date;
   
     -- Footprint/Transaction Discrepancy Report
   
   
   
   -- Outyear Report
   PROCEDURE prc_get_outyear_rpt (
      p_serv_type             IN      VARCHAR,
      p_fund_off              IN      NUMBER,
      p_outyear_recordset   OUT     sys_refcursor
   )
   IS 
   v_cost_cat NUMBER;
   v_fund_off NUMBER;
   
   BEGIN
    
     v_fund_off := 0;
   
   Select COST_CAT_ID
   INTO   v_cost_cat
   FROM   LU_COST_CAT
   WHERE  COST_CAT_CODE = p_serv_type;
   
      IF p_fund_off != 0
      THEN
         v_fund_off := p_fund_off;
      END IF;
   
    IF v_fund_off = 0
      THEN   
        IF p_serv_type = 'A'
        THEN
            OPEN p_outyear_recordset FOR
            Select 
             a.AAPP_NUM as aappNum, 
             a.FUNDING_OFFICE_NUM as fundOffNum, 
             f.FUNDING_OFFICE_DESC as fundOffDesc,
             b.CONTRACTOR_NAME as contractorName, 
             d.CENTER_NAME as centerName, 
             a.VENUE as venue, 
             a.Center_ID as centerID, 
             a.Other_Type_desc as otherTypeDesc,
             AAPP_PROGRAM_ACTIVITY(a.aapp_num, 'S') as progAct, 
             a.DATE_START as dateStart,
             (SELECT MAX (e.date_end)
             FROM aapp_yearend e
             WHERE e.aapp_num = a.aapp_num) AS dateEnd,
             fop_batch.fun_fopcatyearamount(a.aapp_num, v_cost_cat, utility.FUN_GETCURRNTPROGRAM_YEAR) as PY0,
             fop_batch.fun_fopestamount(a.aapp_num, v_cost_cat, utility.FUN_GETCURRNTPROGRAM_YEAR + 1) as PY1, 
             fop_batch.fun_fopestamount_outyear(a.aapp_num, v_cost_cat, utility.FUN_GETCURRNTPROGRAM_YEAR + 2) as PY2, 
             fop_batch.fun_fopestamount_outyear(a.aapp_num, v_cost_cat, utility.FUN_GETCURRNTPROGRAM_YEAR + 3) as PY3 
            FROM AAPP a, 
                 CONTRACTOR b, 
                 AAPP_Contract_Type c, 
                 Center d,
                 lu_Funding_Office f
            WHERE a.CONTRACTOR_ID = b.CONTRACTOR_ID (+)
            AND a.AAPP_NUM = c.AAPP_NUM 
            AND a.CENTER_ID = d.CENTER_ID (+)
            AND a.FUNDING_OFFICE_NUM = f.FUNDING_OFFICE_NUM
            AND a.AGREEMENT_TYPE_CODE in ('DC', 'GR')
            AND c.CONTRACT_TYPE_CODE = p_serv_type 
            AND a.date_start <= utility.FUN_GET_PY_DATE(utility.FUN_GETCURRNTPROGRAM_YEAR + 3, 'E') 
            AND (SELECT MAX(e.date_end) 
                 FROM aapp_yearend e 
                 WHERE e.aapp_num = a.aapp_num) >= utility.FUN_GET_PY_DATE(utility.FUN_GETCURRNTPROGRAM_YEAR, 'S') 
            Group BY a.AAPP_Num, a.Funding_Office_Num, f.FUNDING_OFFICE_DESC, b.Contractor_Name, d.Center_Name, a.Venue, a.Center_ID, a.Other_Type_desc, AAPP_PROGRAM_ACTIVITY(a.aapp_num, 'S'), a.DATE_START--, (SELECT MAX (e.date_end) FROM aapp_yearend e WHERE e.aapp_num = a.aapp_num)
            ORDER BY centerName, aappNum;
        Elsif p_serv_type = 'S'
            THEN
            OPEN p_outyear_recordset FOR
               Select 
             a.AAPP_NUM as aappNum, 
             a.FUNDING_OFFICE_NUM as fundOffNum, 
             f.FUNDING_OFFICE_DESC as fundOffDesc,
             b.CONTRACTOR_NAME as contractorName, 
             d.CENTER_NAME as centerName, 
             a.VENUE as venue, 
             a.Center_ID as centerID, 
             a.Other_Type_desc as otherTypeDesc,
             AAPP_PROGRAM_ACTIVITY(a.aapp_num, 'S') as progAct,  
             a.DATE_START as dateStart,
             (SELECT MAX (e.date_end)
             FROM aapp_yearend e
             WHERE e.aapp_num = a.aapp_num) AS dateEnd,
             fop_batch.fun_fopcatyearamount(a.aapp_num, v_cost_cat, utility.FUN_GETCURRNTPROGRAM_YEAR) as PY0,
             fop_batch.fun_fopestamount(a.aapp_num, v_cost_cat, utility.FUN_GETCURRNTPROGRAM_YEAR + 1) as PY1, 
             fop_batch.fun_fopestamount_outyear(a.aapp_num, v_cost_cat, utility.FUN_GETCURRNTPROGRAM_YEAR + 2) as PY2, 
             fop_batch.fun_fopestamount_outyear(a.aapp_num, v_cost_cat, utility.FUN_GETCURRNTPROGRAM_YEAR + 3) as PY3 
            FROM AAPP a, 
                 CONTRACTOR b, 
                 AAPP_Contract_Type c, 
                 Center d,
                 lu_Funding_Office f
            WHERE a.CONTRACTOR_ID = b.CONTRACTOR_ID (+)
            AND a.AAPP_NUM = c.AAPP_NUM 
            AND a.CENTER_ID = d.CENTER_ID (+)
            AND a.FUNDING_OFFICE_NUM = f.FUNDING_OFFICE_NUM
            AND a.AGREEMENT_TYPE_CODE in ('DC', 'GR')
            AND c.CONTRACT_TYPE_CODE = p_serv_type 
            AND a.date_start <= utility.FUN_GET_PY_DATE(utility.FUN_GETCURRNTPROGRAM_YEAR + 3, 'E') 
            AND (SELECT MAX(e.date_end) 
                 FROM aapp_yearend e 
                 WHERE e.aapp_num = a.aapp_num) >= utility.FUN_GET_PY_DATE(utility.FUN_GETCURRNTPROGRAM_YEAR, 'S') 
            Group BY a.AAPP_Num, a.Funding_Office_Num, f.FUNDING_OFFICE_DESC, b.Contractor_Name, d.Center_Name, a.Venue, a.Center_ID, a.Other_Type_desc, AAPP_PROGRAM_ACTIVITY(a.aapp_num, 'S'), a.DATE_START--, (SELECT MAX (e.date_end) FROM aapp_yearend e WHERE e.aapp_num = a.aapp_num)
            ORDER BY fundOffNum, otherTypeDesc;
        ELSE
            OPEN p_outyear_recordset FOR
               Select 
             a.AAPP_NUM as aappNum, 
             a.FUNDING_OFFICE_NUM as fundOffNum, 
             f.FUNDING_OFFICE_DESC as fundOffDesc,
             b.CONTRACTOR_NAME as contractorName, 
             d.CENTER_NAME as centerName, 
             a.VENUE as venue, 
             a.Center_ID as centerID, 
             a.Other_Type_desc as otherTypeDesc,
             AAPP_PROGRAM_ACTIVITY(a.aapp_num, 'S') as progAct, 
             a.DATE_START as dateStart,
             (SELECT MAX (e.date_end)
             FROM aapp_yearend e
             WHERE e.aapp_num = a.aapp_num) AS dateEnd,
             fop_batch.fun_fopcatyearamount(a.aapp_num, v_cost_cat, utility.FUN_GETCURRNTPROGRAM_YEAR) as PY0,
             fop_batch.fun_fopestamount(a.aapp_num, v_cost_cat, utility.FUN_GETCURRNTPROGRAM_YEAR + 1) as PY1, 
             fop_batch.fun_fopestamount_outyear(a.aapp_num, v_cost_cat, utility.FUN_GETCURRNTPROGRAM_YEAR + 2) as PY2, 
             fop_batch.fun_fopestamount_outyear(a.aapp_num, v_cost_cat, utility.FUN_GETCURRNTPROGRAM_YEAR + 3) as PY3 
            FROM AAPP a, 
                 CONTRACTOR b, 
                 AAPP_Contract_Type c, 
                 Center d,
                 lu_Funding_Office f
            WHERE a.CONTRACTOR_ID = b.CONTRACTOR_ID (+)
            AND a.AAPP_NUM = c.AAPP_NUM 
            AND a.CENTER_ID = d.CENTER_ID (+)
            AND a.FUNDING_OFFICE_NUM = f.FUNDING_OFFICE_NUM
            AND a.AGREEMENT_TYPE_CODE in ('DC', 'GR')
            AND c.CONTRACT_TYPE_CODE = p_serv_type 
            AND a.date_start <= utility.FUN_GET_PY_DATE(utility.FUN_GETCURRNTPROGRAM_YEAR + 3, 'E') 
            AND (SELECT MAX(e.date_end) 
                 FROM aapp_yearend e 
                 WHERE e.aapp_num = a.aapp_num) >= utility.FUN_GET_PY_DATE(utility.FUN_GETCURRNTPROGRAM_YEAR, 'S') 
            Group BY a.AAPP_Num, a.Funding_Office_Num, f.FUNDING_OFFICE_DESC, b.Contractor_Name, d.Center_Name, a.Venue, a.Center_ID, a.Other_Type_desc, AAPP_PROGRAM_ACTIVITY(a.aapp_num, 'S'), a.DATE_START--, (SELECT MAX (e.date_end) FROM aapp_yearend e WHERE e.aapp_num = a.aapp_num)
            ORDER BY fundOffNum, centerName, venue;
        END IF;    
    Else
      IF p_serv_type = 'A'
        THEN
            OPEN p_outyear_recordset FOR
               Select              
             a.AAPP_NUM as aappNum, 
             a.FUNDING_OFFICE_NUM as fundOffNum, 
             f.FUNDING_OFFICE_DESC as fundOffDesc,
             b.CONTRACTOR_NAME as contractorName, 
             d.CENTER_NAME as centerName, 
             a.VENUE as venue, 
             a.Center_ID as centerID, 
             a.Other_Type_desc as otherTypeDesc,
             AAPP_PROGRAM_ACTIVITY(a.aapp_num, 'S') as progAct, 
             a.DATE_START as dateStart,
             (SELECT MAX (e.date_end)
             FROM aapp_yearend e
             WHERE e.aapp_num = a.aapp_num) AS dateEnd,
             fop_batch.fun_fopcatyearamount(a.aapp_num, v_cost_cat, utility.FUN_GETCURRNTPROGRAM_YEAR) as PY0,
             fop_batch.fun_fopestamount(a.aapp_num, v_cost_cat, utility.FUN_GETCURRNTPROGRAM_YEAR + 1) as PY1, 
             fop_batch.fun_fopestamount_outyear(a.aapp_num, v_cost_cat, utility.FUN_GETCURRNTPROGRAM_YEAR + 2) as PY2, 
             fop_batch.fun_fopestamount_outyear(a.aapp_num, v_cost_cat, utility.FUN_GETCURRNTPROGRAM_YEAR + 3) as PY3 
            FROM AAPP a, 
                 CONTRACTOR b, 
                 AAPP_Contract_Type c, 
                 Center d,
                 lu_Funding_Office f
            WHERE a.CONTRACTOR_ID = b.CONTRACTOR_ID (+)
            AND a.AAPP_NUM = c.AAPP_NUM 
            AND a.CENTER_ID = d.CENTER_ID (+)
            AND a.FUNDING_OFFICE_NUM = f.FUNDING_OFFICE_NUM
            AND a.AGREEMENT_TYPE_CODE in ('DC', 'GR')
            AND c.CONTRACT_TYPE_CODE = p_serv_type 
            AND a.FUNDING_OFFICE_NUM = v_fund_off
            AND a.date_start <= utility.FUN_GET_PY_DATE(utility.FUN_GETCURRNTPROGRAM_YEAR + 3, 'E') 
            AND (SELECT MAX(e.date_end) 
                 FROM aapp_yearend e 
                 WHERE e.aapp_num = a.aapp_num) >= utility.FUN_GET_PY_DATE(utility.FUN_GETCURRNTPROGRAM_YEAR, 'S') 
            Group BY a.AAPP_Num, a.Funding_Office_Num, f.FUNDING_OFFICE_DESC, b.Contractor_Name, d.Center_Name, a.Venue, a.Center_ID, a.Other_Type_desc, AAPP_PROGRAM_ACTIVITY(a.aapp_num, 'S'), a.DATE_START--, (SELECT MAX (e.date_end) FROM aapp_yearend e WHERE e.aapp_num = a.aapp_num)
            ORDER BY centerName, aappNum;
        Elsif p_serv_type = 'S'
            THEN
            OPEN p_outyear_recordset FOR
               Select 
             a.AAPP_NUM as aappNum, 
             a.FUNDING_OFFICE_NUM as fundOffNum, 
             f.FUNDING_OFFICE_DESC as fundOffDesc,
             b.CONTRACTOR_NAME as contractorName, 
             d.CENTER_NAME as centerName, 
             a.VENUE as venue, 
             a.Center_ID as centerID, 
             a.Other_Type_desc as otherTypeDesc,
             AAPP_PROGRAM_ACTIVITY(a.aapp_num, 'S') as progAct, 
             a.DATE_START as dateStart,
             (SELECT MAX (e.date_end)
             FROM aapp_yearend e
             WHERE e.aapp_num = a.aapp_num) AS dateEnd,
             fop_batch.fun_fopcatyearamount(a.aapp_num, v_cost_cat, utility.FUN_GETCURRNTPROGRAM_YEAR) as PY0,
             fop_batch.fun_fopestamount(a.aapp_num, v_cost_cat, utility.FUN_GETCURRNTPROGRAM_YEAR + 1) as PY1, 
             fop_batch.fun_fopestamount_outyear(a.aapp_num, v_cost_cat, utility.FUN_GETCURRNTPROGRAM_YEAR + 2) as PY2, 
             fop_batch.fun_fopestamount_outyear(a.aapp_num, v_cost_cat, utility.FUN_GETCURRNTPROGRAM_YEAR + 3) as PY3 
            FROM AAPP a, 
                 CONTRACTOR b, 
                 AAPP_Contract_Type c, 
                 Center d,
                 lu_Funding_Office f
            WHERE a.CONTRACTOR_ID = b.CONTRACTOR_ID (+)
            AND a.AAPP_NUM = c.AAPP_NUM 
            AND a.CENTER_ID = d.CENTER_ID (+)
            AND a.FUNDING_OFFICE_NUM = f.FUNDING_OFFICE_NUM
            AND a.AGREEMENT_TYPE_CODE in ('DC', 'GR')
            AND c.CONTRACT_TYPE_CODE = p_serv_type 
            AND a.FUNDING_OFFICE_NUM = v_fund_off
            AND a.date_start <= utility.FUN_GET_PY_DATE(utility.FUN_GETCURRNTPROGRAM_YEAR + 3, 'E') 
            AND (SELECT MAX(e.date_end) 
                 FROM aapp_yearend e 
                 WHERE e.aapp_num = a.aapp_num) >= utility.FUN_GET_PY_DATE(utility.FUN_GETCURRNTPROGRAM_YEAR, 'S') 
            Group BY a.AAPP_Num, a.Funding_Office_Num, f.FUNDING_OFFICE_DESC, b.Contractor_Name, d.Center_Name, a.Venue, a.Center_ID, a.Other_Type_desc, AAPP_PROGRAM_ACTIVITY(a.aapp_num, 'S'), a.DATE_START--, (SELECT MAX (e.date_end) FROM aapp_yearend e WHERE e.aapp_num = a.aapp_num)
            ORDER BY otherTypeDesc;
        ELSE
            OPEN p_outyear_recordset FOR
               Select 
             a.AAPP_NUM as aappNum, 
             a.FUNDING_OFFICE_NUM as fundOffNum, 
             f.FUNDING_OFFICE_DESC as fundOffDesc,
             b.CONTRACTOR_NAME as contractorName, 
             d.CENTER_NAME as centerName, 
             a.VENUE as venue, 
             a.Center_ID as centerID, 
             a.Other_Type_desc as otherTypeDesc,
             AAPP_PROGRAM_ACTIVITY(a.aapp_num, 'S') as progAct, 
             a.DATE_START as dateStart,
             (SELECT MAX (e.date_end)
             FROM aapp_yearend e
             WHERE e.aapp_num = a.aapp_num) AS dateEnd,
             fop_batch.fun_fopcatyearamount(a.aapp_num, v_cost_cat, utility.FUN_GETCURRNTPROGRAM_YEAR) as PY0,
             fop_batch.fun_fopestamount(a.aapp_num, v_cost_cat, utility.FUN_GETCURRNTPROGRAM_YEAR + 1) as PY1, 
             fop_batch.fun_fopestamount_outyear(a.aapp_num, v_cost_cat, utility.FUN_GETCURRNTPROGRAM_YEAR + 2) as PY2, 
             fop_batch.fun_fopestamount_outyear(a.aapp_num, v_cost_cat, utility.FUN_GETCURRNTPROGRAM_YEAR + 3) as PY3 
            FROM AAPP a, 
                 CONTRACTOR b, 
                 AAPP_Contract_Type c, 
                 Center d,
                 lu_Funding_Office f
            WHERE a.CONTRACTOR_ID = b.CONTRACTOR_ID (+)
            AND a.AAPP_NUM = c.AAPP_NUM 
            AND a.CENTER_ID = d.CENTER_ID (+)
            AND a.FUNDING_OFFICE_NUM = f.FUNDING_OFFICE_NUM
            AND a.AGREEMENT_TYPE_CODE in ('DC', 'GR')
            AND c.CONTRACT_TYPE_CODE = p_serv_type 
            AND a.FUNDING_OFFICE_NUM = v_fund_off
            AND a.date_start <= utility.FUN_GET_PY_DATE(utility.FUN_GETCURRNTPROGRAM_YEAR + 3, 'E') 
            AND (SELECT MAX(e.date_end) 
                 FROM aapp_yearend e 
                 WHERE e.aapp_num = a.aapp_num) >= utility.FUN_GET_PY_DATE(utility.FUN_GETCURRNTPROGRAM_YEAR, 'S') 
            Group BY a.AAPP_Num, a.Funding_Office_Num, f.FUNDING_OFFICE_DESC, b.Contractor_Name, d.Center_Name, a.Venue, a.Center_ID, a.Other_Type_desc, AAPP_PROGRAM_ACTIVITY(a.aapp_num, 'S'), a.DATE_START--, (SELECT MAX (e.date_end) FROM aapp_yearend e WHERE e.aapp_num = a.aapp_num)
            ORDER BY centerName, venue;
        END IF;    
    END IF;  

   END prc_get_outyear_rpt;
   
   PROCEDURE prc_get_workload_change_rpt (
      p_recordset    OUT      sys_refcursor
   )
   IS
   BEGIN

      -- get cost category:  A
      OPEN p_recordset FOR
         select a.funding_office_num fundingOfficeNum,
            a.aapp_num aappNum,
            aapp_program_activity(a.aapp_num,'S') programActivity,
            --aapp_contract_types(a.aapp_num) contractTypes,
            venue,
            center_name centerName,
            date_start as dateStart,
           (SELECT MAX (ye.date_end)
             FROM aapp_yearend ye
             WHERE ye.aapp_num = a.aapp_num) AS dateEnd,
            contract_year contractYear,
            (select value from aapp_workload where
                aapp_num = a.aapp_num and
                workload_type_code = 'SL' and
                contract_year = y.contract_year) as slots,
            (select value from aapp_workload where
                aapp_num = a.aapp_num and
                workload_type_code = 'AR' and
                contract_year = y.contract_year) as arrivals,
            (select value from aapp_workload where
                aapp_num = a.aapp_num and
                workload_type_code = 'GR' and
                contract_year = y.contract_year) as grads,
            (select value from aapp_workload where
                aapp_num = a.aapp_num and
                workload_type_code = 'FE' and
                contract_year = y.contract_year) as enrollees
        from aapp a, center c, aapp_yearend y
        where a.center_id = c.center_id(+) and
              a.contract_status_id = 1 and
              a.aapp_num = y.aapp_num and
              --a.aapp_num = 1071 and
              a.aapp_num in
              (select a1.aapp_num
              from aapp a1, aapp_yearend ay1,
                (select aapp_num,
                    (select avg(value)
                    from aapp_workload
                    where aapp_num = a1.aapp_num
                         and workload_type_code = 'SL') as slots_average,
                    (select avg(value)
                    from aapp_workload
                    where aapp_num = a1.aapp_num
                         and workload_type_code = 'AR') as arrivals_average,
                    (select avg(value)
                    from aapp_workload
                    where aapp_num = a1.aapp_num
                         and workload_type_code = 'GR') as grads_average,
                    (select avg(value)
                    from aapp_workload
                    where aapp_num = a1.aapp_num
                         and workload_type_code = 'FE') as enrollees_average
                    from aapp a1) ay_avg 
                    where a1.aapp_num = ay1.aapp_num  and
                    a1.aapp_num = ay_avg.aapp_num and
                        (
                          slots_average <> (select value from aapp_workload where
                                            aapp_num = a1.aapp_num and
                                                workload_type_code = 'SL' and
                                            contract_year = ay1.contract_year)
                          or
                          arrivals_average <> (select value from aapp_workload where
                                            aapp_num = a1.aapp_num and
                                                workload_type_code = 'AR' and
                                            contract_year = ay1.contract_year)
                          or
                          grads_average <> (select value from aapp_workload where
                                            aapp_num = a1.aapp_num and
                                                workload_type_code = 'GR' and
                                            contract_year = ay1.contract_year)
                          or
                          enrollees_average <> (select value from aapp_workload where
                                            aapp_num = a1.aapp_num and
                                                workload_type_code = 'FE' and
                                            contract_year = ay1.contract_year)
                          
                          
                          ))
        order by a.aapp_num, contract_year;

      
   END prc_get_workload_change_rpt;

END report;