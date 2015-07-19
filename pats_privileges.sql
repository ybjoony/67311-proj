
-- PRIVILEGES FOR pats USER OF PATS DATABASE
---- by Byungjoon Yoon & Leo Ying
--
CREATE USER pats;

revoke delete on visit_medicines from pats;
revoke delete on treatments from pats;
revoke update (units_given)  on visit_medicines  from pats;


-- SQL to limit pats user access on key tables

REVOKE ALL privileges ON users FROM PUBLIC;
GRANT select ON users TO PUBLIC;
