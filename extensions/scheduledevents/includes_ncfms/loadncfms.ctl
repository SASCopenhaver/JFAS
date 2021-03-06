LOAD DATA 
truncate
INTO TABLE footprint_xactn_ncfms_load  
FIELDS TERMINATED BY '|' 
OPTIONALLY ENCLOSED BY '"' 
trailing nullcols
(agency_code,
  doc_type,
  fy ,
  doc_num ,
  amend_num ,
  account_id ,
  agency_id ,
  budget_yr ,
  approp_code ,
  prog_proj ,
  activity ,
  sub_activity,
  funding_org ,
  managing_unit ,
  benefit_unit_code ,
  obj_class_code ,
  proj_num ,
  task_num ,
  reimb_agree_num_code,
  creation_date ,
  effective_date ,
  period_name ,
  vendor_name ,
  vendor_tin ,
  vendor_duns ,
  vendor_state,
  invoice_num,
  funding ,
  commitment,
  undelivered_order,
  accrual ,
  advance,
  unpaid_exp ,
  paid_exp)
