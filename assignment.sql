
/* cs2102 assignment 1 */

drop view if exists v1, v2, v3, v4, v5, v6, v7, v8, v9, v10 cascade;

create or replace  view v1 (sid,cid) as 
select distinct T.sid, T.cid
from Tutors T
except 
select distinct Transcripts.sid, Transcripts.cid
from Transcripts
;

create or replace view v2 (sid) as 
select distinct T1.sid 
from Tutors as T1, Tutors as T2
where T1.sid = T2.sid
and T1.semester = T2.semester
and T1.year = T2.year
and T1.cid <> T2.cid
;

-- create or replace view v2 (sid) as 
-- select distinct T1.sid 
-- from Tutors as T1
-- where 2 <= (
--     select count(distinct cid)
--     from Tutors as T2
--     where T1.sid = T2.sid
--     group by 
-- )
-- ;

create or replace view v3 (cid, year, semester) as 
select distinct T1.cid, T1.year, T1.semester
from (
    select T.cid, T.year, T.semester, count(T.sid) as student_count
    from Transcripts T
    group by (T.cid, T.year, T.semester)
) as T1
where not exists (
    select 1
    from (
        select T.cid, T.year, T.semester, count(T.sid) as student_count
        from Transcripts T
        group by (T.cid, T.year, T.semester)
    ) as T2
    where T2.student_count > T1.student_count
    and T1.cid = T2.cid
)
;

create or replace view v4 (cid, year, semester) as 
select distinct C.cid, C.year, C.semester 
from (Offerings natural join Courses) as C
where C.did = 'cs' 
or C.semester = 2 
or not exists (
    select 1
    from Teaches as T1, Teaches as T2
    where (C.cid = T1.cid and C.cid = T2.cid)
    and (C.year = T1.year and C.year = T2.year)
    and (C.semester = T1.semester and C.semester = T2.semester)
    and T1.pid <> T2.pid
)
;

create or replace view v5 (cid) as 
select distinct C.cid
from Courses as C
where C.did = 'cs' 
and C.cid not in (
    select cid 
    from Transcripts as T 
    where T.sid = 'alice'
)
;

create or replace view v6 (cid, year, semester, cost) as
select distinct T.cid, T.year, T.semester, sum(T.pay) as cost
from (
    select ('T1') as position, Tutors.cid, Tutors.year, Tutors.semester, sum(Tutors.hours * 50) as pay
    from Tutors 
    group by Tutors.cid, Tutors.year, Tutors.semester
    union
    select ('T2') as position, Teaches.cid, Teaches.year, Teaches.semester, sum(Teaches.hours * 100) as pay
    from Teaches
    group by Teaches.cid, Teaches.year, Teaches.semester
) as T
group by T.cid, T.year, T.semester
;

create or replace view v7 (did, faculty, num_admitted, num_offering, total_enrollment) as 
select distinct T.did, T.faculty, T.num_admitted, T.num_offering, T.total_enrollment
from (
    (
        select distinct D.did, D.faculty, 
            (select count(*) 
            from Students as S 
            where S.year = 2021 
            and S.did = D.did) as num_admitted
        from Departments as D
        group by D.did, D.faculty
    ) as T1 
    natural join
    (
        select distinct D.did, D.faculty, 
            (select count(*) 
            from (Offerings natural join Courses) as O 
            where O.year = 2021 and O.did = D.did) as num_offering
        from Departments as D
        group by D.did, D.faculty
    ) as T2 
    natural join
    (
        select distinct D.did, D.faculty, 
            (select count(*) 
            from (Transcripts natural join Courses) as T 
            where T.year = 2021 and T.did = D.did) as total_enrollment
        from Departments as D
        group by D.did, D.faculty
    ) as T3
) as T
;


create or replace view v8 (sid, year, semester) as
select distinct T1.sid, T1.year, T1.semester
from (Transcripts natural join Courses) as T1
where T1.did = 'cs'
and not exists (
    select 1
    from (Transcripts natural join Courses) as T2
    where T1.sid = T2.sid
    and T1.year = T2.year
    and T1.semester = T2.semester
    and T2.did <> 'cs'
)
;

