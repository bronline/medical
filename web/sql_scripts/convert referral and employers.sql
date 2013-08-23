use rivy;

insert into referredby
select distinct null,referredby from patients where referredby<>''order by referredby;

update patients set referredby=(select id from referredby where referrer=referredby) where referredby<>'';

insert into employers
select distinct null,employer from patients where employer<>''order by employer;

update patients set employer=(select id from employers where employer=patients.employer) where employer<>'';