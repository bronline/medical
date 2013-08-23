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
