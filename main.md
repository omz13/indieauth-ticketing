%%%
Title = "IndieAuth Ticketing DRAFT 0.1"
abbrev = "Ticketing"
ipr= "none"
area = "Internet"
workgroup = "indieweb.org"
submissiontype = ""
keyword = ["indieweb", "indieauth", "ticket"]
#date = 2015-04-01T00:00:00Z

[seriesInfo]
name = "technical note"
value = "draft-somers-indieauth-ticketing-00"
stream = ""
status = "experimental"

[[author]]
initials="D."
surname="Somers"
fullname="David Somers"
[author.address]
organization = "Independent Researcher"
email = "dsomers@omz13.com"
%%%

.# Abstract

<reference anchor='IndieAuth' target='https://indieauth.spec.indieweb.org/'>
    <front>
        <title>IndieAuth, IndieWeb Living Standard</title>
        <author initials='A.' surname='Parecki' fullname='Aaron Parecki'>
            <organization>indieweb.org</organization>
        </author>
        <date year='2022' month='02' day='12'/>
    </front>
</reference>
<reference anchor='IANA.OAuth.Parameters' target='https://www.iana.org/assignments/oauth-parameters'>
  <front>
    <title>OAuth Parameters</title>
    <author fullname="IANA" />
  </reference>
<reference anchor="AutoAuth" target='https://indieweb.org/AutoAuth'>
    <front>
        <title>AutoAuth</title>
        <author>
            <organization>indieweb.org</organization>
        </author>
    </front>
</reference>
<reference anchor="TicketAuth" target='https://indieweb.org/IndieAuth_Ticket_Auth'>
    <front>
        <title>IndieAuth Ticket Auth</title>
        <author>
            <organization>indieweb.org</organization>
        </author>
    </front>
</reference>

This document defines new protocols for use with IndieAuth(an extension
to OAuth 2.0) by defining how to request ("please push"), deposit
("push"), and grant ("exchange for a bearer token") tickets between two
parties. It further defines an new protocol to orchestrate the
aforementioned to allow a third-party to act on-behalf-of the first
party at the second-party. Use cases are provided.

{mainmatter}

#  Introduction

This document defines new protocols for use with [@!IndieAuth]
(an extension to OAuth 2.0 [@!RFC6749]) by defining flows between
participants that directly or indirectly use tickets as an instrument to facilitate the following activities:

want ticket
: Requesting that ticket to be sent to somebody's (the requestor's)
  authorization server.

deposit ticket
: Depositing (pushing) a ticket to an authorization server.

exchange ticket for authorization code
: Taking a deposited ticket and exchanging it with its issuer for an
  access code (Bearer token).

third-party wants an authorization code
: Choreography across three parties to provide an authorization code
  (Bearer token) to a third-party to use at a second-party by
  impersonating the first-party.

These activities are implemented respectively by the following flows:

