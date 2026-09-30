---
id: annot-net
name: @Net
category: annotations
kind: annotation
tokens: @Net
sig: "@Net action Name { … }"
tip: Send the action to the host instead of reducing it on a guest; the host checks and reduces it.
order: 50
---

<code>@Net</code> puts an <code>action</code> on the wire. On a guest, <code>dispatch</code> does not reduce it: the record is encoded (a schema hash, the action's number, a sequence number and its fields, one 32-bit word each) and handed to the <code>NetActions</code> port's <code>to_host</code>, which the game binds to its session (<code>ludic.net</code> delivers it reliably and in order per sender). The host checks it (<code>@Validate</code>, and the port's <code>allow</code>), reduces it with the ordinary reducers, and tells the guests per <code>@Broadcast</code>. On the host, and with no session bound (the port answers as a program alone), a <code>@Net</code> action is reduced where it is dispatched, so a package's code is the same in solo, host and guest. Only whole numbers, bools, floats and enums go on the wire: send a handle or an id, and let the host look the rest up. Inside a reducer, <code>action_sender()</code> is the guest that sent the action (0 for this machine).

```ludic
program Spending {
  state Wallet { coins: int = 10 }
  @Net action Spend { n: int = 1 }                 # a guest asks; the host decides
  reducer Wallet on Spend(w: mut Wallet, a: Spend) { w.coins -= a.n }
  entry (w: Wallet) {
    dispatch Spend { n: 3 }                        # no session bound: reduced here
    drain_actions()
    print(w.coins)                                 # 7
  }
}
```
