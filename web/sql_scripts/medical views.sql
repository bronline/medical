DROP VIEW IF EXISTS `appointmentsmade`;
CREATE VIEW  `appointmentsmade` AS select sql_no_cache `a`.`id` AS `id`,`a`.`patientid` AS `patientid`,`a`.`date` AS `date`,`a`.`time` AS `time`,`a`.`type` AS `type`,`a`.`intervals` AS `intervals`,`a`.`timein` AS `timein`,`a`.`missedreason` AS `missedreason` from `appointments` `a` where (((`a`.`date` < curdate()) or ((`a`.`date` = curdate()) and (`a`.`time` < curtime()))) and exists(select `visits`.`id` AS `id` from `visits` where (`visits`.`appointmentid` = `a`.`id`)));

DROP VIEW IF EXISTS `appointmentsmissed`;
CREATE VIEW `appointmentsmissed` AS select sql_no_cache `a`.`id` AS `id`,`a`.`patientid` AS `patientid`,`a`.`date` AS `date`,`a`.`time` AS `time`,`a`.`type` AS `type`,`a`.`intervals` AS `intervals`,`a`.`timein` AS `timein`,`a`.`missedreason` AS `missedreason` from `appointments` `a` where (`a`.`missedreason` is null or a.missedreason='') and (`a`.`date` < curdate() or (`a`.`date` = curdate() and `a`.`time` < curtime()) and (not ( exists (select `visits`.`id` AS `id` from `visits` where (`visits`.`appointmentid` = `a`.`id`)))));

DROP VIEW IF EXISTS `billingaccounts`;
CREATE VIEW  `billingaccounts` AS select `patients`.`id` AS `id`,`patients`.`accountnumber` AS `accountnumber`,concat(`patients`.`lastname`,_latin1', ',`patients`.`firstname`,_latin1' ',`patients`.`middlename`) AS `name`,`patients`.`address` AS `address`,`patients`.`city` AS `city`,`patients`.`state` AS `state`,`patients`.`zipcode` AS `zipcode`,date_format(`patients`.`dob`,_utf8'%m') AS `birthmonth`,date_format(`patients`.`dob`,_utf8'%d') AS `birthday`,date_format(`patients`.`dob`,_utf8'%Y') AS `birthyear`,substr(cast(`patients`.`homephone` as char charset utf8),1,3) AS `areacode`,substr(cast(`patients`.`homephone` as char charset utf8),4,7) AS `phonenumber`,(case when (`patients`.`gender` = 1) then _utf8'X' else _utf8' ' end) AS `male`,(case when (`patients`.`gender` > 1) then _utf8'X' else _utf8' ' end) AS `female`,`patients`.`employer` AS `employer`,(case when (`patients`.`conditionid` = 2) then _utf8'X' else _utf8' ' end) AS `employmentyes`,(case when (`patients`.`conditionid` = 3) then _utf8'X' else _utf8' ' end) AS `autoyes`,(case when (`patients`.`conditionid` = 3) then `patients`.`accidentstate` else _utf8' ' end) AS `autostate`,(case when (`patients`.`conditionid` = 4) then _utf8'X' else _utf8' ' end) AS `otheryes`,(case when (`patients`.`conditionid` <> 1) then date_format(`patients`.`accidentdate`,_utf8'%m') else _utf8' ' end) AS `14mm`,(case when (`patients`.`conditionid` <> 1) then date_format(`patients`.`accidentdate`,_utf8'%d') else _utf8' ' end) AS `14dd`,(case when (`patients`.`conditionid` <> 1) then date_format(`patients`.`accidentdate`,_utf8'%Y') else _utf8' ' end) AS `14yy`,(case when (`patients`.`conditionid` <> 2) then _utf8'X' else _utf8' ' end) AS `employmentno`,(case when (`patients`.`conditionid` <> 3) then _utf8'X' else _utf8' ' end) AS `autono`,(case when (`patients`.`conditionid` <> 4) then _utf8'X' else _utf8' ' end) AS `otherno` from `patients`;

DROP VIEW IF EXISTS `chargediagnosis`;
CREATE VIEW  `chargediagnosis` AS select `cms1500diagnosis`.`patientid` AS `patientid`,(case when (count(`cms1500diagnosis`.`21a`) = 1) then _utf8'1' when (count(`cms1500diagnosis`.`21a`) = 2) then _utf8'12' when (count(`cms1500diagnosis`.`21a`) = 3) then _utf8'123' when (count(`cms1500diagnosis`.`21a`) > 3) then _utf8'1234' end) AS `diagnosiscode` from `cms1500diagnosis` group by `cms1500diagnosis`.`patientid`;

DROP VIEW IF EXISTS `chargepaymentsbyinsurance`;
CREATE VIEW  `chargepaymentsbyinsurance` AS select `a`.`chargeid` AS `chargeid`,sum(`a`.`amount`) AS `amount` from (`payments` `a` join `providers` `b` on((`a`.`provider` = `b`.`id`))) where ((not(`b`.`reserved`)) and (`a`.`provider` <> 10)) group by `a`.`chargeid`;

DROP VIEW IF EXISTS `chargepaymentsbypatient`;
CREATE VIEW  `chargepaymentsbypatient` AS select `a`.`chargeid` AS `chargeid`,sum(`a`.`amount`) AS `amount` from (`payments` `a` left join `providers` `b` on((`a`.`provider` = `b`.`id`))) where ((`a`.`provider` = 0) or (`b`.`reserved` and (`a`.`provider` <> 10))) group by `a`.`chargeid`;