- Ticket Wanted flow as specified in (#ticket-wanted-flow).

- Ticket Deposit flow as specified in (#ticket-deposit-flow).

- Ticket Grant flow as specified in (#ticket-grant-flow).

- Authorization Code On-Behalf-Of grant flow as specified in
  (#code-obo-flow).

## Use Cases

The participants are:

- The first-party, formally the subject, also known as Alice, who
  authenticates herself to services using an IndieAuth authorization
  server as specified in Section 5.3.2 of [@!IndieAuth].

- The second-party, formally the resource server, also known as Bob, is
  a publisher who makes protected resources available to authorized
  parties using IndieAuth for identification and Bearer Token Usage
  [@!RFC6750].

- The third-party, formally the actor, also known as Carol, who can
  perform different rôles for the benefit of the Alice (first-party) at
  the Bob (the second-party) who in this context is formally the
  audience(for Carol's performance).

### There is a feed that you can subscribe to {#use-case-sub}

In this case, Carol is playing the rôle of Felicity who is a feed
reader.

Bob makes available feed-oriented resources which can be used by Alice
to read resources recently published on his site. Bob tells Alice's
authorization server the location of the feed, which then tells Felicity
to subscribe to it.

This to be achieved when:

1. The resource server (Bob) implements ticket deposit flow.

1. The subject's (Alice) authorization server implements ticket
deposit flow and optionally ticket grant flow.

1. The resource server (Bob) uses ticket deposit flow to inform the
subject (Alice) that there is a feed she might want to subscribe to.
When Bob informs Alice of the location of the feed is at the
discretion of the resource server.

1. If the subject's (Alice) authorization server implements ticket
grant flow it then performs it. This serves the important purpose of
confirming that the ticket originated from Bob (the resource server)
and not a nefarious actor. The secondary purpose is to have a Bearer
token that can be passed to a feed reader to access private
resources.

1. The subject's (Alice) authorization server requests the reader (Felicity) to
subscribe to Bob's feed using an appropriate mechanism; how this is
achieved is dependent on the authorization server and the feed reader
but would typically involve a WebSub subscription request as
specified in Section 5.1 of [@?W3C.REC-websub-20180123].


!---
~~~ ascii-art
┌───────────────────────┐    ┌───────────────────────┐    ┌───────────┐
│        "Alice"        │    │         "Bob"         │    │"Felicity" │
├───────────────────────┤    ├───────────────────────┤    ├───────────┤
│        subject        │    │    resource server    │    │   actor   │
├───────────┬───────────┤    ├───────────┬───────────┤    ├───────────┤
│  profile  │subject as │    │ metadata  │audience as│    │ websubhub │
└───────────┴───────────┘    └───────────┴─────┬─────┘    └───────────┘
      │           │                │           │                │      
      │           │                │discover   │                │      
      │◀──────────┼────────────────┼─subject─ ┌┴┐               │      
      │           │                │metadata  │D│               │      
      │           │                │          │ │               │      
      │          ┌┴┐◁───ticket─────┼──────────└┬┘               │      
      │          │D│               │           │                │      
      │          │ │   discover    │           │                │      
      │          │┌┴┐──audience───▶│           │                │      
      │          ││ │  metadate    │           │                │      
      │          ││ │              │           │                │      
      │          ││X│  ticket      │           │                │      
      │          ││ │──grant───────┼─────────▷┌┴┐               │      
      │          ││ │              │          │X│               │      
      │          │└┬┘◀ ─ ac─ ─ ─ ─ ┼ ─ ─ ─ ─ ─└┬┘               │      
      │          │ │               │           │     subscribe  │      
      │          └┬┘───────────────┼───────────┼──────to feed──▶│      
      ▼           ▼                ▼           ▼                ▼      
                                                                       
D: ticket deposit flow                                                 
X: ticket grant flow (exchange ticket for token)                       
S: subscribe to feed                                                   
~~~
!---
Figure: Use case of ticketing for feed notification and subscription

### Reading private content on-behalf-of {#use_case_obo}

In this case, Carol is playing the rôle of Rachel, an impersonator, who
only does so with a permissive and in a non-malicious manner.

Alice wants to have Rachel read private resources that Bob makes
available to her. Bob does not know Rachel but Rachel can impersonate
Alice so she can read things on-behalf-of Alice.

To achieve this the goal is the acquisition of an authorization code
(Bearer token) across the security boundary of three parties
(subject, audience, and actor/impersonator).

It should be stressed that this should happen without any action
needed by the subject (it is "hands-off"), who also retaining agency
over obtaining and passing token-based authorization codes to their
chosen actor and that no preexisting relationship is needed between
audience and actor.

This to be achieved when:

1. The subject's authorization server implements ticket deposit flow,
  token grant flow, and authorization code on-behalf-of grant flow.

2. The audience's authorization server implements ticket wanted flow,
ticket deposit flow, and ticket grant flow.

3. The actor implements authorization code on-behalf-of grant flow.

4. The actor attempts to read a protected resource from the audience,
receives a 403 Unauthorized response, then performs authorization
code on-behalf-of grant flow with the subject's authorization server
to obtain a Bearer token that can be used to access the protected
resource.

!---
~~~ ascii-art
┌───────────────────────┐    ┌───────────────────────┐    ┌───────────┐
│        "Alice"        │    │         "Bob"         │    │ "Rachel"  │
├───────────────────────┤    ├───────────────────────┤    ├───────────┤
│        subject        │    │    resource server    │    │   actor   │
├───────────┬───────────┤    ├───────────┬───────────┤    ├───────────┤
│  profile  │subject as │    │ metadata  │audience as│    │  reader   │
└───────────┴───────────┘    └───────────┴───────────┘    └───────────┘
      │           │                │           │                │      
      │           │                │           │     discover   │      
      │◀──────────┼────────────────┼───────────┼──────subject──┌┴┐     
      │           │                │           │     metadata  │O│     
      │           │                │           │               │ │     
      │          ┌┴┐◀──────────────┼───────────┼───────ac-obo──│ │     
      │          │O│   discover    │           │               │ │     
      │          │┌┴┐──audience───▶│           │               │ │     
      │          ││W│  metadata    │           │               │ │     
      │          ││ │              │           │               │ │     
      │          ││ ├──want ticket─┼─────────▶┌┴┐              │ │     
      │          ││ │              │          │W│              │ │     
      │          │└┬┘◀─ ack ─ ─ ─ ─│─ ─ ─ ─ ─ │ │              │ │     
      │          │ │               │          │ │              │ │     
      │          │ │               │discover  │ │              │ │     
      │◀─────────┤ ├───────────────┼─subject─┌┴┐│              │ │     
      │          │ │               │metadata │D││              │ │     
      │          │ │               │         │ ││              │ │     
      │          │┌┴┐◁──ticket─────┼─────────└┬┘│              │ │     
      │          ││D│              │          │ │              │ │     
      │          │└┬┘  discover    │          │ │              │ │     
      │          │┌┴┐──audience───▶│          │ │              │ │     
      │          ││ │  metadate    │          │ │              │ │     
      │          ││ │              │          │ │              │ │     
      │          ││X│  ticket      │          │ │              │ │     
      │          ││ │──grant───────┼────────▷┌┴┐│              │ │     
      │          ││ │              │         │X││              │ │     
      │          │└┬┘ ◀ ─ac ─ ─ ─ ─│─ ─ ─ ─ ─└┬┘│              │ │     
      │          │ │               │          └┬┘              │ │     
      │          └┬┘─ ─ ─ ─ ─ ─ ─ ─│─ ─ ─ ─ ─ ─│─ ─ ─ ─ ─ ac─ ▶└┬┘     
      │           │                │           │                │      
      ▼           ▼                ▼           ▼                ▼      
                                                                       
W: want ticket flow                                                    
D: ticket deposit flow                                                 
X: ticket grant flow (exchange ticket for token)                       
O: code obo grant flow (get token via ticketing between participants)  
~~~
!---
Figure: Use case of ticketing for acquiring an authorization code for
use by a third-party

### Reading private feeds

In this case, Carol performs a dual rôle (she is Felicity-Rachel): the
ability to not only read feeds (the Felicity rôle), which themselves
may be a protect resource, but also any protected resources in the
feed, by impersonating Alice as necessary (the Rachel rôle).

## Conventions

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL
NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "NOT RECOMMENDED",
"MAY", and "OPTIONAL" in this document are to be interpreted as
described in BCP 14 [@!RFC2119] [@!RFC8174] when, and only when, they
appear in all capitals, as shown here.

## Terminology

This specification uses
the terms "as metadata"
and "user profile URL"
defined by [@!IndieAuth],
the terms
"access token",
"authorization server",
"authorization endpoint",
"authorization request",
"client",
"resource server", and
"token endpoint"
defined by The OAuth 2.0 Authorization Framework [@!RFC6749],
the terms
"delegation" and
"security token service"
defined by [@!RFC8693]
the term "bearer token"
defined by [@!RFC6750]

This specification defines the following terms:

Actor
: A URL that represents the identity of the acting party. Typically,
  this will be the party (the third-party) that is authorized to use a
  token obtained by and to act on-behalf-of the subject at another
  party (the second-party).

Audience
: A URL that represents the second-party in a multi-participant
  protocol.

Rôle
: The activity (a scope) that an actor will perform on-behalf-of a
  subject.

Subject
: A person, the first-party in a multi-participant protocol.

Subject Identity
: The identity of the subject as a URI, nominally an IndieAuth user
  profile URL.

Ticket
: A ticket is an opaque string, not intended to have any meaning to
  clients using it.

Ticket Endpoint
: The IndieAuth/OAuth 2.0 endpoint through which ticket deposit
  operation is accomplished.

Ticket Wanted Endpoint
: The IndieAuth/OAuth 2.0 endpoint through which ticket wanted operation
  is accomplished.

Ticketing
: The act of acquiring or using tickets as a utility to allow
  information to be exchanged between two or more parties through use
  of the network protocol defined in this document.

## Example Formatting

Where examples of protocol messages are given, the payload has been
formatted for presentation and is not a true representation of what
is the wire data: for form-urlencoded payloads URL-encoding has not
been done and additional white-space and line-breaks are shown between
key-value pairs to aid readability; similarly for JSON payloads. 

# Ticketing

This specification defines new protocol flows around the use of tickets
between participants in the IndieAuth universe:

Ticket Wanted
: This is where somebody requests an authorization server to send a
  ticket to the authorization server for a subject.

Ticket Deposit
: This is where somebody issues a ticket to the authorization server
  for a subject to indicate that it can be exchanged at the
  authorization server for the audience to obtain an access code
  (Bearer token) or to notify them simply of the presence of a
  feed at the resource server that they may be interested in subscribing to.

Ticket Grant
: This is where a ticket is redeemed at the authorization server for
  audience to grant a token assigned to the subject.

Authorization Code On-Behalf-Of \(ac-obo\) Grant
: This is where an actor requests that the authorization server for
  the subject for a bearer token to use at the audience on their
  behalf. The authorization server validates that the request is from
  the actor and then orchestrates wanted ticket flow with the
  audience, waits for it to send a ticket using ticket deposit flow,
  then exchanges the ticket with the authorization server for the
  audience for a token, and finally returns the token to the caller.


## Who implements what

The following table summarizes which participant/system is responsible
for implementing which side of each ticketing flow.

| ticketing flow     | client       | server      |
|--------------------|--------------|-------------|
| (W) ticket wanted  | subject as   | audience as |
| (D) ticket deposit | audience as  | subject as  |
| (X) ticket grant   | subject as   | audience as |
| (O) ac-obo grant   | actor        | subject as  |

## An archetypal implementation

Each protocol flow follows an archetypal pattern, as illustrated in
(#archey), between an initiator (the client-side of an HTTP request)
and a target (the sever-side of an HTTP response):

Client: Discovery (of the target endpoint)
: The client discovers the target endpoint to where a request is to be
  made under the doctrine of "distrust and verify" per
  (#security-considerations).

Client: Make the request
: The client makes a request to the target endpoint as an HTTP "POST".

Server: Receive the request and work it
: The endpoint receives the request, validates the parameters, ensures
  that the request is valid, meets all policy and other criteria of
  the authorization server, processes the request to build response
  parameters, and returns the response.

Client: Receive the response and work it
: The response is either a successful response or an error response.

!---
~~~ ascii-art
┌─────────────┐                     ┌─────────────┐                     
│  Initiator  │                     │   Target    │                     
├─────────────┤                     ├─────────────┤                     
│   Client    │                     │   Server    │                     
└─────────────┘                     └─────────────┘                     
       │                                   │                            
      ┌┴┐──┐                               │                            
      │ │  │ Discover                      │                            
      │ │  │ Target                        │                            
      │ │  │ Endpoint                      │                            
      │ │◀─┘                               │                            
      │ │    POST to target                │                            
      │ │────parameters are──────────────▶┌┴┐──┐validate parameters     
      │ │    x-www-form-urlencoded        │ │  │meets criteria?         
      │ │                                 │ │◀─┘meets policy?           
      │ │                                 │ │                           
┌ALT─ ┤ ├ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┤ ├ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ 
      │ │                                 │ │──┐ work request          │
│     │ │◀ ─ ─ ─ ─ ─ Successful Response ─│ │◀─┘ build response         
 ─ ─ ─│ │─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─│ │─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┤
│     │ │                                 │ │                           
      │ │◀─ ─ ─ ─ ─ ─ ─ ─ Error Response─ ┤ │                          │
└ ─ ─ ┤ ├ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┴┬┴ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ 
      │ │──┐                               │                            
      │ │◀─┘work response                  │                            
      └┬┘                                  │                            
       ▼                                   ▼                            
~~~
!---
Figure: Archetypal flow {#archey}

## Target endpoint discovery {#disco}

The client needs to discover the endpoint where the request needs to
be made.

### Discover Subject AS Metadata {#disco-subject-as-metadata}

For "subject":

A subject is identified by a user profile URL which is their canonical
homepage in the world wide web at a domain which is unique to them
and accessible by either the http or https scheme as specified in
section 3.1 of [@!IndieAuth].

It is RECOMMENDED that a profile URL with a http scheme be considered
unacceptable due to(#security-considerations).

The client undertakes discovery as specified in Section 4.1 of
[@!IndieAuth] against the user profile URL.

### Discover Audience AS Metadata {#disco-audience-as-metadata}

For "audience":

Do discovery for "audience" as detailed in Section 4.1 of [@!IndieAuth]

## Request {#flow-request}

The client makes a request to the target endpoint using the HTTP
"POST" method. Parameters are included in the HTTP request entity-body
 using the "application/x-www-form-urlencoded" format with a
 character encoding of UTF-8 as described in Appendix B of
 [@!RFC6749, Appendix B].

The parameters are detailed for each flow in this specification.

## Processing {#flow-processing}

When an server receives a request it performs the following steps:

1. Validate the parameters to ensure that all mandatory one are present.

1. Ensure that the parameter values are semantically correct, for
example:

  - The type matches that expected.

  - If a URL is expected that the value can be parsed as a URL and is
    normalized as required.

1. Ensures that it meets all policy and other criteria specific to
the implementation.

1. Works the request and construct the result parameters.

## Successful Response {#flow-successful-response}

A successful response is constructed by adding the result parameters to
the entity-body of the HTTP response using the "application/json" media
type, as specified by [@!RFC8259], and an HTTP 202 status code or other
applicable code. The result parameters are serialized into a JavaScript
Object Notation (JSON) structure by adding each parameter at the top
level. Parameter names and string values are included as JSON strings.
Numerical values are included as JSON numbers. The order of parameters
does not matter and can vary.

The result parameters are detailed for each flow in this specification.

## Error Response {#flow-error-response}

If the request is not valid or is unacceptable based on policy or
there is a problem when processing the request the authorization
server MUST construct an error response, as specified in Section 5.2
of [@!RFC6749]. The value of the "error" parameter MUST be
the "invalid_request" error code or other values as detailed for each
flow in this specification.

The authorization server MAY include additional information regarding
the reasons for the error using the "error_description" as discussed
in Section 5.2 of [@!RFC6749].

Other HTTP status codes may also be used as appropriate, for example:

405
: If the request did not use the "POST" method, the authorization
  server responds with an HTTP 405 (Method Not Allowed) status code.

413
: If the request size was beyond the upper bound that the
  authorization server allows, the authorization server responds with
  an HTTP 413 (Payload Too Large) status code.

429
: If the number of requests from a client during a particular time
  period exceeds the number the authorization server allows, the
  authorization server responds with an HTTP 429 (Too Many Requests)
  status code.

## The Ticket {#the-ticket}

The ticket is an opaque string. It MUST be at lest 16 characters in
length and no more than 512 characters.

When an authorization server generates a ticket it is HIGHLY
RECOMMENDED that it is a version 4 UUID generated as specified in
Section 4.4 of [@!RFC4122].

If an authorization server wants to generate a structured ticket it
MUST not be a JWT due to (#security-considerations) and its content
MUST respect (#privacy-considerations).

## Authorization Server Metadata {#as-metadata}

The following authorization server metadata [@!RFC8414] parameters are
introduced to signal an authorization server's capability and policy
with respect to which aspects of ticketing it supports.

ticket\_wanted\_endpoint
: If this endpoint is declared this indicates that the authorization
  server implements the server-side of ticket wanted flow.

ticket\_endpoint
: If this endpoint is declared this indicates that the authorization
  server explicitly implements the server-side of ticket deposit
  flow. A client MAY use the "token\_endpoint" as a fall-back target
  as an implicit (and not guaranteed) signal and target endpoint.

grant\_types\_supported
: If the authorization server supports authorization code on-behalf-of
  grant flow this MUST include
  "urn:indieweb.org:params:oauth:grant-type:on\_behalf\_of"; if it
  supports ticket grant flow it MUST include
  "urn:indieweb.org:params:oauth:grant-type:ticket".

## Ticket Introspection

If an authorization server implements OAuth Introspection
[@?RFC7662] it MAY consider a ticket to be like a token and allow
it to be introspected with "token\_type_\_hint=ticket" as per Section 1 of [@!RFC7662].

Example token introspection request against a ticket:

~~~ http
POST /as/token_introspect HTTP/1.1
Host: https://bob.example.com
Content-type: application/x-www-form-urlencoded; charset=utf-8
Accept: application/json

token=TICKET1234
&token_type_hint=ticket
~~~

Example token introspection response against a ticket:

~~~ http
HTTP 1.1
Content-Type: application/json
Cache: no-cache, no-store

{
   "active" : false,
   "scope": "read",
   "client_id": "https://bob.example"
   "username": "rachel obo alice",
   "token_type": "ticket",
   "iat": "1648710000",
   "exp": "1648992070",
   "sub": "https://alice.example/",
   "aud": "https://bob.example/".
   "iss": "https://bob.example/as"
}
~~~

# Ticket Wanted Flow {#ticket-wanted-flow}

!---
~~~ ascii-art
┌──────────────────────────────────────────────────────────────────────┐
│             ticket wanted flow - (subject, audience):nil             │
└──────────────────────────────────────────────────────────────────────┘
                               ┌───────────────────────────────┐        
                               │           audience            │        
                               ├───────────────────────────────┤        
                               │     authorization server      │        
┌───────────────┐              ├───────────────┬───────────────┤        
│    client     │              │   /metadata   │/ticket_wanted │        
└───────────────┘              └───────────────┴───────────────┘        
        │                              │               │                
       ┌┴┐                             │               │                
       │ │read audience metadata       │               │                
       │ │want ticket_wanted_endpoint  │               │                
       │ │────────────────────────────▶│               │                
       │ │send request:                │               │                
       │ │send a ticket to "subject"   │               │                
       │ │─────────────────────────────┼─────────────▶┌┴┐               
       │ │successful response:         │              │ │               
       │ │request received             │              │ │               
       │ │◀─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┼ ─ ─ ─ ─ ─ ─ ─│ │               
       └┬┘                             │              └┬┘               
┌OPT─ ─ ┼ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─│─ ─ ─ ─ ─ ─ ─ ─│─ ─ ─ ─ ─ ─ ─ ─ 
        │                              │       ┌─REF───┴───────┐       │
│       │                              │       │ticket deposit │        
        │                              │       └───────┬───────┘       │
└ ─ ─ ─ ┼ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─│─ ─ ─ ─ ─ ─ ─ ─│─ ─ ─ ─ ─ ─ ─ ─ 
        ▼                              ▼               ▼                
~~~
!---
Figure: Sequence diagram for ticket wanted flow

## Target Endpoint Discovery {#disco-audience-as-metadata}

1. Obtain the metadata for the authorization server for the subject as
detailed in (#disco-audience-as-metadata).

1. Target endpoint is the "ticket\_wanted\_endpoint" property in the
metadata; if the property does not exist or has an empty value
fallback to the "token\_endpoint" property.

The target endpoint MUST use the "https" scheme per (#security-considerations).

## Request

The client makes a request as specified in (#flow-request) to the
target endpoint with the following parameters:

action
: **REQUIRED**. This MUST be "ticket". NOTE: if the ticket is received
    on a "token\_endpoint" this key-value combination can be used to
    easily identify the request as one for ticket wanted.

subject
: **REQUIRED**. The user profile URL of the subject.

Example ticket wanted request:

~~~ http
POST /as/ticket_wanted HTTP/1.1
Host: https://bob.example.com
Content-type: application/x-www-form-urlencoded; charset=utf-8
Accept: application/json

action=ticket
&subject=https://alice.example.com/
~~~

## Processing

The request is processed as specified in (#flow-processing) and the
specific work to be performed for ticket wanted flow is:

1. To decide to act on the wanted request or not.

1. If it decides to act it does Ticket Deposit Flow for the subject in
the request.

## Successful Response

The response will be as specified in (#flow-successful-response) and
there are no response parameters so the body of the response is at
the discretion of the authorization server.

It is RECOMMEND that http content negotiation as specified in section
5.3 of [@!RFC7231] is undertaken and the server responds to following
media types accordingly (defaulting to "application/json"):

application+json
: An object with a single key of "subject" and value of the subject in
  the request (which may be different due to normalization or
  canonicalization).

Example ticket wanted response with content-negotiated JSON body:

~~~ http
HTTP 1.1
Content-Type: application/json
Cache: no-cache, no-store

{
   "subject" : "https://alice.example.com/"
}
~~~

text/plain:
: "Ticket Wanted Request Received for `<subject>`"

  Example ticket wanted response with content negotiated text/plain body:

~~~ http
HTTP 1.1
Content-Type: text/plain
Cache: no-cache, no-store

Received Ticket Wanted Request for https://alice.example.com/
~~~

## Error Response

If an error response is warranted it MUST be as per
(#flow-error-response).

An error response MUST only be returned if there is a problem with the
request parameters per se (for example missing or malformed).

The server MUST NOT return an error response if the subject is not
known because that would leak that the publisher does not have a
relationship with the subject, and conversely that it does
(which would be an issue if the request did not originate from the
subject but from a malicious client).

# Ticket Deposit Flow {#ticket-deposit-flow}

!---
~~~ ascii-art
┌──────────────────────────────────────────────────────────────────────┐
│                 ticket deposit flow - f(subject):nil                 │
└──────────────────────────────────────────────────────────────────────┘
                               ┌───────────────────────────────┐        
                               │            subject            │        
                               ├───────────────────────────────┤        
                               │              as               │        
┌───────────────┐              ├───────────────┬───────────────┤        
│    client     │              │   /metadata   │    /ticket    │        
└───────────────┘              └───────────────┴───────────────┘        
        │ read subject as metadata     │               │                
        │ want ticket_endpoint         │               │                
       ┌┴┐────────────────────────────▶│               │                
       │ │generate ticket              │               │                
       │ │send request:                │               │                
       │ │ticket to use at "audience"  │               │                
       │ │─────────────────────────────┼─────────────▶┌┴┐               
       │ │successful response:         │              │ │               
       │ │request received             │              │ │               
       └┬┘◀─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┼ ─ ─ ─ ─ ─ ─ ─│ │               
┌OPT─ ─ ┼ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─│─ ─ ─ ─ ─ ─ ─ ┤ ├ ─ ─ ─ ─ ─ ─ ─ 
        │                              │       ┌─REF──┴─┴──────┐       │
│       │                              │       │ ticket grant  │        
        │                              │       └───────┬───────┘       │
└ ─ ─ ─ ┼ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─│─ ─ ─ ─ ─ ─ ─ ─│─ ─ ─ ─ ─ ─ ─ ─ 
        ▼                              ▼               ▼                
~~~
!---
Figure: Sequence diagram for ticket deposit flow

## Target Discovery

1. Obtain the metadata for the authorization server for the subject as
detailed in (#disco-subject-as-metadata).

1. Target endpoint is the "ticket\_endpoint" property in the
metadata.

The target endpoint MUST use the https schema per
(#security-considerations).

## Request

The client makes a request as specified in (#flow-request) to the
target endpoint with the following parameters:

`subject`
: **REQUIRED**. The user profile URL of the subject.

`resource`
: **REQUIRED**. The URL to the resource server where the ticket can be
    used (the audience). If the path component is just the root directory this is a hint that the ticket can be exchanged for an token (using ticket grant) otherwise it is a path to feed on the resource server that the subject may be interested in subscribing to in their feed reader.

`ticket`
: **REQUIRED**. The ticket as per (#the-ticket).

Example ticket deposit request:

~~~ http
POST /as/ticket_wanted HTTP/1.1
Host: bob.example.com
Content-type: application/x-www-form-urlencoded; charset=utf-8
Accept: application/json, text/plain

subject=https://alice.example.com/
resource=https://bob.example.com/
ticket=TICKET1234567890
~~~

Example ticket deposit request hinting there is a feed that the
subject can subscribe to:

~~~ http
POST /as/ticket_wanted HTTP/1.1
Host: bob.example.com
Content-type: application/x-www-form-urlencoded; charset=utf-8
Accept: application/json, text/plain

subject=https://alice.example.com/
resource=https://bob.example.com/feeds/
ticket=TICKET1234567890
~~~

## Processing

The request is processed as specified in (#flow-processing) and the
specific work to be performed for ticket deposit flow is:

1. Confirm that the subject is handled by this
authorization server.

1. If "resource" has a path component that is not just the root
directory, it is a path to a feed that can be subscribed to; how the
authorization server does this is outside the scope of this
specification but would typically involve a subscription
request as specified in Section 5.1 of [@?W3C.REC-websub-20180123] to
an endpoint configured by the subject.

1. Optionally, perform ticket grant type flow with the following
parameters:

    - ticket is the "ticket" from the request.

    - audience is the "resource" from the request.

## Successful Response

The authorization server MUST respond as specified in
(#flow-successful-response) with the caveat that a response body is
optional, but if provided the parameters are:

ticket\_received
: The value of the ticket in the request.

Example ticket deposit successful response:

~~~ http
HTTP/1.1 202 Accepted
Content-Type: application/json
Cache-Control: no-cache, no-store

{
  "ticket_deposited" : "TICKET1234567890"
}
~~~

A server MAY use content negotiation, and respond to "text/plain" with
the a body containing the parameter as a key "=" value.

Example ticket deposit successful response with
content-negotiated text/plain body:

~~~ http
HTTP/1.1 202 Accepted
Content-Type: text/plain
Cache-Control: no-cache, no-store

ticket_deposited=TICKET1234567890
~~~

For content negotiation evaluating to "text/html" the server can
respond with any body that it likes.

## Error Response

If an error response is warranted it MUST be as per
(#flow-error-response).

# Ticket Grant Flow {#ticket-grant-flow}

!---
~~~ ascii-art
┌──────────────────────────────────────────────────────────────────────┐
│              ticket grant flow – f(ticket, audience):ac              │
└──────────────────────────────────────────────────────────────────────┘
                               ┌───────────────────────────────┐        
                               │           audience            │        
                               ├───────────────────────────────┤        
                               │              as               │        
┌───────────────┐              ├───────────────┬───────────────┤        
│    client     │              │   /metadata   │    /ticket    │        
└───────────────┘              └───────────────┴───────────────┘        
        │ read audience as metadata    │               │                
        │ want token                   │               │                
       ┌┴┐────────────────────────────▶│               │                
       │ │                             │               │                
       │ │send request:                │               │                
       │ │grant ac for this ticket     │               │                
       │ │─────────────────────────────┼─────────────▶┌┴┐               
       │ │successful response:         │              │ │               
       │ │ac (Bearer token)            │              │ │               
       └┬┘◀─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┼ ─ ─ ─ ─ ─ ─ ─└┬┘               
        │                              │               │                
        ▼                              ▼               ▼                
~~~
!---
Figure: Sequence diagram for ticket grant flow

## Discovery

1. Obtain the metadata for the authorization server for the audience
as detailed in (#disco-audience-as-metadata).

2. The target endpoint is the "token\_endpoint" property.

## Request

The client makes a request as specified in (#flow-request) to the
target endpoint with the following parameters:

grant\_type
: **REQUIRED**. This MUST be "ticket".

ticket
: **REQUIRED** the ticket to exchange for an access code (Bearer token).

Example ticket grant request:

~~~ http
POST /as/token HTTP/1.1
Host: bob.example.com
Content-type: application/x-www-form-urlencoded; charset=utf-8
Accept: application/json, text/plain

grant_type=ticket
&ticket=TICKET1234567890
~~~


## Processing

The request is processed as specified in (#flow-processing) and the
specific work to be performed for ticket grant flow is:

1. The generation of a Bearer token for the subject with a short
lifespan due to (#security-considerations). It is RECOMMENDED that
the age be limited to more than 36 hours.

1. Construction of access token response 

    Note that a refresh token SHOULD NOT be included in the response
    but if it is it will be ignored.

## Successful Response

The response is an access token response as specified in section 5.3.3
of [@!IndieAuth].

Example response to a ticket grant request:

~~~ http
HTTP 1.1
Content-Type: application/json
Cache: no-cache, no-store

{
  "access_token" : "TOKEN1234567890",
  "token_type"   : "Bearer",
  "expires_in"   : 259200,
  "scope"        : "read"
}
~~~


## Error Response

If an error response is warranted it MUST be as per
(#flow-error-response).

# Authorization Code On-Behalf-Of Grant Flow {#code-obo-flow}

!---
~~~ ascii-art
┌──────────────────────────────────────────────────────────────────────┐
│   ac-obo flow – f(subject, resource/audience, actor/client_id):ac    │
└──────────────────────────────────────────────────────────────────────┘
                               ┌───────────────────────────────┐        
                               │            subject            │        
                               ├───────────────────────────────┤        
                               │              as               │        
┌───────────────┐              ├───────────────┬───────────────┤        
│    client     │              │   /metadata   │    /token     │        
└───────────────┘              └───────────────┴───────────────┘        
        │                              │               │                
        │ read subject as metadata     │               │                
        │ want token endpoint          │               │                
       ┌┴┐────────────────────────────▶│               │                
       │ │send request:                │               │                
       │ │grant ac for actor           │               │                
       │ │to use at audience           │               │                
       │ │on behalf of subject         │               │                
       │ │─────────────────────────────┼─────────────▶┌┴┐               
       │ │                             │       ┌─REF──┴─┴──────┐        
       │ │                             │       │ ticket wanted │        
       │ │                             │       └──────┬─┬──────┘        
       │ │                             │       ┌─REF──┴─┴──────┐        
       │ │                             │       │ticket deposit │        
       │ │                             │       └──────┬─┬──────┘        
       │ │                             │       ┌─REF──┴─┴──────┐        
       │ │ successful response:        │       │ ticket grant  │        
       │ │ ac (Bearer token)           │       └──────┬─┬──────┘        
       └┬┘◀─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┼ ─ ─ ─ ─ ─ ─ ─└┬┘               
        │                              │               │                
        ▼                              ▼               ▼                
~~~
!---
Figure: Sequence diagram for authorization code on-behalf-of grant flow

## Discovery

1. Obtain the metadata for the authorization server for the subject
as detailed in (#disco-subject-as-metadata).

1. The metadata MUST have a "grant\_types\_supported" that
includes "on\_behalf\_of" to indicate that the subject's authorization
server supports "requested\_token\_use=on\_behalf\_of" at
its "token\_endpoint" and is therefore a signal that it implements the
authorization code on behalf of grant flow.

1. The target endpoint is the "ticket\_endpoint" property in the
metadata.

## Request

When the request is made, it MUST also include something which can be
used to assure the receiver that it has come from the 
"client\_id" provided. The client MUST NOT use more than one method in
 each request. The following methods be offered:

client_secret
: By providing a "client\_secret" that has previously been exchange
  out-of-band between the actor and the subject.

client_id, claim_type="code\_verifier" and claim
: By providing the last successful "code_verifier" parameter from when
  the client assured their identity with the actor. This is the
  preferred method because it provides a "hands-off" experience for the
  subject. The rationale for using a PKCE Code Verifier is detailed in
  (#why-code-verifier).

The client makes a request as specified in (#flow-request) to the
target endpoint with the following parameters:

grant\_type
: **REQUIRED**. This MUST be "authorization\_code".

requested\_token\_use
: **REQUIRED**. This MUST
    be "urn:indieweb.org:params:oauth:grant-type:on\_behalf\_of" or the
    less strictly qualified form "on\_behalf\_of".

subject
: **REQUIRED**. The user profile URL of the subject.

resource
: **REQUIRED**. The URL of the resource server where the granted code
    will be used, i.e. the audience.

client\_id
: **REQUIRED**. The URL of the requestor (the actor).


client\_secret
: **OPTIONAL**. A secret previously provided by the actor to assure
    the receiver that the request was made by it. 

claim
: **OPTIONAL** but **REQUIRED** if "claim\_type" is not provided. An
    item from the actor's authorization server to prove its claim to
    be the aforementioned to the caller. This parameter
    becomes **MANDATORY** when no "client\_secret" is offered.

claim\_type
: **OPTIONAL** but **REQUIRED** if "claim" is provided. The format of
    the proof as defined by the authorization server. The value
    indicates what type of data the "claim" parameters contains.

Example authorization code on-behalf-of grant request:

~~~ http
POST /as/token HTTP/1.1
Host: alice.example.com
Content-type: application/x-www-form-urlencoded; charset=utf-8
Accept: application/json

grant_type=authorization_code
&requested_token_use=on_behalf_of
&subject=https://alice.example.com/
&resource=https://bob.example.com/
&client_id=https://rachel.example.com/
&claim=CV123
&claim_type=pkce_verifier
~~~

## Processing

The request is processed as specified in (#flow-processing) and the
specific work to be performed for authorization code on-behalf-of
grant flow is:

1. Check that the subject is known to the token endpoint.

1. Check that the client_id corresponds to an actor
(reader) that it wants to delegate to.

1. Ensure that the subject has verified their identity with the
client (the actor); if the subject has verified their identity, the
authorization server should have a record of the code request made to
its authorization endpoint.

1. Check that the client issuing the grant request is who they claim
to be. This is done by checking the validity of the "claim"
and "claim_type" pairing.

1. Do ticket wanted flow (target is the current authorization
server) to request a ticket.

1. Wait for a ticket to be made available via ticket deposit flow. 

1. Do ticket grant flow (with target of subject) to exchange the
ticket for a token.

1. Ensure that the ticket grant response meets the constrictions
specified in (#obo-successful-response) and if not it a policy
decision whether to respond with an error response or to filter the
parameters to conform.

1. The response parameters are the ticket grant response parameters
with the caveat that the "refresh\_token" if provided MUST be
removed.

## Successful Response {#obo-successful-response}

If a successful response is warranted it MUST be as per
(#flow-successful-response) and the parameters correspond to this for
a normal OAuth 2.0 response as specified in Section 5 of
[@!RFC6749] but the following constraints:

* It is RECOMMENDED the expiration time is in the near future and that
  a refresh token is provided.

* The "scope" MUST contain at least "read".

* The "scope" SHOULD be as limited as possible as per
  (#security-considerations).

Additional parameters MAY be included for implementation-specific
reasons.

Example access token successful response:

~~~ http
HTTP 1.1 200 OK
Content-type: application/json
Cache-Control: no-cache, no-store

{
  "access_token" : "AT1234"
  "token_type"   : "Bearer"
  "expires_in"   : 3600
  "scope"        : "read"
  "refresh_token": "RT1234"
}
~~~

## Error Response

If an error response is warranted it MUST be as per
(#flow-error-response).

The following alternative "error" values MUST be used instead of the
generic "bad_request" in the following circumstances:

"invalid\_ticket\_want"
: When there is an issue performing the ticket wanted flow (W) with
  the "audience", for example, unable to obtain the metadata for the
  authorization server. It is HIGHLY RECOMMENDED that the reason is
  returned in the "error_description" with attention to
  (#security-considerations) and (#privacy-considerations).

"invalid\_ticket"
: When either no ticket is available or one has not been received in
  response to a ticket wanted request, within a reasonable amount of
  time.

"invalid\_ticket\_grant"
: When there is an issue performing the ticket grant flow (X) with the
  audience's authorization server. It is HIGHLY RECOMMENDED that the
  reason is returned in the "error_description" with attention to
  (#security-considerations) and (#privacy-considerations).

# Security Considerations {#security-considerations}

Much of the guidance from Section 10 of [@!RFC6749], the Security
Considerations in The OAuth 2.0 Authorization Framework, is also
applicable here. Furthermore, [@!RFC6819] provides additional security
considerations for OAuth, and [@!I-D.ietf-oauth-security-topics] has
updated security guidance based on deployment experience and new
threats that have emerged since OAuth 2.0 was originally published.

If the ticket issued by an authorization server is a JWT particular
attention should be paid to Section 5 of [@!RFC9068].

The use of JWTs as a ticket is not encouraged and implementors should
use an opaque string.

Do NOT attempt to read tickets. No assumption should be made as to their
format and they may or many not validate as a JWT. While reading
tickets is a useful for debugging, implementations should not depend on
this ability because tickets are opaque.

In addition, both delegation and impersonation introduce unique security
issues. Any time one principal is delegated the rights of another
principal, the potential for abuse is a concern. The use of the "scope"
claim (in addition to other typical constraints such as a limited token
lifetime) is suggested to mitigate potential for such abuse, as it
restricts the contexts in which the delegated rights can be exercised.

For authorization code on-behalf-of grant flow, the relative agency of
the subject is limited by the expiration time of the token issued.
The agency can only be exercised when the subject's authorization
server is requested to acquire a new token during this flow. Hence
the limitation on the subject's agency is bounded by the age of the
token from the audience that they forward to the actor. For this
reason it is imperative that an audience issue tokens in response to
this grant request with a sensibly short expiration time to ensure
the subject can maintain agency over the actor.

# Privacy Considerations {#privacy-considerations}

Tickets and tokens employed in the context of the functionality
described herein may contain privacy-sensitive information and, to
prevent disclosure of such information to unintended parties, MUST only
be transmitted over encrypted channels, such as Transport Layer
Security (TLS).

Deployments SHOULD determine the minimally necessary amount of data and
only include such information in issued tickets or tokens. In some
cases, data minimization may be needed and this is of particular
relevance when an authorization server is acting like an STS in
authorization code on-behalf-of grant flow.

#  IndieWeb Considerations

1. In [@!IndieAuth] the user profile URL can use the http or https
scheme. The use of https is contrary to (#security-considerations).

1. Some authorization servers may regard user profiles URLs at the
same host and path but access by different scheme
(http://example.com/ and https://example.com/) as separate
identities. As IndieWeb uses the domain as a identifier for a
subject, this would seem to be misinterpretation. Give the previous
consideration if user profiles were mandated to be accessible only
over https then this second consideration would be moot.

## "OAuth Parameters" Registry

To indicate ticket grant flow is supported:

- URN: `urn:indieweb.org:params:oauth:grant-type:ticket`
- Common Name: Ticket exchange grant type for IndieAuth Ticketing
- Change Controller: indieweb.org
- Specification Document: (#as-metadata) of this specification

To signal that authorization code on-behalf-of grant flow is supported:

- URN: `urn:indieweb.org:params:oauth:grant-type:on_behalf_of`
- Common Name: On-Behalf-Of Ticketing grant type
- Change Controller: indieweb.org
- Specification Document: (#as-metadata) of this specification

#  IANA Considerations

There are no IANA actions requested at this time.

#  Related Work

Assertion Framework for OAuth 2.0 Client Authentication and
Authorization Grants
: [@?RFC7521] provides a common framework for OAuth 2.0 to interwork
  with other identity systems using assertions and to provide
  alternative client authentication mechanisms.

Assertion grant profile for OAuth 2.0 authorization grants
: https://docs.pingidentity.com/bundle/pingfederate-93/page/umd1564002958895.html

AutoAuth
: Described in [@?AutoAuth]. An extension to IndieAuth that allows
  clients to authorize to other servers in the name of their user,
  without the user being present to confirm each individual
  authorization flow.

Microsoft identity platform and OAuth 2.0 On-Behalf-Of flow
: https://docs.microsoft.com/en-us/azure/active-directory/develop/v2-oauth2-on-behalf-of-flow

  This where an application invokes a service/web API, which in turn
  needs to call another service/web API. The idea is to propagate the
  delegated user identity and permissions through the request chain.
  Detailed at 

TicketAuth
: Described in [@?TicketAuth], this is an extension to IndieAuth that
  enables a publisher to send authorization, known as a ticket, that
  can be redeemed for an access token. This allows both solicited and
  unsolicited invitations to fetch restricted resources.

Token Exchange
: OAuth Token Exchange [@!RFC8693] is a protocol to request and obtain
  security tokens from an authorization server for impersonation and
  delegation.

{backmatter}

# Why use a Code Verifier? {#why-code-verifier}

If the subject has identified themselves to the actor as specified in
Section 5.3.2 of [@!IndieAuth] various exchanges will have taken
place between the subject's authorization server and the actor's
authorization client during which a "code\_verifier" is generated
because IndieAuth mandates the use of PKCE as specified in
[@!RFC7636]. The actor can use the "code\_verifier" of the last
successfully exchange with the subject's authorization server as claim
that they are who they are on the basis that only they have this
information and that the subject's authorization server can verify
it. For this to be implemented:

- The actor MUST require the subject to identify themslves using
  IndieAuth which means the actor has an authorization server.

- The actor's authorization server MUST be able to stored and retrieve
  the last successfully exchanged "code\_verifier"  with the subject.

- The subject's authorization server MUST be able to store and
  retrieve the last successfully exchanged "code\_verifier" with
  the actor.

# Acknowledgements

This document stands on the shoulders of the members of the IndieWeb
community for their work on [@?TicketAuth] and [@?AutoAuth] which
provided inspiration for this document.

The following individuals directly or indirectly contributed ideas,
feedback, and wording to this specification: @fluffy, @gwg, @zegnat.

# Document History

	[[ To be removed from the final specification ]]

	-00

	* first draft
