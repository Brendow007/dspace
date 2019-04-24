
-- DROP SEQUENCE author_seq;
-- DROP INDEX author0status_idx;
-- DROP TABLE author;
-- DROP SEQUENCE itemevaluation_seq;
-- DROP TABLE itemevaluation;


   CREATE SEQUENCE  FAQGROUP_SEQ;
   CREATE TABLE FAQGROUP
   (
  FAQGROUP_ID NUMBER(*,0),
	GROUP_NAME VARCHAR2(30 CHAR),
	GROUP_ORDER NUMBER(*,0),
	 PRIMARY KEY (FAQGROUP_ID)
	 );

  CREATE SEQUENCE  FAQ_SEQ;
  CREATE TABLE FAQ
   (
  QUESTION_ID NUMBER(*,0),
	QUESTION VARCHAR2(1000),
	GROUP_ID NUMBER(*,0),
  ANSWER VARCHAR2(2000),
	FAQ_ID NUMBER NOT NULL ENABLE,
	CONSTRAINT FAQ_PK PRIMARY KEY (FAQ_ID)
	 );




CREATE SEQUENCE author_seq;

CREATE TABLE author
(
  author_id	          		INTEGER PRIMARY KEY,
  eperson_id          		INTEGER,
  cpf                 		VARCHAR2(11) UNIQUE,
  institution_name    		VARCHAR2(100),
  institution_shortname 	VARCHAR2(20),
  department            	VARCHAR2(100),
  job_title	            	VARCHAR2(50),
  celphone	            	VARCHAR2(11),
  institution_site      	VARCHAR2(255),
  institution_repository 	VARCHAR2(255),
  institution_ava	    	VARCHAR2(255),
  item_count	 		INTEGER,
  refusal_cause	 		VARCHAR2(1000),
  token	 			VARCHAR2(50),
  active	           	NUMBER(1) DEFAULT 0
);

CREATE INDEX author0status_idx ON author(active);
ALTER TABLE author ADD CONSTRAINT author_eperson_id_fkey FOREIGN KEY (eperson_id) REFERENCES EPerson(eperson_id) ON DELETE CASCADE;

CREATE TABLE itemevaluation
(
  id INTEGER PRIMARY KEY,
  item_id INTEGER,
  grade INTEGER,
  created DATE
);

CREATE SEQUENCE itemevaluation_seq;

CREATE SEQUENCE poll_seq;

CREATE TABLE poll
(
  email character varying(64),
  note integer,
  poll_id integer NOT NULL,
  CONSTRAINT poll_pkey PRIMARY KEY (poll_id),
  CONSTRAINT poll_email_key UNIQUE (email)
);