DROP VIEW IF EXISTS `chargesbyvisit`;
CREATE VIEW  `chargesbyvisit` AS select `charges`.`visitid` AS `visitid`,count(0) AS `itemcount`,sum(`charges`.`chargeamount`) AS `chargeamount` from `charges` group by `charges`.`visitid`;

DROP VIEW IF EXISTS `chargesummary`;
CREATE VIEW  `chargesummary` AS select `a`.`id` AS `chargeid`,`b`.`date` AS `chargedate`,`c`.`description` AS `chargeitem`,`a`.`chargeamount` AS `chargeamount` from ((`charges` `a` join `visits` `b` on((`a`.`visitid` = `b`.`id`))) join `items` `c` on((`a`.`itemid` = `c`.`id`)));

DROP VIEW IF EXISTS `chargewriteoffs`;
CREATE VIEW  `chargewriteoffs` AS select `writeoffs`.`chargeid` AS `chargeid`,sum(`writeoffs`.`amount`) AS `amount` from `writeoffs` group by `writeoffs`.`chargeid`;

DROP VIEW IF EXISTS `documenttemplatelist`;
CREATE VIEW  `documenttemplatelist` AS select `documenttemplates`.`id` AS `id`,`documenttypes`.`description` AS `Type`,`documentidentifiers`.`identifier` AS `identifier`,`documenttemplates`.`description` AS `description`,`documenttemplates`.`pathtotemplate` AS `pathtotemplate` from ((`documenttemplates` left join `documenttypes` on((`documenttypes`.`id` = `documenttemplates`.`type`))) left join `documentidentifiers` on((`documentidentifiers`.`id` = `documenttemplates`.`identifier`)));

DROP VIEW IF EXISTS `duetoday`;
CREATE VIEW  `duetoday` AS select `c`.`id` AS `chargeid`,`c`.`visitid` AS `visitid`,`c`.`itemid` AS `itemid`,ifnull(`v`.`patientid`,0) AS `patientid`,`c`.`resourceid` AS `resourceid`,`c`.`chargeamount` AS `chargeamount`,`c`.`copayamount` AS `copayamount`,ifnull(`p`.`checknumber`,0) AS `checknumber`,ifnull(`p`.`amount`,0) AS `amount`,`v`.`date` AS `visitdate`,ifnull(`p`.`date`,_utf8'0001-01-01') AS `paymentdate` from ((`charges` `c` left join `payments` `p` on((`p`.`chargeid` = `c`.`id`))) left join `visits` `v` on((`c`.`visitid` = `v`.`id`))) where ((`c`.`copayamount` <> 0) and ((select ifnull(sum(`p`.`amount`),0) AS `ifnull(sum(amount), 0)` from `payments` `p` where (`p`.`chargeid` = `c`.`id`)) < `c`.`copayamount`));

DROP VIEW IF EXISTS `employmentstatus`;
CREATE VIEW  `employmentstatus` AS select `occupation`.`id` AS `id`,(case when (`occupation`.`occupation` = _latin1'FT Student') then _utf8'S' when (`occupation`.`occupation` = _latin1'PT Student') then _utf8'P' when (`occupation`.`occupation` <> _latin1'Unemployed') then _utf8'E' else _utf8'U' end) AS `employmentstatus` from `occupation`;

DROP VIEW IF EXISTS `facilityaddress`;
CREATE VIEW `facilityaddress` AS
select `resources`.`id` AS `id`,
(case when (trim(`resources`.`officename`) = _latin1'') then `environment`.`facilityname` else `resources`.`officename` end) AS `facilityname`,
(case when (trim(`resources`.`address`) = _latin1'') then
  substr(`environment`.`facilityaddress`,1,(locate(_latin1'\r',`environment`.`facilityaddress`) - 2))
else
  substr(`resources`.`address`,1,(locate(_latin1'\r',`resources`.`address`) - 2))
end) AS `facilityaddress`,
(case when (trim(`resources`.`address`) = _latin1'') then
  substr(`environment`.`facilityaddress`,(locate(_latin1'\r',`environment`.`facilityaddress`) + 2))
else
  substr(`resources`.`address`,(locate(_latin1'\rl',`resources`.`address`) + 2))
end) AS `facilitycsz`,
(case when (trim(`resources`.`pin`) = _latin1'') then `environment`.`pin` else `resources`.`pin` end) AS `pin`,
`resources`.`pin` AS `providernpi`,
(case when (trim(`resources`.`grp`) = _latin1'') then `environment`.`grp` else `resources`.`grp` end) AS `grp`,
(case when (trim(`resources`.`taxid`) = _latin1'') then `environment`.`taxid` else `resources`.`taxid` end) AS `taxid`,
`environment`.`pin` AS `practicenpi` from (`resources` join `environment`);


DROP VIEW IF EXISTS `firstvisits`;
CREATE VIEW  `firstvisits` AS select `visits`.`patientid` AS `patientid`,min(`visits`.`date`) AS `date` from `visits` group by `visits`.`patientid`;

DROP VIEW IF EXISTS `insurancedisplay`;
CREATE VIEW  `insurancedisplay` AS select `patientinsurance`.`id` AS `id`,`patientinsurance`.`patientid` AS `patientid`,`patientinsurance`.`providerid` AS `providerid`,`providers`.`name` AS `name`,`patientinsurance`.`providernumber` AS `providernumber`,`patientinsurance`.`providergroup` AS `providergroup`,`relationship`.`relationship` AS `relationship`,`patientinsurance`.`primaryprovider` AS `primaryprovider` from ((`patientinsurance` left join `providers` on((`providers`.`id` = `patientinsurance`.`providerid`))) left join `relationship` on((`patientinsurance`.`relationshipid` = `relationship`.`id`)));

