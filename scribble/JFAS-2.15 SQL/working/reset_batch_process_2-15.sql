delete
from fop
where py = 2015

delete
from batch_process_log
where year = 2015

delete
from splan_trans_det
where splan_trans_id in (select splan_trans_id from splan_trans where py = 2015)

delete
from splan_trans
where py = 2015

delete
from
splan_trans_future