
-- Table: public.itemevaluation

-- DROP TABLE public.itemevaluation;

   /*CREATE SEQUENCE  "EDUCAPES"."FAQGROUP_SEQ";
   CREATE TABLE "EDUCAPES"."FAQGROUP"
   (	"FAQGROUP_ID" NUMBER(*,0),
	"GROUP_NAME" VARCHAR2(30 CHAR),
	"GROUP_ORDER" NUMBER(*,0),
	 PRIMARY KEY ("FAQGROUP_ID" )
	 );

  CREATE SEQUENCE  "EDUCAPES"."FAQ_SEQ";
  CREATE TABLE "EDUCAPES"."FAQ"
   (	"QUESTION_ID" NUMBER(*,0),
	"QUESTION" VARCHAR2(300 CHAR),
	"GROUP_ID" NUMBER(*,0),
	"ANSWER" VARCHAR2(1000 CHAR),
	"FAQ_ID" NUMBER NOT NULL ENABLE,
	 CONSTRAINT "FAQ_PK" PRIMARY KEY ("FAQ_ID")
	 );*/


CREATE TABLE public.itemevaluation
(
  item_id integer,
  grade integer,
  created timestamp with time zone,
  id integer NOT NULL,
  CONSTRAINT itemevaluation_pkey PRIMARY KEY (id)
);

-- ALTER TABLE public.itemevaluation OWNER TO dspace;


-- Sequence: public.itemevaluation_seq

-- DROP SEQUENCE public.itemevaluation_seq;

CREATE SEQUENCE public.itemevaluation_seq;

-- ALTER TABLE public.itemevaluation_seq OWNER TO dspace;

-- DROP SEQUENCE author_seq;
-- DROP INDEX author0status_idx;
-- DROP TABLE author;


CREATE SEQUENCE poll_seq;

CREATE TABLE poll
(
  email character varying(64),
  note integer,
  poll_id integer NOT NULL,
  CONSTRAINT poll_pkey PRIMARY KEY (poll_id),
  CONSTRAINT poll_email_key UNIQUE (email)
);




create sequence partners_seq;

create table partners(
  PARTNER_ID    integer not null
    constraint PARTNERS_PK primary key,
  NAME          VARCHAR(40)  default 'nome',
  URL           VARCHAR(58)  default 'url',
  PATH          VARCHAR(100) default 'filename',
  GROUP_PARTNER integer        default '0',
  ORDER_PARTNER integer        default 0,
  STATUS        integer        default 0
);



CREATE SEQUENCE author_seq;

CREATE TABLE author
(
  author_id	          		INTEGER PRIMARY KEY,
  eperson_id          		INTEGER,
  cpf                 		VARCHAR(11) UNIQUE,
  institution_name    		VARCHAR(100),
  institution_shortname 	VARCHAR(20),
  department            	VARCHAR(100),
  job_title	            	VARCHAR(50),
  celphone	            	VARCHAR(11),
  institution_site      	VARCHAR(255),
  institution_repository 	VARCHAR(255),
  institution_ava	    	VARCHAR(255),
  item_count	 			INTEGER,
  refusal_cause	 			TEXT,
  token	 			 		VARCHAR(50),
  active	           		BOOL DEFAULT 'f'
);

CREATE INDEX author0status_idx ON author(active);
ALTER TABLE author ADD CONSTRAINT author_eperson_id_fkey FOREIGN KEY (eperson_id) REFERENCES EPerson(eperson_id) ON DELETE CASCADE;