DROP VIEW IF EXISTS `insuranceinformation`;
CREATE VIEW `insuranceinformation` AS
select `patientinsurance`.`patientid` AS `patientid`,`patientinsurance`.`providerid` AS `providerid`,
`patientinsurance`.`providernumber` AS `providernumber`,`patientinsurance`.`providergroup` AS `providergroup`,
`patientinsurance`.`planname` AS `planname`,`providers`.`box19` AS `box19`,
(case when (`providers`.`category` = 1) then _utf8'X' else _utf8' ' end) AS `medicare`,
(case when (`providers`.`category` = 2) then _utf8'X' else _utf8' ' end) AS `medicaid`,
(case when (`providers`.`category` = 3) then _utf8'X' else _utf8' ' end) AS `champus`,
(case when (`providers`.`category` = 4) then _utf8'X' else _utf8' ' end) AS `champusva`,
(case when (`providers`.`category` = 5) then _utf8'X' else _utf8' ' end) AS `ghp`,
(case when (`providers`.`category` = 6) then _utf8'X' else _utf8' ' end) AS `feca`,
(case when (`providers`.`category` = 7) then _utf8'X' else _utf8' ' end) AS `otherhp`,
(case when (`providers`.`assignment` = 1) then _utf8'X' else _utf8' ' end) AS `assignmentyes`,
(case when (`providers`.`assignment` = 0) then _utf8'X' else _utf8' ' end) AS `assignmentno`,
(case when (`patientinsurance`.`relationshipid` < 2) then _utf8'X' else _utf8' ' end) AS `relationshipself`,
(case when (`patientinsurance`.`relationshipid` = 2) then _utf8'X' else _utf8' ' end) AS `relationshipspouse`,
(case when (`patientinsurance`.`relationshipid` = 3) then _utf8'X' else _utf8' ' end) AS `relationshipchild`,
(case when (`patientinsurance`.`relationshipid` = 4) then _utf8'X' else _utf8' ' end) AS `relationshipother`,
(select count(0) AS `count(*)` from `patientinsurance` `p` where (`p`.`patientid` = `patientinsurance`.`patientid`)) AS `insuranceproviders`,
`providers`.`name` AS `providername`,substr(`providers`.`address`,1,(locate(_latin1'\n',`providers`.`address`) - 1)) AS `provideraddress1`,
substr(`providers`.`address`,(locate(_latin1'\n',`providers`.`address`) + 1),locate(_latin1'\n',substr(`providers`.`address`,(locate(_latin1'\n',`providers`.`address`) + 1)))) AS `provideraddress2`,
substr(substr(`providers`.`address`,(locate(_latin1'\n',`providers`.`address`) + 1)),(locate(_latin1'\n',substr(`providers`.`address`,(locate(_latin1'\n',`providers`.`address`) + 1))) + 1)) AS `provideraddress3`
from (`patientinsurance` left join `providers` on((`patientinsurance`.`providerid` = `providers`.`id`)));

DROP VIEW IF EXISTS `nonbillableitems`;
CREATE  VIEW  `nonbillableitems` AS select `a`.`patientid` AS `patientid`,`a`.`providerid` AS `providerid`,`a`.`itemid` AS `itemid` from `patientprovideritems` `a` where (exists(select `defaultpayments`.`id` AS `id` from `defaultpayments` where ((not(`defaultpayments`.`billinsurance`)) and (`defaultpayments`.`patientid` = `a`.`patientid`) and (`defaultpayments`.`providerid` = `a`.`providerid`) and (`defaultpayments`.`itemid` = `a`.`itemid`))) or (exists(select `defaultpayments`.`id` AS `id` from `defaultpayments` where ((not(`defaultpayments`.`billinsurance`)) and (`defaultpayments`.`patientid` = 0) and (`defaultpayments`.`providerid` = `a`.`providerid`) and (`defaultpayments`.`itemid` = `a`.`itemid`))) and (not(exists(select `defaultpayments`.`id` AS `id` from `defaultpayments` where (`defaultpayments`.`billinsurance` and (`defaultpayments`.`patientid` = `a`.`patientid`) and (`defaultpayments`.`providerid` = `a`.`providerid`) and (`defaultpayments`.`itemid` = `a`.`itemid`)))))));

DROP VIEW IF EXISTS `paidamounts`;
CREATE VIEW  `paidamounts` AS select `p`.`patientid` AS `patientid`,`p`.`chargeid` AS `chargeid`,sum(`p`.`amount`) AS `paidamount` from `payments` `p` group by `p`.`patientid`,`p`.`chargeid`;


DROP VIEW IF EXISTS `patientappointments`;
CREATE VIEW  `patientappointments` AS select `a`.`id` AS `id`,`a`.`patientid` AS `patientid`,`b`.`type` AS `type`,`a`.`date` AS `date`,`a`.`time` AS `time`,`b`.`bgcolor` AS `bgcolor`,`b`.`textcolor` AS `textcolor` from (`appointments` `a` left join `appointmenttypes` `b` on((`a`.`type` = `b`.`id`)));

DROP VIEW IF EXISTS `patientbalance`;
CREATE VIEW  `patientbalance` AS select `a`.`id` AS `id`,`a`.`date` AS `date`,`a`.`description` AS `description`,`a`.`chargeamount` AS `chargeamount`,ifnull(`e`.`paidamount`,0) AS `paidamount`,cast((`a`.`chargeamount` - ifnull(`e`.`paidamount`,0)) as decimal) AS `balance`,`a`.`patientid` AS `patientid` from (`patientchargesummary` `a` left join `paidamounts` `e` on((`a`.`id` = `e`.`chargeid`)));

