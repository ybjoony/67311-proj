-- INDEXES FOR PATS DATABASE
--
-- by Byungjoon Yoon & Leo Ying
--
--
CREATE INDEX description_idx ON medicines USING gin(to_tsvector('english', description)); 
