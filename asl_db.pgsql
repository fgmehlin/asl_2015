--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

--
-- Name: createclient(); Type: FUNCTION; Schema: public; Owner: asl_pg
--

CREATE FUNCTION createclient() RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
nextval INTEGER;
BEGIN
SELECT nextval('client_id_seq') INTO nextval;
INSERT INTO clients (client_id) VALUES (nextval);
RETURN nextval;
END
$$;


ALTER FUNCTION public.createclient() OWNER TO asl_pg;

--
-- Name: createmessage(integer, integer, integer, character varying); Type: FUNCTION; Schema: public; Owner: asl_pg
--

CREATE FUNCTION createmessage(sender integer, receiver integer, queue integer, message character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
DECLARE
 messid integer;
 countQ integer;
 ok boolean;
BEGIN

SELECT count(*) INTO countQ FROM queues WHERE queue_id = queue;

IF countQ <> 0 THEN

    INSERT INTO messages (message_id, sender_id, receiver_id, toa, message) VALUES 
    (default, sender, receiver, now(), message);
    
    SELECT max(message_id) INTO messid FROM messages WHERE sender_id=sender;

    INSERT INTO message_queue (queue_id, message_id) VALUES(queue, messid);

    ok = True;
    ELSE
    ok = False;
    END IF;
    RETURN ok;
END
$$;


ALTER FUNCTION public.createmessage(sender integer, receiver integer, queue integer, message character varying) OWNER TO asl_pg;

--
-- Name: createqueue(); Type: FUNCTION; Schema: public; Owner: asl_pg
--

CREATE FUNCTION createqueue() RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN

INSERT INTO queues (queue_id) VALUES (default);

END;
$$;


ALTER FUNCTION public.createqueue() OWNER TO asl_pg;

--
-- Name: deletequeue(integer); Type: FUNCTION; Schema: public; Owner: asl_pg
--

CREATE FUNCTION deletequeue(queueid integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
DECLARE
count integer;
deleteOK boolean;
BEGIN

SELECT count(mq.message_id) INTO count FROM queues AS q, message_queue AS mq WHERE q.queue_id = mq.queue_id AND q.queue_id = queueid;

IF count = 0 THEN
DELETE FROM queues WHERE queue_id = queueid;
deleteOK := TRUE;
ELSE
deleteOK := FALSE;
END IF;

RETURN deleteOK;
END;
$$;


ALTER FUNCTION public.deletequeue(queueid integer) OWNER TO asl_pg;

--
-- Name: peekmessagebyqueue(integer, integer); Type: FUNCTION; Schema: public; Owner: asl_pg
--

CREATE FUNCTION peekmessagebyqueue(clientid integer, queueid integer) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE
peekedmessage VARCHAR(2000);
BEGIN

SELECT message INTO peekedmessage FROM messages AS m, message_queue AS mq WHERE m.message_id = mq.message_id AND m.receiver_id in (-1, clientid) AND mq.queue_id = queueid ORDER BY m.toa DESC LIMIT 1;
RETURN peekedmessage;
END;
$$;


ALTER FUNCTION public.peekmessagebyqueue(clientid integer, queueid integer) OWNER TO asl_pg;

--
-- Name: peekmessagebysender(integer, integer); Type: FUNCTION; Schema: public; Owner: asl_pg
--

CREATE FUNCTION peekmessagebysender(clientid integer, senderid integer) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE
peekedmessage VARCHAR(2000);
BEGIN

SELECT message INTO peekedmessage FROM messages AS m, message_queue AS mq WHERE m.message_id = mq.message_id AND m.receiver_id in (-1, clientid) AND m.sender_id = senderid ORDER BY m.toa DESC LIMIT 1;
RETURN peekedmessage;
END;
$$;


ALTER FUNCTION public.peekmessagebysender(clientid integer, senderid integer) OWNER TO asl_pg;

--
-- Name: popmessagebyqueue(integer, integer); Type: FUNCTION; Schema: public; Owner: asl_pg
--

CREATE FUNCTION popmessagebyqueue(clientid integer, queueid integer) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE
popMessage VARCHAR(2000);
messid integer;
BEGIN

SELECT m.message, m.message_id INTO popMessage, messid FROM messages AS m, message_queue AS mq WHERE m.message_id = mq.message_id AND m.receiver_id in (-1, clientid) AND mq.queue_id = queueid ORDER BY m.toa DESC LIMIT 1;

DELETE FROM message_queue WHERE message_id = messid;
DELETE FROM messages WHERE message_id = messid;

RETURN popMessage;
END;
$$;


ALTER FUNCTION public.popmessagebyqueue(clientid integer, queueid integer) OWNER TO asl_pg;

--
-- Name: popmessagebysender(integer, integer); Type: FUNCTION; Schema: public; Owner: asl_pg
--

CREATE FUNCTION popmessagebysender(clientid integer, senderid integer) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE
popMessage VARCHAR(2000);
messid integer;
BEGIN

SELECT m.message, m.message_id INTO popMessage, messid FROM messages AS m, message_queue AS mq WHERE m.message_id = mq.message_id AND m.receiver_id in (-1, clientid) AND m.sender_id = senderid ORDER BY m.toa DESC LIMIT 1;

DELETE FROM message_queue WHERE message_id = messid;
DELETE FROM messages WHERE message_id = messid;

RETURN popMessage;
END;
$$;


ALTER FUNCTION public.popmessagebysender(clientid integer, senderid integer) OWNER TO asl_pg;

--
-- Name: resetdb(); Type: FUNCTION; Schema: public; Owner: asl_pg
--

CREATE FUNCTION resetdb() RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN

DELETE FROM message_queue;
DELETE FROM queues;
DELETE FROM messages;
DELETE FROM clients;

ALTER SEQUENCE client_id_seq RESTART WITH 1;
ALTER SEQUENCE message_id_seq RESTART WITH 1;
ALTER SEQUENCE queue_id_seq RESTART WITH 1;

INSERT INTO clients (client_id) VALUES (-1);

END;
$$;


ALTER FUNCTION public.resetdb() OWNER TO asl_pg;

--
-- Name: client_id_seq; Type: SEQUENCE; Schema: public; Owner: asl_pg
--

CREATE SEQUENCE client_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE client_id_seq OWNER TO asl_pg;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: clients; Type: TABLE; Schema: public; Owner: asl_pg; Tablespace: 
--

CREATE TABLE clients (
    client_id integer DEFAULT nextval('client_id_seq'::regclass) NOT NULL
);


ALTER TABLE clients OWNER TO asl_pg;

--
-- Name: message_id_seq; Type: SEQUENCE; Schema: public; Owner: asl_pg
--

CREATE SEQUENCE message_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE message_id_seq OWNER TO asl_pg;

--
-- Name: message_queue; Type: TABLE; Schema: public; Owner: asl_pg; Tablespace: 
--

CREATE TABLE message_queue (
    queue_id integer NOT NULL,
    message_id integer NOT NULL
);


ALTER TABLE message_queue OWNER TO asl_pg;

--
-- Name: messages; Type: TABLE; Schema: public; Owner: asl_pg; Tablespace: 
--

CREATE TABLE messages (
    message_id integer DEFAULT nextval('message_id_seq'::regclass) NOT NULL,
    sender_id integer NOT NULL,
    receiver_id integer,
    toa timestamp without time zone,
    message character varying(2000)
);


ALTER TABLE messages OWNER TO asl_pg;

--
-- Name: queue_id_seq; Type: SEQUENCE; Schema: public; Owner: asl_pg
--

CREATE SEQUENCE queue_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE queue_id_seq OWNER TO asl_pg;

--
-- Name: queues; Type: TABLE; Schema: public; Owner: asl_pg; Tablespace: 
--

CREATE TABLE queues (
    queue_id integer DEFAULT nextval('queue_id_seq'::regclass) NOT NULL
);


ALTER TABLE queues OWNER TO asl_pg;

--
-- Name: client_id_seq; Type: SEQUENCE SET; Schema: public; Owner: asl_pg
--

SELECT pg_catalog.setval('client_id_seq', 3, true);


--
-- Data for Name: clients; Type: TABLE DATA; Schema: public; Owner: asl_pg
--

COPY clients (client_id) FROM stdin;
-1
1
2
3
\.


--
-- Name: message_id_seq; Type: SEQUENCE SET; Schema: public; Owner: asl_pg
--

SELECT pg_catalog.setval('message_id_seq', 207, true);


--
-- Data for Name: message_queue; Type: TABLE DATA; Schema: public; Owner: asl_pg
--

COPY message_queue (queue_id, message_id) FROM stdin;
18	152
20	154
48	156
20	158
21	160
47	162
52	164
16	166
13	17
6	19
20	168
55	170
44	172
41	174
45	176
35	178
38	180
54	182
73	184
23	186
10	188
55	190
10	192
62	194
53	196
37	198
52	200
33	202
48	204
83	206
6	79
21	133
35	135
53	137
48	139
40	141
33	143
41	145
54	147
21	149
45	151
62	153
55	155
43	157
47	159
36	161
62	163
36	165
22	167
5	18
57	169
56	171
16	173
38	175
33	177
13	179
41	181
20	183
18	185
37	187
17	40
55	189
45	191
22	193
79	195
47	197
22	52
41	199
51	201
55	203
55	205
71	207
23	68
18	72
20	78
18	84
45	126
32	136
54	138
53	140
33	142
25	144
35	146
18	148
56	150
\.


--
-- Data for Name: messages; Type: TABLE DATA; Schema: public; Owner: asl_pg
--

COPY messages (message_id, sender_id, receiver_id, toa, message) FROM stdin;
152	3	2	2015-10-08 22:16:37.462973	NfrZkKrqk0SQnzPhBXfWzbFcJMi8RlKzcyko9ciBBPkYbPQiiSDiPB9QfKYKYIofDUAvqUNiYQy1jbqIyJoMOAlQvIDHC93eBbsk77JcWO66tvwzYNJ8Ucvsb4ayE2nBCk0IHHQ1KmFDIRwE5OQ2TnAK53KC9e5m9FcNBKyA5MAsQXGrDrhtxnNjiLDhcNGHYwXLF18O
154	3	1	2015-10-08 22:16:37.557801	NfrZkKrqk0SQnzPhBXfWzbFcJMi8RlKzcyko9ciBBPkYbPQiiSDiPB9QfKYKYIofDUAvqUNiYQy1jbqIyJoMOAlQvIDHC93eBbsk77JcWO66tvwzYNJ8Ucvsb4ayE2nBCk0IHHQ1KmFDIRwE5OQ2TnAK53KC9e5m9FcNBKyA5MAsQXGrDrhtxnNjiLDhcNGHYwXLF18O
156	3	2	2015-10-08 22:16:37.698979	NfrZkKrqk0SQnzPhBXfWzbFcJMi8RlKzcyko9ciBBPkYbPQiiSDiPB9QfKYKYIofDUAvqUNiYQy1jbqIyJoMOAlQvIDHC93eBbsk77JcWO66tvwzYNJ8Ucvsb4ayE2nBCk0IHHQ1KmFDIRwE5OQ2TnAK53KC9e5m9FcNBKyA5MAsQXGrDrhtxnNjiLDhcNGHYwXLF18O
158	3	2	2015-10-08 22:16:37.887375	NfrZkKrqk0SQnzPhBXfWzbFcJMi8RlKzcyko9ciBBPkYbPQiiSDiPB9QfKYKYIofDUAvqUNiYQy1jbqIyJoMOAlQvIDHC93eBbsk77JcWO66tvwzYNJ8Ucvsb4ayE2nBCk0IHHQ1KmFDIRwE5OQ2TnAK53KC9e5m9FcNBKyA5MAsQXGrDrhtxnNjiLDhcNGHYwXLF18O
160	3	1	2015-10-08 22:16:38.256337	NfrZkKrqk0SQnzPhBXfWzbFcJMi8RlKzcyko9ciBBPkYbPQiiSDiPB9QfKYKYIofDUAvqUNiYQy1jbqIyJoMOAlQvIDHC93eBbsk77JcWO66tvwzYNJ8Ucvsb4ayE2nBCk0IHHQ1KmFDIRwE5OQ2TnAK53KC9e5m9FcNBKyA5MAsQXGrDrhtxnNjiLDhcNGHYwXLF18O
162	3	2	2015-10-08 22:16:38.419951	NfrZkKrqk0SQnzPhBXfWzbFcJMi8RlKzcyko9ciBBPkYbPQiiSDiPB9QfKYKYIofDUAvqUNiYQy1jbqIyJoMOAlQvIDHC93eBbsk77JcWO66tvwzYNJ8Ucvsb4ayE2nBCk0IHHQ1KmFDIRwE5OQ2TnAK53KC9e5m9FcNBKyA5MAsQXGrDrhtxnNjiLDhcNGHYwXLF18O
164	3	1	2015-10-08 22:16:38.623508	NfrZkKrqk0SQnzPhBXfWzbFcJMi8RlKzcyko9ciBBPkYbPQiiSDiPB9QfKYKYIofDUAvqUNiYQy1jbqIyJoMOAlQvIDHC93eBbsk77JcWO66tvwzYNJ8Ucvsb4ayE2nBCk0IHHQ1KmFDIRwE5OQ2TnAK53KC9e5m9FcNBKyA5MAsQXGrDrhtxnNjiLDhcNGHYwXLF18O
166	3	1	2015-10-08 22:16:38.96327	NfrZkKrqk0SQnzPhBXfWzbFcJMi8RlKzcyko9ciBBPkYbPQiiSDiPB9QfKYKYIofDUAvqUNiYQy1jbqIyJoMOAlQvIDHC93eBbsk77JcWO66tvwzYNJ8Ucvsb4ayE2nBCk0IHHQ1KmFDIRwE5OQ2TnAK53KC9e5m9FcNBKyA5MAsQXGrDrhtxnNjiLDhcNGHYwXLF18O
17	2	1	2015-10-08 18:26:45.187398	NfrZkKrqk0SQnzPhBXfWzbFcJMi8RlKzcyko9ciBBPkYbPQiiSDiPB9QfKYKYIofDUAvqUNiYQy1jbqIyJoMOAlQvIDHC93eBbsk77JcWO66tvwzYNJ8Ucvsb4ayE2nBCk0IHHQ1KmFDIRwE5OQ2TnAK53KC9e5m9FcNBKyA5MAsQXGrDrhtxnNjiLDhcNGHYwXLF18O
19	2	1	2015-10-08 18:26:45.303055	NfrZkKrqk0SQnzPhBXfWzbFcJMi8RlKzcyko9ciBBPkYbPQiiSDiPB9QfKYKYIofDUAvqUNiYQy1jbqIyJoMOAlQvIDHC93eBbsk77JcWO66tvwzYNJ8Ucvsb4ayE2nBCk0IHHQ1KmFDIRwE5OQ2TnAK53KC9e5m9FcNBKyA5MAsQXGrDrhtxnNjiLDhcNGHYwXLF18O
168	3	2	2015-10-08 22:16:39.070945	NfrZkKrqk0SQnzPhBXfWzbFcJMi8RlKzcyko9ciBBPkYbPQiiSDiPB9QfKYKYIofDUAvqUNiYQy1jbqIyJoMOAlQvIDHC93eBbsk77JcWO66tvwzYNJ8Ucvsb4ayE2nBCk0IHHQ1KmFDIRwE5OQ2TnAK53KC9e5m9FcNBKyA5MAsQXGrDrhtxnNjiLDhcNGHYwXLF18O
170	3	1	2015-10-08 22:16:39.190212	NfrZkKrqk0SQnzPhBXfWzbFcJMi8RlKzcyko9ciBBPkYbPQiiSDiPB9QfKYKYIofDUAvqUNiYQy1jbqIyJoMOAlQvIDHC93eBbsk77JcWO66tvwzYNJ8Ucvsb4ayE2nBCk0IHHQ1KmFDIRwE5OQ2TnAK53KC9e5m9FcNBKyA5MAsQXGrDrhtxnNjiLDhcNGHYwXLF18O
172	3	2	2015-10-08 22:16:39.363472	NfrZkKrqk0SQnzPhBXfWzbFcJMi8RlKzcyko9ciBBPkYbPQiiSDiPB9QfKYKYIofDUAvqUNiYQy1jbqIyJoMOAlQvIDHC93eBbsk77JcWO66tvwzYNJ8Ucvsb4ayE2nBCk0IHHQ1KmFDIRwE5OQ2TnAK53KC9e5m9FcNBKyA5MAsQXGrDrhtxnNjiLDhcNGHYwXLF18O
174	3	2	2015-10-08 22:16:39.489075	NfrZkKrqk0SQnzPhBXfWzbFcJMi8RlKzcyko9ciBBPkYbPQiiSDiPB9QfKYKYIofDUAvqUNiYQy1jbqIyJoMOAlQvIDHC93eBbsk77JcWO66tvwzYNJ8Ucvsb4ayE2nBCk0IHHQ1KmFDIRwE5OQ2TnAK53KC9e5m9FcNBKyA5MAsQXGrDrhtxnNjiLDhcNGHYwXLF18O
176	3	1	2015-10-08 22:16:39.699518	NfrZkKrqk0SQnzPhBXfWzbFcJMi8RlKzcyko9ciBBPkYbPQiiSDiPB9QfKYKYIofDUAvqUNiYQy1jbqIyJoMOAlQvIDHC93eBbsk77JcWO66tvwzYNJ8Ucvsb4ayE2nBCk0IHHQ1KmFDIRwE5OQ2TnAK53KC9e5m9FcNBKyA5MAsQXGrDrhtxnNjiLDhcNGHYwXLF18O
178	3	2	2015-10-08 22:16:39.849145	NfrZkKrqk0SQnzPhBXfWzbFcJMi8RlKzcyko9ciBBPkYbPQiiSDiPB9QfKYKYIofDUAvqUNiYQy1jbqIyJoMOAlQvIDHC93eBbsk77JcWO66tvwzYNJ8Ucvsb4ayE2nBCk0IHHQ1KmFDIRwE5OQ2TnAK53KC9e5m9FcNBKyA5MAsQXGrDrhtxnNjiLDhcNGHYwXLF18O
79	2	1	2015-10-08 18:26:50.754152	NfrZkKrqk0SQnzPhBXfWzbFcJMi8RlKzcyko9ciBBPkYbPQiiSDiPB9QfKYKYIofDUAvqUNiYQy1jbqIyJoMOAlQvIDHC93eBbsk77JcWO66tvwzYNJ8Ucvsb4ayE2nBCk0IHHQ1KmFDIRwE5OQ2TnAK53KC9e5m9FcNBKyA5MAsQXGrDrhtxnNjiLDhcNGHYwXLF18O
133	2	1	2015-10-08 18:26:56.272524	NfrZkKrqk0SQnzPhBXfWzbFcJMi8RlKzcyko9ciBBPkYbPQiiSDiPB9QfKYKYIofDUAvqUNiYQy1jbqIyJoMOAlQvIDHC93eBbsk77JcWO66tvwzYNJ8Ucvsb4ayE2nBCk0IHHQ1KmFDIRwE5OQ2TnAK53KC9e5m9FcNBKyA5MAsQXGrDrhtxnNjiLDhcNGHYwXLF18O
135	2	1	2015-10-08 18:26:56.452668	NfrZkKrqk0SQnzPhBXfWzbFcJMi8RlKzcyko9ciBBPkYbPQiiSDiPB9QfKYKYIofDUAvqUNiYQy1jbqIyJoMOAlQvIDHC93eBbsk77JcWO66tvwzYNJ8Ucvsb4ayE2nBCk0IHHQ1KmFDIRwE5OQ2TnAK53KC9e5m9FcNBKyA5MAsQXGrDrhtxnNjiLDhcNGHYwXLF18O
137	2	1	2015-10-08 18:26:56.545918	NfrZkKrqk0SQnzPhBXfWzbFcJMi8RlKzcyko9ciBBPkYbPQiiSDiPB9QfKYKYIofDUAvqUNiYQy1jbqIyJoMOAlQvIDHC93eBbsk77JcWO66tvwzYNJ8Ucvsb4ayE2nBCk0IHHQ1KmFDIRwE5OQ2TnAK53KC9e5m9FcNBKyA5MAsQXGrDrhtxnNjiLDhcNGHYwXLF18O
139	2	1	2015-10-08 18:26:56.908293	NfrZkKrqk0SQnzPhBXfWzbFcJMi8RlKzcyko9ciBBPkYbPQiiSDiPB9QfKYKYIofDUAvqUNiYQy1jbqIyJoMOAlQvIDHC93eBbsk77JcWO66tvwzYNJ8Ucvsb4ayE2nBCk0IHHQ1KmFDIRwE5OQ2TnAK53KC9e5m9FcNBKyA5MAsQXGrDrhtxnNjiLDhcNGHYwXLF18O
141	2	1	2015-10-08 18:26:57.038505	NfrZkKrqk0SQnzPhBXfWzbFcJMi8RlKzcyko9ciBBPkYbPQiiSDiPB9QfKYKYIofDUAvqUNiYQy1jbqIyJoMOAlQvIDHC93eBbsk77JcWO66tvwzYNJ8Ucvsb4ayE2nBCk0IHHQ1KmFDIRwE5OQ2TnAK53KC9e5m9FcNBKyA5MAsQXGrDrhtxnNjiLDhcNGHYwXLF18O
143	2	1	2015-10-08 18:26:57.310673	NfrZkKrqk0SQnzPhBXfWzbFcJMi8RlKzcyko9ciBBPkYbPQiiSDiPB9QfKYKYIofDUAvqUNiYQy1jbqIyJoMOAlQvIDHC93eBbsk77JcWO66tvwzYNJ8Ucvsb4ayE2nBCk0IHHQ1KmFDIRwE5OQ2TnAK53KC9e5m9FcNBKyA5MAsQXGrDrhtxnNjiLDhcNGHYwXLF18O
145	2	1	2015-10-08 18:26:57.580635	NfrZkKrqk0SQnzPhBXfWzbFcJMi8RlKzcyko9ciBBPkYbPQiiSDiPB9QfKYKYIofDUAvqUNiYQy1jbqIyJoMOAlQvIDHC93eBbsk77JcWO66tvwzYNJ8Ucvsb4ayE2nBCk0IHHQ1KmFDIRwE5OQ2TnAK53KC9e5m9FcNBKyA5MAsQXGrDrhtxnNjiLDhcNGHYwXLF18O
147	2	1	2015-10-08 18:26:57.848745	NfrZkKrqk0SQnzPhBXfWzbFcJMi8RlKzcyko9ciBBPkYbPQiiSDiPB9QfKYKYIofDUAvqUNiYQy1jbqIyJoMOAlQvIDHC93eBbsk77JcWO66tvwzYNJ8Ucvsb4ayE2nBCk0IHHQ1KmFDIRwE5OQ2TnAK53KC9e5m9FcNBKyA5MAsQXGrDrhtxnNjiLDhcNGHYwXLF18O
149	2	1	2015-10-08 18:26:57.993966	NfrZkKrqk0SQnzPhBXfWzbFcJMi8RlKzcyko9ciBBPkYbPQiiSDiPB9QfKYKYIofDUAvqUNiYQy1jbqIyJoMOAlQvIDHC93eBbsk77JcWO66tvwzYNJ8Ucvsb4ayE2nBCk0IHHQ1KmFDIRwE5OQ2TnAK53KC9e5m9FcNBKyA5MAsQXGrDrhtxnNjiLDhcNGHYwXLF18O
151	2	1	2015-10-08 18:26:58.215878	NfrZkKrqk0SQnzPhBXfWzbFcJMi8RlKzcyko9ciBBPkYbPQiiSDiPB9QfKYKYIofDUAvqUNiYQy1jbqIyJoMOAlQvIDHC93eBbsk77JcWO66tvwzYNJ8Ucvsb4ayE2nBCk0IHHQ1KmFDIRwE5OQ2TnAK53KC9e5m9FcNBKyA5MAsQXGrDrhtxnNjiLDhcNGHYwXLF18O
153	3	2	2015-10-08 22:16:37.512347	NfrZkKrqk0SQnzPhBXfWzbFcJMi8RlKzcyko9ciBBPkYbPQiiSDiPB9QfKYKYIofDUAvqUNiYQy1jbqIyJoMOAlQvIDHC93eBbsk77JcWO66tvwzYNJ8Ucvsb4ayE2nBCk0IHHQ1KmFDIRwE5OQ2TnAK53KC9e5m9FcNBKyA5MAsQXGrDrhtxnNjiLDhcNGHYwXLF18O
155	3	2	2015-10-08 22:16:37.639354	NfrZkKrqk0SQnzPhBXfWzbFcJMi8RlKzcyko9ciBBPkYbPQiiSDiPB9QfKYKYIofDUAvqUNiYQy1jbqIyJoMOAlQvIDHC93eBbsk77JcWO66tvwzYNJ8Ucvsb4ayE2nBCk0IHHQ1KmFDIRwE5OQ2TnAK53KC9e5m9FcNBKyA5MAsQXGrDrhtxnNjiLDhcNGHYwXLF18O
157	3	2	2015-10-08 22:16:37.838356	NfrZkKrqk0SQnzPhBXfWzbFcJMi8RlKzcyko9ciBBPkYbPQiiSDiPB9QfKYKYIofDUAvqUNiYQy1jbqIyJoMOAlQvIDHC93eBbsk77JcWO66tvwzYNJ8Ucvsb4ayE2nBCk0IHHQ1KmFDIRwE5OQ2TnAK53KC9e5m9FcNBKyA5MAsQXGrDrhtxnNjiLDhcNGHYwXLF18O
159	3	2	2015-10-08 22:16:38.099766	NfrZkKrqk0SQnzPhBXfWzbFcJMi8RlKzcyko9ciBBPkYbPQiiSDiPB9QfKYKYIofDUAvqUNiYQy1jbqIyJoMOAlQvIDHC93eBbsk77JcWO66tvwzYNJ8Ucvsb4ayE2nBCk0IHHQ1KmFDIRwE5OQ2TnAK53KC9e5m9FcNBKyA5MAsQXGrDrhtxnNjiLDhcNGHYwXLF18O
161	3	1	2015-10-08 22:16:38.353071	NfrZkKrqk0SQnzPhBXfWzbFcJMi8RlKzcyko9ciBBPkYbPQiiSDiPB9QfKYKYIofDUAvqUNiYQy1jbqIyJoMOAlQvIDHC93eBbsk77JcWO66tvwzYNJ8Ucvsb4ayE2nBCk0IHHQ1KmFDIRwE5OQ2TnAK53KC9e5m9FcNBKyA5MAsQXGrDrhtxnNjiLDhcNGHYwXLF18O
163	3	2	2015-10-08 22:16:38.482155	NfrZkKrqk0SQnzPhBXfWzbFcJMi8RlKzcyko9ciBBPkYbPQiiSDiPB9QfKYKYIofDUAvqUNiYQy1jbqIyJoMOAlQvIDHC93eBbsk77JcWO66tvwzYNJ8Ucvsb4ayE2nBCk0IHHQ1KmFDIRwE5OQ2TnAK53KC9e5m9FcNBKyA5MAsQXGrDrhtxnNjiLDhcNGHYwXLF18O
165	3	2	2015-10-08 22:16:38.871708	NfrZkKrqk0SQnzPhBXfWzbFcJMi8RlKzcyko9ciBBPkYbPQiiSDiPB9QfKYKYIofDUAvqUNiYQy1jbqIyJoMOAlQvIDHC93eBbsk77JcWO66tvwzYNJ8Ucvsb4ayE2nBCk0IHHQ1KmFDIRwE5OQ2TnAK53KC9e5m9FcNBKyA5MAsQXGrDrhtxnNjiLDhcNGHYwXLF18O
167	3	2	2015-10-08 22:16:39.004155	NfrZkKrqk0SQnzPhBXfWzbFcJMi8RlKzcyko9ciBBPkYbPQiiSDiPB9QfKYKYIofDUAvqUNiYQy1jbqIyJoMOAlQvIDHC93eBbsk77JcWO66tvwzYNJ8Ucvsb4ayE2nBCk0IHHQ1KmFDIRwE5OQ2TnAK53KC9e5m9FcNBKyA5MAsQXGrDrhtxnNjiLDhcNGHYwXLF18O
18	2	1	2015-10-08 18:26:45.243563	NfrZkKrqk0SQnzPhBXfWzbFcJMi8RlKzcyko9ciBBPkYbPQiiSDiPB9QfKYKYIofDUAvqUNiYQy1jbqIyJoMOAlQvIDHC93eBbsk77JcWO66tvwzYNJ8Ucvsb4ayE2nBCk0IHHQ1KmFDIRwE5OQ2TnAK53KC9e5m9FcNBKyA5MAsQXGrDrhtxnNjiLDhcNGHYwXLF18O
169	3	1	2015-10-08 22:16:39.150372	NfrZkKrqk0SQnzPhBXfWzbFcJMi8RlKzcyko9ciBBPkYbPQiiSDiPB9QfKYKYIofDUAvqUNiYQy1jbqIyJoMOAlQvIDHC93eBbsk77JcWO66tvwzYNJ8Ucvsb4ayE2nBCk0IHHQ1KmFDIRwE5OQ2TnAK53KC9e5m9FcNBKyA5MAsQXGrDrhtxnNjiLDhcNGHYwXLF18O
171	3	1	2015-10-08 22:16:39.297751	NfrZkKrqk0SQnzPhBXfWzbFcJMi8RlKzcyko9ciBBPkYbPQiiSDiPB9QfKYKYIofDUAvqUNiYQy1jbqIyJoMOAlQvIDHC93eBbsk77JcWO66tvwzYNJ8Ucvsb4ayE2nBCk0IHHQ1KmFDIRwE5OQ2TnAK53KC9e5m9FcNBKyA5MAsQXGrDrhtxnNjiLDhcNGHYwXLF18O
173	3	2	2015-10-08 22:16:39.45355	NfrZkKrqk0SQnzPhBXfWzbFcJMi8RlKzcyko9ciBBPkYbPQiiSDiPB9QfKYKYIofDUAvqUNiYQy1jbqIyJoMOAlQvIDHC93eBbsk77JcWO66tvwzYNJ8Ucvsb4ayE2nBCk0IHHQ1KmFDIRwE5OQ2TnAK53KC9e5m9FcNBKyA5MAsQXGrDrhtxnNjiLDhcNGHYwXLF18O
175	3	2	2015-10-08 22:16:39.552051	NfrZkKrqk0SQnzPhBXfWzbFcJMi8RlKzcyko9ciBBPkYbPQiiSDiPB9QfKYKYIofDUAvqUNiYQy1jbqIyJoMOAlQvIDHC93eBbsk77JcWO66tvwzYNJ8Ucvsb4ayE2nBCk0IHHQ1KmFDIRwE5OQ2TnAK53KC9e5m9FcNBKyA5MAsQXGrDrhtxnNjiLDhcNGHYwXLF18O
177	3	2	2015-10-08 22:16:39.734719	NfrZkKrqk0SQnzPhBXfWzbFcJMi8RlKzcyko9ciBBPkYbPQiiSDiPB9QfKYKYIofDUAvqUNiYQy1jbqIyJoMOAlQvIDHC93eBbsk77JcWO66tvwzYNJ8Ucvsb4ayE2nBCk0IHHQ1KmFDIRwE5OQ2TnAK53KC9e5m9FcNBKyA5MAsQXGrDrhtxnNjiLDhcNGHYwXLF18O
179	3	1	2015-10-08 22:16:39.966287	NfrZkKrqk0SQnzPhBXfWzbFcJMi8RlKzcyko9ciBBPkYbPQiiSDiPB9QfKYKYIofDUAvqUNiYQy1jbqIyJoMOAlQvIDHC93eBbsk77JcWO66tvwzYNJ8Ucvsb4ayE2nBCk0IHHQ1KmFDIRwE5OQ2TnAK53KC9e5m9FcNBKyA5MAsQXGrDrhtxnNjiLDhcNGHYwXLF18O
40	2	1	2015-10-08 18:26:47.516737	NfrZkKrqk0SQnzPhBXfWzbFcJMi8RlKzcyko9ciBBPkYbPQiiSDiPB9QfKYKYIofDUAvqUNiYQy1jbqIyJoMOAlQvIDHC93eBbsk77JcWO66tvwzYNJ8Ucvsb4ayE2nBCk0IHHQ1KmFDIRwE5OQ2TnAK53KC9e5m9FcNBKyA5MAsQXGrDrhtxnNjiLDhcNGHYwXLF18O
52	2	1	2015-10-08 18:26:48.827019	NfrZkKrqk0SQnzPhBXfWzbFcJMi8RlKzcyko9ciBBPkYbPQiiSDiPB9QfKYKYIofDUAvqUNiYQy1jbqIyJoMOAlQvIDHC93eBbsk77JcWO66tvwzYNJ8Ucvsb4ayE2nBCk0IHHQ1KmFDIRwE5OQ2TnAK53KC9e5m9FcNBKyA5MAsQXGrDrhtxnNjiLDhcNGHYwXLF18O
68	2	1	2015-10-08 18:26:49.870108	NfrZkKrqk0SQnzPhBXfWzbFcJMi8RlKzcyko9ciBBPkYbPQiiSDiPB9QfKYKYIofDUAvqUNiYQy1jbqIyJoMOAlQvIDHC93eBbsk77JcWO66tvwzYNJ8Ucvsb4ayE2nBCk0IHHQ1KmFDIRwE5OQ2TnAK53KC9e5m9FcNBKyA5MAsQXGrDrhtxnNjiLDhcNGHYwXLF18O
72	2	1	2015-10-08 18:26:50.104516	NfrZkKrqk0SQnzPhBXfWzbFcJMi8RlKzcyko9ciBBPkYbPQiiSDiPB9QfKYKYIofDUAvqUNiYQy1jbqIyJoMOAlQvIDHC93eBbsk77JcWO66tvwzYNJ8Ucvsb4ayE2nBCk0IHHQ1KmFDIRwE5OQ2TnAK53KC9e5m9FcNBKyA5MAsQXGrDrhtxnNjiLDhcNGHYwXLF18O
78	2	1	2015-10-08 18:26:50.686845	NfrZkKrqk0SQnzPhBXfWzbFcJMi8RlKzcyko9ciBBPkYbPQiiSDiPB9QfKYKYIofDUAvqUNiYQy1jbqIyJoMOAlQvIDHC93eBbsk77JcWO66tvwzYNJ8Ucvsb4ayE2nBCk0IHHQ1KmFDIRwE5OQ2TnAK53KC9e5m9FcNBKyA5MAsQXGrDrhtxnNjiLDhcNGHYwXLF18O
84	2	1	2015-10-08 18:26:51.030877	NfrZkKrqk0SQnzPhBXfWzbFcJMi8RlKzcyko9ciBBPkYbPQiiSDiPB9QfKYKYIofDUAvqUNiYQy1jbqIyJoMOAlQvIDHC93eBbsk77JcWO66tvwzYNJ8Ucvsb4ayE2nBCk0IHHQ1KmFDIRwE5OQ2TnAK53KC9e5m9FcNBKyA5MAsQXGrDrhtxnNjiLDhcNGHYwXLF18O
126	2	1	2015-10-08 18:26:55.395618	NfrZkKrqk0SQnzPhBXfWzbFcJMi8RlKzcyko9ciBBPkYbPQiiSDiPB9QfKYKYIofDUAvqUNiYQy1jbqIyJoMOAlQvIDHC93eBbsk77JcWO66tvwzYNJ8Ucvsb4ayE2nBCk0IHHQ1KmFDIRwE5OQ2TnAK53KC9e5m9FcNBKyA5MAsQXGrDrhtxnNjiLDhcNGHYwXLF18O
136	2	1	2015-10-08 18:26:56.502282	NfrZkKrqk0SQnzPhBXfWzbFcJMi8RlKzcyko9ciBBPkYbPQiiSDiPB9QfKYKYIofDUAvqUNiYQy1jbqIyJoMOAlQvIDHC93eBbsk77JcWO66tvwzYNJ8Ucvsb4ayE2nBCk0IHHQ1KmFDIRwE5OQ2TnAK53KC9e5m9FcNBKyA5MAsQXGrDrhtxnNjiLDhcNGHYwXLF18O
138	2	1	2015-10-08 18:26:56.822238	NfrZkKrqk0SQnzPhBXfWzbFcJMi8RlKzcyko9ciBBPkYbPQiiSDiPB9QfKYKYIofDUAvqUNiYQy1jbqIyJoMOAlQvIDHC93eBbsk77JcWO66tvwzYNJ8Ucvsb4ayE2nBCk0IHHQ1KmFDIRwE5OQ2TnAK53KC9e5m9FcNBKyA5MAsQXGrDrhtxnNjiLDhcNGHYwXLF18O
140	2	1	2015-10-08 18:26:56.969075	NfrZkKrqk0SQnzPhBXfWzbFcJMi8RlKzcyko9ciBBPkYbPQiiSDiPB9QfKYKYIofDUAvqUNiYQy1jbqIyJoMOAlQvIDHC93eBbsk77JcWO66tvwzYNJ8Ucvsb4ayE2nBCk0IHHQ1KmFDIRwE5OQ2TnAK53KC9e5m9FcNBKyA5MAsQXGrDrhtxnNjiLDhcNGHYwXLF18O
142	2	1	2015-10-08 18:26:57.254883	NfrZkKrqk0SQnzPhBXfWzbFcJMi8RlKzcyko9ciBBPkYbPQiiSDiPB9QfKYKYIofDUAvqUNiYQy1jbqIyJoMOAlQvIDHC93eBbsk77JcWO66tvwzYNJ8Ucvsb4ayE2nBCk0IHHQ1KmFDIRwE5OQ2TnAK53KC9e5m9FcNBKyA5MAsQXGrDrhtxnNjiLDhcNGHYwXLF18O
144	2	1	2015-10-08 18:26:57.389197	NfrZkKrqk0SQnzPhBXfWzbFcJMi8RlKzcyko9ciBBPkYbPQiiSDiPB9QfKYKYIofDUAvqUNiYQy1jbqIyJoMOAlQvIDHC93eBbsk77JcWO66tvwzYNJ8Ucvsb4ayE2nBCk0IHHQ1KmFDIRwE5OQ2TnAK53KC9e5m9FcNBKyA5MAsQXGrDrhtxnNjiLDhcNGHYwXLF18O
146	2	1	2015-10-08 18:26:57.742999	NfrZkKrqk0SQnzPhBXfWzbFcJMi8RlKzcyko9ciBBPkYbPQiiSDiPB9QfKYKYIofDUAvqUNiYQy1jbqIyJoMOAlQvIDHC93eBbsk77JcWO66tvwzYNJ8Ucvsb4ayE2nBCk0IHHQ1KmFDIRwE5OQ2TnAK53KC9e5m9FcNBKyA5MAsQXGrDrhtxnNjiLDhcNGHYwXLF18O
148	2	1	2015-10-08 18:26:57.886209	NfrZkKrqk0SQnzPhBXfWzbFcJMi8RlKzcyko9ciBBPkYbPQiiSDiPB9QfKYKYIofDUAvqUNiYQy1jbqIyJoMOAlQvIDHC93eBbsk77JcWO66tvwzYNJ8Ucvsb4ayE2nBCk0IHHQ1KmFDIRwE5OQ2TnAK53KC9e5m9FcNBKyA5MAsQXGrDrhtxnNjiLDhcNGHYwXLF18O
150	2	1	2015-10-08 18:26:58.182301	NfrZkKrqk0SQnzPhBXfWzbFcJMi8RlKzcyko9ciBBPkYbPQiiSDiPB9QfKYKYIofDUAvqUNiYQy1jbqIyJoMOAlQvIDHC93eBbsk77JcWO66tvwzYNJ8Ucvsb4ayE2nBCk0IHHQ1KmFDIRwE5OQ2TnAK53KC9e5m9FcNBKyA5MAsQXGrDrhtxnNjiLDhcNGHYwXLF18O
180	3	2	2015-10-08 22:16:40.141105	NfrZkKrqk0SQnzPhBXfWzbFcJMi8RlKzcyko9ciBBPkYbPQiiSDiPB9QfKYKYIofDUAvqUNiYQy1jbqIyJoMOAlQvIDHC93eBbsk77JcWO66tvwzYNJ8Ucvsb4ayE2nBCk0IHHQ1KmFDIRwE5OQ2TnAK53KC9e5m9FcNBKyA5MAsQXGrDrhtxnNjiLDhcNGHYwXLF18O
181	3	1	2015-10-08 22:16:40.303001	NfrZkKrqk0SQnzPhBXfWzbFcJMi8RlKzcyko9ciBBPkYbPQiiSDiPB9QfKYKYIofDUAvqUNiYQy1jbqIyJoMOAlQvIDHC93eBbsk77JcWO66tvwzYNJ8Ucvsb4ayE2nBCk0IHHQ1KmFDIRwE5OQ2TnAK53KC9e5m9FcNBKyA5MAsQXGrDrhtxnNjiLDhcNGHYwXLF18O
182	3	2	2015-10-08 22:16:40.421456	NfrZkKrqk0SQnzPhBXfWzbFcJMi8RlKzcyko9ciBBPkYbPQiiSDiPB9QfKYKYIofDUAvqUNiYQy1jbqIyJoMOAlQvIDHC93eBbsk77JcWO66tvwzYNJ8Ucvsb4ayE2nBCk0IHHQ1KmFDIRwE5OQ2TnAK53KC9e5m9FcNBKyA5MAsQXGrDrhtxnNjiLDhcNGHYwXLF18O
183	3	2	2015-10-08 22:16:40.459301	NfrZkKrqk0SQnzPhBXfWzbFcJMi8RlKzcyko9ciBBPkYbPQiiSDiPB9QfKYKYIofDUAvqUNiYQy1jbqIyJoMOAlQvIDHC93eBbsk77JcWO66tvwzYNJ8Ucvsb4ayE2nBCk0IHHQ1KmFDIRwE5OQ2TnAK53KC9e5m9FcNBKyA5MAsQXGrDrhtxnNjiLDhcNGHYwXLF18O
184	3	2	2015-10-08 22:16:40.677644	NfrZkKrqk0SQnzPhBXfWzbFcJMi8RlKzcyko9ciBBPkYbPQiiSDiPB9QfKYKYIofDUAvqUNiYQy1jbqIyJoMOAlQvIDHC93eBbsk77JcWO66tvwzYNJ8Ucvsb4ayE2nBCk0IHHQ1KmFDIRwE5OQ2TnAK53KC9e5m9FcNBKyA5MAsQXGrDrhtxnNjiLDhcNGHYwXLF18O
185	3	1	2015-10-08 22:16:40.878856	NfrZkKrqk0SQnzPhBXfWzbFcJMi8RlKzcyko9ciBBPkYbPQiiSDiPB9QfKYKYIofDUAvqUNiYQy1jbqIyJoMOAlQvIDHC93eBbsk77JcWO66tvwzYNJ8Ucvsb4ayE2nBCk0IHHQ1KmFDIRwE5OQ2TnAK53KC9e5m9FcNBKyA5MAsQXGrDrhtxnNjiLDhcNGHYwXLF18O
186	3	1	2015-10-08 22:16:40.915693	NfrZkKrqk0SQnzPhBXfWzbFcJMi8RlKzcyko9ciBBPkYbPQiiSDiPB9QfKYKYIofDUAvqUNiYQy1jbqIyJoMOAlQvIDHC93eBbsk77JcWO66tvwzYNJ8Ucvsb4ayE2nBCk0IHHQ1KmFDIRwE5OQ2TnAK53KC9e5m9FcNBKyA5MAsQXGrDrhtxnNjiLDhcNGHYwXLF18O
187	3	2	2015-10-08 22:16:41.065222	NfrZkKrqk0SQnzPhBXfWzbFcJMi8RlKzcyko9ciBBPkYbPQiiSDiPB9QfKYKYIofDUAvqUNiYQy1jbqIyJoMOAlQvIDHC93eBbsk77JcWO66tvwzYNJ8Ucvsb4ayE2nBCk0IHHQ1KmFDIRwE5OQ2TnAK53KC9e5m9FcNBKyA5MAsQXGrDrhtxnNjiLDhcNGHYwXLF18O
188	3	1	2015-10-08 22:16:41.140514	NfrZkKrqk0SQnzPhBXfWzbFcJMi8RlKzcyko9ciBBPkYbPQiiSDiPB9QfKYKYIofDUAvqUNiYQy1jbqIyJoMOAlQvIDHC93eBbsk77JcWO66tvwzYNJ8Ucvsb4ayE2nBCk0IHHQ1KmFDIRwE5OQ2TnAK53KC9e5m9FcNBKyA5MAsQXGrDrhtxnNjiLDhcNGHYwXLF18O
189	3	1	2015-10-08 22:16:41.254477	NfrZkKrqk0SQnzPhBXfWzbFcJMi8RlKzcyko9ciBBPkYbPQiiSDiPB9QfKYKYIofDUAvqUNiYQy1jbqIyJoMOAlQvIDHC93eBbsk77JcWO66tvwzYNJ8Ucvsb4ayE2nBCk0IHHQ1KmFDIRwE5OQ2TnAK53KC9e5m9FcNBKyA5MAsQXGrDrhtxnNjiLDhcNGHYwXLF18O
190	3	1	2015-10-08 22:16:41.415204	NfrZkKrqk0SQnzPhBXfWzbFcJMi8RlKzcyko9ciBBPkYbPQiiSDiPB9QfKYKYIofDUAvqUNiYQy1jbqIyJoMOAlQvIDHC93eBbsk77JcWO66tvwzYNJ8Ucvsb4ayE2nBCk0IHHQ1KmFDIRwE5OQ2TnAK53KC9e5m9FcNBKyA5MAsQXGrDrhtxnNjiLDhcNGHYwXLF18O
191	3	2	2015-10-08 22:16:41.499343	NfrZkKrqk0SQnzPhBXfWzbFcJMi8RlKzcyko9ciBBPkYbPQiiSDiPB9QfKYKYIofDUAvqUNiYQy1jbqIyJoMOAlQvIDHC93eBbsk77JcWO66tvwzYNJ8Ucvsb4ayE2nBCk0IHHQ1KmFDIRwE5OQ2TnAK53KC9e5m9FcNBKyA5MAsQXGrDrhtxnNjiLDhcNGHYwXLF18O
192	3	2	2015-10-08 22:16:41.616965	NfrZkKrqk0SQnzPhBXfWzbFcJMi8RlKzcyko9ciBBPkYbPQiiSDiPB9QfKYKYIofDUAvqUNiYQy1jbqIyJoMOAlQvIDHC93eBbsk77JcWO66tvwzYNJ8Ucvsb4ayE2nBCk0IHHQ1KmFDIRwE5OQ2TnAK53KC9e5m9FcNBKyA5MAsQXGrDrhtxnNjiLDhcNGHYwXLF18O
193	3	2	2015-10-08 22:16:41.683508	NfrZkKrqk0SQnzPhBXfWzbFcJMi8RlKzcyko9ciBBPkYbPQiiSDiPB9QfKYKYIofDUAvqUNiYQy1jbqIyJoMOAlQvIDHC93eBbsk77JcWO66tvwzYNJ8Ucvsb4ayE2nBCk0IHHQ1KmFDIRwE5OQ2TnAK53KC9e5m9FcNBKyA5MAsQXGrDrhtxnNjiLDhcNGHYwXLF18O
194	3	2	2015-10-08 22:16:41.971052	NfrZkKrqk0SQnzPhBXfWzbFcJMi8RlKzcyko9ciBBPkYbPQiiSDiPB9QfKYKYIofDUAvqUNiYQy1jbqIyJoMOAlQvIDHC93eBbsk77JcWO66tvwzYNJ8Ucvsb4ayE2nBCk0IHHQ1KmFDIRwE5OQ2TnAK53KC9e5m9FcNBKyA5MAsQXGrDrhtxnNjiLDhcNGHYwXLF18O
195	3	2	2015-10-08 22:16:42.389482	NfrZkKrqk0SQnzPhBXfWzbFcJMi8RlKzcyko9ciBBPkYbPQiiSDiPB9QfKYKYIofDUAvqUNiYQy1jbqIyJoMOAlQvIDHC93eBbsk77JcWO66tvwzYNJ8Ucvsb4ayE2nBCk0IHHQ1KmFDIRwE5OQ2TnAK53KC9e5m9FcNBKyA5MAsQXGrDrhtxnNjiLDhcNGHYwXLF18O
196	3	1	2015-10-08 22:16:42.512858	NfrZkKrqk0SQnzPhBXfWzbFcJMi8RlKzcyko9ciBBPkYbPQiiSDiPB9QfKYKYIofDUAvqUNiYQy1jbqIyJoMOAlQvIDHC93eBbsk77JcWO66tvwzYNJ8Ucvsb4ayE2nBCk0IHHQ1KmFDIRwE5OQ2TnAK53KC9e5m9FcNBKyA5MAsQXGrDrhtxnNjiLDhcNGHYwXLF18O
197	3	1	2015-10-08 22:16:42.751189	NfrZkKrqk0SQnzPhBXfWzbFcJMi8RlKzcyko9ciBBPkYbPQiiSDiPB9QfKYKYIofDUAvqUNiYQy1jbqIyJoMOAlQvIDHC93eBbsk77JcWO66tvwzYNJ8Ucvsb4ayE2nBCk0IHHQ1KmFDIRwE5OQ2TnAK53KC9e5m9FcNBKyA5MAsQXGrDrhtxnNjiLDhcNGHYwXLF18O
198	3	2	2015-10-08 22:16:42.902839	NfrZkKrqk0SQnzPhBXfWzbFcJMi8RlKzcyko9ciBBPkYbPQiiSDiPB9QfKYKYIofDUAvqUNiYQy1jbqIyJoMOAlQvIDHC93eBbsk77JcWO66tvwzYNJ8Ucvsb4ayE2nBCk0IHHQ1KmFDIRwE5OQ2TnAK53KC9e5m9FcNBKyA5MAsQXGrDrhtxnNjiLDhcNGHYwXLF18O
199	3	2	2015-10-08 22:16:43.246418	NfrZkKrqk0SQnzPhBXfWzbFcJMi8RlKzcyko9ciBBPkYbPQiiSDiPB9QfKYKYIofDUAvqUNiYQy1jbqIyJoMOAlQvIDHC93eBbsk77JcWO66tvwzYNJ8Ucvsb4ayE2nBCk0IHHQ1KmFDIRwE5OQ2TnAK53KC9e5m9FcNBKyA5MAsQXGrDrhtxnNjiLDhcNGHYwXLF18O
200	3	1	2015-10-08 22:16:43.394001	NfrZkKrqk0SQnzPhBXfWzbFcJMi8RlKzcyko9ciBBPkYbPQiiSDiPB9QfKYKYIofDUAvqUNiYQy1jbqIyJoMOAlQvIDHC93eBbsk77JcWO66tvwzYNJ8Ucvsb4ayE2nBCk0IHHQ1KmFDIRwE5OQ2TnAK53KC9e5m9FcNBKyA5MAsQXGrDrhtxnNjiLDhcNGHYwXLF18O
201	3	2	2015-10-08 22:16:43.559373	NfrZkKrqk0SQnzPhBXfWzbFcJMi8RlKzcyko9ciBBPkYbPQiiSDiPB9QfKYKYIofDUAvqUNiYQy1jbqIyJoMOAlQvIDHC93eBbsk77JcWO66tvwzYNJ8Ucvsb4ayE2nBCk0IHHQ1KmFDIRwE5OQ2TnAK53KC9e5m9FcNBKyA5MAsQXGrDrhtxnNjiLDhcNGHYwXLF18O
202	3	1	2015-10-08 22:16:43.594293	NfrZkKrqk0SQnzPhBXfWzbFcJMi8RlKzcyko9ciBBPkYbPQiiSDiPB9QfKYKYIofDUAvqUNiYQy1jbqIyJoMOAlQvIDHC93eBbsk77JcWO66tvwzYNJ8Ucvsb4ayE2nBCk0IHHQ1KmFDIRwE5OQ2TnAK53KC9e5m9FcNBKyA5MAsQXGrDrhtxnNjiLDhcNGHYwXLF18O
203	3	1	2015-10-08 22:16:43.629554	NfrZkKrqk0SQnzPhBXfWzbFcJMi8RlKzcyko9ciBBPkYbPQiiSDiPB9QfKYKYIofDUAvqUNiYQy1jbqIyJoMOAlQvIDHC93eBbsk77JcWO66tvwzYNJ8Ucvsb4ayE2nBCk0IHHQ1KmFDIRwE5OQ2TnAK53KC9e5m9FcNBKyA5MAsQXGrDrhtxnNjiLDhcNGHYwXLF18O
204	3	2	2015-10-08 22:16:43.689024	NfrZkKrqk0SQnzPhBXfWzbFcJMi8RlKzcyko9ciBBPkYbPQiiSDiPB9QfKYKYIofDUAvqUNiYQy1jbqIyJoMOAlQvIDHC93eBbsk77JcWO66tvwzYNJ8Ucvsb4ayE2nBCk0IHHQ1KmFDIRwE5OQ2TnAK53KC9e5m9FcNBKyA5MAsQXGrDrhtxnNjiLDhcNGHYwXLF18O
205	3	1	2015-10-08 22:16:43.82214	NfrZkKrqk0SQnzPhBXfWzbFcJMi8RlKzcyko9ciBBPkYbPQiiSDiPB9QfKYKYIofDUAvqUNiYQy1jbqIyJoMOAlQvIDHC93eBbsk77JcWO66tvwzYNJ8Ucvsb4ayE2nBCk0IHHQ1KmFDIRwE5OQ2TnAK53KC9e5m9FcNBKyA5MAsQXGrDrhtxnNjiLDhcNGHYwXLF18O
206	3	1	2015-10-08 22:16:43.909182	NfrZkKrqk0SQnzPhBXfWzbFcJMi8RlKzcyko9ciBBPkYbPQiiSDiPB9QfKYKYIofDUAvqUNiYQy1jbqIyJoMOAlQvIDHC93eBbsk77JcWO66tvwzYNJ8Ucvsb4ayE2nBCk0IHHQ1KmFDIRwE5OQ2TnAK53KC9e5m9FcNBKyA5MAsQXGrDrhtxnNjiLDhcNGHYwXLF18O
207	3	1	2015-10-08 22:16:44.00575	NfrZkKrqk0SQnzPhBXfWzbFcJMi8RlKzcyko9ciBBPkYbPQiiSDiPB9QfKYKYIofDUAvqUNiYQy1jbqIyJoMOAlQvIDHC93eBbsk77JcWO66tvwzYNJ8Ucvsb4ayE2nBCk0IHHQ1KmFDIRwE5OQ2TnAK53KC9e5m9FcNBKyA5MAsQXGrDrhtxnNjiLDhcNGHYwXLF18O
\.


--
-- Name: queue_id_seq; Type: SEQUENCE SET; Schema: public; Owner: asl_pg
--

SELECT pg_catalog.setval('queue_id_seq', 88, true);


--
-- Data for Name: queues; Type: TABLE DATA; Schema: public; Owner: asl_pg
--

COPY queues (queue_id) FROM stdin;
5
6
9
10
13
16
17
18
20
21
22
23
25
29
32
33
35
36
37
38
39
40
41
43
44
45
47
48
49
51
52
53
54
55
56
57
58
59
60
61
62
65
67
69
71
72
73
74
75
76
77
78
79
80
81
83
85
86
87
88
\.


--
-- Name: clients_pkey; Type: CONSTRAINT; Schema: public; Owner: asl_pg; Tablespace: 
--

ALTER TABLE ONLY clients
    ADD CONSTRAINT clients_pkey PRIMARY KEY (client_id);


--
-- Name: messages_pkey; Type: CONSTRAINT; Schema: public; Owner: asl_pg; Tablespace: 
--

ALTER TABLE ONLY messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (message_id);


--
-- Name: queues_pkey; Type: CONSTRAINT; Schema: public; Owner: asl_pg; Tablespace: 
--

ALTER TABLE ONLY queues
    ADD CONSTRAINT queues_pkey PRIMARY KEY (queue_id);


--
-- Name: toa_idx; Type: INDEX; Schema: public; Owner: asl_pg; Tablespace: 
--

CREATE UNIQUE INDEX toa_idx ON messages USING btree (toa);


--
-- Name: message_queue_message_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: asl_pg
--

ALTER TABLE ONLY message_queue
    ADD CONSTRAINT message_queue_message_id_fkey FOREIGN KEY (message_id) REFERENCES messages(message_id);


--
-- Name: message_queue_queue_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: asl_pg
--

ALTER TABLE ONLY message_queue
    ADD CONSTRAINT message_queue_queue_id_fkey FOREIGN KEY (queue_id) REFERENCES queues(queue_id);


--
-- Name: messages_receiver_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: asl_pg
--

ALTER TABLE ONLY messages
    ADD CONSTRAINT messages_receiver_id_fkey FOREIGN KEY (receiver_id) REFERENCES clients(client_id);


--
-- Name: messages_sender_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: asl_pg
--

ALTER TABLE ONLY messages
    ADD CONSTRAINT messages_sender_id_fkey FOREIGN KEY (sender_id) REFERENCES clients(client_id);


--
-- Name: public; Type: ACL; Schema: -; Owner: florangmehlin
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM florangmehlin;
GRANT ALL ON SCHEMA public TO florangmehlin;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- Name: client_id_seq; Type: ACL; Schema: public; Owner: asl_pg
--

REVOKE ALL ON SEQUENCE client_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE client_id_seq FROM asl_pg;
GRANT ALL ON SEQUENCE client_id_seq TO asl_pg;


--
-- Name: clients; Type: ACL; Schema: public; Owner: asl_pg
--

REVOKE ALL ON TABLE clients FROM PUBLIC;
REVOKE ALL ON TABLE clients FROM asl_pg;
GRANT ALL ON TABLE clients TO asl_pg;


--
-- Name: message_id_seq; Type: ACL; Schema: public; Owner: asl_pg
--

REVOKE ALL ON SEQUENCE message_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE message_id_seq FROM asl_pg;
GRANT ALL ON SEQUENCE message_id_seq TO asl_pg;


--
-- Name: message_queue; Type: ACL; Schema: public; Owner: asl_pg
--

REVOKE ALL ON TABLE message_queue FROM PUBLIC;
REVOKE ALL ON TABLE message_queue FROM asl_pg;
GRANT ALL ON TABLE message_queue TO asl_pg;


--
-- Name: messages; Type: ACL; Schema: public; Owner: asl_pg
--

REVOKE ALL ON TABLE messages FROM PUBLIC;
REVOKE ALL ON TABLE messages FROM asl_pg;
GRANT ALL ON TABLE messages TO asl_pg;


--
-- Name: queue_id_seq; Type: ACL; Schema: public; Owner: asl_pg
--

REVOKE ALL ON SEQUENCE queue_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE queue_id_seq FROM asl_pg;
GRANT ALL ON SEQUENCE queue_id_seq TO asl_pg;


--
-- Name: queues; Type: ACL; Schema: public; Owner: asl_pg
--

REVOKE ALL ON TABLE queues FROM PUBLIC;
REVOKE ALL ON TABLE queues FROM asl_pg;
GRANT ALL ON TABLE queues TO asl_pg;


--
-- PostgreSQL database dump complete
--