DROP VIEW IF EXISTS `patientchargesummary`;
CREATE VIEW  `patientchargesummary` AS select `c`.`id` AS `id`,`v`.`date` AS `date`,`v`.`patientid` AS `patientid`,concat(`i`.`code`,_latin1' - ',`i`.`description`) AS `description`,`c`.`chargeamount` AS `chargeamount` from ((`visits` `v` join `charges` `c` on((`c`.`visitid` = `v`.`id`))) join `items` `i` on((`c`.`itemid` = `i`.`id`)));

DROP VIEW IF EXISTS `patientdocumentlist`;
CREATE VIEW  `patientdocumentlist` AS select `a`.`id` AS `id`,`a`.`patientid` AS `patientid`,`b`.`description` AS `type`,`c`.`identifier` AS `identifier`,`a`.`documentpath` AS `documentpath`,`a`.`description` AS `description` from ((`patientdocuments` `a` left join `documenttypes` `b` on((`b`.`id` = `a`.`documenttype`))) left join `documentidentifiers` `c` on((`c`.`id` = `a`.`identifierid`)));


DROP VIEW IF EXISTS `patientplanvisits`;
CREATE VIEW  `patientplanvisits` AS select count(`v`.`id`) AS `visits`,`v`.`patientid` AS `patientid` from (`visits` `v` join `patientplan` `p` on((`v`.`patientid` = `p`.`patientid`))) where ((`v`.`date` >= `p`.`startdate`) and (`v`.`date` <= `p`.`enddate`)) group by `v`.`patientid`;

DROP VIEW IF EXISTS `patientprovideritems`;
CREATE VIEW  `patientprovideritems` AS select distinct `a`.`patientid` AS `patientid`,`a`.`providerid` AS `providerid`,`b`.`id` AS `itemid` from (`patientinsurance` `a` join `items` `b`);

DROP VIEW IF EXISTS `patientsinbatch`;
CREATE VIEW  `patientsinbatch` AS select distinct `v`.`patientid` AS `patientid`,`b`.`batchid` AS `batchid`,`a`.`name` AS `name` from (((`batchcharges` `b` join `charges` `c` on((`b`.`chargeid` = `c`.`id`))) join `visits` `v` on((`c`.`visitid` = `v`.`id`))) join `billingaccounts` `a` on((`v`.`patientid` = `a`.`id`)));

DROP VIEW IF EXISTS `patientvisitlist`;
CREATE VIEW  `patientvisitlist` AS select `a`.`id` AS `id`,`a`.`patientid` AS `patientid`,`a`.`date` AS `date`,`c`.`description` AS `type`,`d`.`itemcount` AS `itemcount`,`d`.`charges` AS `charges`,`d`.`inspayments` AS `inspayments`,`d`.`patpayments` AS `patpayments`,`d`.`writeoffs` AS `writeoffs`,(((`d`.`charges` - `d`.`inspayments`) - `d`.`patpayments`) - `d`.`writeoffs`) AS `balance` from (((`visits` `a` left join `appointments` `b` on((`a`.`appointmentid` = `b`.`id`))) left join `appointmenttypes` `c` on((`b`.`type` = `c`.`id`))) left join `visitledger` `d` on((`a`.`id` = `d`.`visitid`))) order by 1 desc;

DROP VIEW IF EXISTS `patientvisits`;
CREATE VIEW  `patientvisits` AS select `visits`.`id` AS `visitid`,`patients`.`id` AS `patientid`,`patients`.`accountnumber` AS `accountnumber`,`visits`.`date` AS `date` from (`patients` left join `visits` on((`patients`.`id` = `visits`.`patientid`))) order by `patients`.`accountnumber`,`visits`.`date`;

DROP VIEW IF EXISTS `paymentsbyinsurance`;
CREATE VIEW  `paymentsbyinsurance` AS select `a`.`id` AS `id`,`a`.`provider` AS `provider`,`a`.`checknumber` AS `checknumber`,`a`.`amount` AS `amount`,`a`.`chargeid` AS `chargeid`,`a`.`patientid` AS `patientid`,`a`.`date` AS `date`,`a`.`parentpayment` AS `parentpayment`,`a`.`originalamount` AS `originalamount` from (`payments` `a` join `providers` `b` on((`a`.`provider` = `b`.`id`))) where ((not(`b`.`reserved`)) and (`a`.`provider` <> 10));

DROP VIEW IF EXISTS `paymentsbypatient`;
CREATE VIEW  `paymentsbypatient` AS select `a`.`id` AS `id`,`a`.`provider` AS `provider`,`a`.`checknumber` AS `checknumber`,`a`.`amount` AS `amount`,`a`.`chargeid` AS `chargeid`,`a`.`patientid` AS `patientid`,`a`.`date` AS `date`,`a`.`parentpayment` AS `parentpayment`,`a`.`originalamount` AS `originalamount` from (`payments` `a` left join `providers` `b` on((`a`.`provider` = `b`.`id`))) where ((`a`.`provider` = 0) or (`b`.`reserved` and (`a`.`provider` <> 10)));

DROP VIEW IF EXISTS `paymentsummary`;
CREATE VIEW  `paymentsummary` AS select `a`.`id` AS `paymentid`,`a`.`amount` AS `paymentamount`,`b`.`chargeamount` AS `chargeamount`,ifnull(`e`.`name`,_latin1'Cash') AS `provider`,`d`.`description` AS `chargeitem`,`a`.`date` AS `paymentdate`,`c`.`date` AS `chargedate`,`a`.`parentpayment` AS `parentpayment` from ((((`payments` `a` join `charges` `b` on((`a`.`chargeid` = `b`.`id`))) join `visits` `c` on((`b`.`visitid` = `c`.`id`))) join `items` `d` on((`b`.`itemid` = `d`.`id`))) left join `providers` `e` on((`a`.`provider` = `e`.`id`))) where (`a`.`amount` > 0);

