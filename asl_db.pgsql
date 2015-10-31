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
 ok boolean;
 existqueue integer;
BEGIN

SELECT queue_id into existqueue FROM queues WHERE queue_id = queue;

    IF FOUND THEN

    INSERT INTO messages (message_id, sender_id, receiver_id, toa, message, queue_id) VALUES 
    (default, sender, receiver, now(), message, queue);

        IF FOUND THEN
       ok = True;
        ELSE
            ok = False;
        END IF;
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

CREATE FUNCTION createqueue() RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
queueid integer;
BEGIN

INSERT INTO queues (queue_id) VALUES (default) RETURNING queue_id INTO queueid;
RETURN queueid;
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
deleteOK boolean;
BEGIN

DELETE FROM queues WHERE queue_id = queueid;

IF FOUND THEN
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

SELECT message INTO peekedmessage FROM messages AS m WHERE m.receiver_id in (-1, clientid) AND m.queue_id = queueid ORDER BY m.toa LIMIT 1;
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

SELECT message INTO peekedmessage FROM messages AS m WHERE m.receiver_id in (-1, clientid) AND m.sender_id = senderid ORDER BY m.toa LIMIT 1;
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

SELECT m.message, m.message_id INTO popMessage, messid FROM messages AS m WHERE m.receiver_id in (-1, clientid) AND m.queue_id = queueid ORDER BY m.toa LIMIT 1;

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

SELECT m.message, m.message_id INTO popMessage, messid FROM messages AS m WHERE m.receiver_id in (-1, clientid) AND m.sender_id = senderid ORDER BY m.toa LIMIT 1;

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
-- Name: messages; Type: TABLE; Schema: public; Owner: asl_pg; Tablespace: 
--

CREATE TABLE messages (
    message_id integer DEFAULT nextval('message_id_seq'::regclass) NOT NULL,
    sender_id integer NOT NULL,
    receiver_id integer,
    toa timestamp without time zone,
    message character varying(2000),
    queue_id integer
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

SELECT pg_catalog.setval('client_id_seq', 1, false);


--
-- Data for Name: clients; Type: TABLE DATA; Schema: public; Owner: asl_pg
--

COPY clients (client_id) FROM stdin;
-1
\.


--
-- Name: message_id_seq; Type: SEQUENCE SET; Schema: public; Owner: asl_pg
--

SELECT pg_catalog.setval('message_id_seq', 1, true);


--
-- Data for Name: messages; Type: TABLE DATA; Schema: public; Owner: asl_pg
--

COPY messages (message_id, sender_id, receiver_id, toa, message, queue_id) FROM stdin;
\.


--
-- Name: queue_id_seq; Type: SEQUENCE SET; Schema: public; Owner: asl_pg
--

SELECT pg_catalog.setval('queue_id_seq', 1, true);


--
-- Data for Name: queues; Type: TABLE DATA; Schema: public; Owner: asl_pg
--

COPY queues (queue_id) FROM stdin;
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
-- Name: mess_send_recei_idx; Type: INDEX; Schema: public; Owner: asl_pg; Tablespace: 
--

CREATE INDEX mess_send_recei_idx ON messages USING btree (message_id, sender_id, receiver_id);


--
-- Name: messages_queue_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: asl_pg
--

ALTER TABLE ONLY messages
    ADD CONSTRAINT messages_queue_id_fkey FOREIGN KEY (queue_id) REFERENCES queues(queue_id) ON DELETE CASCADE;


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