create or replace view v9 (sid, year, semester) as 
select distinct T.sid, T.year, T.semester
from Transcripts as T
except
select distinct T.sid, T.year, T.semester
from Transcripts as T
where exists (
    select 1
    from Transcripts as T1
    where T.sid <> T1.sid
    and T.year = T1.year
    and T.semester = T1.semester
    and T.cid = T1.cid
    and T.marks < T1.marks
)
;

create or replace view v10 (sid1, sid2, sid3, sid4) as 
select distinct T1.sid, T2.sid, T3.sid, T4.sid 
from Tutors as T1, Tutors as T2, Tutors as T3, Tutors as T4
where T1.sid < T2.sid and T2.sid < T3.sid and T3.sid < T4.sid
and T1.year = 2022 and T2.year = 2022 and T3.year = 2022 and T4.year = 2022
and T1.semester = 1 and T2.semester = 1 and T3.semester = 1 and T4.semester = 1
and exists (
    select 1
    from Students as S1, Students as S2, Students as S3, Students as S4
    where (S1.sid = T1.sid and S2.sid = T2.sid and S3.sid = T3.sid and S4.sid = T4.sid)
    and (T1.year >= 2019 and T2.year >= 2019 and T3.year >= 2019 and T4.year >= 2019)
) and exists (
    select 1
    from Transcripts TA1, Transcripts TB1, Transcripts TA2, Transcripts TB2
    where TA1.sid < TB1.sid and TA1.sid = TA2.sid and TB1.sid = TB2.sid
    and (TA1.sid = T1.sid or TA1.sid = T2.sid or TA1.sid = T3.sid or TA1.sid = T4.sid)
    and (TB1.sid = T1.sid or TB1.sid = T2.sid or TB1.sid = T3.sid or TB1.sid = T4.sid)
    and (TA1.cid = 'cs1' and TA2.cid = 'cs2') 
    and (TB1.cid = 'cs1' and TB2.cid = 'cs2')
) and exists (
    select 1
    from Transcripts TA, Transcripts TB 
    where TA.sid < TB.sid 
    and (TA.sid = T1.sid or TA.sid = T2.sid or TA.sid = T3.sid or TA.sid = T4.sid)
    and (TB.sid = T1.sid or TB.sid = T2.sid or TB.sid = T3.sid or TB.sid = T4.sid)
    and (TA.cid = 'cs3' or TA.cid = 'cs4') 
    and (TB.cid = 'cs3' or TB.cid = 'cs4')
) and not exists (
    select 1
    from Tutors as TA
    group by (TA.sid, TA.year, TA.semester)
    having (TA.sid = T1.sid or TA.sid = T2.sid or TA.sid = T3.sid or TA.sid = T4.sid)
    and (TA.semester = 1 and TA.year = 2022)
    and sum(TA.hours) < 10
)

-- group by T1.sid, T2.sid, T3.sid, T4.sid, T1.year, T1.semester, 
--     T2.year,
-- having sum(T1.hours) >= 10 
-- and sum(T2.hours) >= 10  
-- and sum(T3.hours) >= 10 
-- and sum(T4.hours) >= 10


-- and exists (
--     select 1
--     from Tutors T
--     where T.sid = T1.sid
--     and T.year = T1.year
--     and T.semester = T1.semester
--     group by T.year, T.semester
--     having sum(T.hours) >= 10
-- ) and exists (
--     select 1
--     from Tutors T
--     where T.sid = T2.sid
--     and T.year = T2.year
--     and T.semester = T2.semester
--     group by T.year, T.semester
--     having sum(T.hours) >= 10
-- ) and exists (
--     select 1
--     from Tutors T
--     where T.sid = T3.sid
--     and T.year = T3.year
--     and T.semester = T3.semester
--     group by T.year, T.semester
--     having sum(T.hours) >= 10
-- ) and exists (
--     select 1
--     from Tutors T
--     where T.sid = T4.sid
--     and T.year = T4.year
--     and T.semester = T4.semester
--     group by T.year, T.semester
--     having sum(T.hours) >= 10
-- )
;