DROP VIEW IF EXISTS `providerchargesummary`;
CREATE VIEW  `providerchargesummary` AS select `a`.`patientid` AS `patientId`,cast(sum(`a`.`chargeamount`) as decimal) AS `Charges`,count(0) AS `Items`,`c`.`lastname` AS `Last`,`c`.`firstname` AS `First`,`b`.`name` AS `Provider`,`d`.`providerid` AS `providerid`,`a`.`date` AS `date` from (((`patientbalance` `a` join `patients` `c` on((`a`.`patientid` = `c`.`id`))) join `patientinsurance` `d` on((`c`.`id` = `d`.`patientid`))) join `providers` `b` on((`d`.`providerid` = `b`.`id`))) where (`a`.`balance` <> 0) group by `a`.`patientid`,`c`.`lastname`,`c`.`firstname`,`d`.`providerid`,`a`.`date` order by `c`.`lastname`,`c`.`firstname`;

DROP VIEW IF EXISTS `showappointments`;
CREATE VIEW  `showappointments` AS select `a`.`id` AS `id`,`a`.`patientid` AS `patientid`,`a`.`date` AS `date`,`a`.`time` AS `time`,ifnull(`b`.`type`,_latin1'Unknown Type') AS `type`,ifnull(`b`.`bgcolor`,_latin1'') AS `bgcolor`,ifnull(`b`.`textcolor`,_latin1'') AS `textcolor` from (`appointments` `a` left join `appointmenttypes` `b` on((`a`.`type` = `b`.`id`)));

DROP VIEW IF EXISTS `soapnoteheader`;
CREATE VIEW `soapnoteheader` AS select `patients`.`id` AS `id`,concat(`patients`.`lastname`,_latin1', ',`patients`.`firstname`) AS `patientname`,`patients`.`address` AS `patientaddress`,concat(`patients`.`city`,_latin1', ',`patients`.`state`,_latin1'  ',`patients`.`zipcode`) AS `patientcsz`,`patients`.`accountnumber` AS `accountnumber`,`supplieraddress`.`supplieraddress` AS `officeaddress`,`supplieraddress`.`suppliercsz` AS `officecsz`,`supplieraddress`.`supplier` AS `doctorname`,`supplieraddress`.`32a` AS `NPI`,`supplieraddress`.`supplierphone` AS `Phone`,`patients`.`dob` AS `dob` from (`patients` join `supplieraddress`);

DROP VIEW IF EXISTS `supplieraddress`;
CREATE VIEW  `supplieraddress` AS select `e`.`suppliername` AS `suppliername`,`e`.`supplier` AS `supplier`,substr(`e`.`supplieraddress`,1,(locate(_latin1'\r',`e`.`supplieraddress`) - 1)) AS `supplieraddress`,substr(`e`.`supplieraddress`,(locate(_latin1'\r',`e`.`supplieraddress`) + 2)) AS `suppliercsz`,`e`.`supplierphone` AS `supplierphone`,`e`.`pin` AS `32a` from `environment` `e`;

DROP VIEW IF EXISTS `visitcharges`;
CREATE VIEW  `visitcharges` AS select `c`.`visitid` AS `visitId`,count(0) AS `charges`,sum(`c`.`chargeamount`) AS `visitcharges`,`v`.`date` AS `date`,`v`.`patientid` AS `patientid`,`p`.`providerid` AS `providerid`,`p`.`lastname` AS `lastname`,`p`.`firstname` AS `firstname` from ((`charges` `c` join `visits` `v` on((`c`.`visitid` = `v`.`id`))) join `patients` `p` on((`v`.`patientid` = `p`.`id`))) group by `c`.`visitid` order by `p`.`lastname`,`p`.`firstname`;

DROP VIEW IF EXISTS `visitchargesummary`;
CREATE VIEW  `visitchargesummary` AS select `a`.`visitid` AS `visitid`,`b`.`description` AS `Type`,`c`.`description` AS `Description`,`d`.`name` AS `Resource`,`a`.`chargeamount` AS `chargeamount` from (((`charges` `a` join `items` `c` on((`a`.`itemid` = `c`.`id`))) join `itemtypes` `b` on((`c`.`typeid` = `b`.`id`))) left join `resources` `d` on((`a`.`resourceid` = `d`.`id`))) order by `c`.`typeid`;

DROP VIEW IF EXISTS `visitledger`;
CREATE VIEW  `visitledger` AS select `a`.`visitid` AS `visitid`,count(0) AS `itemcount`,ifnull(sum(`a`.`chargeamount`),0) AS `charges`,ifnull((select sum(`b`.`amount`) AS `sum(``b``.``amount``)` from (`payments` `b` join `providers` `c` on((`b`.`provider` = `c`.`id`))) where ((not(`c`.`reserved`)) and (`b`.`provider` <> 10) and (`b`.`chargeid` = `a`.`id`))),0) AS `inspayments`,ifnull((select sum(`c`.`amount`) AS `sum(``c``.``amount``)` from `paymentsbypatient` `c` where (`c`.`chargeid` = `a`.`id`)),0) AS `patpayments`,ifnull((select sum(`d`.`amount`) AS `sum(``d``.``amount``)` from `writeoffs` `d` where (`d`.`chargeid` = `a`.`id`)),0) AS `writeoffs` from `charges` `a` group by `a`.`visitid`;

