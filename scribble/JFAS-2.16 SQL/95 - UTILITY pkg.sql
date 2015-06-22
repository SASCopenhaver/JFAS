create or replace PACKAGE      utility
AS
   v_py_date_start   VARCHAR2 (10) := '07/01/';
   v_py_date_end     VARCHAR2 (10) := '06/30/';
   v_fy_date_start   VARCHAR2 (10) := '10/01/';
   v_fy_date_end     VARCHAR2 (10) := '09/30/';

   FUNCTION fun_getcurrntprogram_year
      RETURN NUMBER;

   FUNCTION fun_getcurrntprogram_year_ccc
      RETURN NUMBER;

   FUNCTION fun_getcurrntprogram_year_oth
      RETURN NUMBER;

   FUNCTION fun_getcurrntprogram_year_sp  -- sp stands for Spend Plan
      RETURN NUMBER;


   FUNCTION fun_getdate (p_date VARCHAR2, p_year NUMBER)
      RETURN DATE;

   FUNCTION fun_dateoverlap (
      p_start_date1   DATE,
      p_end_date1     DATE,
      p_start_date2   DATE,
      p_end_date2     DATE
   )
      RETURN SMALLINT;

   FUNCTION fun_get_py_date (p_program_year NUMBER, p_type CHAR)
      RETURN DATE;

   FUNCTION fun_get_fep_pers_inflat_rate (p_program_year NUMBER)
      RETURN NUMBER;

   FUNCTION fun_get_omb_inflat_rate (p_date DATE)
      RETURN NUMBER;

   FUNCTION fun_get_omb_inflat_rate (p_date DATE, p_type VARCHAR)
      RETURN NUMBER;

   FUNCTION fun_get_center_name (p_aapp_num NUMBER)
      RETURN VARCHAR2;
   
   Function fun_get_region_num (p_aapp_num NUMBER)
      RETURN NUMBER;  

   FUNCTION fun_get_region_desc (p_aapp_num NUMBER)
      RETURN VARCHAR2;

   FUNCTION fun_get_ccc_region_desc (p_aapp_num NUMBER)
      RETURN VARCHAR2;

   FUNCTION fun_get_contractor_name (p_aapp_num NUMBER)
      RETURN VARCHAR2;

   FUNCTION fun_cnt_date (
      p_aapp_num        NUMBER,
      p_contract_year   NUMBER,
      p_type            CHAR
   )
      RETURN DATE;

   FUNCTION fun_get_year (p_date DATE, p_type CHAR)
      RETURN NUMBER;

   FUNCTION fun_get_quarter (p_date DATE, p_type CHAR)
      RETURN NUMBER;
   
   FUNCTION fun_get_py_prorate_factor (p_program_year NUMBER)
      RETURN NUMBER;
      

END utility;

/

