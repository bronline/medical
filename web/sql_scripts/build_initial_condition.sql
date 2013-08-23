﻿insert into patientconditions
select null, id, 0, 'Initial Condition', 'Auto-Generated by ChiroPractice',
ifnull((select min(date) from visits where patientid=p.id),'2009-01-01'), '2075-12-31'
from patients p where id not in (select distinct patientid from patientconditions);

update visits set conditionid=(select min(id) from patientconditions where patientid=visits.patientid)
where conditionid=0;