DROP VIEW IF EXISTS `visitpaymentsbyinsurance`;
CREATE VIEW  `visitpaymentsbyinsurance` AS select `b`.`visitid` AS `visitid`,sum(`c`.`amount`) AS `amount` from ((`visits` `a` join `charges` `b` on((`a`.`id` = `b`.`visitid`))) join `paymentsbyinsurance` `c` on((`b`.`id` = `c`.`chargeid`))) group by `b`.`visitid`;

DROP VIEW IF EXISTS `visitpaymentsbypatient`;
CREATE VIEW  `visitpaymentsbypatient` AS select `b`.`visitid` AS `visitid`,sum(`c`.`amount`) AS `amount` from ((`visits` `a` join `charges` `b` on((`a`.`id` = `b`.`visitid`))) join `paymentsbypatient` `c` on((`b`.`id` = `c`.`chargeid`))) group by `b`.`visitid`;

DROP VIEW IF EXISTS `visitsummary`;
CREATE VIEW  `visitsummary` AS select `a`.`id` AS `id`,`c`.`type` AS `type`,`a`.`date` AS `date`,`a`.`timein` AS `timein`,`a`.`patientid` AS `patientid` from ((`visits` `a` left join `appointments` `b` on((`a`.`appointmentid` = `b`.`id`))) left join `appointmenttypes` `c` on((`b`.`type` = `c`.`id`)));

DROP VIEW IF EXISTS `visitwriteoffs`;
CREATE VIEW  `visitwriteoffs` AS select `b`.`visitid` AS `visitid`,sum(`c`.`amount`) AS `amount` from ((`visits` `a` join `charges` `b` on((`a`.`id` = `b`.`visitid`))) join `writeoffs` `c` on((`b`.`id` = `c`.`chargeid`))) group by `b`.`visitid`;

DROP VIEW IF EXISTS `writeoffs`;
CREATE VIEW  `writeoffs` AS select `payments`.`chargeid` AS `chargeid`,sum(`payments`.`amount`) AS `amount` from `payments` where (`payments`.`provider` = 10) group by `payments`.`chargeid`;

DROP VIEW IF EXISTS `nonbillableitems`;
CREATE  VIEW `nonbillableitems` AS select `a`.`patientid` AS `patientid`,`a`.`providerid` AS `providerid`,`a`.`itemid` AS `itemid` from `patientprovideritems` `a` where (exists(select `defaultpayments`.`id` AS `id` from `defaultpayments` where ((not(`defaultpayments`.`billinsurance`)) and (`defaultpayments`.`patientid` = `a`.`patientid`) and (`defaultpayments`.`providerid` = `a`.`providerid`) and (`defaultpayments`.`itemid` = `a`.`itemid`))) or (exists(select `defaultpayments`.`id` AS `id` from `defaultpayments` where ((not(`defaultpayments`.`billinsurance`)) and (`defaultpayments`.`patientid` = 0) and (`defaultpayments`.`providerid` = `a`.`providerid`) and (`defaultpayments`.`itemid` = `a`.`itemid`))) and (not(exists(select `defaultpayments`.`id` AS `id` from `defaultpayments` where (`defaultpayments`.`billinsurance` and (`defaultpayments`.`patientid` = `a`.`patientid`) and (`defaultpayments`.`providerid` = `a`.`providerid`) and (`defaultpayments`.`itemid` = `a`.`itemid`)))))));

