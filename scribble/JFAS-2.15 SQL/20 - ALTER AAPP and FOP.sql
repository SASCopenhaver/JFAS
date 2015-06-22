ALTER TABLE AAPP ADD SPLAN_CAT_ID NUMBER;

-- set all active national office AAPPs to cat 34 (Misc expenses)
update aapp
set splan_cat_id = 34
where funding_office_num = 20 and
      contract_status_id = 1 and
      splan_cat_id is null;

commit;

ALTER TABLE FOP ADD SPLAN_TRANS_DET_ID NUMBER;