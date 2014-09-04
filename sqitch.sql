CREATE SCHEMA sqitch;
COMMENT ON SCHEMA sqitch IS 'Sqitch database deployment metadata v1.0.';

CREATE SCHEMA flipr;


CREATE TABLE sqitch.projects
(
    project varchar(1024) NOT NULL,
    uri varchar(1024),
    created_at timestamptz NOT NULL DEFAULT clock_timestamp(),
    creator_name varchar(1024) NOT NULL,
    creator_email varchar(1024) NOT NULL
);

COMMENT ON TABLE sqitch.projects IS 'Sqitch projects deployed to this database.';

ALTER TABLE sqitch.projects ADD CONSTRAINT C_PRIMARY PRIMARY KEY (project); 
ALTER TABLE sqitch.projects ADD CONSTRAINT C_UNIQUE UNIQUE (uri); 

CREATE TABLE sqitch.changes
(
    change_id char(40) NOT NULL,
    change varchar(1024) NOT NULL,
    project varchar(1024) NOT NULL,
    note varchar(65000) NOT NULL DEFAULT '',
    committed_at timestamptz NOT NULL DEFAULT clock_timestamp(),
    committer_name varchar(1024) NOT NULL,
    committer_email varchar(1024) NOT NULL,
    planned_at timestamptz NOT NULL,
    planner_name varchar(1024) NOT NULL,
    planner_email varchar(1024) NOT NULL
);

COMMENT ON TABLE sqitch.changes IS 'Tracks the changes currently deployed to the database.';

ALTER TABLE sqitch.changes ADD CONSTRAINT C_PRIMARY PRIMARY KEY (change_id); 

CREATE TABLE sqitch.tags
(
    tag_id char(40) NOT NULL,
    tag varchar(1024) NOT NULL,
    project varchar(1024) NOT NULL,
    change_id char(40) NOT NULL,
    note varchar(65000) NOT NULL DEFAULT '',
    committed_at timestamptz NOT NULL DEFAULT clock_timestamp(),
    committer_name varchar(1024) NOT NULL,
    committer_email varchar(1024) NOT NULL,
    planned_at timestamptz NOT NULL,
    planner_name varchar(1024) NOT NULL,
    planner_email varchar(1024) NOT NULL
);

COMMENT ON TABLE sqitch.tags IS 'Tracks the tags currently applied to the database.';

ALTER TABLE sqitch.tags ADD CONSTRAINT C_PRIMARY PRIMARY KEY (tag_id); 
ALTER TABLE sqitch.tags ADD CONSTRAINT C_UNIQUE UNIQUE (project, tag); 

CREATE TABLE sqitch.dependencies
(
    change_id char(40) NOT NULL,
    type varchar(8) NOT NULL,
    dependency varchar(2048) NOT NULL,
    dependency_id char(40)
);

COMMENT ON TABLE sqitch.dependencies IS 'Tracks the currently satisfied dependencies.';

ALTER TABLE sqitch.dependencies ADD CONSTRAINT C_PRIMARY PRIMARY KEY (change_id, dependency); 

CREATE TABLE sqitch.events
(
    event varchar(6) NOT NULL,
    change_id char(40) NOT NULL,
    change varchar(1024) NOT NULL,
    project varchar(1024) NOT NULL,
    note varchar(65000) NOT NULL DEFAULT '',
    requires long varchar(1048576) NOT NULL DEFAULT '{}',
    conflicts long varchar(1048576) NOT NULL DEFAULT '{}',
    tags long varchar(1048576) NOT NULL DEFAULT '{}',
    committed_at timestamptz NOT NULL DEFAULT clock_timestamp(),
    committer_name varchar(1024) NOT NULL,
    committer_email varchar(1024) NOT NULL,
    planned_at timestamptz NOT NULL,
    planner_name varchar(1024) NOT NULL,
    planner_email varchar(1024) NOT NULL
);

COMMENT ON TABLE sqitch.events IS 'Contains full history of all deployment events.';

ALTER TABLE sqitch.events ADD CONSTRAINT C_PRIMARY PRIMARY KEY (change_id, committed_at); 

ALTER TABLE sqitch.changes ADD CONSTRAINT C_FOREIGN FOREIGN KEY (project) references sqitch.projects (project);
ALTER TABLE sqitch.tags ADD CONSTRAINT C_FOREIGN FOREIGN KEY (project) references sqitch.projects (project);
ALTER TABLE sqitch.tags ADD CONSTRAINT C_FOREIGN_1 FOREIGN KEY (change_id) references sqitch.changes (change_id);
ALTER TABLE sqitch.dependencies ADD CONSTRAINT C_FOREIGN FOREIGN KEY (change_id) references sqitch.changes (change_id);
ALTER TABLE sqitch.dependencies ADD CONSTRAINT C_FOREIGN_1 FOREIGN KEY (dependency_id) references sqitch.changes (change_id);
ALTER TABLE sqitch.events ADD CONSTRAINT C_FOREIGN FOREIGN KEY (project) references sqitch.projects (project);

CREATE PROJECTION sqitch.changes_super /*+basename(changes),createtype(P)*/ 
(
 change_id,
 change,
 project,
 note,
 committed_at,
 committer_name,
 committer_email,
 planned_at,
 planner_name,
 planner_email
)
AS
 SELECT changes.change_id,
        changes.change,
        changes.project,
        changes.note,
        changes.committed_at,
        changes.committer_name,
        changes.committer_email,
        changes.planned_at,
        changes.planner_name,
        changes.planner_email
 FROM sqitch.changes
 ORDER BY changes.project,
          changes.change_id
SEGMENTED BY hash(changes.change_id) ALL NODES ;

CREATE PROJECTION sqitch.projects_super /*+basename(projects),createtype(L)*/ 
(
 project,
 uri,
 created_at,
 creator_name,
 creator_email
)
AS
 SELECT projects.project,
        projects.uri,
        projects.created_at,
        projects.creator_name,
        projects.creator_email
 FROM sqitch.projects
 ORDER BY projects.project
SEGMENTED BY hash(projects.project) ALL NODES ;

CREATE PROJECTION sqitch.events_super /*+basename(events),createtype(L)*/ 
(
 event,
 change_id,
 change,
 project,
 note,
 requires,
 conflicts,
 tags,
 committed_at,
 committer_name,
 committer_email,
 planned_at,
 planner_name,
 planner_email
)
AS
 SELECT events.event,
        events.change_id,
        events.change,
        events.project,
        events.note,
        events.requires,
        events.conflicts,
        events.tags,
        events.committed_at,
        events.committer_name,
        events.committer_email,
        events.planned_at,
        events.planner_name,
        events.planner_email
 FROM sqitch.events
 ORDER BY events.project,
          events.change_id,
          events.committed_at
SEGMENTED BY hash(events.change_id, events.committed_at) ALL NODES ;


SELECT MARK_DESIGN_KSAFE(0);