DROP VIEW IF EXISTS `cms1500data`;
CREATE VIEW  `cms1500data` AS select sql_no_cache `patients`.`id` AS `id`,`insuranceinformation`.`providerid` AS `providerid`,`insuranceinformation`.`medicare` AS `medicare`,`insuranceinformation`.`medicaid` AS `medicaid`,`insuranceinformation`.`champus` AS `champus`,`insuranceinformation`.`champusva` AS `champusva`,`insuranceinformation`.`ghp` AS `ghp`,`insuranceinformation`.`feca` AS `feca`,`insuranceinformation`.`otherhp` AS `otherhp`,`insuranceinformation`.`providernumber` AS `providernumber`,(case when (trim(`insuranceinformation`.`planname`) = _latin1'') then `insuranceinformation`.`providername` else `insuranceinformation`.`planname` end) AS `planname`,`insuranceinformation`.`box19` AS `field19`,`ba`.`accountnumber` AS `accountnumber`,concat(`patients`.`lastname`,', ',`patients`.`firstname`,' ',`patients`.`middlename`) AS `patientname`,`patients`.`address` AS `patientaddress`,`patients`.`city` AS `patientcity`,`patients`.`state` AS `patientstate`,`patients`.`zipcode` AS `patientzip`,substr(cast(`patients`.`homephone` as char charset utf8),1,3) AS `patientareacode`,substr(cast(`patients`.`homephone` as char charset utf8),4,7) AS `patientphone`,(case when (`patients`.`gender` = 1) then _utf8'X' else _utf8' ' end) AS `male`,(case when (`patients`.`gender` > 1) then _utf8'X' else _utf8' ' end) AS `female`,`insuranceinformation`.`relationshipself` AS `relationshipself`,`insuranceinformation`.`relationshipspouse` AS `relationshipspouse`,`insuranceinformation`.`relationshipchild` AS `relationshipchild`,`insuranceinformation`.`relationshipother` AS `relationshipother`,(case when (`patients`.`maritalstatus` = 2) then _utf8'X' else _utf8' ' end) AS `maritalstatusmarried`,(case when (`patients`.`maritalstatus` = 1) then _utf8'X' else _utf8' ' end) AS `maritalstatussingle`,(case when (`patients`.`maritalstatus` = 3) then _utf8'X' else _utf8' ' end) AS `maritalstatusother`,date_format(`patients`.`dob`,_utf8'%m') AS `patientbirthmonth`,date_format(`patients`.`dob`,_utf8'%d') AS `patientbirthday`,date_format(`patients`.`dob`,_utf8'%Y') AS `patientbirthyear`,`ba`.`name` AS `insuredname`,`ba`.`address` AS `insuredaddress`,`ba`.`city` AS `insuredcity`,`ba`.`state` AS `insuredstate`,`ba`.`zipcode` AS `insuredzip`,`ba`.`areacode` AS `insuredareacode`,`ba`.`phonenumber` AS `insuredphonenumber`,`ba`.`birthmonth` AS `insuredbirthmonth`,`ba`.`birthday` AS `insuredbirthday`,`ba`.`birthyear` AS `insuredbirthyear`,`ba`.`male` AS `insuredmale`,`ba`.`female` AS `insuredfemale`,(case when (`insuranceinformation`.`insuranceproviders` < 2) then _utf8'X' else _utf8' ' end) AS `otherhpno`,(case when (`insuranceinformation`.`insuranceproviders` > 1) then _utf8'X' else _utf8' ' end) AS `otherhpyes`,(case when (`es`.`employmentstatus` = _utf8'E') then _utf8'X' else _utf8' ' end) AS `employed`,(case when (`es`.`employmentstatus` = _utf8'S') then _utf8'X' else _utf8' ' end) AS `ftstudent`,(case when (`es`.`employmentstatus` = _utf8'P') then _utf8'X' else _utf8' ' end) AS `ptStudent`,_utf8'X' AS `field20n`,`tempdiagnosis`.`21_1a` AS `21_1a`,`tempdiagnosis`.`21_1b` AS `21_1b`,`tempdiagnosis`.`21_2a` AS `21_2a`,`tempdiagnosis`.`21_2b` AS `21_2b`,`tempdiagnosis`.`21_3a` AS `21_3a`,`tempdiagnosis`.`21_3b` AS `21_3b`,`tempdiagnosis`.`21_4a` AS `21_4a`,`tempdiagnosis`.`21_4b` AS `21_4b`,`insuranceinformation`.`providergroup` AS `insuredgroupnumber`,`insuranceinformation`.`assignmentyes` AS `assignmentyes`,`insuranceinformation`.`assignmentno` AS `assignmentno`,`insuranceinformation`.`providername` AS `providername`,`insuranceinformation`.`provideraddress1` AS `provideraddress1`,`insuranceinformation`.`provideraddress2` AS `provideraddress2`,`insuranceinformation`.`provideraddress3` AS `provideraddress3`,`facilityaddress`.`taxid` AS `taxid`,(case when `environment`.`ssn` then _utf8'X' else _utf8' ' end) AS `taxidssn`,(case when (not(`environment`.`ssn`)) then _utf8'X' else _utf8' ' end) AS `taxidein`,`ba`.`employer` AS `employer`,_utf8'0' AS `paiddollars`,_utf8'00' AS `paidcents`,_utf8'0' AS `balancedollars`,_utf8'00' AS `balancecents`,`sa`.`suppliername` AS `suppliername`,`sa`.`supplier` AS `supplier`,`sa`.`supplieraddress` AS `supplieraddress`,`sa`.`suppliercsz` AS `suppliercsz`,`sa`.`supplierphone` AS `supplierphone`,`sa`.`32a` AS `32a`,`ba`.`14mm` AS `14mm`,`ba`.`14dd` AS `14dd`,`ba`.`14yy` AS `14yy`,`ba`.`employmentyes` AS `employmentyes`,`ba`.`autoyes` AS `autoyes`,`ba`.`autostate` AS `autostate`,`ba`.`otheryes` AS `otheryes`,`ba`.`employmentno` AS `employmentno`,`ba`.`autono` AS `autono`,`ba`.`otherno` AS `otherno`,`resources`.`name` AS `31sig`,`resources`.`signature` AS `12sig`,`resources`.`signature` AS `13sig`,`facilityaddress`.`facilityname` AS `facilityname`,`facilityaddress`.`facilityaddress` AS `facilityaddress`,`facilityaddress`.`facilitycsz` AS `facilitycsz`,date_format(curdate(),_utf8'%m%d%Y') AS `12date`,date_format(curdate(),_utf8'%m%d%Y') AS `31date`,`facilityaddress`.`pin` AS `pin`,`facilityaddress`.`grp` AS `grp` from ((((((((`patients` left join `billingaccounts` `ba` on((`ba`.`accountnumber` = `patients`.`billingaccount`))) left join `employmentstatus` `es` on((`es`.`id` = `patients`.`occupationid`))) left join `insuranceinformation` on((`insuranceinformation`.`patientid` = `patients`.`id`))) left join `tempdiagnosis` on((`tempdiagnosis`.`patientid` = `patients`.`id`))) join `environment`) join `supplieraddress` `sa`) join `facilityaddress` on((`facilityaddress`.`id` = `environment`.`defaultresource`))) join `resources` on((`resources`.`id` = `environment`.`defaultresource`)));

DROP VIEW IF EXISTS `visitcharges`;
CREATE  VIEW `visitcharges` AS select `c`.`visitid` AS `visitId`,count(0) AS `charges`,sum(`c`.`chargeamount`) AS `visitcharges`,`v`.`date` AS `date`,`v`.`patientid` AS `patientid`,`p`.`providerid` AS `providerid`,`p`.`lastname` AS `lastname`,`p`.`firstname` AS `firstname` from ((`visits` `v` left join `charges` `c` on((`c`.`visitid` = `v`.`id`))) join `patients` `p` on((`v`.`patientid` = `p`.`id`))) group by `v`.`id` order by `p`.`lastname`,`p`.`firstname`;

