---
id: udp
title: Udp
order: 9
---

Plain IPv4 datagrams, polled — the transport under a game's own netcode: peer-to-peer play, a LAN lobby, a STUN query. Open a socket with <a href="udp-open.html"><code>Udp.open</code></a>, send with <a href="udp-send.html"><code>Udp.send</code></a>, and each frame drain what arrived with <a href="udp-recv.html"><code>Udp.recv</code></a>, which returns <code>0</code> when nothing is waiting and never blocks. The sender of the last datagram read is <a href="udp-from_ip.html"><code>Udp.from_ip</code></a> / <a href="udp-from_port.html"><code>from_port</code></a>.

An address is an <code>int</code>: <code>a.b.c.d</code> is <code>(a &lt;&lt; 24) | (b &lt;&lt; 16) | (c &lt;&lt; 8) | d</code>, converted by <a href="udp-ip.html"><code>Udp.ip</code></a> and <a href="udp-ip_text.html"><code>Udp.ip_text</code></a>. Datagrams can be lost, repeated and reordered; the protocol a game builds on top says what to do about that. Like <code>Http.*</code> it is <strong>out-of-band</strong> and must never feed the deterministic lockstep/replay simulation directly. BSD sockets on macOS, Winsock on Windows.