create or replace PACKAGE BODY      utility
AS
   FUNCTION fun_getcurrntprogram_year
      RETURN NUMBER
   AS
      v_num   NUMBER;
   BEGIN
      SELECT MAX (YEAR)
        INTO v_num
        FROM batch_process_log
       WHERE status = 1 AND process_type = 'DOLFOP';

      RETURN v_num;
   END fun_getcurrntprogram_year;

   FUNCTION fun_getcurrntprogram_year_ccc
      RETURN NUMBER
   AS
      v_num   NUMBER;
   BEGIN
      SELECT MAX (YEAR)
        INTO v_num
        FROM batch_process_log
       WHERE status = 1 AND process_type = 'CCC';

      RETURN v_num;
   END fun_getcurrntprogram_year_ccc;

   FUNCTION fun_getcurrntprogram_year_oth
      RETURN NUMBER
   AS
      v_num   NUMBER;
   BEGIN
      SELECT MAX (YEAR)
        INTO v_num
        FROM batch_process_log
       WHERE status = 1 AND process_type = 'OTHER';

      RETURN v_num;
   END fun_getcurrntprogram_year_oth;


   FUNCTION fun_getcurrntprogram_year_sp -- sp stands for Spend Plan
      RETURN NUMBER
   AS
      v_num   NUMBER;
   BEGIN
      SELECT MAX (YEAR)
        INTO v_num
        FROM batch_process_log
       WHERE status = 1 AND process_type = 'SPLAN';

      RETURN v_num;
   END fun_getcurrntprogram_year_sp;



   FUNCTION fun_getdate (p_date VARCHAR2, p_year NUMBER)
      RETURN DATE
   AS
   BEGIN
      RETURN TO_DATE (p_date || TO_CHAR (p_year), 'mm/dd/yyyy');
   END fun_getdate;

   FUNCTION fun_dateoverlap (
      p_start_date1   DATE,
      p_end_date1     DATE,
      p_start_date2   DATE,
      p_end_date2     DATE
   )
      RETURN SMALLINT
   AS
      v_num   SMALLINT := 0;
   BEGIN
      IF     p_start_date1 < p_end_date1
     AND p_start_date2 < p_end_date2
   AND (p_start_date1 BETWEEN p_start_date2 AND p_end_date2
           OR p_end_date1 BETWEEN p_start_date2 AND p_end_date2
           OR (p_start_date1 <= p_start_date2 AND p_end_date2 <= p_end_date1))
      THEN
         v_num := 1;
      END IF;

      RETURN v_num;
   END fun_dateoverlap;

   FUNCTION fun_get_py_date (p_program_year NUMBER, p_type CHAR)
      RETURN DATE
   AS
      v_num   NUMBER := p_program_year + 1;
   BEGIN
      IF p_type = 'S'
      THEN
         RETURN utility.fun_getdate (v_py_date_start, p_program_year);
      ELSE
         RETURN utility.fun_getdate (v_py_date_end, v_num);
      END IF;
   END fun_get_py_date;

   FUNCTION fun_get_fep_pers_inflat_rate (p_program_year NUMBER)
      RETURN NUMBER
   AS
      v_base_py               NUMBER := p_program_year - 1;
      v_base_prg_date_start   DATE
                                  := utility.fun_get_py_date (v_base_py, 'S');
      v_base_prg_date_end     DATE
                                  := utility.fun_get_py_date (v_base_py, 'E');
      v_prg_date_start        DATE
                             := utility.fun_get_py_date (p_program_year, 'S');
      v_prg_date_end          DATE
                             := utility.fun_get_py_date (p_program_year, 'E');
      v_next_py               NUMBER := p_program_year + 1;
      v_base_raise_date       DATE;
      v_base_rate_planned     NUMBER;
      v_base_rate_actual      NUMBER;
      v_base_days_prior       NUMBER;
      v_base_days_after       NUMBER;
      v_base_cost             NUMBER;
      v_next_prg_date_start   DATE
                                  := utility.fun_get_py_date (v_next_py, 'S');
      v_next_prg_date_end     DATE
                                  := utility.fun_get_py_date (v_next_py, 'E');
      v_raise_date            DATE;
      v_rate_planned          NUMBER;
      v_rate_actual           NUMBER;
      v_days_prior            NUMBER;
      v_days_after            NUMBER;
      v_cost                  NUMBER;
   BEGIN
      SELECT date_start, rate_planned, rate_actual
        INTO v_base_raise_date, v_base_rate_planned, v_base_rate_actual
        FROM fed_pers_inflation
       WHERE YEAR = p_program_year;

      v_base_days_prior :=
                     datediff ('DD', v_base_prg_date_start, v_base_raise_date)
      ;
      v_base_days_after :=
                    datediff ('DD', v_base_raise_date, v_base_prg_date_end);
      -- negate leap year
   if datediff ('DD', v_base_prg_date_start, v_base_prg_date_end) < 365 then
     v_base_days_after := v_base_days_after + 1;
   end if;
   
   v_base_cost :=
           v_base_days_prior * 100 / 100
         + v_base_days_after * (100 + v_base_rate_planned) / 100;

      SELECT date_start, rate_planned, rate_actual
        INTO v_raise_date, v_rate_planned, v_rate_actual
        FROM fed_pers_inflation
       WHERE YEAR = v_next_py;

      v_days_prior := datediff ('DD', v_prg_date_start, v_raise_date);
      v_days_after := datediff ('DD', v_raise_date, v_prg_date_end);
   -- negate leap year
   if datediff ('DD', v_prg_date_start, v_prg_date_end) < 365 then
    v_days_after := v_days_after + 1;
   end if;
   
      v_cost :=
           v_days_prior * (100 + v_base_rate_actual) / 100
         +   v_days_after
           * (100 + v_rate_planned)
           / 100
           * (100 + v_base_rate_actual)
           / 100;
      RETURN ROUND (v_cost / v_base_cost * 10000) / 10000;
   END fun_get_fep_pers_inflat_rate;

   FUNCTION fun_get_omb_inflat_rate (p_date DATE)
      RETURN NUMBER
   AS
      v_rate   NUMBER;
   BEGIN
      SELECT inflation_rate
        INTO v_rate
        FROM (SELECT   inflation_rate
                  FROM omb_inflation
                 WHERE YEAR <= p_date
              ORDER BY YEAR DESC)
       WHERE ROWNUM < 2;

      RETURN v_rate;
   END fun_get_omb_inflat_rate;

   FUNCTION fun_get_omb_inflat_rate (p_date DATE, p_type VARCHAR)
      RETURN NUMBER
   AS
      v_rate   NUMBER := 1;
   BEGIN
      IF p_type = 'B3'
      THEN
         SELECT VALUE
           INTO v_rate
           FROM system_setting
          WHERE system_setting_code = 'inflation_rate_vehicle';
      ELSE
         v_rate := utility.fun_get_omb_inflat_rate (p_date);
      END IF;

      RETURN v_rate;
   END fun_get_omb_inflat_rate;

   FUNCTION fun_get_center_name (p_aapp_num NUMBER)
      RETURN VARCHAR2
   AS
      v_center_name   center.center_name%TYPE;
   BEGIN
      BEGIN
         SELECT b.center_name
           INTO v_center_name
           FROM aapp a, center b
          WHERE a.aapp_num = p_aapp_num AND a.center_id = b.center_id;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            v_center_name := '';
      END;

      RETURN v_center_name;
   END fun_get_center_name;
   
   FUNCTION fun_get_region_num (p_aapp_num NUMBER)
      RETURN NUMBER
   AS 
       v_region_num  lu_region.region_num%TYPE;
   BEGIN
      BEGIN
      Select a.FUNDING_OFFICE_NUM
   INTO v_region_num
   FROM aapp a
         WHERE a.aapp_num = p_aapp_num;
   End;
   
   RETURN v_region_num;
   END fun_get_region_num;

   FUNCTION fun_get_region_desc (p_aapp_num NUMBER)
      RETURN VARCHAR2
   AS
      v_region_desc   lu_region.region_desc%TYPE;
   BEGIN
      BEGIN
         SELECT c.region_desc
           INTO v_region_desc
           FROM aapp a, lu_funding_office b, lu_region c
          WHERE a.aapp_num = p_aapp_num
            AND a.funding_office_num = b.funding_office_num
            AND b.region_num = c.region_num;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            v_region_desc := '';
      END;

      RETURN v_region_desc;
   END fun_get_region_desc;

   FUNCTION fun_get_ccc_region_desc (p_aapp_num NUMBER)
      RETURN VARCHAR2
   AS
      v_region_desc   lu_region.region_desc%TYPE;
   BEGIN
      BEGIN
         SELECT d.region_desc
           INTO v_region_desc
           FROM aapp a, center b, lu_state c, lu_region d
          WHERE a.aapp_num = p_aapp_num
            AND a.center_id = b.center_id
            AND b.state_abbr = c.state_abbr
            AND c.region_num = d.region_num;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            v_region_desc := '';
      END;

      RETURN v_region_desc;
   END fun_get_ccc_region_desc;

   FUNCTION fun_get_contractor_name (p_aapp_num NUMBER)
      RETURN VARCHAR2
   AS
      v_contractor_name   contractor.contractor_name%TYPE;
   BEGIN
      BEGIN
         SELECT b.contractor_name
           INTO v_contractor_name
           FROM aapp a, contractor b
          WHERE a.aapp_num = p_aapp_num AND a.contractor_id = b.contractor_id;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            v_contractor_name := '';
      END;

      RETURN v_contractor_name;
   END fun_get_contractor_name;

   
   FUNCTION fun_cnt_date (
      p_aapp_num        NUMBER,
      p_contract_year   NUMBER,
      p_type            CHAR
   )
      RETURN DATE
   AS
      v_date   aapp.date_start%TYPE;
      v_num    NUMBER;
   BEGIN
      SELECT COUNT (1)
        INTO v_num
        FROM aapp_yearend
       WHERE aapp_num = p_aapp_num AND contract_year = p_contract_year;

      IF v_num = 0
      THEN
         IF p_type = 'S'
         THEN
            SELECT date_start
              INTO v_date
              FROM aapp
             WHERE aapp_num = p_aapp_num;
         ELSE
            SELECT MAX (date_end)
              INTO v_date
              FROM aapp_yearend
             WHERE aapp_num = p_aapp_num;
         END IF;
      ELSE
         --Start Date
         IF p_type = 'S'
         THEN
            IF p_contract_year = 1
            THEN
               SELECT date_start
                 INTO v_date
                 FROM aapp
                WHERE aapp_num = p_aapp_num;
            ELSE
               SELECT date_end + 1
                 INTO v_date
                 FROM aapp_yearend
                WHERE aapp_num = p_aapp_num
                  AND contract_year = p_contract_year - 1;
            END IF;
         --End Date
         ELSE
            SELECT date_end
              INTO v_date
              FROM aapp_yearend
             WHERE aapp_num = p_aapp_num AND contract_year = p_contract_year;
         END IF;
      END IF;

      RETURN v_date;
   END fun_cnt_date;

   FUNCTION fun_get_year (p_date DATE, p_type CHAR)
      RETURN NUMBER
   AS
      v_year   NUMBER := 0;
      v_date   DATE   := NVL (p_date, SYSDATE);
   /*************************************
      TYPE
      P Program Year
      F Fiscal Year
      C Calendar Year
      *************************************/
   BEGIN
      IF p_type = 'P'
      THEN
         IF     TO_CHAR (v_date, 'yyyy') || '/' || '01/01/' <=
                                              TO_CHAR (v_date, 'yyyy/mm/dd/')
            AND TO_CHAR (v_date, 'yyyy/mm/dd/') <
                             TO_CHAR (v_date, 'yyyy') || '/'
                             || v_py_date_start
         THEN
            v_year := TO_NUMBER (TO_CHAR (v_date, 'yyyy')) - 1;
         ELSE
            v_year := TO_NUMBER (TO_CHAR (v_date, 'yyyy'));
         END IF;
      ELSIF p_type = 'F'
      THEN
         IF     TO_CHAR (v_date, 'yyyy') || '/' || '01/01/' <=
                                              TO_CHAR (v_date, 'yyyy/mm/dd/')
            AND TO_CHAR (v_date, 'yyyy/mm/dd/') <
                             TO_CHAR (v_date, 'yyyy') || '/'
                             || v_fy_date_start
         THEN
            v_year := TO_NUMBER (TO_CHAR (v_date, 'yyyy'));
         ELSE
            v_year := TO_NUMBER (TO_CHAR (v_date, 'yyyy')) + 1;
         END IF;
      ELSE
         v_year := TO_NUMBER (TO_CHAR (v_date, 'yyyy'));
      END IF;

      RETURN v_year;
   END fun_get_year;

   FUNCTION fun_get_quarter (p_date DATE, p_type CHAR)
      RETURN NUMBER
   AS
      v_quarter      NUMBER := 0;
      v_date_start   DATE;
      v_year         NUMBER := 0;
      v_date         DATE   := NVL (p_date, SYSDATE);
   /*************************************
   TYPE
   P Program Year
   F Fiscal Year
   C Calendar Year
   *************************************/
   BEGIN
      IF p_type = 'P'
      THEN
         v_year := utility.fun_get_year (v_date, p_type);
         v_date_start := utility.fun_get_py_date (v_year, 'S');
      ELSIF p_type = 'F'
      THEN
         SELECT YEAR
           INTO v_date_start
           FROM (SELECT   YEAR
                     FROM omb_inflation
                    WHERE YEAR < v_date
                 ORDER BY YEAR DESC)
          WHERE ROWNUM < 2;
      ELSE
         v_date_start :=
                 TO_DATE ('01/01/' || TO_CHAR (v_date, 'yyyy'), 'mm/dd/yyyy');
      END IF;

      SELECT FLOOR (ABS (MONTHS_BETWEEN (v_date_start, v_date)) / 3) + 1
        INTO v_quarter
        FROM DUAL;

      RETURN v_quarter;
   END fun_get_quarter;
   
   FUNCTION fun_get_py_prorate_factor (p_program_year NUMBER)
      RETURN NUMBER
 AS
   v_prev_program_year   NUMBER      := p_program_year - 1;
   v_prev_prg_date_start DATE        := utility.fun_get_py_date (v_prev_program_year, 'S');
      v_prev_prg_date_end   DATE        := utility.fun_get_py_date (v_prev_program_year, 'E');
   v_prg_date_start      DATE        := utility.fun_get_py_date (p_program_year, 'S');
      v_prg_date_end        DATE        := utility.fun_get_py_date (p_program_year, 'E');
   v_prev_prg_length     NUMBER;
   v_prg_length          NUMBER;
 
    BEGIN
      -- determine ratio between next program year length, and current program year length
   -- used in CCC worksheet calculations
   -- program year passed in should be the COMING program year 
   
     v_prev_prg_length := datediff ('DD', v_prev_prg_date_start, v_prev_prg_date_end);
     v_prg_length :=  datediff ('DD', v_prg_date_start, v_prg_date_end);
 RETURN ROUND((v_prg_length / v_prev_prg_length) * 10000) / 10000;
      
   END fun_get_py_prorate_factor;
   
  
END utility;