DROP VIEW IF EXISTS `writeoffs`;
CREATE  VIEW `writeoffs` AS select `payments`.`chargeid` AS `chargeid`,sum(`payments`.`amount`) AS `amount` from `payments` where (`payments`.`provider` = 10) group by `payments`.`chargeid`;

DROP VIEW IF EXISTS `visitcharges`;
CREATE  VIEW `visitcharges` AS select `c`.`visitid` AS `visitId`,count(0) AS `charges`,sum(`c`.`chargeamount`) AS `visitcharges`,`v`.`date` AS `date`,`v`.`patientid` AS `patientid`,`p`.`providerid` AS `providerid`,`p`.`lastname` AS `lastname`,`p`.`firstname` AS `firstname` from ((`visits` `v` left join `charges` `c` on((`c`.`visitid` = `v`.`id`))) join `patients` `p` on((`v`.`patientid` = `p`.`id`))) group by `v`.`id` order by `p`.`lastname`,`p`.`firstname`;

DROP VIEW IF EXISTS `visitchargesummary`;
CREATE VIEW `visitchargesummary` AS select `a`.`visitid` AS `visitid`,`b`.`description` AS `Type`,`c`.`description` AS `Description`,`d`.`name` AS `Resource`,`a`.`chargeamount` AS `chargeamount` from (((`charges` `a` join `items` `c` on((`a`.`itemid` = `c`.`id`))) join `itemtypes` `b` on((`c`.`typeid` = `b`.`id`))) left join `resources` `d` on((`a`.`resourceid` = `d`.`id`))) order by `c`.`typeid`;

DROP VIEW IF EXISTS `visitpaymentsbyinsurance`;
CREATE  VIEW `visitpaymentsbyinsurance` AS select `b`.`visitid` AS `visitid`,sum(`c`.`amount`) AS `amount` from ((`visits` `a` join `charges` `b` on((`a`.`id` = `b`.`visitid`))) join `paymentsbyinsurance` `c` on((`b`.`id` = `c`.`chargeid`))) group by `b`.`visitid`;

DROP VIEW IF EXISTS `visitpaymentsbypatient`;
CREATE VIEW `visitpaymentsbypatient` AS select `b`.`visitid` AS `visitid`,sum(`c`.`amount`) AS `amount` from ((`visits` `a` join `charges` `b` on((`a`.`id` = `b`.`visitid`))) join `paymentsbypatient` `c` on((`b`.`id` = `c`.`chargeid`))) group by `b`.`visitid`;

DROP VIEW IF EXISTS `visitwriteoffs`;
CREATE VIEW `visitwriteoffs` AS select `b`.`visitid` AS `visitid`,sum(`c`.`amount`) AS `amount` from ((`visits` `a` join `charges` `b` on((`a`.`id` = `b`.`visitid`))) join `writeoffs` `c` on((`b`.`id` = `c`.`chargeid`))) group by `b`.`visitid`;

DROP VIEW IF EXISTS `chargesbyvisit`;
CREATE VIEW `chargesbyvisit` AS select `visits`.`id` AS `visitid`,count(0) AS `itemcount`,ifnull(sum(`charges`.`chargeamount`),0) AS `chargeamount` from (`visits` left join `charges` on((`visits`.`id` = `charges`.`visitid`))) group by `visits`.`id`;


DROP VIEW IF EXISTS `cms1500charges`;
CREATE VIEW `cms1500charges` AS select `batchcharges`.`batchid` AS `batchid`,`batchcharges`.`chargeid` AS `chargeid`,`visits`.`patientid` AS `patientid`,`charges`.`resourceid` AS `resourceid`,date_format(`visits`.`date`,_utf8'%m') AS `month`,date_format(`visits`.`date`,_utf8'%d') AS `day`,date_format(`visits`.`date`,_utf8'%y') AS `year`,_utf8'11' AS `placeofService`,_utf8' ' AS `typeofservice`,`items`.`code` AS `code`,ifnull(`chargediagnosis`.`diagnosiscode`,_utf8' ') AS `diagnosiscode`,cast(`charges`.`chargeamount` as unsigned) AS `dollars`,(case when (cast((`charges`.`chargeamount` - cast(`charges`.`chargeamount` as unsigned)) as unsigned) = 0) then _utf8'00' else cast(cast((`charges`.`chargeamount` - cast(`charges`.`chargeamount` as unsigned)) as unsigned) as char charset utf8) end) AS `cents`,1 AS `units`,_utf8' ' AS `familyplan`,_utf8' ' AS `emg`,(case when isnull(`resources`.`pin`) then `environment`.`pin` else `resources`.`pin` end) AS `cob`,_utf8'' AS `modifier`,(case when `providers`.`showqualifier` then `resources`.`idqual` else _utf8' ' end) AS `idqual`,(case when `providers`.`showqualifier` then `resources`.`medicareid` else _utf8' ' end) AS `medicareid`,ifnull(`visits`.`conditionid`,0) AS `conditionid` from ((((((((`batchcharges` left join `batches` on((`batchcharges`.`batchid` = `batches`.`id`))) left join `providers` on((`batches`.`provider` = `providers`.`id`))) left join `charges` on((`charges`.`id` = `batchcharges`.`chargeid`))) left join `visits` on((`charges`.`visitid` = `visits`.`id`))) left join `chargediagnosis` on((`visits`.`patientid` = `chargediagnosis`.`patientid`))) left join `items` on((`charges`.`itemid` = `items`.`id`))) left join `resources` on((`resources`.`id` = `charges`.`resourceid`))) join `environment`);